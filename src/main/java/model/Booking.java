package model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "bookings")
@Access(AccessType.FIELD)
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer bookingId;

    @ManyToOne
    @JoinColumn(name = "service_id", nullable = false)
    private CareService service;

    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String customerEmail;

    @Column(nullable = false)
    private LocalDate startDate;

    @Column(nullable = false)
    private LocalDate endDate;

    @Column(nullable = false)
    private double pricePerDay;

    @Column(length = 1000)
    private String notes;

    @Column(nullable = false)
    private String status = "pending"; // pending, confirmed, completed, cancelled

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "package_id")
    private Package servicePackage;

    @ManyToOne
    @JoinColumn(name = "caregiver_id")
    private Caregiver caregiver;

    private String serviceAddress;

    private String stripeSessionId;

    private double subtotal;

    private double gst;

    private double totalAmount;

    // ===== Getters and Setters =====
    public Integer getBookingId() { return bookingId; }
    public void setBookingId(Integer bookingId) { this.bookingId = bookingId; }

    public CareService getService() { return service; }
    public void setService(CareService service) { this.service = service; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public double getPricePerDay() { return pricePerDay; }
    public void setPricePerDay(double pricePerDay) { this.pricePerDay = pricePerDay; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Package getServicePackage() { return servicePackage; }
    public void setServicePackage(Package servicePackage) { this.servicePackage = servicePackage; }

    public Caregiver getCaregiver() { return caregiver; }
    public void setCaregiver(Caregiver caregiver) { this.caregiver = caregiver; }

    public String getServiceAddress() { return serviceAddress; }
    public void setServiceAddress(String serviceAddress) { this.serviceAddress = serviceAddress; }

    public String getStripeSessionId() { return stripeSessionId; }
    public void setStripeSessionId(String stripeSessionId) { this.stripeSessionId = stripeSessionId; }

    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }

    public double getGst() { return gst; }
    public void setGst(double gst) { this.gst = gst; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
}