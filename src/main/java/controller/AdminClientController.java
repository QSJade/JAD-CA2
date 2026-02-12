package controller;

import model.User;
import model.UserProfile;
import service.UserService;
import service.UserProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import jakarta.servlet.http.HttpSession;

import java.util.List;
import java.util.ArrayList;

@Controller
@RequestMapping("/admin/clients")
public class AdminClientController {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private UserProfileService userProfileService;
    
    // ===== CLIENT LISTING =====
    @GetMapping
    public String listAllClients(Model model, HttpSession session) {
        // Check admin access
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<User> allUsers = userService.getAllUsers();
        // Filter only customers (not admins)
        List<User> customers = new ArrayList<>();
        for (User user : allUsers) {
            if ("customer".equals(user.getRole())) {
                customers.add(user);
            }
        }
        
        model.addAttribute("clients", customers);
        return "admin/clientList";
    }
    
    // ===== CLIENT DETAILS =====
    @GetMapping("/{id}")
    public String viewClient(@PathVariable Integer id, Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        User user = userService.getUserById(id);
        UserProfile profile = userProfileService.getProfileByCustomerId(id);
        
        model.addAttribute("client", user);
        model.addAttribute("profile", profile != null ? profile : new UserProfile());
        
        return "admin/clientDetail";
    }
    
    // ===== EDIT CLIENT FORM =====
    @GetMapping("/{id}/edit")
    public String editClientForm(@PathVariable Integer id, Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        User user = userService.getUserById(id);
        UserProfile profile = userProfileService.getProfileByCustomerId(id);
        
        model.addAttribute("client", user);
        model.addAttribute("profile", profile != null ? profile : new UserProfile());
        
        return "admin/clientEdit";
    }
    
    // ===== UPDATE CLIENT =====
    @PostMapping("/{id}/update")
    public String updateClient(@PathVariable Integer id,
                              @ModelAttribute User user,
                              @ModelAttribute UserProfile profile,
                              RedirectAttributes redirectAttributes,
                              HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        try {
            // Update basic user info
            user.setCustomerId(id);
            user.setRole("customer");
            userService.updateUser(id, user);
            
            // Update health profile
            profile.setCustomerId(id);
            userProfileService.createOrUpdateProfile(profile);
            
            redirectAttributes.addFlashAttribute("successMessage", "Client updated successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Update failed: " + e.getMessage());
        }
        
        return "redirect:/admin/clients/" + id;
    }
    
    // ===== DELETE CLIENT =====
    @PostMapping("/{id}/delete")
    public String deleteClient(@PathVariable Integer id,
                              RedirectAttributes redirectAttributes,
                              HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        try {
            userService.deleteUser(id);
            redirectAttributes.addFlashAttribute("successMessage", "Client deleted successfully");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "Delete failed: " + e.getMessage());
        }
        
        return "redirect:/admin/clients";
    }
    
    // ===== CLIENT INQUIRY & REPORTING =====
    
    @GetMapping("/search")
    public String searchClients(@RequestParam(required = false) String keyword,
                               @RequestParam(required = false) String searchType,
                               Model model, HttpSession session) {
        
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<UserProfile> results = new ArrayList<>();
        String searchDescription = "";
        
        if (keyword != null && !keyword.isEmpty()) {
            searchDescription = "Search results for: " + keyword;
            
            if ("health".equals(searchType)) {
                results = userProfileService.searchClientsByHealthCondition(keyword);
                searchDescription = "Clients with health condition: " + keyword;
            } else if ("dietary".equals(searchType)) {
                results = userProfileService.searchClientsByDietaryRestriction(keyword);
                searchDescription = "Clients with dietary restriction: " + keyword;
            } else if ("emergency".equals(searchType)) {
                results = userProfileService.searchClientsByEmergencyContact(keyword);
                searchDescription = "Clients with emergency contact: " + keyword;
            }
        }
        
        model.addAttribute("searchResults", results);
        model.addAttribute("searchDescription", searchDescription);
        model.addAttribute("keyword", keyword);
        model.addAttribute("searchType", searchType);
        
        return "admin/clientSearchResults";
    }
    
    @GetMapping("/reports/wheelchair")
    public String wheelchairClients(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<UserProfile> profiles = userProfileService.getClientsWhoUseWheelchair();
        model.addAttribute("profiles", profiles);
        model.addAttribute("reportTitle", "Clients Who Use Wheelchairs");
        model.addAttribute("reportCount", profiles.size());
        
        return "admin/clientReport";
    }
    
    @GetMapping("/reports/pets")
    public String clientsWithPets(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<UserProfile> profiles = userProfileService.getClientsWithPets();
        model.addAttribute("profiles", profiles);
        model.addAttribute("reportTitle", "Clients With Pets");
        model.addAttribute("reportCount", profiles.size());
        
        return "admin/clientReport";
    }
    
    @GetMapping("/reports/smokers")
    public String smokers(Model model, HttpSession session) {
        String role = (String) session.getAttribute("sessUserRole");
        if (!"admin".equals(role)) {
            return "redirect:/login?errCode=unauthorized";
        }
        
        List<UserProfile> profiles = userProfileService.getSmokers();
        model.addAttribute("profiles", profiles);
        model.addAttribute("reportTitle", "Clients Who Smoke");
        model.addAttribute("reportCount", profiles.size());
        
        return "admin/clientReport";
    }
}