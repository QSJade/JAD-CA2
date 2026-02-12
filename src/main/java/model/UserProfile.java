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
    
    // ===== NEW FIELDS FOR PART 2 =====
    private String emergencyContactName;
    private String emergencyContactPhone;
    private String emergencyContactRelation;
    private String bloodType;
    private String allergies;
    private String chronicConditions;

    // ===== Getters & Setters =====
    public Integer getProfileId() { return profileId; }
    public void setProfileId(Integer profileId) { this.profileId = profileId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public Integer getCustomerId() { 
        return user != null ? user.getCustomerId() : null; 
    }
    public void setCustomerId(Integer customerId) {
        if (user == null) {
            user = new User();
        }
        user.setCustomerId(customerId);
    }

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
    
    // =====  GETTERS/SETTERS =====
    public String getEmergencyContactName() { return emergencyContactName; }
    public void setEmergencyContactName(String emergencyContactName) { this.emergencyContactName = emergencyContactName; }
    
    public String getEmergencyContactPhone() { return emergencyContactPhone; }
    public void setEmergencyContactPhone(String emergencyContactPhone) { this.emergencyContactPhone = emergencyContactPhone; }
    
    public String getEmergencyContactRelation() { return emergencyContactRelation; }
    public void setEmergencyContactRelation(String emergencyContactRelation) { this.emergencyContactRelation = emergencyContactRelation; }
    
    public String getBloodType() { return bloodType; }
    public void setBloodType(String bloodType) { this.bloodType = bloodType; }
    
    public String getAllergies() { return allergies; }
    public void setAllergies(String allergies) { this.allergies = allergies; }
    
    public String getChronicConditions() { return chronicConditions; }
    public void setChronicConditions(String chronicConditions) { this.chronicConditions = chronicConditions; }
}