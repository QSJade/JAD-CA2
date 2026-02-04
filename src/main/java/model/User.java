package model;

public class User {

    private int customerId;  
    private String name;
    private String email;
    private String address;
    private String password;
    private String role;     

    // =================== customerId ===================
    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    // =================== name ===================
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    // =================== email ===================
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // =================== address ===================
    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    // =================== password ===================
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    // =================== role ===================
    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }
}
