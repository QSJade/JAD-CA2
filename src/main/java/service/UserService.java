package service;

import model.User;
import repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public List<User> getAllUsers() { return userRepository.findAll(); }

    public User getUserById(Integer id) { return userRepository.findById(id).orElse(null); }

    public User getUserByEmail(String email) { return userRepository.findByEmail(email).orElse(null); }

    public User createUser(User user) { return userRepository.save(user); }

    public User updateUser(Integer id, User updated) {
        return userRepository.findById(id).map(u -> {
            u.setName(updated.getName());
            u.setEmail(updated.getEmail());
            u.setPassword(updated.getPassword());
            u.setAddress(updated.getAddress());
            u.setRole(updated.getRole());
            return userRepository.save(u);
        }).orElse(null);
    }

    public boolean deleteUser(Integer id) {
        if(userRepository.existsById(id)) {
            userRepository.deleteById(id);
            return true;
        }
        return false;
    }
}
