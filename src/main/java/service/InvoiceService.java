package service;

import model.*;
import repository.InvoiceRepository;
import repository.BookingRepository;
import repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class InvoiceService {
    
    @Autowired
    private InvoiceRepository invoiceRepository;
    
    @Autowired
    private BookingRepository bookingRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Transactional
    public Invoice createInvoiceFromBooking(Integer bookingId) {
        Booking booking = bookingRepository.findById(bookingId)
            .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        
        // Check if invoice already exists
        // You might want to add a method to check by bookingId
        
        // Generate invoice number
        String invoiceNumber = "INV-" + System.currentTimeMillis();
        
        Invoice invoice = new Invoice();
        invoice.setBooking(booking);
        invoice.setUser(booking.getUser());
        invoice.setInvoiceNumber(invoiceNumber);
        invoice.setDueDate(LocalDate.now().plusDays(14)); // 14 days to pay
        invoice.setSubtotal(booking.getSubtotal());
        invoice.setGst(booking.getGst());
        invoice.setTotalAmount(booking.getTotalAmount());
        invoice.setPaymentStatus("paid"); // Since Stripe payment is completed
        invoice.setPaymentDate(LocalDateTime.now());
        invoice.setStripePaymentIntentId(booking.getStripeSessionId());
        
        // Create invoice item
        InvoiceItem item = new InvoiceItem();
        item.setInvoice(invoice);
        item.setDescription(booking.getService().getServiceName() + 
                           " - " + booking.getServicePackage().getPackageName());
        
        long days = booking.getEndDate().toEpochDay() - booking.getStartDate().toEpochDay() + 1;
        item.setQuantity((int) days);
        item.setUnitPrice(booking.getPricePerDay());
        item.setAmount(booking.getSubtotal());
        
        invoice.getInvoiceItems().add(item);
        
        return invoiceRepository.save(invoice);
    }
    
    public List<Invoice> getAllInvoices() {
        return invoiceRepository.findAll();
    }
    
    public Invoice getInvoiceById(Integer id) {
        return invoiceRepository.findById(id).orElse(null);
    }
    
    public List<Invoice> getInvoicesByDateRange(LocalDateTime start, LocalDateTime end) {
        return invoiceRepository.findByInvoiceDateBetween(start, end);
    }
    
    public List<Object[]> getTopClients(int limit) {
        return invoiceRepository.findTopClientsBySpending();
    }
    
    public List<Invoice> getInvoicesByService(Integer serviceId) {
        return invoiceRepository.findInvoicesByServiceId(serviceId);
    }
    
    public Double getTotalRevenue() {
        Double revenue = invoiceRepository.getTotalRevenue();
        return revenue != null ? revenue : 0.0;
    }
    
    public Long getTotalPaidInvoices() {
        Long count = invoiceRepository.getTotalPaidInvoices();
        return count != null ? count : 0L;
    }
    
    public List<Object[]> getMonthlyRevenue() {
        return invoiceRepository.getMonthlyRevenue();
    }
}