package service;

import model.Caregiver;
import repository.CaregiverRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class CaregiverService {

    @Autowired
    private CaregiverRepository caregiverRepository;

    public List<Caregiver> getAllCaregivers() { return caregiverRepository.findAll(); }

    public Caregiver getCaregiverById(Integer id) { return caregiverRepository.findById(id).orElse(null); }

    public Caregiver createCaregiver(Caregiver caregiver) { return caregiverRepository.save(caregiver); }

    public Caregiver updateCaregiver(Integer id, Caregiver updated) {
        return caregiverRepository.findById(id).map(c -> {
            c.setName(updated.getName());
            c.setEmail(updated.getEmail());
            c.setPhone(updated.getPhone());
            c.setRating(updated.getRating());
            c.setIsActive(updated.getIsActive());
            return caregiverRepository.save(c);
        }).orElse(null);
    }

    public boolean deleteCaregiver(Integer id) {
        if(caregiverRepository.existsById(id)) {
            caregiverRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
