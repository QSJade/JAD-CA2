package controller;

import model.User;
import service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public List<User> getAllUsers() { return userService.getAllUsers(); }

    @GetMapping("/{id}")
    public User getUser(@PathVariable Integer id) { return userService.getUserById(id); }

    @PostMapping
    public User createUser(@RequestBody User user) { return userService.createUser(user); }

    @PutMapping("/{id}")
    public User updateUser(@PathVariable Integer id, @RequestBody User updated) {
        return userService.updateUser(id, updated);
    }

    @DeleteMapping("/{id}")
    public boolean deleteUser(@PathVariable Integer id) { return userService.deleteUser(id); }
}
