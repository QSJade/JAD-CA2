<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, model.UserProfile" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Health Profile</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<%@ include file="../header.jsp" %>

<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

// Get profile from request attribute (set by controller)
UserProfile profile = (UserProfile) request.getAttribute("profile");
if (profile == null) {
    profile = new UserProfile();
}

// Check error messages
String errCode = request.getParameter("errCode");
if ("healthUpdateFail".equals(errCode)) {
    out.println("<p style='color: red; text-align: center;'>Failed to update health profile. Please try again.</p>");
}

// Check success message
String success = request.getParameter("success");
if ("healthUpdated".equals(success)) {
    out.println("<p style='color: green; text-align: center;'>Health profile updated successfully!</p>");
}
%>

<h1>Health Profile & Emergency Contact</h1>

<div class="form-wrapper">
    <form action="${pageContext.request.contextPath}/profile/health/update" method="post" class="profile-form">
        
        <h3>Care Preferences</h3>
        <div class="form-row">
            <label>Has Pets:</label>
            <select name="hasPets">
                <option value="true" <%= profile.getHasPets() != null && profile.getHasPets() ? "selected" : "" %>>Yes</option>
                <option value="false" <%= profile.getHasPets() == null || !profile.getHasPets() ? "selected" : "" %>>No</option>
            </select>
        </div>
        
        <div class="form-row">
            <label>Uses Wheelchair:</label>
            <select name="usesWheelchair">
                <option value="true" <%= profile.getUsesWheelchair() != null && profile.getUsesWheelchair() ? "selected" : "" %>>Yes</option>
                <option value="false" <%= profile.getUsesWheelchair() == null || !profile.getUsesWheelchair() ? "selected" : "" %>>No</option>
            </select>
        </div>
        
        <div class="form-row">
            <label>Smoker:</label>
            <select name="isSmoker">
                <option value="true" <%= profile.getIsSmoker() != null && profile.getIsSmoker() ? "selected" : "" %>>Yes</option>
                <option value="false" <%= profile.getIsSmoker() == null || !profile.getIsSmoker() ? "selected" : "" %>>No</option>
            </select>
        </div>
        
        <div class="form-row">
            <label>Health Conditions:</label>
            <textarea name="healthConditions" rows="3"><%= profile.getHealthConditions() != null ? profile.getHealthConditions() : "" %></textarea>
        </div>
        
        <div class="form-row">
            <label>Dietary Restrictions:</label>
            <textarea name="dietaryRestrictions" rows="3"><%= profile.getDietaryRestrictions() != null ? profile.getDietaryRestrictions() : "" %></textarea>
        </div>
        
        <div class="form-row">
            <label>Medication Restrictions:</label>
            <textarea name="medicationRestrictions" rows="3"><%= profile.getMedicationRestrictions() != null ? profile.getMedicationRestrictions() : "" %></textarea>
        </div>
     
        <h3>Medical Information</h3>
        <div class="form-row">
            <label>Blood Type:</label>
            <select name="bloodType">
                <option value="">-- Select --</option>
                <option value="A+" <%= "A+".equals(profile.getBloodType()) ? "selected" : "" %>>A+</option>
                <option value="A-" <%= "A-".equals(profile.getBloodType()) ? "selected" : "" %>>A-</option>
                <option value="B+" <%= "B+".equals(profile.getBloodType()) ? "selected" : "" %>>B+</option>
                <option value="B-" <%= "B-".equals(profile.getBloodType()) ? "selected" : "" %>>B-</option>
                <option value="O+" <%= "O+".equals(profile.getBloodType()) ? "selected" : "" %>>O+</option>
                <option value="O-" <%= "O-".equals(profile.getBloodType()) ? "selected" : "" %>>O-</option>
                <option value="AB+" <%= "AB+".equals(profile.getBloodType()) ? "selected" : "" %>>AB+</option>
                <option value="AB-" <%= "AB-".equals(profile.getBloodType()) ? "selected" : "" %>>AB-</option>
            </select>
        </div>
        
        <div class="form-row">
            <label>Allergies:</label>
            <textarea name="allergies" rows="3"><%= profile.getAllergies() != null ? profile.getAllergies() : "" %></textarea>
        </div>
        
        <div class="form-row">
            <label>Chronic Conditions:</label>
            <textarea name="chronicConditions" rows="3"><%= profile.getChronicConditions() != null ? profile.getChronicConditions() : "" %></textarea>
        </div>
        
        <div class="form-row">
            <label>Other Info:</label>
            <textarea name="otherInfo" rows="3"><%= profile.getOtherInfo() != null ? profile.getOtherInfo() : "" %></textarea>
        </div>
        
        <h3>Emergency Contact</h3>
        <div class="form-row">
            <label>Contact Name:</label>
            <input type="text" name="emergencyContactName" value="<%= profile.getEmergencyContactName() != null ? profile.getEmergencyContactName() : "" %>">
        </div>
        
<div class="form-row">
    <label>Contact Phone:</label>
    <input type="text" 
           id="emergencyContactPhone"
           name="emergencyContactPhone" 
           value="<%= profile.getEmergencyContactPhone() != null ? profile.getEmergencyContactPhone() : "" %>"
           maxlength="10">
</div>
        
        <div class="form-row">
            <label>Relationship:</label>
            <input type="text" name="emergencyContactRelation" value="<%= profile.getEmergencyContactRelation() != null ? profile.getEmergencyContactRelation() : "" %>">
        </div>
        
        <div class="button-row">
            <input type="submit" value="Save Health Profile" class="btn-update">
            <a href="${pageContext.request.contextPath}/profile/profile" class="btn-outline">Cancel</a>
        </div>
    </form>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>