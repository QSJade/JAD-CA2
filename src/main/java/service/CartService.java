package service;

import model.BookingCartItem;
import model.CareService;
import model.Package;
import repository.ServiceRepository;
import repository.PackageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.annotation.SessionScope;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

@Service
@SessionScope
public class CartService {
    
    @Autowired
    private ServiceRepository serviceRepository;
    
    @Autowired
    private PackageRepository packageRepository;
    
    // ===== CART STATE MANAGEMENT =====
    
    private List<BookingCartItem> cartItems = new ArrayList<>();
    
    public void addToCart(BookingCartItem item) {
        cartItems.add(item);
    }
    
    public List<BookingCartItem> getCartItems() {
        return new ArrayList<>(cartItems);
    }
    
    public void removeFromCart(int index) {
        if (index >= 0 && index < cartItems.size()) {
            cartItems.remove(index);
        }
    }
    
    public void clearCart() {
        cartItems.clear();
    }
    
    public boolean isEmpty() {
        return cartItems.isEmpty();
    }
    
    public int getItemCount() {
        return cartItems.size();
    }
    
    // ===== PRICING CALCULATIONS =====
    
    public double calculatePricePerDay(Integer serviceId, Integer packageId) {
        // Get service base price
        CareService service = serviceRepository.findById(serviceId)
            .orElseThrow(() -> new IllegalArgumentException("Service not found: " + serviceId));
        double basePrice = service.getPricePerDay();
        
        // Get package multiplier
        Package pkg = packageRepository.findById(packageId)
            .orElseThrow(() -> new IllegalArgumentException("Package not found: " + packageId));
        double multiplier = pkg.getMultiplier();
        
        // Calculate final price
        return basePrice * multiplier;
    }
    
    public long calculateDays(String startDate, String endDate) {
        try {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            return ChronoUnit.DAYS.between(start, end) + 1; // inclusive
        } catch (Exception e) {
            return 0;
        }
    }
    
    public double calculateItemTotal(BookingCartItem item) {
        long days = calculateDays(item.getStartDate(), item.getEndDate());
        return item.getPricePerDay() * days;
    }
    
    public double calculateSubtotal() {
        return cartItems.stream()
            .mapToDouble(this::calculateItemTotal)
            .sum();
    }
    
    public double calculateSubtotal(List<BookingCartItem> items) {
        return items.stream()
            .mapToDouble(this::calculateItemTotal)
            .sum();
    }
    
    public double calculateGst() {
        return calculateSubtotal() * 0.09; // 9% GST
    }
    
    public double calculateGst(double subtotal) {
        return subtotal * 0.09;
    }
    
    public double calculateTotal() {
        double subtotal = calculateSubtotal();
        double gst = calculateGst(subtotal);
        return subtotal + gst;
    }
    
    public double calculateTotal(double subtotal, double gst) {
        return subtotal + gst;
    }
    
    // ===== CART ITEM CREATION HELPER =====
    
    public BookingCartItem createCartItem(Integer serviceId, Integer packageId, 
                                         String serviceName, String packageName,
                                         String startDate, String endDate, 
                                         String notes, String address) {
        
        double pricePerDay = calculatePricePerDay(serviceId, packageId);
        
        return new BookingCartItem(
            serviceId, packageId, serviceName, packageName,
            startDate, endDate, notes, address, pricePerDay
        );
    }
    
    // ===== CART VALIDATION =====
    
    public boolean isValidDates(String startDate, String endDate) {
        try {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            return !end.isBefore(start);
        } catch (Exception e) {
            return false;
        }
    }
    
    public List<String> validateCart() {
        List<String> errors = new ArrayList<>();
        for (int i = 0; i < cartItems.size(); i++) {
            BookingCartItem item = cartItems.get(i);
            if (!isValidDates(item.getStartDate(), item.getEndDate())) {
                errors.add("Item " + (i + 1) + " has invalid dates");
            }
            if (item.getPricePerDay() <= 0) {
                errors.add("Item " + (i + 1) + " has invalid price");
            }
        }
        return errors;
    }
}