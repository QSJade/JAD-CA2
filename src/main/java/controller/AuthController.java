package controller;

import model.User;
import service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
public class AuthController {
    
    @Autowired
    private UserService userService;
    
    @PostMapping("/verifyUser")
    public void verifyUser(@RequestParam String email,
                          @RequestParam String password,
                          HttpSession session,
                          HttpServletResponse response) throws IOException {
        
        User user = userService.getUserByEmail(email);
        
        if (user != null && userService.authenticate(email, password)) {
            // Set session attributes
            session.setAttribute("sessCustomerId", user.getCustomerId());
            session.setAttribute("sessCustomerName", user.getName());
            session.setAttribute("sessCustomerEmail", user.getEmail());
            session.setAttribute("sessCustomerAddress", user.getAddress());
            session.setAttribute("sessUserRole", user.getRole());
            
            response.sendRedirect("homepage");
        } else {
            response.sendRedirect("login?errCode=invalidLogin");
        }
    }
    
    @PostMapping("/registerUser")
    public void registerUser(@RequestParam String name,
                            @RequestParam String email,
                            @RequestParam String password,
                            @RequestParam String address,
                            @RequestParam(required = false) String saveAddress,
                            HttpServletResponse response) throws IOException {
        
        // Check if email already exists
        if (userService.isEmailExists(email)) {
            response.sendRedirect("register?errCode=duplicateEmail");
            return;
        }
        
        try {
            User user = new User();
            user.setName(name);
            user.setEmail(email);
            user.setPassword(password); // Will be hashed in createUser
            user.setRole("customer");
            
            if ("yes".equals(saveAddress)) {
                user.setAddress(address);
            }
            
            userService.createUser(user);
            response.sendRedirect("login?success=registered");
            
        } catch (Exception e) {
            response.sendRedirect("register?errCode=registrationFailed");
        }
    }
    
    @GetMapping("/logout")
    public void logout(HttpSession session, HttpServletResponse response) throws IOException {
        session.invalidate();
        response.sendRedirect("homepage");
    }
}