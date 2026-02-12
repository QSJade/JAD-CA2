package service;

import model.Package;
import repository.PackageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PackageService {

    @Autowired
    private PackageRepository packageRepository;

    public List<Package> getAllPackages() {
        return packageRepository.findAll();
    }

    public Package getPackageById(Integer id) {
        return packageRepository.findById(id).orElse(null);
    }
}