<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.UserProfile, model.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Client Report</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .report-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    .report-header {
        background: linear-gradient(135deg, #2c8a3e, #1f6a2f);
        color: white;
        padding: 30px;
        border-radius: 10px;
        margin-bottom: 30px;
    }
    .report-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
    }
    .report-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .report-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .report-table tr:hover {
        background: #f5f5f5;
    }
    .stat-card {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        margin-bottom: 20px;
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

List<UserProfile> profiles = (List<UserProfile>) request.getAttribute("profiles");
String reportTitle = (String) request.getAttribute("reportTitle");
Integer reportCount = (Integer) request.getAttribute("reportCount");
%>

<div class="report-container">
    <div class="report-header">
        <h1 style="color: white; margin-bottom: 10px;"><%= reportTitle != null ? reportTitle : "Client Report" %></h1>
        <p style="font-size: 18px; opacity: 0.9;">Total Clients: <%= reportCount != null ? reportCount : 0 %></p>
    </div>
    
    <div class="stat-card">
        <h3 style="color: #2c8a3e; margin-bottom: 10px;">Report Summary</h3>
        <p>This report shows all clients who match the selected criteria.</p>
    </div>
    
    <% if (profiles != null && !profiles.isEmpty()) { %>
        <table class="report-table">
            <thead>
                <tr>
                    <th>Client ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Contact</th>
                    <th>Details</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% for (UserProfile profile : profiles) { 
                    User user = profile.getUser();
                    if (user == null) continue;
                %>
                <tr>
                    <td><%= user.getCustomerId() %></td>
                    <td><strong><%= user.getName() %></strong></td>
                    <td><%= user.getEmail() %></td>
                    <td><%= user.getAddress() != null ? user.getAddress() : "N/A" %></td>
                    <td>
                        <% if (reportTitle != null) { %>
                            <% if (reportTitle.contains("Wheelchair")) { %>
                                <span class="badge" style="background: #e8f5e9; padding: 4px 8px; border-radius: 4px;">♿ Wheelchair User</span>
                            <% } else if (reportTitle.contains("Pets")) { %>
                                <span class="badge" style="background: #e8f5e9; padding: 4px 8px; border-radius: 4px;">🐾 Has Pets</span>
                            <% } else if (reportTitle.contains("Smoke")) { %>
                                <span class="badge" style="background: #e8f5e9; padding: 4px 8px; border-radius: 4px;">🚬 Smoker</span>
                            <% } %>
                        <% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/clients/<%= user.getCustomerId() %>" style="padding: 4px 12px; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">View</a>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } else { %>
        <div style="text-align: center; padding: 60px; background: white; border-radius: 8px;">
            <p style="font-size: 18px; color: #666;">No clients found in this category.</p>
        </div>
    <% } %>
    
    <div style="margin-top: 30px; text-align: center;">
        <a href="${pageContext.request.contextPath}/admin/clients" class="btn-outline">Back to Client Management</a>
        <button onclick="window.print()" class="btn-update" style="margin-left: 10px;">Print Report</button>
    </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>