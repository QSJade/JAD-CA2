package model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_profiles")
@Access(AccessType.FIELD)
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer profileId;

    @OneToOne
    @JoinColumn(name = "customer_id")
    private User user;

    private Boolean hasPets;
    private String healthConditions;
    private Boolean usesWheelchair;
    private Boolean isSmoker;
    private String dietaryRestrictions;
    private String medicationRestrictions;
    private String otherInfo;
    private LocalDateTime createdAt;

    // ===== Getters & Setters =====
    public Integer getProfileId() { return profileId; }
    public void setProfileId(Integer profileId) { this.profileId = profileId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Boolean getHasPets() { return hasPets; }
    public void setHasPets(Boolean hasPets) { this.hasPets = hasPets; }

    public String getHealthConditions() { return healthConditions; }
    public void setHealthConditions(String healthConditions) { this.healthConditions = healthConditions; }

    public Boolean getUsesWheelchair() { return usesWheelchair; }
    public void setUsesWheelchair(Boolean usesWheelchair) { this.usesWheelchair = usesWheelchair; }

    public Boolean getIsSmoker() { return isSmoker; }
    public void setIsSmoker(Boolean isSmoker) { this.isSmoker = isSmoker; }

    public String getDietaryRestrictions() { return dietaryRestrictions; }
    public void setDietaryRestrictions(String dietaryRestrictions) { this.dietaryRestrictions = dietaryRestrictions; }

    public String getMedicationRestrictions() { return medicationRestrictions; }
    public void setMedicationRestrictions(String medicationRestrictions) { this.medicationRestrictions = medicationRestrictions; }

    public String getOtherInfo() { return otherInfo; }
    public void setOtherInfo(String otherInfo) { this.otherInfo = otherInfo; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
