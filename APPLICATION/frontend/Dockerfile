# ================================
# Stage 1: Build the application
# ================================
FROM maven:3.8.6-openjdk-11 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies first (layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the source code and build
COPY src ./src
RUN mvn clean package -DskipTests

# ================================
# Stage 2: Run the application
# ================================
FROM openjdk:11-jdk-slim

# Set working directory inside container
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the app
ENTRYPOINT ["java", "-jar", "app.jar"]
