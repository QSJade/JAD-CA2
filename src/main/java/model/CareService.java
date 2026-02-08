package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "services")
@Access(AccessType.FIELD)
public class CareService {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer serviceId;

    @Column(unique = true)
    private String serviceName;

    private String description;

    private double pricePerDay;

    private Boolean isActive;

    private LocalDateTime createdAt;

    @ManyToOne
    @JoinColumn(name = "package_id")
    private Package servicePackage;

    @OneToMany(mappedBy = "service")
    private List<Booking> bookings;

    // ===== Getters and Setters =====
    public Integer getServiceId() { return serviceId; }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPricePerDay() { return pricePerDay; }
    public void setPricePerDay(double pricePerDay) { this.pricePerDay = pricePerDay; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Package getServicePackage() { return servicePackage; }
    public void setServicePackage(Package servicePackage) { this.servicePackage = servicePackage; }

    public List<Booking> getBookings() { return bookings; }
    public void setBookings(List<Booking> bookings) { this.bookings = bookings; }

}
