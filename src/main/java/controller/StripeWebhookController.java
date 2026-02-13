package controller;

import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import service.InvoiceService;
import service.BookingService;
import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/stripe")
public class StripeWebhookController {
    
    @Value("${stripe.webhook.secret}")
    private String webhookSecret;
    
    @Autowired
    private InvoiceService invoiceService;
    
    @Autowired
    private BookingService bookingService;
    
    @PostMapping("/webhook")
    public String handleWebhook(@RequestBody String payload, 
                               @RequestHeader("Stripe-Signature") String sigHeader) {
        try {
            Event event = Webhook.constructEvent(payload, sigHeader, webhookSecret);
            
            switch (event.getType()) {
                case "checkout.session.completed":
                    Session session = (Session) event.getData().getObject();
                    // Create invoice for the completed payment
                    // You'll need to get the bookingId from your session metadata
                    Integer bookingId = Integer.parseInt(session.getMetadata().get("bookingId"));
                    invoiceService.createInvoiceFromBooking(bookingId);
                    break;
                default:
                    // Ignore other events
            }
            
            return "success";
        } catch (Exception e) {
            return "error: " + e.getMessage();
        }
    }
}