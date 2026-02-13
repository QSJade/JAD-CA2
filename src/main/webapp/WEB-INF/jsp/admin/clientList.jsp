<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User, model.UserProfile" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Client Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .admin-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }
    .admin-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    .search-section {
        background: #f8f9fa;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 30px;
    }
    .report-links {
        display: flex;
        gap: 15px;
        margin: 20px 0;
        flex-wrap: wrap;
    }
    .report-link {
        padding: 10px 20px;
        background: #e8f5e9;
        color: #2c8a3e;
        text-decoration: none;
        border-radius: 5px;
        font-weight: 500;
        transition: all 0.3s;
    }
    .report-link:hover {
        background: #2c8a3e;
        color: white;
    }
    .client-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
    }
    .client-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .client-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .client-table tr:hover {
        background: #f5f5f5;
    }
    .btn-action {
        padding: 6px 12px;
        margin: 0 2px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        color: white;
        font-size: 12px;
        text-decoration: none;
        display: inline-block;
    }
    .btn-view { background-color: #3498db; }
    .btn-edit { background-color: #f39c12; }
    .btn-delete { background-color: #e74c3c; }
    .btn-view:hover { background-color: #2980b9; }
    .btn-edit:hover { background-color: #e67e22; }
    .btn-delete:hover { background-color: #c0392b; }
    .message {
        padding: 15px;
        border-radius: 8px;
        margin-bottom: 20px;
        font-weight: 500;
    }
    .message.success {
        background-color: #d4edc9;
        color: #2c8a3e;
        border: 1px solid #c3e6cb;
    }
    .message.error {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
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

List<User> clients = (List<User>) request.getAttribute("clients");
String successMessage = (String) request.getAttribute("successMessage");
String errorMessage = (String) request.getAttribute("errorMessage");
%>

<div class="admin-container">
    <div class="admin-header">
        <h1>Client Management</h1>
        <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline">← Back to Dashboard</a>
    </div>
    
    <% if (successMessage != null) { %>
        <div class="message success"><%= successMessage %></div>
    <% } %>
    <% if (errorMessage != null) { %>
        <div class="message error"><%= errorMessage %></div>
    <% } %>
    
    <!-- Search Section -->
    <div class="search-section">
        <h3>Search Clients</h3>
        <form action="${pageContext.request.contextPath}/admin/clients/search" method="get" style="display: flex; gap: 10px; align-items: flex-end;">
            <div style="flex: 1;">
                <label for="keyword">Search Keyword:</label>
                <input type="text" id="keyword" name="keyword" style="width: 100%; padding: 8px;" placeholder="Enter search term...">
            </div>
            <div style="flex: 1;">
                <label for="searchType">Search By:</label>
                <select id="searchType" name="searchType" style="width: 100%; padding: 8px;">
                    <option value="health">Health Condition</option>
                    <option value="dietary">Dietary Restriction</option>
                    <option value="emergency">Emergency Contact</option>
                </select>
            </div>
            <div>
                <button type="submit" class="btn-pay" style="padding: 10px 20px;">Search</button>
            </div>
        </form>
    </div>
    
    <!-- Report Links -->
    <div class="report-links">
        <a href="${pageContext.request.contextPath}/admin/clients/reports/wheelchair" class="report-link">♿ Clients Using Wheelchair</a>
        <a href="${pageContext.request.contextPath}/admin/clients/reports/pets" class="report-link">🐾 Clients With Pets</a>
        <a href="${pageContext.request.contextPath}/admin/clients/reports/smokers" class="report-link">🚬 Clients Who Smoke</a>
    </div>
    
    <h2>All Clients (<%= clients != null ? clients.size() : 0 %>)</h2>
    
    <table class="client-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Address</th>
                <th>Registered</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
            if (clients != null && !clients.isEmpty()) {
                for (User client : clients) {
            %>
                <tr>
                    <td><%= client.getCustomerId() %></td>
                    <td><strong><%= client.getName() %></strong></td>
                    <td><%= client.getEmail() %></td>
                    <td><%= client.getAddress() != null ? client.getAddress() : "N/A" %></td>
                    <td><%= client.getCreatedAt() != null ? client.getCreatedAt().toLocalDate() : "N/A" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>" class="btn-action btn-view">View</a>
                        <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>/edit" class="btn-action btn-edit">Edit</a>
                        <form action="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>/delete" method="post" style="display:inline;" 
                              onsubmit="return confirm('Are you sure you want to delete this client?');">
                            <button type="submit" class="btn-action btn-delete">Delete</button>
                        </form>
                    </td>
                </tr>
            <%
                }
            } else {
            %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        No clients found.
                    </td>
                </tr>
            <%
            }
            %>
        </tbody>
    </table>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>