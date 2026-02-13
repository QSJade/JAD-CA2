<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, java.util.UUID" %>
<%
request.setCharacterEncoding("UTF-8");

// Check if admin
String userRole = (String) session.getAttribute("sessUserRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=unauthorized");
    return;
}

// Get form parameters
String serviceName = request.getParameter("serviceName");
String serviceDetails = request.getParameter("serviceDetails");
String price = request.getParameter("price");

// Validate required fields
if (serviceName == null || serviceDetails == null || price == null ||
    serviceName.isEmpty() || serviceDetails.isEmpty() || price.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/admin/addService?errCode=missingFields");
    return;
}

// Handle file upload
String imageUrl = null;
Part filePart = request.getPart("serviceImage");

if (filePart != null && filePart.getSize() > 0) {
    String contentType = filePart.getContentType();
    if (contentType.startsWith("image/")) {
        // Get original filename
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Get file extension
        String extension = "";
        int lastDot = fileName.lastIndexOf(".");
        if (lastDot > 0) {
            extension = fileName.substring(lastDot + 1);
        } else {
            extension = "jpg"; // default extension
        }
        
        // Generate unique filename
        String uniqueFileName = "service_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + extension;
        
        // Set upload path - creates folder in your webapp
        String uploadPath = application.getRealPath("/") + "uploads/services/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // Save file
        String filePath = uploadPath + uniqueFileName;
        filePart.write(filePath);
        
        // Set image URL for database (relative path)
        imageUrl = "uploads/services/" + uniqueFileName;
    }
}

// Insert into database
try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);
    
    String sql;
    PreparedStatement ps;
    
    if (imageUrl != null) {
        // Insert with image
        sql = "INSERT INTO services (service_name, description, price_per_day, image_url, is_active, created_at) VALUES (?, ?, ?, ?, TRUE, NOW())";
        ps = conn.prepareStatement(sql);
        ps.setString(1, serviceName);
        ps.setString(2, serviceDetails);
        ps.setBigDecimal(3, new java.math.BigDecimal(price));
        ps.setString(4, imageUrl);
    } else {
        // Insert without image
        sql = "INSERT INTO services (service_name, description, price_per_day, is_active, created_at) VALUES (?, ?, ?, TRUE, NOW())";
        ps = conn.prepareStatement(sql);
        ps.setString(1, serviceName);
        ps.setString(2, serviceDetails);
        ps.setBigDecimal(3, new java.math.BigDecimal(price));
    }
    
    int rows = ps.executeUpdate();
    ps.close();
    conn.close();
    
    if (rows > 0) {
        // Success - redirect to admin service page with success message
        response.sendRedirect(request.getContextPath() + "/adminService?msg=added");
    } else {
        // Failed - redirect back to add form with error
        response.sendRedirect(request.getContextPath() + "/admin/addService?errCode=insertFailed");
    }
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/admin/addService?errCode=error");
}
%>