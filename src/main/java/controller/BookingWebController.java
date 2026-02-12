package controller;

import model.Booking;
import service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/bookings")
public class BookingWebController {

    @Autowired
    private BookingService bookingService;

    @PostMapping("/{bookingId}/pay")
    public String payForBooking(@PathVariable Integer bookingId, 
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

    @PostMapping("/{bookingId}/cancel")
    public String cancelBooking(@PathVariable Integer bookingId,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        Booking booking = bookingService.getBookingById(bookingId);
        
        if (booking == null) {
            redirectAttributes.addAttribute("errCode", "bookingNotFound");
            return "redirect:/profile";
        }
        
        // Check if booking belongs to this user
        if (!booking.getUser().getCustomerId().equals(customerId)) {
            redirectAttributes.addAttribute("errCode", "unauthorized");
            return "redirect:/profile";
        }
        
        // ONLY ALLOW CANCELLATION FOR PENDING BOOKINGS (NOT PAID YET)
        if ("pending".equalsIgnoreCase(booking.getStatus())) {
            boolean success = bookingService.cancelBooking(bookingId, customerId);
            if (success) {
                redirectAttributes.addAttribute("success", "bookingCancelled");
            } else {
                redirectAttributes.addAttribute("errCode", "cancelFailed");
            }
        } else {
            // Cannot cancel confirmed/completed bookings without refund
            redirectAttributes.addAttribute("errCode", "cannotCancelPaid");
        }
        
        return "redirect:/profile";
    }
}