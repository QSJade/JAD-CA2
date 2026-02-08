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
<title>Login</title>
</head>
<body>
<%@ include file="header.jsp" %>

<% 
    String errCode = request.getParameter("errCode");
    if (errCode != null && errCode.equals("invalidLogin")) { 
%>
    <p style='color: red;'>You have entered an invalid ID/Password</p>
<% 
    } else if (errCode != null && errCode.equals("notLoggedIn")) { 
%>
    <p style='color: red;'>Please log in first to access this</p>
<% 
    } 
%>

<div class="form-wrapper">
<form action="<%=request.getContextPath()%>/verifyUser" method = "post" class="profile-form">
  <div class="form-row">
    <label for="email">Email:</label>
    <input type="email" name="email" required>
  </div>

  <div class="form-row">
    <label for="password">Password:</label>
    <input type="password" name="password" required>
  </div>

  <button type="button" onclick="window.location.href='register.jsp'">
    Don't have an account yet?
  </button>

  <input type="submit" name="btnSubmit" value="Login">
</form>
</div>

<%@ include file="footer.jsp" %>
</body>
</html>