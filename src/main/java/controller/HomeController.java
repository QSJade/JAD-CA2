package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.bind.annotation.RequestPart;
import jakarta.servlet.http.HttpServletRequest;

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
    
 // ===== ADMIN SERVICE MANAGEMENT =====
    @GetMapping("/adminService")
    public String adminService() {
        return "admin/adminService";
    }

    @GetMapping("/admin/addService")
    public String addService() {
        return "admin/addService";
    }

    @GetMapping("/admin/editService")
    public String editService() {
        return "admin/editService";
    }
    
    @GetMapping("/admin/selectServiceToEdit")
    public String selectServiceToEdit() {
        return "admin/selectServiceToEdit";
    }

	@PostMapping("/admin/editServiceBackend")
	public String editServiceBackend(
	        @RequestParam("id") String id,
	        @RequestParam("serviceName") String serviceName,
	        @RequestParam("serviceDetails") String serviceDetails,
	        @RequestParam("price") String price,
	        @RequestParam(value = "removeImage", required = false) String removeImage,
	        @RequestPart(value = "serviceImage", required = false) MultipartFile serviceImage,
	        HttpServletRequest request) {
	    
	    return "admin/editServiceBackend";
	}
	
	@PostMapping("/admin/addServiceBackend")
	public String addServiceBackend(
	        @RequestParam("serviceName") String serviceName,
	        @RequestParam("serviceDetails") String serviceDetails,
	        @RequestParam("price") String price,
	        @RequestPart(value = "serviceImage", required = false) MultipartFile serviceImage,
	        HttpServletRequest request) {
	    
	    return "admin/addServiceBackend";
	}
	
    @PostMapping("/admin/deleteService")
    public String deleteService(@RequestParam Integer id) {
        return "admin/deleteService";
    }

    @PostMapping("/admin/deleteReview")
    public String deleteReview(@RequestParam Integer id) {
        return "admin/deleteReview";
    }
    
    // ===== REVIEW MANAGEMENT =====
    @GetMapping("/reviewAdmin")
    public String reviewAdmin() {
        return "admin/reviewAdmin";
    }
    
    // ===== FEEDBACK PAGE MAPPINGS =====
    @GetMapping("/feedback")
    public String feedback(@RequestParam Integer bookingId, @RequestParam Integer serviceId) {
        return "feedback/feedback";
    }
    
    @GetMapping("/feedback/update")
    public String updateFeedbackPage(@RequestParam Integer feedbackId, @RequestParam Integer serviceId) {
        return "feedback/updateFeedback";
    }
    
    // ===== FEEDBACK QUERY MAPPINGS =====
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