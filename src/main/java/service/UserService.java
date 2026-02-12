package service;

import at.favre.lib.crypto.bcrypt.BCrypt;
import model.User;
import repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    
    private static final String PEPPER = "MySuperSecretPepper123!";
    private static final int COST_FACTOR = 12;

    // ===== PASSWORD SECURITY METHODS =====
    
    private String hashPassword(String plainPassword) {
        return BCrypt.withDefaults()
            .hashToString(COST_FACTOR, (plainPassword + PEPPER).toCharArray());
    }
    
    private boolean verifyPassword(String plainPassword, String hashedPassword) {
        BCrypt.Result result = BCrypt.verifyer()
            .verify((plainPassword + PEPPER).toCharArray(), hashedPassword);
        return result.verified;
    }
    
    public boolean authenticate(String email, String plainPassword) {
        User user = getUserByEmail(email);
        return user != null && verifyPassword(plainPassword, user.getPassword());
    }

    // ===== USER CRUD METHODS =====

    public List<User> getAllUsers() { 
        return userRepository.findAll(); 
    }

    public User getUserById(Integer id) { 
        return userRepository.findById(id).orElse(null); 
    }

    public User getUserByEmail(String email) { 
        return userRepository.findByEmail(email).orElse(null); 
    }

    @Transactional
    public User createUser(User user) {
        // Hash password before saving
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(hashPassword(user.getPassword()));
        }
        return userRepository.save(user);
    }

    @Transactional
    public User updateUser(Integer id, User updated) {
        return userRepository.findById(id).map(u -> {
            u.setName(updated.getName());
            u.setEmail(updated.getEmail());
            u.setAddress(updated.getAddress());
            u.setRole(updated.getRole());
            
            // Only update password if provided
            if (updated.getPassword() != null && !updated.getPassword().isEmpty()) {
                u.setPassword(hashPassword(updated.getPassword()));
            }
            
            return userRepository.save(u);
        }).orElse(null);
    }
    
    @Transactional
    public User updateUserBasicInfo(User user) {
        return userRepository.findById(user.getCustomerId()).map(u -> {
            u.setName(user.getName());
            u.setAddress(user.getAddress());
            // Password NOT updated here
            return userRepository.save(u);
        }).orElse(null);
    }

    @Transactional
    public boolean deleteUser(Integer id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
    
    public boolean isEmailExists(String email) {
        return userRepository.findByEmail(email).isPresent();
    }
}