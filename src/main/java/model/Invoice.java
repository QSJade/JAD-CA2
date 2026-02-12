package model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "invoices")
public class Invoice {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer invoiceId;
    
    @ManyToOne
    @JoinColumn(name = "booking_id", nullable = false)
    private Booking booking;
    
    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private User user;
    
    @Column(unique = true, nullable = false)
    private String invoiceNumber;
    
    @Column(nullable = false)
    private LocalDateTime invoiceDate = LocalDateTime.now();
    
    @Column(nullable = false)
    private LocalDate dueDate;
    
    @Column(nullable = false)
    private Double subtotal;
    
    @Column(nullable = false)
    private Double gst;
    
    @Column(nullable = false)
    private Double totalAmount;
    
    @Column(nullable = false)
    private String paymentStatus = "pending"; // pending, paid, overdue, refunded
    
    private LocalDateTime paymentDate;
    
    private String stripePaymentIntentId;
    
    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<InvoiceItem> invoiceItems = new ArrayList<>();
    
    // Getters and Setters
    public Integer getInvoiceId() { return invoiceId; }
    public void setInvoiceId(Integer invoiceId) { this.invoiceId = invoiceId; }
    
    public Booking getBooking() { return booking; }
    public void setBooking(Booking booking) { this.booking = booking; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }
    
    public LocalDateTime getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(LocalDateTime invoiceDate) { this.invoiceDate = invoiceDate; }
    
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    
    public Double getSubtotal() { return subtotal; }
    public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }
    
    public Double getGst() { return gst; }
    public void setGst(Double gst) { this.gst = gst; }
    
    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }
    
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    
    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }
    
    public String getStripePaymentIntentId() { return stripePaymentIntentId; }
    public void setStripePaymentIntentId(String stripePaymentIntentId) { this.stripePaymentIntentId = stripePaymentIntentId; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public List<InvoiceItem> getInvoiceItems() { return invoiceItems; }
    public void setInvoiceItems(List<InvoiceItem> invoiceItems) { this.invoiceItems = invoiceItems; }
}