package service;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import model.Booking;
import org.springframework.stereotype.Service;

import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class PaymentService {

    private static final double GST_RATE = 0.09; // Singapore GST

    static {
        Stripe.apiKey = "sk_test_YourSecretKeyHere";
    }

    /**
     * Create Stripe checkout session for a list of bookings
     *
     * @param bookings  list of Booking entities
     * @param successUrl URL to redirect on successful payment
     * @param cancelUrl  URL to redirect if payment canceled
     * @return Stripe Session object
     * @throws StripeException if Stripe API fails
     */
    public Session createCheckoutSession(List<Booking> bookings, String successUrl, String cancelUrl) throws StripeException {

        SessionCreateParams.Builder sessionBuilder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl);

        for (Booking b : bookings) {

            // Calculate number of days (inclusive)
            long days = ChronoUnit.DAYS.between(b.getStartDate(), b.getEndDate()) + 1;
            if (days <= 0) days = 1;

            // Subtotal and GST
            double subtotal = b.getPricePerDay() * days;
            double gst = subtotal * GST_RATE;
            long totalInCents = Math.round((subtotal + gst) * 100); // Stripe expects cents

            // Build line item with service name + package name
            String productName = b.getService().getServiceName();
            if (b.getService() != null) {
                productName += " - " + b.getServicePackage().getPackageName();
            }

            SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
                    .setQuantity(1L)
                    .setPriceData(
                            SessionCreateParams.LineItem.PriceData.builder()
                                    .setCurrency("sgd")
                                    .setUnitAmount(totalInCents)
                                    .setProductData(
                                            SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                    .setName(productName)
                                                    .build()
                                    )
                                    .build()
                    )
                    .build();

            sessionBuilder.addLineItem(lineItem);
        }

        // Create and return the Stripe session
        return Session.create(sessionBuilder.build());
    }
}
