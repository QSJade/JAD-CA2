package controller;

import model.BookingCartItem;
import service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;

import java.util.List;

@Controller
@RequestMapping("/cart")
public class CartController {
    
    @Autowired
    private CartService cartService;
    
    @GetMapping("/view")
    public String viewCart(Model model) {
        List<BookingCartItem> cartItems = cartService.getCartItems();
        
        model.addAttribute("cartItems", cartItems);
        model.addAttribute("subtotal", cartService.calculateSubtotal());
        model.addAttribute("gst", cartService.calculateGst());
        model.addAttribute("total", cartService.calculateTotal());
        model.addAttribute("itemCount", cartService.getItemCount());
        model.addAttribute("isEmpty", cartService.isEmpty());
        
        return "booking/viewCart";
    }
    
    @GetMapping("/checkout")
    public String checkout(Model model, HttpSession session) {
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        if (cartService.isEmpty()) {
            return "redirect:/cart/view";
        }
        
        List<BookingCartItem> cartItems = cartService.getCartItems();
        double subtotal = cartService.calculateSubtotal();
        double gst = cartService.calculateGst(subtotal);
        double total = cartService.calculateTotal(subtotal, gst);
        
        model.addAttribute("cartItems", cartItems);
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("gst", gst);
        model.addAttribute("total", total);
        
        return "booking/checkout";
    }
    
    @PostMapping("/add")
    public String addToCart(@RequestParam Integer serviceId,
                           @RequestParam Integer packageId,
                           @RequestParam String serviceName,
                           @RequestParam String packageName,
                           @RequestParam String startDate,
                           @RequestParam String endDate,
                           @RequestParam(required = false) String notes,
                           @RequestParam("service_address") String address,
                           HttpSession session) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        if (!cartService.isValidDates(startDate, endDate)) {
            return "redirect:/booking/createBooking?serviceId=" + serviceId + 
                   "&packageId=" + packageId + "&errCode=invalidDates";
        }
        
        BookingCartItem item = cartService.createCartItem(
            serviceId, packageId, serviceName, packageName,
            startDate, endDate, notes, address
        );
        
        cartService.addToCart(item);
        return "redirect:/cart/view";
    }
    
    @PostMapping("/update")
    public String updateCart(@RequestParam(required = false) Integer[] packageId,
                            @RequestParam(required = false) String[] startDate,
                            @RequestParam(required = false) String[] endDate) {
        
        List<BookingCartItem> cartItems = cartService.getCartItems();
        
        for (int i = 0; i < cartItems.size(); i++) {
            BookingCartItem item = cartItems.get(i);
            
            if (startDate != null && i < startDate.length && startDate[i] != null) {
                item.setStartDate(startDate[i]);
            }
            if (endDate != null && i < endDate.length && endDate[i] != null) {
                item.setEndDate(endDate[i]);
            }
            
            if (packageId != null && i < packageId.length && packageId[i] != null) {
                int newPackageId = packageId[i];
                if (item.getPackageId() != newPackageId) {
                    item.setPackageId(newPackageId);
                    
                    try {
                        double newPrice = cartService.calculatePricePerDay(
                            item.getServiceId(), newPackageId
                        );
                        item.setPricePerDay(newPrice);
                        
                        // Update package name
                        String newPackageName = getPackageName(newPackageId);
                        if (newPackageName != null) {
                            item.setPackageName(newPackageName);
                        }
                    } catch (IllegalArgumentException e) {
                        // Log error
                    }
                }
            }
        }
        
        return "redirect:/cart/view";
    }
    
    @GetMapping("/remove/{index}")
    public String removeFromCart(@PathVariable Integer index) {
        cartService.removeFromCart(index);
        return "redirect:/cart/view";
    }
    
    @PostMapping("/clear")
    public String clearCart() {
        cartService.clearCart();
        return "redirect:/cart/view";
    }
    
    // Helper method to get package name
    private String getPackageName(int packageId) {
        switch(packageId) {
            case 1: return "Gold";
            case 2: return "Silver";
            case 3: return "Bronze";
            default: return "Unknown";
        }
    }
}