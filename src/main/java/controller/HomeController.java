package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class HomeController {
    
    @GetMapping({"/", "/homepage"})
    public String home() {
        return "homepage";
    }
    
    @GetMapping("/login")
    public String login() {
        return "login";
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
    public String serviceHome(@RequestParam Integer serviceId) {
        return "serviceHome";
    }
    
    @GetMapping("/serviceDetails")
    public String serviceDetails() {
        return "serviceDetails";
    }
    
    @GetMapping("/serviceMeal")
    public String serviceMeal(@RequestParam Integer serviceId) {
        return "serviceMeal";
    }
    
    @GetMapping("/serviceTransport")
    public String serviceTransport(@RequestParam Integer serviceId) {
        return "serviceTransport";
    }
    
    @GetMapping("/reviewAdmin")
    public String reviewAdmin() {
        return "reviewAdmin";
    }
    
    // ===== FEEDBACK PAGE MAPPINGS (Clean URLs) =====
    
    @GetMapping("/feedback")
    public String feedback(@RequestParam Integer bookingId, @RequestParam Integer serviceId) {
        return "feedback/feedback";
    }
    
    @GetMapping("/feedback/update")
    public String updateFeedbackPage(@RequestParam Integer feedbackId, @RequestParam Integer serviceId) {
        return "feedback/updateFeedback";
    }
    
    @PostMapping("/feedback/create")
    public String createFeedbackQuery() {
        return "feedback/createFeedbackQuery";
    }
    
    @PostMapping("/feedback/update")
    public String updateFeedbackQuery() {
        return "feedback/updateFeedbackQuery";
    }
    
    @GetMapping("/feedback/delete")
    public String deleteFeedbackQuery() {
        return "feedback/deleteFeedbackQuery";
    }
    
    // ===== BOOKING ROUTES =====
    
    @GetMapping("/booking/checkout")
    public String checkout() {
        return "booking/checkout";
    }
    
    @GetMapping("/booking/payment")
    public String payment() {
        return "booking/payment";
    }
    
    @GetMapping("/booking/createBooking")
    public String createBooking(@RequestParam Integer serviceId, @RequestParam Integer packageId) {
        return "booking/createBooking";
    }
    
    @GetMapping("/booking/viewCart")
    public String viewCart() {
        return "booking/viewCart";
    }
    
    @GetMapping("/booking/paymentSuccess")
    public String paymentSuccess() {
        return "booking/paymentSuccess";
    }
}