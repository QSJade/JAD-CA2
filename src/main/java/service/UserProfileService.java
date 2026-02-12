package service;

import model.User;
import model.UserProfile;
import repository.UserProfileRepository;
import repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

@Service
public class UserProfileService {

    @Autowired
    private UserProfileRepository userProfileRepository;
    
    @Autowired
    private UserRepository userRepository;

    public UserProfile getProfileByCustomerId(Integer customerId) {
        return userProfileRepository.findByUserCustomerId(customerId).orElse(null);
    }

    @Transactional
    public UserProfile createOrUpdateProfile(UserProfile profile) {
        UserProfile existingProfile = userProfileRepository
            .findByUserCustomerId(profile.getCustomerId()).orElse(null);
        
        if (existingProfile == null) {
            // New profile
            User user = userRepository.findById(profile.getCustomerId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
            profile.setUser(user);
            profile.setCreatedAt(LocalDateTime.now());
            return userProfileRepository.save(profile);
        } else {
            // Update existing profile
            existingProfile.setHasPets(profile.getHasPets());
            existingProfile.setHealthConditions(profile.getHealthConditions());
            existingProfile.setUsesWheelchair(profile.getUsesWheelchair());
            existingProfile.setIsSmoker(profile.getIsSmoker());
            existingProfile.setDietaryRestrictions(profile.getDietaryRestrictions());
            existingProfile.setMedicationRestrictions(profile.getMedicationRestrictions());
            existingProfile.setOtherInfo(profile.getOtherInfo());
            
            // NEW FIELDS
            existingProfile.setEmergencyContactName(profile.getEmergencyContactName());
            existingProfile.setEmergencyContactPhone(profile.getEmergencyContactPhone());
            existingProfile.setEmergencyContactRelation(profile.getEmergencyContactRelation());
            existingProfile.setBloodType(profile.getBloodType());
            existingProfile.setAllergies(profile.getAllergies());
            existingProfile.setChronicConditions(profile.getChronicConditions());
            
            return userProfileRepository.save(existingProfile);
        }
    }
    
 // ============ ADMIN CLIENT MANAGEMENT METHODS ============

    public List<UserProfile> getAllClientProfiles() {
        return userProfileRepository.findAllByOrderByUserCustomerIdDesc();
    }

    public UserProfile getClientProfile(Integer customerId) {
        return userProfileRepository.findByUserCustomerId(customerId).orElse(null);
    }

    @Transactional
    public UserProfile updateClientProfile(Integer customerId, UserProfile profile) {
        User user = userRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        UserProfile existingProfile = userProfileRepository
            .findByUserCustomerId(customerId).orElse(new UserProfile());
        
        existingProfile.setUser(user);
        existingProfile.setHasPets(profile.getHasPets());
        existingProfile.setHealthConditions(profile.getHealthConditions());
        existingProfile.setUsesWheelchair(profile.getUsesWheelchair());
        existingProfile.setIsSmoker(profile.getIsSmoker());
        existingProfile.setDietaryRestrictions(profile.getDietaryRestrictions());
        existingProfile.setMedicationRestrictions(profile.getMedicationRestrictions());
        existingProfile.setOtherInfo(profile.getOtherInfo());
        existingProfile.setEmergencyContactName(profile.getEmergencyContactName());
        existingProfile.setEmergencyContactPhone(profile.getEmergencyContactPhone());
        existingProfile.setEmergencyContactRelation(profile.getEmergencyContactRelation());
        existingProfile.setBloodType(profile.getBloodType());
        existingProfile.setAllergies(profile.getAllergies());
        existingProfile.setChronicConditions(profile.getChronicConditions());
        
        if (existingProfile.getProfileId() == null) {
            existingProfile.setCreatedAt(LocalDateTime.now());
        }
        
        return userProfileRepository.save(existingProfile);
    }

    // ============ CLIENT INQUIRY & REPORTING METHODS ============

    public List<UserProfile> searchClientsByHealthCondition(String condition) {
        return userProfileRepository.findByHealthConditionsContaining(condition);
    }

    public List<UserProfile> searchClientsByDietaryRestriction(String restriction) {
        return userProfileRepository.findByDietaryRestrictionsContaining(restriction);
    }

    public List<UserProfile> searchClientsByEmergencyContact(String name) {
        return userProfileRepository.findByEmergencyContactNameContaining(name);
    }

    public List<UserProfile> getClientsWhoUseWheelchair() {
        return userProfileRepository.findByUsesWheelchairTrue();
    }

    public List<UserProfile> getClientsWithPets() {
        return userProfileRepository.findByHasPetsTrue();
    }

    public List<UserProfile> getSmokers() {
        return userProfileRepository.findByIsSmokerTrue();
    }
}