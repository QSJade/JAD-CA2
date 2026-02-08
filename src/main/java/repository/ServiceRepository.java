package repository;

import model.CareService;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ServiceRepository extends JpaRepository<CareService, Integer> {}
