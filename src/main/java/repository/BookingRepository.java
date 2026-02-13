package repository;

import model.Booking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface BookingRepository extends JpaRepository<Booking, Integer> {

    List<Booking> findByUserCustomerId(Integer customerId);
    
    List<Booking> findByStatusAndEndDateBefore(String status, LocalDate date);
    
    // FOR ADMIN SALES
    List<Booking> findByStartDateBetween(LocalDate startDate, LocalDate endDate);
    
    List<Booking> findByServiceServiceId(Integer serviceId);
    
    @Query("SELECT b FROM Booking b WHERE b.status = :status AND b.startDate BETWEEN :startDate AND :endDate")
    List<Booking> findByStatusAndDateRange(@Param("status") String status, 
                                           @Param("startDate") LocalDate startDate, 
                                           @Param("endDate") LocalDate endDate);
}