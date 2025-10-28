package com.javaproject.controllers;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SecuredController {

    @GetMapping("/secured")
    public String securedPage(Model model) {
        // This will handle requests to /secured after login
        model.addAttribute("message", "Welcome to the secured area!");
        return "secured"; // This corresponds to secured.html (or secured.jsp)
    }

    @GetMapping("/health")
    public String healthCheck() {
        // Simple endpoint to prevent 'health' from being parsed as a Long
        return "OK";
    }

    @GetMapping("/favicon.ico")
    public void faviconHandler() {
        // Prevent Spring from trying to interpret favicon.ico as /secured/{id}
    }
}
