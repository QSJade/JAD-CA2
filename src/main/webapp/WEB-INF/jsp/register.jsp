<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <!--
  - Author(s): Jade
  - Date: 27/10/2025
  - Copyright Notice:
  - @(#)
  - Description: 
  -->
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="css/style.css">
<title>Insert title here</title>
</head>
<body>
<%@ include file="header.jsp" %>
    <%
        // Check for error message
        String errCode = request.getParameter("errCode");
        if (errCode != null && errCode.equals("invalidLogin")) {
            out.println("<p style='color: red;'>You have entered an invalid ID/Password</p>");
        }      
        else if (errCode != null && errCode.equals("duplicateEmail")) {
            out.println("<p style='color: red;'>This email is already registered. Please use another one.</p>");
        }
    %>
    
<form action="registerUser.jsp" method="post" class="form-wrapper">
  <div class="form-row">
    <label for="name">Username:</label>
    <input type="text" name="name" required>
  </div>
  
  <div class="form-row">
    <label for="email">Email:</label>
    <input type="email" name="email" required>
  </div>
  
  <div class="form-row">
    <label for="address">Address:</label>
    <input type="text" name="address" required>
  </div>
  
  <div class="checkbox-row">
    <input type="checkbox" name="saveAddress" value="yes">
    <label for="saveAddress">Save this information</label>
  </div>
  
  <div class="form-row">
    <label for="password">Password:</label>
    <input type="password" name="password" minlength="6" required>
  </div>
  
  <button type="button" onclick="window.location.href='login'">
    Already have an account?
  </button>

  <input type="submit" name="btnSubmit" value="Sign Up">
</form>

<%@ include file="footer.jsp" %>
</body>
</html>