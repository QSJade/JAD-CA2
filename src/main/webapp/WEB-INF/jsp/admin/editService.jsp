<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Service</title>
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
    .current-image {
        margin: 15px 0;
        padding: 15px;
        background: #f8f9fa;
        border-radius: 5px;
        text-align: center;
    }
    .current-image img {
        max-width: 200px;
        max-height: 150px;
        border-radius: 5px;
        border: 1px solid #ddd;
    }
    .image-preview {
        margin-top: 10px;
        text-align: center;
        display: none;
    }
    .image-preview img {
        max-width: 200px;
        max-height: 150px;
        border-radius: 5px;
        border: 2px solid #2c8a3e;
    }
    .btn-save { 
        background: #2c8a3e; 
        color: #fff; 
        border: none; 
        padding: 12px 30px; 
        border-radius: 5px; 
        cursor: pointer; 
        font-size: 16px;
    }
    .btn-save:hover { background: #1f6a2f; }
    .btn-cancel { 
        background: #6c757d; 
        color: white; 
        padding: 12px 30px; 
        border-radius: 5px; 
        text-decoration: none; 
        display: inline-block;
    }
    .btn-cancel:hover { background: #5a6268; }
    .btn-remove {
        background: #dc3545;
        color: white;
        padding: 5px 10px;
        border: none;
        border-radius: 3px;
        cursor: pointer;
        font-size: 12px;
        margin-top: 10px;
    }
    .btn-remove:hover { background: #c82333; }
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

String id = request.getParameter("id");
String serviceName = "";
String description = "";
String price = "";
String imageUrl = "";

if (id != null && !id.isEmpty()) {
    try {
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        Connection conn = DriverManager.getConnection(connURL);

        String sql = "SELECT service_name, description, price_per_day, image_url FROM services WHERE service_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(id));

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            serviceName = rs.getString("service_name");
            description = rs.getString("description");
            price = rs.getString("price_per_day");
            imageUrl = rs.getString("image_url") != null ? rs.getString("image_url") : "";
        }

        rs.close(); 
        ps.close(); 
        conn.close();

    } catch(Exception e) {
        out.print("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
} else {
    response.sendRedirect(request.getContextPath() + "/admin/selectServiceToEdit");
    return;
}
%>

<div class="main-content">
    <div class="form-container">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">✏️ Edit Service</h2>
        
        <div style="background: #f8f9fa; padding: 10px; border-radius: 5px; margin-bottom: 20px;">
            <strong>Service ID:</strong> <%= id %>
        </div>

        <!-- IMPORTANT: enctype="multipart/form-data" is required for file upload -->
        <form action="${pageContext.request.contextPath}/admin/editServiceBackend" method="post" enctype="multipart/form-data">
            <input type="hidden" name="id" value="<%= id %>">

            <div class="form-group">
                <label>📋 Service Name:</label>
                <input type="text" name="serviceName" value="<%= serviceName %>" required>
            </div>

            <div class="form-group">
                <label>📝 Description:</label>
                <textarea name="serviceDetails" rows="4" required><%= description %></textarea>
            </div>

            <div class="form-group">
                <label>💰 Price Per Day ($):</label>
                <input type="number" name="price" step="0.01" value="<%= price %>" required>
            </div>

            <!-- ===== IMAGE UPLOAD SECTION ===== -->
            <div class="form-group">
                <label>🖼️ Service Image:</label>
                
                <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
                    <div class="current-image">
                        <p style="margin-bottom: 10px; color: #666;">Current Image:</p>
                        <img src="${pageContext.request.contextPath}/<%= imageUrl %>" alt="Service image" onerror="this.style.display='none'">
                        <div style="margin-top: 10px;">
                            <label style="display: flex; align-items: center; justify-content: center; gap: 5px;">
                                <input type="checkbox" name="removeImage" value="yes"> Remove current image
                            </label>
                        </div>
                    </div>
                <% } %>
                
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
                <button type="submit" class="btn-save">💾 Save Changes</button>
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