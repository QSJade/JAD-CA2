package repository;

import model.CareService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ServiceRepository extends JpaRepository<CareService, Integer> {
    
    // Method naming convention - JPA implements automatically
    List<CareService> findByIsActiveTrue();
}