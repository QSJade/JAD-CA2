package controller;

import model.CareService;
import service.CareServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/b2b")
@CrossOrigin(origins = "*") // Allows external websites to call this API
public class B2BServiceController {

    @Autowired
    private CareServiceService careServiceService; // Service to fetch data from database

    /**
     * GET /api/b2b/services - Get all services, optionally filtered by category
     * 
     * Step 1: Client calls this URL (e.g., GET /api/b2b/services?category=HOME_CARE)
     * Step 2: Controller receives request with optional category parameter
     * Step 3: Fetches all active services from database via CareServiceService
     * Step 4: Filters services by category if parameter was provided
     * Step 5: Converts database entities to DTOs (controls what data is exposed)
     * Step 6: Wraps response in standard format with success flag, timestamp, etc.
     * Step 7: Returns JSON to client
     */
    @GetMapping("/services")
    public ApiResponse<List<ServiceDTO>> getServices(
            @RequestParam(required = false) String category) {
        
        // Step 1: Get all active services from database
        List<CareService> services = careServiceService.getAllServices();
        
        // Step 2: Filter by category if provided (e.g., only HOME_CARE)
        if (category != null && !category.isEmpty()) {
            services = services.stream()
                .filter(service -> {
                    // Check if service name contains the category keyword
                    String serviceName = service.getServiceName().toLowerCase();
                    String cat = category.toLowerCase();
                    
                    if (cat.contains("home")) return serviceName.contains("home");
                    if (cat.contains("meal")) return serviceName.contains("meal");
                    if (cat.contains("transport")) return serviceName.contains("transport");
                    return true;
                })
                .collect(Collectors.toList());
        }
        
        // Step 3: Convert CareService entities to ServiceDTOs
        // This prevents exposing internal database fields
        List<ServiceDTO> dtos = services.stream()
            .map(ServiceDTO::new)
            .collect(Collectors.toList());
        
        // Step 4: Return success response with data
        return ApiResponse.success(dtos);
    }

    /**
     * GET /api/b2b/services/{id} - Get a single service by ID
     * 
     * Step 1: Client calls URL with specific ID (e.g., GET /api/b2b/services/1)
     * Step 2: Controller extracts ID from URL path
     * Step 3: Fetches service from database by ID
     * Step 4: If found, converts to DTO and returns success
     * Step 5: If not found, returns error message
     */
    @GetMapping("/services/{id}")
    public ApiResponse<ServiceDTO> getServiceById(@PathVariable Integer id) {
        
        // Step 1: Try to find service in database
        CareService service = careServiceService.getServiceById(id);
        
        // Step 2: Check if service exists
        if (service == null) {
            return ApiResponse.error("Service not found");
        }
        
        // Step 3: Convert to DTO and return
        return ApiResponse.success(new ServiceDTO(service));
    }
}

/**
 * ServiceDTO - Data Transfer Object
 * Step 1: Client requests data
 * Step 2: Controller gets CareService entity from database
 * Step 3: Creates ServiceDTO from CareService entity
 * Step 4: Only fields in this class are sent to client
 */
class ServiceDTO {
    private Integer serviceId;      // Unique ID
    private String serviceName;     // Display name (e.g., "In-Home Care")
    private String description;     // What the service offers
    private Double pricePerDay;     // Cost per day
    private Boolean isActive;       // Whether service is currently offered
    private String category;        // HOME_CARE, MEAL_SUPPORT, TRANSPORTATION, OTHER

    public ServiceDTO() {} 

    /**
     * DTO - Data Transfer Object = Talks to client (has JSON fields) 
     * Convert CareService entity to DTO
     * Step 1: Take database entity
     * Step 2: Copy only the fields we want to expose
     * Step 3: Determine category based on service name
     */
    public ServiceDTO(CareService service) {
        this.serviceId = service.getServiceId();
        this.serviceName = service.getServiceName();
        this.description = service.getDescription();
        this.pricePerDay = service.getPricePerDay();
        this.isActive = service.getIsActive();
        this.category = determineCategory(service.getServiceName());
    }

// Check category
    private String determineCategory(String serviceName) {
        String name = serviceName.toLowerCase();
        if (name.contains("home")) return "HOME_CARE";
        if (name.contains("meal")) return "MEAL_SUPPORT";
        if (name.contains("transport")) return "TRANSPORTATION";
        return "OTHER";
    }

    // ===== GETTERS AND SETTERS =====
    public Integer getServiceId() { return serviceId; }
    public void setServiceId(Integer serviceId) { this.serviceId = serviceId; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Double getPricePerDay() { return pricePerDay; }
    public void setPricePerDay(Double pricePerDay) { this.pricePerDay = pricePerDay; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}

// Creates ApiResponse object and returns to client as JSON
class ApiResponse<T> {
    private boolean success;      // true = worked, false = failed
    private String message;       // "Success" or error description
    private T data;              // The actual data (service list or single service)
    private LocalDateTime timestamp; // When this response was created
    private int count;          // Number of items in data (for lists)

    public ApiResponse() {
        this.timestamp = LocalDateTime.now();
    }

    private ApiResponse(boolean success, String message, T data) {
        this();
        this.success = success;
        this.message = message;
        this.data = data;
        
        // Calculate count based on data type
        if (data instanceof List) {
            this.count = ((List<?>) data).size();
        } else if (data != null) {
            this.count = 1;
        } else {
            this.count = 0;
        }
    }

    // Success 
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, "Success", data);
    }

    // Error message
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null);
    }

    // ===== GETTERS AND SETTERS =====
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }
}