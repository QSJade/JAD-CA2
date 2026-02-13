package controller;

import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.checkout.Session;
import com.stripe.param.checkout.SessionCreateParams;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpSession;
import model.Booking;
import model.BookingCartItem;
import model.CareService;
import model.Package;
import model.User;
import model.Invoice;
import model.InvoiceItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import service.BookingService;
import service.CareServiceService;
import service.PackageService;
import service.CartService;
import service.UserService;
import repository.InvoiceRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
    
    @Autowired
    private CartService cartService;
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private InvoiceRepository invoiceRepository;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeSecretKey;
    }

    // ===== FOR CART PAYMENT (FROM CHECKOUT PAGE) =====
    @PostMapping("/checkout")
    @ResponseBody
    public Map<String, String> cartCheckout(HttpSession session) throws StripeException {
        
        List<BookingCartItem> cart = cartService.getCartItems();
        
        if (cart == null || cart.isEmpty()) {
            throw new IllegalStateException("Cart is empty");
        }
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        String customerEmail = (String) session.getAttribute("sessCustomerEmail");
        
        if (customerId == null || customerEmail == null) {
            throw new IllegalStateException("User not logged in");
        }
        
        User user = userService.getUserById(customerId);
        if (user == null) {
            throw new IllegalStateException("User not found");
        }
        
        List<SessionCreateParams.LineItem> lineItems = new ArrayList<>();
        double cartTotal = 0.0;
        
        for (BookingCartItem item : cart) {
            CareService service = careServiceService.getServiceById(item.getServiceId());
            Package pkg = packageService.getPackageById(item.getPackageId());
            
            long days = ChronoUnit.DAYS.between(
                LocalDate.parse(item.getStartDate()), 
                LocalDate.parse(item.getEndDate())
            ) + 1;
            
            double pricePerDay = service.getPricePerDay() * pkg.getMultiplier();
            double subtotal = pricePerDay * days;
            double gst = subtotal * 0.09;
            double total = subtotal + gst;
            double pricePerDayWithGst = total / days;
            
            cartTotal += total;
            
            String productName = service.getServiceName() + " - " + pkg.getPackageName();
            
            // Charge amount WITH GST included
            SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
                .setPriceData(
                    SessionCreateParams.LineItem.PriceData.builder()
                        .setCurrency("sgd")
                        .setUnitAmount((long) (pricePerDayWithGst * 100))
                        .setProductData(
                            SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                .setName(productName + " (incl. GST)")
                                .build()
                        )
                        .build()
                )
                .setQuantity(days)
                .build();
                
            lineItems.add(lineItem);
        }
        
        String baseUrl = "http://localhost:8080";
        
        SessionCreateParams params = SessionCreateParams.builder()
            .setMode(SessionCreateParams.Mode.PAYMENT)
            .setSuccessUrl(baseUrl + "/stripe/cart-success")
            .setCancelUrl(baseUrl + "/cart/view?errCode=paymentCancelled")
            .setCustomerEmail(customerEmail)
            .addAllLineItem(lineItems)
            .putMetadata("customerId", String.valueOf(customerId))
            .putMetadata("cartTotal", String.valueOf(cartTotal))
            .build();
        
        Session stripeSession = Session.create(params);
        
        session.setAttribute("pendingCart", cart);
        session.setAttribute("pendingUser", user);
        session.setAttribute("stripeSessionId", stripeSession.getId());
        
        Map<String, String> response = new HashMap<>();
        response.put("id", stripeSession.getId());
        return response;
    }
    
    @GetMapping("/cart-success")
    public String cartPaymentSuccess(HttpSession session,
                                    RedirectAttributes redirectAttributes) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        @SuppressWarnings("unchecked")
        List<BookingCartItem> cart = (List<BookingCartItem>) session.getAttribute("pendingCart");
        User user = (User) session.getAttribute("pendingUser");
        
        if (cart == null || cart.isEmpty()) {
            redirectAttributes.addAttribute("errCode", "paymentFailed");
            return "redirect:/profile";
        }
        
        if (user == null) {
            user = userService.getUserById(customerId);
        }
        
        int successCount = 0;
        List<String> errors = new ArrayList<>();
        String stripeSessionId = (String) session.getAttribute("stripeSessionId");
        
        for (BookingCartItem item : cart) {
            try {
                // 1. CREATE BOOKING
                Booking booking = new Booking();
                
                CareService service = careServiceService.getServiceById(item.getServiceId());
                Package pkg = packageService.getPackageById(item.getPackageId());
                
                if (service == null) {
                    errors.add("Service not found for ID: " + item.getServiceId());
                    continue;
                }
                if (pkg == null) {
                    errors.add("Package not found for ID: " + item.getPackageId());
                    continue;
                }
                
                booking.setService(service);
                booking.setServicePackage(pkg);
                booking.setUser(user);
                booking.setCustomerEmail(user.getEmail());
                booking.setStartDate(LocalDate.parse(item.getStartDate()));
                booking.setEndDate(LocalDate.parse(item.getEndDate()));
                booking.setPricePerDay(item.getPricePerDay());
                booking.setNotes(item.getNotes());
                booking.setServiceAddress(item.getAddress());
                booking.setStatus("confirmed");
                booking.setStripeSessionId(stripeSessionId);
                
                long days = ChronoUnit.DAYS.between(
                    booking.getStartDate(), 
                    booking.getEndDate()
                ) + 1;
                
                double subtotal = booking.getPricePerDay() * days;
                double gst = subtotal * 0.09;
                double total = subtotal + gst;
                
                booking.setSubtotal(subtotal);
                booking.setGst(gst);
                booking.setTotalAmount(total);
                
                Booking savedBooking = bookingService.createBooking(booking);
                
                // 2. CREATE INVOICE for this booking
                Invoice invoice = new Invoice();
                invoice.setBooking(savedBooking);
                invoice.setUser(user);
                
                String invoiceNumber = "INV-" + LocalDate.now().toString().replace("-", "") 
                                     + "-" + savedBooking.getBookingId();
                invoice.setInvoiceNumber(invoiceNumber);
                
                invoice.setInvoiceDate(LocalDateTime.now());
                invoice.setDueDate(LocalDate.now().plusDays(14));
                invoice.setSubtotal(subtotal);
                invoice.setGst(gst);
                invoice.setTotalAmount(total);
                invoice.setPaymentStatus("paid");
                invoice.setPaymentDate(LocalDateTime.now());
                invoice.setStripePaymentIntentId(stripeSessionId);
                
                // Create invoice item
                InvoiceItem invoiceItem = new InvoiceItem();
                invoiceItem.setInvoice(invoice);
                invoiceItem.setDescription(service.getServiceName() + " - " + pkg.getPackageName());
                invoiceItem.setQuantity((int) days);
                invoiceItem.setUnitPrice(item.getPricePerDay());
                invoiceItem.setAmount(subtotal);
                
                invoice.getInvoiceItems().add(invoiceItem);
                
                invoiceRepository.save(invoice);
                
                successCount++;
                
            } catch (Exception e) {
                errors.add("Failed to create booking: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        cartService.clearCart();
        session.removeAttribute("cart");
        session.removeAttribute("pendingCart");
        session.removeAttribute("pendingUser");
        session.removeAttribute("stripeSessionId");
        
        if (successCount > 0) {
            redirectAttributes.addAttribute("success", "paymentConfirmed");
            redirectAttributes.addAttribute("count", successCount);
        } else {
            redirectAttributes.addAttribute("errCode", "paymentFailed");
        }
        
        if (!errors.isEmpty()) {
            session.setAttribute("paymentErrors", errors);
        }
        
        return "redirect:/profile";
    }

    // ===== FOR SINGLE BOOKING PAYMENT (FROM PROFILE PAGE) =====
    @PostMapping("/create-checkout-session")
    @ResponseBody
    public Map<String, String> createCheckoutSession(@RequestBody Map<String, Object> payload, 
                                                    HttpSession session) throws StripeException {
        
        Integer bookingId = (Integer) payload.get("bookingId");
        Integer serviceId = (Integer) payload.get("serviceId");
        String startDate = (String) payload.get("startDate");
        String endDate = (String) payload.get("endDate");
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        String customerEmail = (String) session.getAttribute("sessCustomerEmail");
        
        if (customerId == null || customerEmail == null) {
            throw new IllegalStateException("User not logged in");
        }
        
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
        double subtotal = pricePerDay * days;
        double gst = subtotal * 0.09;
        double total = subtotal + gst;
        double pricePerDayWithGst = total / days;
        
        String productName = service.getServiceName() + " - " + pkg.getPackageName();
        
        // Charge WITH GST
        SessionCreateParams.LineItem lineItem = SessionCreateParams.LineItem.builder()
            .setPriceData(
                SessionCreateParams.LineItem.PriceData.builder()
                    .setCurrency("sgd")
                    .setUnitAmount((long) (pricePerDayWithGst * 100))
                    .setProductData(
                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                            .setName(productName + " (incl. GST)")
                            .build()
                    )
                    .build()
            )
            .setQuantity(days)
            .build();
        
        String baseUrl = "http://localhost:8080";
        
        SessionCreateParams params = SessionCreateParams.builder()
            .setMode(SessionCreateParams.Mode.PAYMENT)
            .setSuccessUrl(baseUrl + "/stripe/success?bookingId=" + bookingId)
            .setCancelUrl(baseUrl + "/profile?errCode=paymentCancelled")
            .setCustomerEmail(customerEmail)
            .addLineItem(lineItem)
            .putMetadata("bookingId", String.valueOf(bookingId))
            .putMetadata("customerId", String.valueOf(customerId))
            .putMetadata("total", String.valueOf(total))
            .build();
        
        Session stripeSession = Session.create(params);
        
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
            try {
                Booking booking = bookingService.getBookingById(bookingId);
                User user = booking.getUser();
                String stripeSessionId = (String) session.getAttribute("stripeSessionId");
                
                // CREATE INVOICE for single booking
                Invoice invoice = new Invoice();
                invoice.setBooking(booking);
                invoice.setUser(user);
                
                String invoiceNumber = "INV-" + LocalDate.now().toString().replace("-", "") 
                                     + "-" + bookingId;
                invoice.setInvoiceNumber(invoiceNumber);
                
                invoice.setInvoiceDate(LocalDateTime.now());
                invoice.setDueDate(LocalDate.now().plusDays(14));
                invoice.setSubtotal(booking.getSubtotal());
                invoice.setGst(booking.getGst());
                invoice.setTotalAmount(booking.getTotalAmount());
                invoice.setPaymentStatus("paid");
                invoice.setPaymentDate(LocalDateTime.now());
                invoice.setStripePaymentIntentId(stripeSessionId);
                
                InvoiceItem invoiceItem = new InvoiceItem();
                invoiceItem.setInvoice(invoice);
                invoiceItem.setDescription(booking.getService().getServiceName() 
                                         + " - " + booking.getServicePackage().getPackageName());
                
                long days = ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate()) + 1;
                invoiceItem.setQuantity((int) days);
                invoiceItem.setUnitPrice(booking.getPricePerDay());
                invoiceItem.setAmount(booking.getSubtotal());
                
                invoice.getInvoiceItems().add(invoiceItem);
                
                invoiceRepository.save(invoice);
                
                redirectAttributes.addAttribute("success", "paymentConfirmed");
            } catch (Exception e) {
                redirectAttributes.addAttribute("success", "paymentConfirmed");
                redirectAttributes.addAttribute("warning", "Booking confirmed but invoice creation failed");
                e.printStackTrace();
            }
        } else {
            redirectAttributes.addAttribute("errCode", "paymentFailed");
        }
        
        return "redirect:/profile";
    }
    
    @GetMapping("/cancel")
    public String paymentCancel() {
        return "redirect:/profile?errCode=paymentCancelled";
    }
}