<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.io.*, java.nio.file.*, java.util.UUID" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add New Service</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    body { font-family: Arial; background: #f7f7f7; margin: 0; }
    .main-content {
        display: flex; justify-content: center; align-items: flex-start;
        padding: 40px 0; min-height: calc(100vh - 100px);
    }
    .form-container {
        background: #fff; padding: 30px 40px; border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 500px; max-width: 90%;
    }
    .form-group { margin-bottom: 20px; }
    .form-group label { 
        display: block; 
        font-size: 14px; 
        margin-bottom: 5px; 
        font-weight: bold; 
        color: #2c8a3e; 
    }
    .form-group input, .form-group textarea {
        width: 100%; 
        padding: 10px; 
        border: 1px solid #ccc; 
        border-radius: 5px;
        font-size: 14px;
    }
    .form-group textarea {
        min-height: 100px;
        resize: vertical;
    }
    .image-preview {
        margin-top: 15px;
        text-align: center;
        display: none;
    }
    .image-preview img {
        max-width: 200px;
        max-height: 150px;
        border-radius: 5px;
        border: 2px solid #2c8a3e;
    }
    .btn-add { 
        background: #2c8a3e; 
        color: #fff; 
        border: none; 
        padding: 12px 30px; 
        border-radius: 5px; 
        cursor: pointer; 
        font-size: 16px;
    }
    .btn-add:hover { background: #1f6a2f; }
    .btn-cancel { 
        background: #6c757d; 
        color: white; 
        padding: 12px 30px; 
        border-radius: 5px; 
        text-decoration: none; 
        display: inline-block;
    }
    .btn-cancel:hover { background: #5a6268; }
    .msg { 
        margin-bottom: 20px; 
        font-weight: bold; 
        text-align: center; 
        padding: 10px;
        border-radius: 5px;
    }
    .success { background: #d4edc9; color: #2c8a3e; }
    .error { background: #f8d7da; color: #721c24; }
</style>
</head>
<body>

<%@ include file="../header.jsp" %>

<%
String userRole = (String) session.getAttribute("sessUserRole");
if (!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=unauthorized");
    return;
}

// ===== PROCESS FORM SUBMISSION =====
String submit = request.getParameter("submit");
if (submit != null) {
    String serviceName = request.getParameter("serviceName");
    String serviceDetails = request.getParameter("serviceDetails");
    String price = request.getParameter("price");
    
    // Handle file upload
    String imageUrl = null;
    Part filePart = request.getPart("serviceImage");
    
    // Write the url to submit into db
if (filePart != null && filePart.getSize() > 0) {
    String contentType = filePart.getContentType();
    if (contentType.startsWith("image/")) {
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Get file extension without . 
        /*
        String fileName = "service_image.jpg"                     
        lastDot = 14 (position of '.')                          
		fileName.substring(lastDot)     → ".jpg"  (includes dot)
		fileName.substring(lastDot + 1) → "jpg"   (skips dot)
        */
        String extension = "";
        int lastDot = fileName.lastIndexOf(".");
        if (lastDot > 0) {
            extension = fileName.substring(lastDot + 1);
        } else {
            extension = "jpg"; // default extension
        }
        
        String uniqueFileName = "service_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + extension;
        
        String uploadPath = application.getRealPath("/") + "uploads/services/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        
        String filePath = uploadPath + uniqueFileName;
        filePart.write(filePath);
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
            sql = "INSERT INTO services (service_name, description, price_per_day, image_url, is_active, created_at) VALUES (?, ?, ?, ?, TRUE, NOW())";
            ps = conn.prepareStatement(sql);
            ps.setString(1, serviceName);
            ps.setString(2, serviceDetails);
            ps.setBigDecimal(3, new java.math.BigDecimal(price));
            ps.setString(4, imageUrl);
        } else {
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
            out.println("<div class='msg success'>✓ Service added successfully!</div>");
        } else {
            out.println("<div class='msg error'>Failed to add service.</div>");
        }
        
    } catch (Exception e) {
        out.println("<div class='msg error'>Error: " + e.getMessage() + "</div>");
    }
}
%>

<div class="main-content">
    <div class="form-container">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">➕ Add New Service</h2>

        <form action="${pageContext.request.contextPath}/admin/addServiceBackend" method="post" enctype="multipart/form-data">
            <input type="hidden" name="submit" value="1">
            
            <div class="form-group">
                <label>Service Name:</label>
                <input type="text" name="serviceName" placeholder="e.g., In-Home Care" required>
            </div>

            <div class="form-group">
                <label>Description:</label>
                <textarea name="serviceDetails" placeholder="Describe what this service offers..." required></textarea>
            </div>

            <div class="form-group">
                <label>Price Per Day ($):</label>
                <input type="number" name="price" step="0.01" placeholder="0.00" required>
            </div>

            <!-- ===== IMAGE UPLOAD SECTION ===== -->
            <div class="form-group">
                <label>Service Image (Optional):</label>
                <input type="file" name="serviceImage" accept="image/*" id="imageUpload">
                <small style="display: block; color: #666; margin-top: 5px;">
                    Accepted formats: JPG, PNG, GIF (Max size: 5MB)
                </small>
                
                <!-- Image preview -->
                <div id="imagePreview" class="image-preview">
                    <p style="margin-bottom: 5px; color: #666;">Preview:</p>
                    <img id="previewImg" src="#" alt="Preview">
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; margin-top: 30px;">
                <button type="submit" class="btn-add">✅ Add Service</button>
                <a href="${pageContext.request.contextPath}/adminService" class="btn-cancel">↩ Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
// Image preview functionality
document.getElementById('imageUpload').addEventListener('change', function(e) {
    const preview = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    const file = e.target.files[0];
    
    if (file) {
        // Check file size (5MB limit)
        if (file.size > 5 * 1024 * 1024) {
            alert('File size must be less than 5MB');
            this.value = '';
            preview.style.display = 'none';
            return;
        }
        
        // Check file type
        if (!file.type.match('image.*')) {
            alert('Please select an image file');
            this.value = '';
            preview.style.display = 'none';
            return;
        }
        
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            preview.style.display = 'block';
        }
        reader.readAsDataURL(file);
    } else {
        preview.style.display = 'none';
    }
});
</script>

<%@ include file="../footer.jsp" %>

</body>
</html>