/*
 * -------------------------------------------------------
 * Author(s): Jade
 * Date: 19/1/2025
 * Description:
 * REST Controller for managing customer-related operations
 * such as retrieve, create, update, and delete users.
 * -------------------------------------------------------
 */
package controller;

import model.User;
import model.ProfileDAO;

import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/users")
public class UserController {

    // ================= GET USER BY ID =================
    @GetMapping("/{customerId}")
    public User getUser(@PathVariable int customerId) {

        User user = null;

        try {
            ProfileDAO db = new ProfileDAO();
            user = db.getUserDetails(customerId);
        } catch (Exception e) {
            System.out.println("Error in getUser(): " + e);
        }

        return user;
    }

    // ================= GET ALL USERS =================
    @GetMapping
    public List<User> getAllUsers() {

        List<User> userList = new ArrayList<>();

        try {
            ProfileDAO db = new ProfileDAO();
            userList = db.getAllUsers();

            System.out.println("Retrieved " + userList.size() + " users");

        } catch (Exception e) {
            System.err.println("Error in getAllUsers(): " + e);
            e.printStackTrace();
        }

        return userList;
    }

    // ================= CREATE USER =================
    @PostMapping(consumes = "application/json")
    public int createUser(@RequestBody User user) {

        int rec = 0;

        try {
            ProfileDAO db = new ProfileDAO();
            rec = db.insertUser(user);
            System.out.println("User created, rows affected: " + rec);

        } catch (Exception e) {
            System.out.println("Error in createUser(): " + e);
        }

        return rec;
    }

    // ================= UPDATE USER =================
    @PutMapping(value = "/{customerId}", consumes = "application/json")
    public int updateUser(@PathVariable int customerId,
                          @RequestBody User user) {

        int rec = 0;

        try {
            ProfileDAO db = new ProfileDAO();
            rec = db.updateUser(customerId, user);
            System.out.println("User updated, rows affected: " + rec);

        } catch (Exception e) {
            System.out.println("Error in updateUser(): " + e);
        }

        return rec;
    }

    // ================= DELETE USER =================
    @DeleteMapping("/{customerId}")
    public int deleteUser(@PathVariable int customerId) {

        int rec = 0;

        try {
            ProfileDAO db = new ProfileDAO();
            rec = db.deleteUser(customerId);
            System.out.println("User deleted, rows affected: " + rec);

        } catch (Exception e) {
            System.out.println("Error in deleteUser(): " + e);
        }

        return rec;
    }
}
