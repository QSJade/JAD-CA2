package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    
    @GetMapping("/")
    public String home() {
        return "homepage";
    }
    
    @GetMapping("/login")
    public String login() {
        return "login";
    }
    
    @GetMapping("/logout")
    public String logout() {
        return "logout";
    }
    
    @GetMapping("/register")
    public String register() {
        return "register";
    }
    
    @GetMapping("/registerUser")
    public String registerUser() {
        return "registerUser";
    }
    
    @GetMapping("/verifyUser")
    public String verifyUser() {
        return "verifyUser";
    }
    
    @GetMapping("/serviceHome")
    public String serviceHome() {
        return "serviceHome";
    }
    
    @GetMapping("/serviceDetails")
    public String serviceDetails() {
        return "serviceDetails";
    }
    
    @GetMapping("/serviceMeal")
    public String serviceMeal() {
        return "serviceMeal";
    }
    
    @GetMapping("/serviceTransport")
    public String serviceTransport() {
        return "serviceTransport";
    }
    
    @GetMapping("/reviewAdmin")
    public String reviewAdmin() {
        return "reviewAdmin";
    }
    
    // Booking mappings
    @GetMapping("/booking/checkout")
    public String checkout() {
        return "booking/checkout";
    }
    
    @GetMapping("/booking/payment")
    public String payment() {
        return "booking/payment";
    }
    
    // Profile mappings
    @GetMapping("/profile")
    public String profile() {
        return "profile/profile";
    }
    
    // Feedback mappings
    @GetMapping("/feedback")
    public String feedback() {
        return "feedback/feedback";
    }

}