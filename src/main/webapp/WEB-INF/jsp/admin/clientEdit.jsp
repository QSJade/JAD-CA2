<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User, model.UserProfile" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Client</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .edit-container {
        max-width: 900px;
        margin: 0 auto;
        padding: 20px;
    }
    .form-section {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 30px;
        margin-bottom: 30px;
    }
    .form-row {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
    }
    .form-row label {
        width: 180px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .form-row input,
    .form-row select,
    .form-row textarea {
        flex: 1;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
    }
    .form-row textarea {
        min-height: 80px;
        resize: vertical;
    }
    .checkbox-row {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
        margin-left: 180px;
    }
    .checkbox-row label {
        margin-left: 10px;
        font-weight: normal;
    }
    .button-group {
        display: flex;
        gap: 15px;
        margin-top: 30px;
        justify-content: center;
    }
    h2 {
        color: #2c8a3e;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 2px solid #eaeaea;
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

<div class="edit-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h1>Edit Client: <%= client.getName() %></h1>
        <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>" class="btn-outline">← Cancel</a>
    </div>
    
    <form action="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>/update" method="post">
        
        <!-- Personal Information -->
        <div class="form-section">
            <h2>Personal Information</h2>
            
            <div class="form-row">
                <label>Client ID:</label>
                <input type="text" value="<%= client.getCustomerId() %>" readonly style="background: #f8f9fa;">
            </div>
            <div class="form-row">
                <label for="name">Full Name:</label>
                <input type="text" id="name" name="name" value="<%= client.getName() != null ? client.getName() : "" %>" required>
            </div>
            <div class="form-row">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" value="<%= client.getEmail() != null ? client.getEmail() : "" %>" readonly style="background: #f8f9fa;">
            </div>
            <div class="form-row">
                <label for="address">Address:</label>
                <input type="text" id="address" name="address" value="<%= client.getAddress() != null ? client.getAddress() : "" %>" required>
            </div>
        </div>
        
        <!-- Care Preferences -->
        <div class="form-section">
            <h2>Care Preferences</h2>
            
            <div class="form-row">
                <label>Has Pets:</label>
                <select name="hasPets">
                    <option value="">-- Select --</option>
                    <option value="true" <%= profile != null && profile.getHasPets() != null && profile.getHasPets() ? "selected" : "" %>>Yes</option>
                    <option value="false" <%= profile != null && profile.getHasPets() != null && !profile.getHasPets() ? "selected" : "" %>>No</option>
                </select>
            </div>
            
            <div class="form-row">
                <label>Uses Wheelchair:</label>
                <select name="usesWheelchair">
                    <option value="">-- Select --</option>
                    <option value="true" <%= profile != null && profile.getUsesWheelchair() != null && profile.getUsesWheelchair() ? "selected" : "" %>>Yes</option>
                    <option value="false" <%= profile != null && profile.getUsesWheelchair() != null && !profile.getUsesWheelchair() ? "selected" : "" %>>No</option>
                </select>
            </div>
            
            <div class="form-row">
                <label>Smoker:</label>
                <select name="isSmoker">
                    <option value="">-- Select --</option>
                    <option value="true" <%= profile != null && profile.getIsSmoker() != null && profile.getIsSmoker() ? "selected" : "" %>>Yes</option>
                    <option value="false" <%= profile != null && profile.getIsSmoker() != null && !profile.getIsSmoker() ? "selected" : "" %>>No</option>
                </select>
            </div>
            
            <div class="form-row">
                <label>Health Conditions:</label>
                <textarea name="healthConditions"><%= profile != null && profile.getHealthConditions() != null ? profile.getHealthConditions() : "" %></textarea>
            </div>
            
            <div class="form-row">
                <label>Dietary Restrictions:</label>
                <textarea name="dietaryRestrictions"><%= profile != null && profile.getDietaryRestrictions() != null ? profile.getDietaryRestrictions() : "" %></textarea>
            </div>
            
            <div class="form-row">
                <label>Medication Restrictions:</label>
                <textarea name="medicationRestrictions"><%= profile != null && profile.getMedicationRestrictions() != null ? profile.getMedicationRestrictions() : "" %></textarea>
            </div>
        </div>
        
        <!-- Medical Information -->
        <div class="form-section">
            <h2>Medical Information</h2>
            
            <div class="form-row">
                <label>Blood Type:</label>
                <select name="bloodType">
                    <option value="">-- Select Blood Type --</option>
                    <option value="A+" <%= profile != null && "A+".equals(profile.getBloodType()) ? "selected" : "" %>>A+</option>
                    <option value="A-" <%= profile != null && "A-".equals(profile.getBloodType()) ? "selected" : "" %>>A-</option>
                    <option value="B+" <%= profile != null && "B+".equals(profile.getBloodType()) ? "selected" : "" %>>B+</option>
                    <option value="B-" <%= profile != null && "B-".equals(profile.getBloodType()) ? "selected" : "" %>>B-</option>
                    <option value="O+" <%= profile != null && "O+".equals(profile.getBloodType()) ? "selected" : "" %>>O+</option>
                    <option value="O-" <%= profile != null && "O-".equals(profile.getBloodType()) ? "selected" : "" %>>O-</option>
                    <option value="AB+" <%= profile != null && "AB+".equals(profile.getBloodType()) ? "selected" : "" %>>AB+</option>
                    <option value="AB-" <%= profile != null && "AB-".equals(profile.getBloodType()) ? "selected" : "" %>>AB-</option>
                </select>
            </div>
            
            <div class="form-row">
                <label>Allergies:</label>
                <textarea name="allergies"><%= profile != null && profile.getAllergies() != null ? profile.getAllergies() : "" %></textarea>
            </div>
            
            <div class="form-row">
                <label>Chronic Conditions:</label>
                <textarea name="chronicConditions"><%= profile != null && profile.getChronicConditions() != null ? profile.getChronicConditions() : "" %></textarea>
            </div>
            
            <div class="form-row">
                <label>Other Info:</label>
                <textarea name="otherInfo"><%= profile != null && profile.getOtherInfo() != null ? profile.getOtherInfo() : "" %></textarea>
            </div>
        </div>
        
        <!-- Emergency Contact -->
        <div class="form-section">
            <h2>Emergency Contact</h2>
            
            <div class="form-row">
                <label>Contact Name:</label>
                <input type="text" name="emergencyContactName" value="<%= profile != null && profile.getEmergencyContactName() != null ? profile.getEmergencyContactName() : "" %>">
            </div>
            
            <div class="form-row">
                <label>Contact Phone:</label>
                <input type="text" name="emergencyContactPhone" value="<%= profile != null && profile.getEmergencyContactPhone() != null ? profile.getEmergencyContactPhone() : "" %>">
            </div>
            
            <div class="form-row">
                <label>Relationship:</label>
                <input type="text" name="emergencyContactRelation" value="<%= profile != null && profile.getEmergencyContactRelation() != null ? profile.getEmergencyContactRelation() : "" %>">
            </div>
        </div>
        
        <div class="button-group">
            <button type="submit" class="btn-update">Save Changes</button>
            <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>" class="btn-outline">Cancel</a>
        </div>
    </form>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>