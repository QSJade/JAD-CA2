package service;

import model.Booking;
import model.Invoice;
import model.InvoiceItem;
import model.User;
import repository.InvoiceRepository;
import repository.BookingRepository;
import repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;

@Service
public class InvoiceService {
    
    @Autowired
    private InvoiceRepository invoiceRepository;
    
    @Autowired
    private BookingRepository bookingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    // ===== CREATE INVOICE FROM BOOKING =====
    @Transactional
    public Invoice createInvoiceFromBooking(Integer bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
            .orElseThrow(() -> new IllegalArgumentException("Booking not found with ID: " + bookingId));
        
        // Check if invoice already exists for this booking
        Optional<Invoice> existingInvoice = invoiceRepository.findByBookingId(bookingId);
        if (existingInvoice.isPresent()) {
            return existingInvoice.get();
        }
        
        // Generate invoice number: INV-YYYYMMDD-XXXXX
        String invoiceNumber = "INV-" + LocalDate.now().toString().replace("-", "") + 
                              "-" + bookingId + "-" + System.currentTimeMillis() % 10000;
        
        Invoice invoice = new Invoice();
        invoice.setBooking(booking);
        invoice.setUser(booking.getUser());
        invoice.setInvoiceNumber(invoiceNumber);
        invoice.setInvoiceDate(LocalDateTime.now());
        invoice.setDueDate(LocalDate.now().plusDays(14));
        invoice.setSubtotal(booking.getSubtotal() != null ? booking.getSubtotal() : 0.0);
        invoice.setGst(booking.getGst() != null ? booking.getGst() : 0.0);
        invoice.setTotalAmount(booking.getTotalAmount() != null ? booking.getTotalAmount() : 0.0);
        invoice.setPaymentStatus("paid");
        invoice.setPaymentDate(LocalDateTime.now());
        invoice.setStripePaymentIntentId(booking.getStripeSessionId());
        
        // Create invoice item
        InvoiceItem item = new InvoiceItem();
        item.setInvoice(invoice);
        item.setDescription(booking.getService().getServiceName() + 
                           " - " + booking.getServicePackage().getPackageName());
        
        long days = ChronoUnit.DAYS.between(booking.getStartDate(), booking.getEndDate()) + 1;
        item.setQuantity((int) days);
        item.setUnitPrice(booking.getPricePerDay());
        item.setAmount(booking.getSubtotal() != null ? booking.getSubtotal() : 0.0);
        
        invoice.getInvoiceItems().add(item);
        
        return invoiceRepository.save(invoice);
    }
    
    // ===== GET ALL INVOICES =====
    public List<Invoice> getAllInvoices() {
        return invoiceRepository.findAll();
    }
    
    // ===== GET INVOICE BY ID (without initialization) =====
    public Invoice getInvoiceById(Integer id) {
        return invoiceRepository.findById(id).orElse(null);
    }
    
    // ===== GET INVOICE BY ID WITH ALL COLLECTIONS INITIALIZED (FIX 3) =====
    @Transactional
    public Invoice getInvoiceByIdWithItems(Integer id) {
        Invoice invoice = invoiceRepository.findById(id).orElse(null);
        
        // Force initialization of lazy collections while session is open
        if (invoice != null) {
            // Initialize invoice items
            invoice.getInvoiceItems().size();
            
            // Initialize related entities
            if (invoice.getBooking() != null) {
                invoice.getBooking().getService().getServiceName();
                if (invoice.getBooking().getServicePackage() != null) {
                    invoice.getBooking().getServicePackage().getPackageName();
                }
                if (invoice.getBooking().getUser() != null) {
                    invoice.getBooking().getUser().getName();
                }
            }
            
            if (invoice.getUser() != null) {
                invoice.getUser().getName();
                invoice.getUser().getEmail();
            }
        }
        
        return invoice;
    }
    
    // ===== GET INVOICE BY BOOKING ID =====
    public Invoice getInvoiceByBookingId(Integer bookingId) {
        Optional<Invoice> optional = invoiceRepository.findByBookingId(bookingId);
        return optional.orElse(null);
    }
    
    // ===== GET INVOICES BY CUSTOMER ID =====
    public List<Invoice> getInvoicesByCustomerId(Integer customerId) {
        return invoiceRepository.findByUserCustomerId(customerId);
    }
    
    // ===== GET INVOICES BY PAYMENT STATUS =====
    public List<Invoice> getInvoicesByStatus(String status) {
        return invoiceRepository.findByPaymentStatus(status);
    }
    
    // ===== GET INVOICES BY DATE RANGE =====
    public List<Invoice> getInvoicesByDateRange(LocalDateTime start, LocalDateTime end) {
        return invoiceRepository.findByInvoiceDateBetween(start, end);
    }
    
    // ===== GET INVOICES BY DATE RANGE (LocalDate version) =====
    public List<Invoice> getInvoicesByDateRange(LocalDate startDate, LocalDate endDate) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.atTime(23, 59, 59);
        return invoiceRepository.findByInvoiceDateBetween(start, end);
    }
    
    // ===== GET TOP CLIENTS BY SPENDING =====
    public List<Object[]> getTopClients(int limit) {
        List<Object[]> results = invoiceRepository.findTopClientsBySpending();
        if (results.size() > limit) {
            return results.subList(0, limit);
        }
        return results;
    }
    
    // ===== GET INVOICES BY SERVICE ID =====
    public List<Invoice> getInvoicesByServiceId(Integer serviceId) {
        return invoiceRepository.findInvoicesByServiceId(serviceId);
    }
    
    // ===== GET TOTAL REVENUE =====
    public Double getTotalRevenue() {
        Double revenue = invoiceRepository.getTotalRevenue();
        return revenue != null ? revenue : 0.0;
    }
    
    // ===== GET TOTAL PAID INVOICES COUNT =====
    public Long getTotalPaidInvoices() {
        Long count = invoiceRepository.getTotalPaidInvoices();
        return count != null ? count : 0L;
    }
    
    // ===== GET MONTHLY REVENUE =====
    public List<Object[]> getMonthlyRevenue() {
        return invoiceRepository.getMonthlyRevenue();
    }
    
    // ===== GET REVENUE BY YEAR =====
    public Double getRevenueByYear(int year) {
        LocalDateTime start = LocalDateTime.of(year, 1, 1, 0, 0);
        LocalDateTime end = LocalDateTime.of(year, 12, 31, 23, 59, 59);
        List<Invoice> invoices = invoiceRepository.findByInvoiceDateBetween(start, end);
        return invoices.stream()
            .filter(i -> "paid".equals(i.getPaymentStatus()))
            .mapToDouble(Invoice::getTotalAmount)
            .sum();
    }
    
    // ===== GET REVENUE BY MONTH =====
    public Double getRevenueByMonth(int year, int month) {
        LocalDateTime start = LocalDateTime.of(year, month, 1, 0, 0);
        LocalDateTime end = start.plusMonths(1).minusSeconds(1);
        List<Invoice> invoices = invoiceRepository.findByInvoiceDateBetween(start, end);
        return invoices.stream()
            .filter(i -> "paid".equals(i.getPaymentStatus()))
            .mapToDouble(Invoice::getTotalAmount)
            .sum();
    }
    
    // ===== UPDATE PAYMENT STATUS =====
    @Transactional
    public Invoice updatePaymentStatus(Integer invoiceId, String status) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found"));
        invoice.setPaymentStatus(status);
        if ("paid".equals(status)) {
            invoice.setPaymentDate(LocalDateTime.now());
        }
        return invoiceRepository.save(invoice);
    }
    
    // ===== GENERATE INVOICE REPORT =====
    public String generateInvoiceReport(Integer invoiceId) {
        Invoice invoice = getInvoiceByIdWithItems(invoiceId);
        if (invoice == null) {
            return "Invoice not found";
        }
        
        StringBuilder report = new StringBuilder();
        report.append("=".repeat(60)).append("\n");
        report.append("INVOICE #").append(invoice.getInvoiceNumber()).append("\n");
        report.append("=".repeat(60)).append("\n");
        report.append("Date: ").append(invoice.getInvoiceDate().toLocalDate()).append("\n");
        report.append("Due Date: ").append(invoice.getDueDate()).append("\n");
        report.append("Customer: ").append(invoice.getUser().getName()).append("\n");
        report.append("Email: ").append(invoice.getUser().getEmail()).append("\n");
        report.append("-".repeat(60)).append("\n");
        report.append(String.format("%-30s %10s %12s %12s\n", 
            "Description", "Qty", "Unit Price", "Amount"));
        report.append("-".repeat(60)).append("\n");
        
        for (InvoiceItem item : invoice.getInvoiceItems()) {
            report.append(String.format("%-30s %10d %12.2f %12.2f\n",
                item.getDescription().length() > 30 ? 
                    item.getDescription().substring(0, 27) + "..." : item.getDescription(),
                item.getQuantity(),
                item.getUnitPrice(),
                item.getAmount()));
        }
        
        report.append("-".repeat(60)).append("\n");
        report.append(String.format("%-52s %12.2f\n", "Subtotal:", invoice.getSubtotal()));
        report.append(String.format("%-52s %12.2f\n", "GST (9%):", invoice.getGst()));
        report.append(String.format("%-52s %12.2f\n", "Total:", invoice.getTotalAmount()));
        report.append("=".repeat(60)).append("\n");
        report.append("Status: ").append(invoice.getPaymentStatus().toUpperCase()).append("\n");
        if (invoice.getPaymentDate() != null) {
            report.append("Payment Date: ").append(invoice.getPaymentDate().toLocalDate()).append("\n");
        }
        report.append("=".repeat(60)).append("\n");
        
        return report.toString();
    }
}