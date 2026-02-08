package model;

import jakarta.persistence.*;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "packages")
@Access(AccessType.FIELD)
public class Package {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer packageId;

    private String packageName;

    private double multiplier;

    // Bookings associated with this package
    @OneToMany(mappedBy = "servicePackage")
    private List<Booking> bookings = new ArrayList<>();

    // Services included in this package
    @OneToMany(mappedBy = "servicePackage")
    private List<CareService> services = new ArrayList<>();

    // ===== Getters and Setters =====
    public Integer getPackageId() { return packageId; }
    public void setPackageId(Integer packageId) { this.packageId = packageId; }

    public String getPackageName() { return packageName; }
    public void setPackageName(String packageName) { this.packageName = packageName; }

    public double getMultiplier() { return multiplier; }
    public void setMultiplier(double multiplier) { this.multiplier = multiplier; }

    public List<Booking> getBookings() { return bookings; }
    public void setBookings(List<Booking> bookings) { this.bookings = bookings; }

    public List<CareService> getServices() { return services; }
    public void setServices(List<CareService> services) { this.services = services; }
}
