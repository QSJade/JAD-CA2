package controller;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/sales")
public class AdminSalesController {
    
    @Autowired
    private InvoiceService invoiceService;
    
    @Autowired
    private BookingService bookingService;
    
    @Autowired
    private CareServiceService careServiceService;
    
    @GetMapping
    public String salesDashboard(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        model.addAttribute("totalRevenue", invoiceService.getTotalRevenue());
        model.addAttribute("totalInvoices", invoiceService.getAllInvoices().size());
        model.addAttribute("paidInvoices", invoiceService.getTotalPaidInvoices());
        model.addAttribute("monthlyRevenue", invoiceService.getMonthlyRevenue());
        model.addAttribute("topClients", invoiceService.getTopClients(5));
        
        return "admin/salesDashboard";
    }
    
    @GetMapping("/invoices")
    public String listInvoices(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<Invoice> invoices = invoiceService.getAllInvoices();
        
        // DEBUG
        System.out.println("===== INVOICE LIST =====");
        System.out.println("Number of invoices found: " + (invoices != null ? invoices.size() : 0));
        if (invoices != null && !invoices.isEmpty()) {
            for (Invoice inv : invoices) {
                System.out.println("Invoice ID: " + inv.getInvoiceId() + 
                                 ", Number: " + inv.getInvoiceNumber() + 
                                 ", Amount: " + inv.getTotalAmount());
            }
        } else {
            System.out.println("NO INVOICES FOUND IN DATABASE!");
        }
        
        model.addAttribute("invoices", invoices);
        
        return "admin/invoiceList";
    }
    
    @GetMapping("/invoices/{id}")
    public String viewInvoice(@PathVariable Integer id, Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        // FIX: Use the new method that initializes lazy collections
        Invoice invoice = invoiceService.getInvoiceByIdWithItems(id);
        model.addAttribute("invoice", invoice);
        
        return "admin/invoiceDetail";
    }
    
    @GetMapping("/bookings")
    public String listBookings(@RequestParam(required = false) String startDate,
                              @RequestParam(required = false) String endDate,
                              @RequestParam(required = false) Integer serviceId,
                              @RequestParam(required = false) Integer customerId,
                              Model model, HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<Booking> bookings;
        
        if (startDate != null && endDate != null && !startDate.isEmpty() && !endDate.isEmpty()) {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            bookings = bookingService.getBookingsByDateRange(start, end);
            model.addAttribute("startDate", startDate);
            model.addAttribute("endDate", endDate);
        } else if (serviceId != null) {
            bookings = bookingService.getBookingsByServiceId(serviceId);
            model.addAttribute("serviceId", serviceId);
            model.addAttribute("serviceName", careServiceService.getServiceById(serviceId).getServiceName());
        } else if (customerId != null) {
            bookings = bookingService.getBookingsByCustomerId(customerId);
            model.addAttribute("customerId", customerId);
        } else {
            bookings = bookingService.getAllBookings();
        }
        
        // Get invoice IDs for each booking
        Map<Integer, Integer> bookingInvoiceMap = new HashMap<>();
        if (bookings != null) {
            for (Booking booking : bookings) {
                Invoice invoice = invoiceService.getInvoiceByBookingId(booking.getBookingId());
                if (invoice != null) {
                    bookingInvoiceMap.put(booking.getBookingId(), invoice.getInvoiceId());
                }
            }
        }
        
        model.addAttribute("bookings", bookings);
        model.addAttribute("bookingInvoiceMap", bookingInvoiceMap);
        model.addAttribute("services", careServiceService.getAllServices());
        
        return "admin/bookingInquiry";
    }
    
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
    
    @GetMapping("/reports/service-usage")
    public String serviceUsageReport(@RequestParam(required = false) Integer serviceId,
                                    Model model, HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        if (serviceId != null) {
            List<Invoice> invoices = invoiceService.getInvoicesByServiceId(serviceId);
            model.addAttribute("invoices", invoices);
            model.addAttribute("selectedService", careServiceService.getServiceById(serviceId));
            double totalAmount = invoices.stream()
                .mapToDouble(Invoice::getTotalAmount)
                .sum();
            model.addAttribute("totalAmount", totalAmount);
        }
        
        model.addAttribute("services", careServiceService.getAllServices());
        
        return "admin/serviceUsageReport";
    }
}