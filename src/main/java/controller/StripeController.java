package controller;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpSession;
import model.Booking;
import model.CareService;
import model.Package;
import model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.stereotype.Controller;
import service.BookingService;
import service.CareServiceService;
import service.PackageService;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/stripe")
public class StripeController {

    @Value("${stripe.secret.key}")
    private String stripeSecretKey;
    
    @Autowired
    private BookingService bookingService;
    
    @Autowired
    private CareServiceService careServiceService;
    
    @Autowired
    private PackageService packageService;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeSecretKey;
    }

    @PostMapping("/create-checkout-session")
    @ResponseBody
    public Map<String, String> createCheckoutSession(@RequestBody Map<String, Object> payload, 
                                                    HttpSession session) throws StripeException {
        
        Integer bookingId = (Integer) payload.get("bookingId");
        Integer serviceId = (Integer) payload.get("serviceId");
        String startDate = (String) payload.get("startDate");
        String endDate = (String) payload.get("endDate");
        
        // Get user from session
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        String customerEmail = (String) session.getAttribute("sessCustomerEmail");
        
        if (customerId == null || customerEmail == null) {
            throw new IllegalStateException("User not logged in");
        }
        
        // Get service and package from the booking
        Booking booking = bookingService.getBookingById(bookingId);
        if (booking == null) {
            throw new IllegalStateException("Booking not found");
        }
        
        CareService service = booking.getService();
        Package pkg = booking.getServicePackage();
        
        long days = ChronoUnit.DAYS.between(
            LocalDate.parse(startDate), 
            LocalDate.parse(endDate)
        ) + 1;
        
        double pricePerDay = service.getPricePerDay() * pkg.getMultiplier();
        
        String productName = service.getServiceName() + " - " + pkg.getPackageName();
        
        // Create line item
        SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
            .setPriceData(
                SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency("sgd")
                    .setUnitAmount((long) (pricePerDay * 100))
                    .setProductData(
                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                            .setName(productName)
                            .build()
                    )
                    .build()
            )
            .setQuantity(days)
            .build();
        
        // Build Stripe session
        String baseUrl = "http://localhost:8080";
        
        SessionCreateParams params = SessionCreateParams.builder()
            .setMode(SessionCreateParams.Mode.PAYMENT)
            .setSuccessUrl(baseUrl + "/stripe/success?bookingId=" + bookingId)
            .setCancelUrl(baseUrl + "/profile?errCode=paymentCancelled")
            .setCustomerEmail(customerEmail)
            .addLineItem(lineItem)
            .build();
        
        Session stripeSession = Session.create(params);
        
        // Store booking ID in session for verification
        session.setAttribute("pendingBookingId", bookingId);
        session.setAttribute("stripeSessionId", stripeSession.getId());
        
        Map<String, String> response = new HashMap<>();
        response.put("id", stripeSession.getId());
        return response;
    }

    @GetMapping("/success")
    public String paymentSuccess(@RequestParam("bookingId") Integer bookingId,
                                HttpSession session,
                                RedirectAttributes redirectAttributes) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        boolean success = bookingService.confirmBooking(bookingId, customerId);
        if (success) {
            redirectAttributes.addAttribute("success", "paymentConfirmed");
        } else {
            redirectAttributes.addAttribute("errCode", "paymentFailed");
        }
        
        return "redirect:/profile";
    }
}