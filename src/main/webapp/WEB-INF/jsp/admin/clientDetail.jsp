<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, model.UserProfile" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Client Details</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .detail-container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 20px;
    }
    .detail-section {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 30px;
        margin-bottom: 30px;
    }
    .detail-row {
        display: flex;
        margin-bottom: 15px;
        border-bottom: 1px solid #eee;
        padding-bottom: 10px;
    }
    .detail-label {
        width: 200px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .detail-value {
        flex: 1;
    }
    .badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        background: #e8f5e9;
        color: #2c8a3e;
    }
    .button-group {
        display: flex;
        gap: 15px;
        margin-top: 30px;
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

User client = (User) request.getAttribute("client");
UserProfile profile = (UserProfile) request.getAttribute("profile");
%>

<div class="detail-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h1>Client Details</h1>
        <a href="${pageContext.request.contextPath}/admin/clients" class="btn-outline">← Back to Clients</a>
    </div>
    
    <!-- Personal Information -->
    <div class="detail-section">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">Personal Information</h2>
        
        <div class="detail-row">
            <div class="detail-label">Client ID:</div>
            <div class="detail-value"><strong><%= client.getCustomerId() %></strong></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Full Name:</div>
            <div class="detail-value"><%= client.getName() %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Email:</div>
            <div class="detail-value"><%= client.getEmail() %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Address:</div>
            <div class="detail-value"><%= client.getAddress() != null ? client.getAddress() : "Not provided" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Role:</div>
            <div class="detail-value"><span class="badge"><%= client.getRole() %></span></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Registered On:</div>
            <div class="detail-value"><%= client.getCreatedAt() != null ? client.getCreatedAt().toLocalDate() : "N/A" %></div>
        </div>
    </div>
    
    <!-- Care Preferences -->
    <div class="detail-section">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">Care Preferences</h2>
        
        <div class="detail-row">
            <div class="detail-label">Has Pets:</div>
            <div class="detail-value">
                <%= profile != null && profile.getHasPets() != null ? 
                    (profile.getHasPets() ? "Yes" : "No") : "Not specified" %>
            </div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Uses Wheelchair:</div>
            <div class="detail-value">
                <%= profile != null && profile.getUsesWheelchair() != null ? 
                    (profile.getUsesWheelchair() ? "Yes" : "No") : "Not specified" %>
            </div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Smoker:</div>
            <div class="detail-value">
                <%= profile != null && profile.getIsSmoker() != null ? 
                    (profile.getIsSmoker() ? "Yes" : "No") : "Not specified" %>
            </div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Health Conditions:</div>
            <div class="detail-value"><%= profile != null && profile.getHealthConditions() != null ? profile.getHealthConditions() : "None specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Dietary Restrictions:</div>
            <div class="detail-value"><%= profile != null && profile.getDietaryRestrictions() != null ? profile.getDietaryRestrictions() : "None specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Medication Restrictions:</div>
            <div class="detail-value"><%= profile != null && profile.getMedicationRestrictions() != null ? profile.getMedicationRestrictions() : "None specified" %></div>
        </div>
    </div>
    
    <!-- Medical Information -->
    <div class="detail-section">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">Medical Information</h2>
        
        <div class="detail-row">
            <div class="detail-label">Blood Type:</div>
            <div class="detail-value"><%= profile != null && profile.getBloodType() != null ? profile.getBloodType() : "Not specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Allergies:</div>
            <div class="detail-value"><%= profile != null && profile.getAllergies() != null ? profile.getAllergies() : "None specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Chronic Conditions:</div>
            <div class="detail-value"><%= profile != null && profile.getChronicConditions() != null ? profile.getChronicConditions() : "None specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Other Info:</div>
            <div class="detail-value"><%= profile != null && profile.getOtherInfo() != null ? profile.getOtherInfo() : "None specified" %></div>
        </div>
    </div>
    
    <!-- Emergency Contact -->
    <div class="detail-section">
        <h2 style="color: #2c8a3e; margin-bottom: 20px;">Emergency Contact</h2>
        
        <div class="detail-row">
            <div class="detail-label">Contact Name:</div>
            <div class="detail-value"><%= profile != null && profile.getEmergencyContactName() != null ? profile.getEmergencyContactName() : "Not specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Contact Phone:</div>
            <div class="detail-value"><%= profile != null && profile.getEmergencyContactPhone() != null ? profile.getEmergencyContactPhone() : "Not specified" %></div>
        </div>
        <div class="detail-row">
            <div class="detail-label">Relationship:</div>
            <div class="detail-value"><%= profile != null && profile.getEmergencyContactRelation() != null ? profile.getEmergencyContactRelation() : "Not specified" %></div>
        </div>
    </div>
    
    <div class="button-group">
        <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>/edit" class="btn-update">Edit Client</a>
        <a href="${pageContext.request.contextPath}/admin/clients" class="btn-outline">Back to List</a>
    </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>