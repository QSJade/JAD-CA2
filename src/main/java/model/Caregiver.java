package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "caregivers")
@Access(AccessType.FIELD)
public class Caregiver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer caregiverId;

    private String name;
    private String email;
    private String phone;
    private Double rating;
    private Boolean isActive;
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "caregiver")
    private List<Booking> bookings = new ArrayList<>();

    // ===== Getters & Setters =====
    public Integer getCaregiverId() { return caregiverId; }
    public void setCaregiverId(Integer caregiverId) { this.caregiverId = caregiverId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<Booking> getBookings() { return bookings; }
    public void setBookings(List<Booking> bookings) { this.bookings = bookings; }
}