package service;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import model.Booking;
import model.CareService;
import model.Package;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class PaymentService {

    @PostConstruct
    public void init() {
        // Load Stripe secret key from environment variable
        Stripe.apiKey = System.getenv("STRIPE_SECRET_KEY");
    }

    /**
     * Create a Stripe Checkout Session from a list of bookings
     */
    public Session createCheckoutSession(List<Booking> bookings, String successUrl, String cancelUrl) throws StripeException {

        SessionCreateParams.Builder paramsBuilder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl + "?session_id={CHECKOUT_SESSION_ID}")
                .setCancelUrl(cancelUrl);

        for (Booking b : bookings) {
            // Calculate total days
            long quantity = ChronoUnit.DAYS.between(b.getStartDate(), b.getEndDate()) + 1;

            SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
                    .setPriceData(
                        SessionCreateParams.LineItem.PriceData.builder()
                                .setCurrency("sgd")
                                .setUnitAmount((long) (b.getPricePerDay() * 100)) // Stripe uses cents
                                .setProductData(
                                    SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                            .setName(b.getService().getServiceName() + " - " + b.getServicePackage().getPackageName())
                                            .build()
                                )
                                .build()
                    )
                    .setQuantity(quantity)
                    .build();

            paramsBuilder.addLineItem(lineItem);
        }

        SessionCreateParams params = paramsBuilder.build();
        return Session.create(params);
    }

    /**
     * Verify the Stripe session and save bookings to the database
     */
    public void verifyAndSave(String sessionId, HttpSession session) throws Exception {
        if (sessionId == null) {
            throw new IllegalArgumentException("Stripe session ID is missing");
        }

        // Retrieve the Stripe session
        Session stripeSession = Session.retrieve(sessionId);
        if (!"paid".equals(stripeSession.getPaymentStatus())) {
            throw new IllegalStateException("Payment not completed");
        }

        // Get cart from session
        List<Booking> cart = (List<Booking>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            throw new IllegalStateException("Cart is empty");
        }

        // Connect to DB
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        try (Connection conn = DriverManager.getConnection(connURL)) {

            String insertSQL = "INSERT INTO bookings " +
                    "(service_id, package_id, customer_id, customer_email, start_date, end_date, price_per_day, notes, service_address, stripe_session_id) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = conn.prepareStatement(insertSQL);

            for (Booking b : cart) {
                CareService service = b.getService();
                Package servicePackage = b.getServicePackage();

                ps.setInt(1, service.getServiceId());
                ps.setInt(2, servicePackage.getPackageId());
                ps.setInt(3, b.getUser().getCustomerId());
                ps.setString(4, stripeSession.getCustomerEmail());
                ps.setDate(5, java.sql.Date.valueOf(b.getStartDate()));
                ps.setDate(6, java.sql.Date.valueOf(b.getEndDate()));
                ps.setDouble(7, b.getPricePerDay());
                ps.setString(8, b.getNotes());
                ps.setString(9, b.getServiceAddress());
                ps.setString(10, sessionId);

                ps.addBatch();
            }

            ps.executeBatch();
            ps.close();
        }

        // Clear cart after successful payment
        session.removeAttribute("cart");
    }
}
