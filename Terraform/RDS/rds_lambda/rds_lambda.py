import os
import json
import boto3
import logging
from botocore.exceptions import ClientError, BotoCoreError

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

rds = boto3.client('rds')
cloudwatch = boto3.client('cloudwatch')

# Environment variables
DB_INSTANCE_ID = os.getenv('DB_INSTANCE_ID')
DRY_RUN = os.getenv('DRY_RUN', 'false').lower() == 'true'
STORAGE_UTILIZATION_THRESHOLD = int(os.getenv('STORAGE_UTILIZATION_THRESHOLD', '80'))  # percent
MAX_STORAGE_GB = int(os.getenv('MAX_STORAGE_GB', '16384'))  # 16TB max limit for many engines

# Ordered instance classes for scaling
INSTANCE_CLASSES = [
    "db.t3.micro",
    "db.t3.small",
    "db.t3.medium",
    "db.t3.large",
    "db.m5.large",
    "db.m5.xlarge",
    "db.m5.2xlarge"
]


def get_next_instance_class(current_class: str, direction: str) -> str:
    if current_class not in INSTANCE_CLASSES:
        raise ValueError(f"Unknown instance class: {current_class}")

    index = INSTANCE_CLASSES.index(current_class)

    if direction == "up" and index < len(INSTANCE_CLASSES) - 1:
        return INSTANCE_CLASSES[index + 1]
    elif direction == "down" and index > 0:
        return INSTANCE_CLASSES[index - 1]
    else:
        return current_class


def get_free_storage_gb(db_instance_id: str) -> float:
    """Fetch free storage space (GB) from CloudWatch metrics."""
    try:
        metric = cloudwatch.get_metric_statistics(
            Namespace="AWS/RDS",
            MetricName="FreeStorageSpace",
            Dimensions=[{"Name": "DBInstanceIdentifier", "Value": db_instance_id}],
            StartTime=datetime.utcnow() - timedelta(minutes=10),
            EndTime=datetime.utcnow(),
            Period=300,
            Statistics=["Average"]
        )
        datapoints = metric.get("Datapoints", [])
        if not datapoints:
            logger.warning("No CloudWatch datapoints found for FreeStorageSpace.")
            return None
        latest = sorted(datapoints, key=lambda x: x["Timestamp"])[-1]
        free_gb = latest["Average"] / (1024 ** 3)
        return free_gb
    except Exception as e:
        logger.error("Error fetching storage metric: %s", e)
        return None


def calculate_new_storage(current_allocated: int, free_gb: float) -> int:
    """Exponential scaling: double until utilization < threshold, capped at MAX_STORAGE_GB."""
    used_percent = 100 - ((free_gb / current_allocated) * 100)
    logger.info(f"Storage utilization: {used_percent:.2f}%")

    if used_percent < STORAGE_UTILIZATION_THRESHOLD:
        logger.info("Storage utilization is within limits.")
        return current_allocated

    new_size = int(current_allocated * 1.5)  # Exponential (×1.5)
    if new_size > MAX_STORAGE_GB:
        new_size = MAX_STORAGE_GB

    logger.info(f"Storage scale triggered: {current_allocated}GB → {new_size}GB")
    return new_size


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    if not DB_INSTANCE_ID:
        raise ValueError("Environment variable DB_INSTANCE_ID is required")

    try:
        record = event.get("Records", [{}])[0]
        sns = record.get("Sns", {})
        alarm_name = sns.get("Subject", "").lower()

        if not alarm_name:
            raise ValueError("SNS subject missing from event")

        direction = "up" if "high" in alarm_name else "down"
        logger.info("Scaling direction determined: %s", direction)

        db_info = rds.describe_db_instances(DBInstanceIdentifier=DB_INSTANCE_ID)["DBInstances"][0]
        current_class = db_info["DBInstanceClass"]
        allocated_storage = db_info["AllocatedStorage"]
        logger.info(f"Current class: {current_class}, Allocated storage: {allocated_storage}GB")

        # --- Instance Scaling ---
        next_class = get_next_instance_class(current_class, direction)
        if next_class != current_class:
            logger.info(f"Scaling instance class → {next_class}")
            if not DRY_RUN:
                rds.modify_db_instance(
                    DBInstanceIdentifier=DB_INSTANCE_ID,
                    DBInstanceClass=next_class,
                    ApplyImmediately=True
                )

        # --- Storage Scaling ---
        free_gb = get_free_storage_gb(DB_INSTANCE_ID)
        if free_gb:
            new_storage = calculate_new_storage(allocated_storage, free_gb)
            if new_storage > allocated_storage:
                logger.info(f"Scaling storage to {new_storage}GB")
                if not DRY_RUN:
                    rds.modify_db_instance(
                        DBInstanceIdentifier=DB_INSTANCE_ID,
                        AllocatedStorage=new_storage,
                        ApplyImmediately=True
                    )

        return {
            "status": "success",
            "old_class": current_class,
            "new_class": next_class,
            "old_storage": allocated_storage,
            "new_storage": new_storage if free_gb else allocated_storage
        }

    except (ClientError, BotoCoreError) as e:
        logger.error("AWS error: %s", e)
        raise
    except Exception as e:
        logger.error("Unexpected error: %s", e)
        raise
