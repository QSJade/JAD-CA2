package service;

import model.UserProfile;
import repository.UserProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserProfileService {

    @Autowired
    private UserProfileRepository userProfileRepository;

    public List<UserProfile> getAllProfiles() {
        return userProfileRepository.findAll();
    }

    public UserProfile getProfileById(Integer id) {
        return userProfileRepository.findById(id).orElse(null);
    }

    public UserProfile createProfile(UserProfile profile) {
        return userProfileRepository.save(profile);
    }

    public UserProfile updateProfile(Integer id, UserProfile updated) {
        return userProfileRepository.findById(id).map(p -> {
            p.setHasPets(updated.getHasPets());
            p.setHealthConditions(updated.getHealthConditions());
            p.setUsesWheelchair(updated.getUsesWheelchair());
            p.setIsSmoker(updated.getIsSmoker());
            p.setDietaryRestrictions(updated.getDietaryRestrictions());
            p.setMedicationRestrictions(updated.getMedicationRestrictions());
            p.setOtherInfo(updated.getOtherInfo());
            return userProfileRepository.save(p);
        }).orElse(null);
    }

    public boolean deleteProfile(Integer id) {
        if(userProfileRepository.existsById(id)) {
            userProfileRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
