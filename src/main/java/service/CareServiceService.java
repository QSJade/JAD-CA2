package service;

import model.CareService;
import repository.ServiceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CareServiceService {

    @Autowired
    private ServiceRepository serviceRepository;

    public List<CareService> getAllServices() { return serviceRepository.findAll(); }

    public CareService getServiceById(Integer id) { return serviceRepository.findById(id).orElse(null); }

    public CareService createService(CareService service) { return serviceRepository.save(service); }

    public CareService updateService(Integer id, CareService updated) {
        return serviceRepository.findById(id).map(s -> {
            s.setServiceName(updated.getServiceName());
            s.setDescription(updated.getDescription());
            s.setPricePerDay(updated.getPricePerDay());
            s.setIsActive(updated.getIsActive());
            return serviceRepository.save(s);
        }).orElse(null);
    }

    public boolean deleteService(Integer id) {
        if(serviceRepository.existsById(id)) {
            serviceRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
