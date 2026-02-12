package repository;

import model.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserProfileRepository extends JpaRepository<UserProfile, Integer> {
    
    Optional<UserProfile> findByUserCustomerId(Integer customerId);
    
    List<UserProfile> findAllByOrderByUserCustomerIdDesc();
    
    @Query("SELECT p FROM UserProfile p WHERE LOWER(p.healthConditions) LIKE LOWER(CONCAT('%', :condition, '%'))")
    List<UserProfile> findByHealthConditionsContaining(@Param("condition") String condition);
    
    @Query("SELECT p FROM UserProfile p WHERE LOWER(p.dietaryRestrictions) LIKE LOWER(CONCAT('%', :restriction, '%'))")
    List<UserProfile> findByDietaryRestrictionsContaining(@Param("restriction") String restriction);
    
    @Query("SELECT p FROM UserProfile p WHERE LOWER(p.emergencyContactName) LIKE LOWER(CONCAT('%', :name, '%'))")
    List<UserProfile> findByEmergencyContactNameContaining(@Param("name") String name);
    
    List<UserProfile> findByUsesWheelchairTrue();
    
    List<UserProfile> findByHasPetsTrue();
    
    List<UserProfile> findByIsSmokerTrue();
}