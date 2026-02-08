package controller;

import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import model.Booking;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import service.PaymentService;

import java.util.List;

@RestController
@RequestMapping("/api/stripe")
public class StripeController {

    @Autowired
    private PaymentService paymentService;

    // ===== Create Stripe Checkout Session =====
    @PostMapping("/checkout")
    public Session checkout(
            @RequestBody List<Booking> bookings,
            @RequestParam String successUrl,
            @RequestParam String cancelUrl
    ) throws StripeException {

        // Customer email can be obtained from the first booking (all bookings belong to the same customer)
        String customerEmail = bookings.isEmpty() ? "" : bookings.get(0).getCustomerEmail();

        return paymentService.createCheckoutSession(bookings, successUrl, cancelUrl);
    }
}
