<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Select Service to Edit</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .select-container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 20px;
    }
    .select-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    .service-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 20px;
        margin-top: 20px;
    }
    .service-card {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 20px;
        transition: transform 0.2s;
        display: flex;
        flex-direction: column;
    }
    .service-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 20px rgba(44, 138, 62, 0.2);
    }
    .service-name {
        font-size: 20px;
        font-weight: bold;
        color: #2c8a3e;
        margin-bottom: 10px;
    }
    .service-description {
        color: #666;
        font-size: 14px;
        margin-bottom: 15px;
        flex-grow: 1;
    }
    .service-price {
        font-size: 18px;
        font-weight: bold;
        color: #2c8a3e;
        margin-bottom: 15px;
    }
    .service-status {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        margin-bottom: 15px;
        align-self: flex-start;
    }
    .status-active {
        background: #d4edc9;
        color: #2c8a3e;
    }
    .status-inactive {
        background: #f8d7da;
        color: #721c24;
    }
    .btn-select {
        background: #2c8a3e;
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        text-decoration: none;
        text-align: center;
        font-weight: bold;
        transition: background 0.2s;
    }
    .btn-select:hover {
        background: #1f6a2f;
    }
    .btn-back {
        background: #6c757d;
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        text-decoration: none;
    }
    .btn-back:hover {
        background: #5a6268;
    }
    .search-box {
        margin-bottom: 30px;
        display: flex;
        gap: 10px;
    }
    .search-box input {
        flex: 1;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 16px;
    }
    .search-box button {
        padding: 10px 20px;
        background: #2c8a3e;
        color: white;
        border: none;
        border-radius: 5px;
        cursor: pointer;
    }
    .no-results {
        text-align: center;
        padding: 60px;
        background: white;
        border-radius: 10px;
        color: #666;
    }
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

String searchTerm = request.getParameter("search");
if (searchTerm == null) searchTerm = "";
%>

<div class="select-container">
    <div class="select-header">
        <h1>✏️ Select Service to Edit</h1>
        <a href="${pageContext.request.contextPath}/adminService" class="btn-back">← Back to Dashboard</a>
    </div>
    
    <!-- Search Box -->
    <div class="search-box">
        <form method="get" action="${pageContext.request.contextPath}/admin/selectServiceToEdit" style="display: flex; gap: 10px; width: 100%;">
            <input type="text" name="search" placeholder="Search by service name or description..." value="<%= searchTerm %>">
            <button type="submit">🔍 Search</button>
            <% if (!searchTerm.isEmpty()) { %>
                <a href="${pageContext.request.contextPath}/admin/selectServiceToEdit" style="background: #6c757d; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none;">Clear</a>
            <% } %>
        </form>
    </div>
    
    <h2>Available Services</h2>
    
    <div class="service-grid">
        <%
        try {
            Class.forName("org.postgresql.Driver");
            String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
            Connection conn = DriverManager.getConnection(connURL);
            
            String sql;
            PreparedStatement ps;
            
            if (searchTerm != null && !searchTerm.isEmpty()) {
                sql = "SELECT service_id, service_name, description, price_per_day, is_active FROM services " +
                      "WHERE LOWER(service_name) LIKE LOWER(?) OR LOWER(description) LIKE LOWER(?) " +
                      "ORDER BY service_id";
                ps = conn.prepareStatement(sql);
                ps.setString(1, "%" + searchTerm + "%");
                ps.setString(2, "%" + searchTerm + "%");
            } else {
                sql = "SELECT service_id, service_name, description, price_per_day, is_active FROM services ORDER BY service_id";
                ps = conn.prepareStatement(sql);
            }
            
            ResultSet rs = ps.executeQuery();
            
            boolean hasServices = false;
            
            while(rs.next()) {
                hasServices = true;
                int serviceId = rs.getInt("service_id");
                String serviceName = rs.getString("service_name");
                String description = rs.getString("description");
                double price = rs.getDouble("price_per_day");
                boolean isActive = rs.getBoolean("is_active");
                
                String statusClass = isActive ? "status-active" : "status-inactive";
                String statusText = isActive ? "Active" : "Inactive";
        %>
        
        <div class="service-card">
            <div class="service-name"><%= serviceName %></div>
            <div class="service-description">
                <%= description != null ? (description.length() > 100 ? description.substring(0, 100) + "..." : description) : "No description" %>
            </div>
            <div class="service-price">$<%= String.format("%.2f", price) %> / day</div>
            <div class="service-status <%= statusClass %>"><%= statusText %></div>
            <a href="${pageContext.request.contextPath}/admin/editService?id=<%= serviceId %>" class="btn-select">
                ✏️ Edit This Service
            </a>
        </div>
        
        <%
            }
            
            if (!hasServices) {
        %>
            <div class="no-results" style="grid-column: 1 / -1;">
                <div style="font-size: 48px; margin-bottom: 20px;">🔍</div>
                <h3 style="color: #666; margin-bottom: 10px;">No Services Found</h3>
                <p style="color: #999; margin-bottom: 20px;">
                    <% if (searchTerm != null && !searchTerm.isEmpty()) { %>
                        No services matching "<%= searchTerm %>"
                    <% } else { %>
                        There are no services available.
                    <% } %>
                </p>
                <a href="${pageContext.request.contextPath}/admin/addService" style="background: #2c8a3e; color: white; padding: 12px 30px; border-radius: 5px; text-decoration: none; display: inline-block;">
                    ➕ Add New Service
                </a>
            </div>
        <%
            }
            
            rs.close();
            ps.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<div style='color: red; padding: 20px; grid-column: 1 / -1;'>Error loading services: " + e.getMessage() + "</div>");
        }
        %>
    </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>