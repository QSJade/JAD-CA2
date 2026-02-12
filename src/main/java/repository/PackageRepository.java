package repository;

import model.Package;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PackageRepository extends JpaRepository<Package, Integer> {
    
    @Query(value = "SELECT * FROM packages", nativeQuery = true)
    List<Package> findAllPackages();
}