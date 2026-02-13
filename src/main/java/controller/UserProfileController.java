package controller;

import model.User;
import model.UserProfile;
import service.UserProfileService;
import service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Controller
@RequestMapping("/profile")
public class UserProfileController {
    
    @Autowired
    private UserProfileService userProfileService;
    
    @Autowired
    private UserService userService;
    
    // ===== PROFILE PAGE =====
    @GetMapping
    public String viewProfile(HttpSession session, Model model) {
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        User user = userService.getUserById(customerId);
        UserProfile profile = userProfileService.getProfileByCustomerId(customerId);
        
        model.addAttribute("user", user);
        model.addAttribute("profile", profile != null ? profile : new UserProfile());
        
        return "profile/profile"; // This maps to /WEB-INF/jsp/profile/profile.jsp
    }
    
    // ===== HEALTH PROFILE PAGE =====
    @GetMapping("/health")
    public String healthProfile(HttpSession session, Model model) {
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        UserProfile profile = userProfileService.getProfileByCustomerId(customerId);
        model.addAttribute("profile", profile != null ? profile : new UserProfile());
        
        return "profile/healthProfile"; // This maps to /WEB-INF/jsp/profile/healthProfile.jsp
    }
    
    // ===== UPDATE PROFILE =====
    @PostMapping("/update")
    public String updateUserInfo(@RequestParam String username,
                                @RequestParam String address,
                                @RequestParam(required = false) String password,
                                HttpSession session,
                                RedirectAttributes redirectAttributes) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        try {
            User user = userService.getUserById(customerId);
            user.setName(username);
            user.setAddress(address);
            
            if (password != null && !password.trim().isEmpty()) {
                user.setPassword(password);
                userService.updateUser(customerId, user);
            } else {
                userService.updateUserBasicInfo(user);
            }
            
            // Update session
            session.setAttribute("sessCustomerName", username);
            session.setAttribute("sessCustomerAddress", address);
            
            redirectAttributes.addAttribute("success", "updated");
        } catch (Exception e) {
            redirectAttributes.addAttribute("errCode", "updateFail");
        }
        
        return "redirect:/profile";
    }
    
    // ===== UPDATE HEALTH PROFILE =====
    @PostMapping("/health/update")
    public String updateHealthProfile(@ModelAttribute UserProfile profile,
                                     HttpSession session,
                                     RedirectAttributes redirectAttributes) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        try {
            profile.setCustomerId(customerId);
            userProfileService.createOrUpdateProfile(profile);
            redirectAttributes.addAttribute("success", "healthUpdated");
        } catch (Exception e) {
            redirectAttributes.addAttribute("errCode", "healthUpdateFail");
        }
        
        return "redirect:/profile/health";
    }
    
    // ===== DELETE ACCOUNT =====
    @PostMapping("/delete")
    public String deleteAccount(HttpSession session,
                               RedirectAttributes redirectAttributes) {
        
        Integer customerId = (Integer) session.getAttribute("sessCustomerId");
        if (customerId == null) {
            return "redirect:/login?errCode=notLoggedIn";
        }
        
        try {
            userService.deleteUser(customerId);
            session.invalidate();
            return "redirect:/homepage";
        } catch (Exception e) {
            return "redirect:/profile";
        }
    }
}