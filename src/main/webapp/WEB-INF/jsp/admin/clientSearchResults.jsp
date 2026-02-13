<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.UserProfile, model.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Search Results</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .results-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    .result-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
        margin-top: 20px;
    }
    .result-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .result-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .result-table tr:hover {
        background: #f5f5f5;
    }
    .badge {
        display: inline-block;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 12px;
        background: #e8f5e9;
        color: #2c8a3e;
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

List<UserProfile> searchResults = (List<UserProfile>) request.getAttribute("searchResults");
String searchDescription = (String) request.getAttribute("searchDescription");
String keyword = (String) request.getAttribute("keyword");
String searchType = (String) request.getAttribute("searchType");
%>

<div class="results-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h1>Search Results</h1>
        <a href="${pageContext.request.contextPath}/admin/clients" class="btn-outline">← Back to Clients</a>
    </div>
    
    <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
        <h3><%= searchDescription != null ? searchDescription : "Search Results" %></h3>
        <p>Found <%= searchResults != null ? searchResults.size() : 0 %> client(s)</p>
    </div>
    
    <% if (searchResults != null && !searchResults.isEmpty()) { %>
        <table class="result-table">
            <thead>
                <tr>
                    <th>Client ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Health Conditions</th>
                    <th>Dietary Restrictions</th>
                    <th>Emergency Contact</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% for (UserProfile profile : searchResults) { 
                    User user = profile.getUser();
                %>
                <tr>
                    <td><%= user != null ? user.getCustomerId() : "N/A" %></td>
                    <td><strong><%= user != null ? user.getName() : "N/A" %></strong></td>
                    <td><%= user != null ? user.getEmail() : "N/A" %></td>
                    <td><%= profile.getHealthConditions() != null ? profile.getHealthConditions() : "N/A" %></td>
                    <td><%= profile.getDietaryRestrictions() != null ? profile.getDietaryRestrictions() : "N/A" %></td>
                    <td>
                        <% if (profile.getEmergencyContactName() != null) { %>
                            <%= profile.getEmergencyContactName() %><br>
                            <small><%= profile.getEmergencyContactPhone() != null ? profile.getEmergencyContactPhone() : "" %></small>
                        <% } else { %>
                            N/A
                        <% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/clients/<%= user != null ? user.getCustomerId() : "" %>" class="btn-action btn-view" style="padding: 4px 8px; background: #3498db; color: white; text-decoration: none; border-radius: 4px;">View</a>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } else { %>
        <div style="text-align: center; padding: 60px; background: white; border-radius: 8px;">
            <p style="font-size: 18px; color: #666;">No clients found matching your search criteria.</p>
            <p style="margin-top: 20px;">Try different keywords or search type.</p>
        </div>
    <% } %>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>