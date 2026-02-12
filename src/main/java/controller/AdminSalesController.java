package controller.admin;

import model.Invoice;
import model.Booking;
import service.InvoiceService;
import service.BookingService;
import service.CareServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Controller
@RequestMapping("/admin/sales")
public class AdminSalesController {
    
    @Autowired
    private InvoiceService invoiceService;
    
    @Autowired
    private BookingService bookingService;
    
    @Autowired
    private CareServiceService careServiceService;
    
    // ===== DASHBOARD =====
    @GetMapping
    public String salesDashboard(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        // Summary statistics
        model.addAttribute("totalRevenue", invoiceService.getTotalRevenue());
        model.addAttribute("totalInvoices", invoiceService.getAllInvoices().size());
        model.addAttribute("paidInvoices", invoiceService.getTotalPaidInvoices());
        model.addAttribute("monthlyRevenue", invoiceService.getMonthlyRevenue());
        model.addAttribute("topClients", invoiceService.getTopClients(5));
        
        return "admin/salesDashboard";
    }
    
    // ===== INVOICE LISTING =====
    @GetMapping("/invoices")
    public String listInvoices(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<Invoice> invoices = invoiceService.getAllInvoices();
        model.addAttribute("invoices", invoices);
        
        return "admin/invoiceList";
    }
    
    @GetMapping("/invoices/{id}")
    public String viewInvoice(@PathVariable Integer id, Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        Invoice invoice = invoiceService.getInvoiceById(id);
        model.addAttribute("invoice", invoice);
        
        return "admin/invoiceDetail";
    }
    
    // ===== BOOKINGS INQUIRY =====
    @GetMapping("/bookings")
    public String listBookings(@RequestParam(required = false) String startDate,
                              @RequestParam(required = false) String endDate,
                              @RequestParam(required = false) Integer serviceId,
                              Model model, HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<Booking> bookings;
        
        if (startDate != null && endDate != null) {
            // Filter by date range
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            bookings = bookingService.getBookingsByDateRange(start, end);
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
        } else if (serviceId != null) {
            // Filter by service
            bookings = bookingService.getBookingsByServiceId(serviceId);
            model.addAttribute("serviceId", serviceId);
            model.addAttribute("serviceName", careServiceService.getServiceById(serviceId).getServiceName());
        } else {
            // All bookings
            bookings = bookingService.getAllBookings();
        }
        
        model.addAttribute("bookings", bookings);
        model.addAttribute("services", careServiceService.getAllActiveServices());
        
        return "admin/bookingInquiry";
    }
    
    // ===== TOP CLIENTS REPORT =====
    @GetMapping("/reports/top-clients")
    public String topClientsReport(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<Object[]> topClients = invoiceService.getTopClients(10);
        model.addAttribute("topClients", topClients);
        
        return "admin/topClientsReport";
    }
    
    // ===== SERVICE USAGE REPORT =====
    @GetMapping("/reports/service-usage")
    public String serviceUsageReport(@RequestParam(required = false) Integer serviceId,
                                    Model model, HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        if (serviceId != null) {
            List<Invoice> invoices = invoiceService.getInvoicesByService(serviceId);
            model.addAttribute("invoices", invoices);
            model.addAttribute("selectedService", careServiceService.getServiceById(serviceId));
        }
        
        model.addAttribute("services", careServiceService.getAllActiveServices());
        
        return "admin/serviceUsageReport";
    }
}