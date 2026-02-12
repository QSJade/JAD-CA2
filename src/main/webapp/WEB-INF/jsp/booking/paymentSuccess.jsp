<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%
String sessionId = (String) request.getAttribute("sessionId");
String message = (String) request.getAttribute("message");
String error = (String) request.getAttribute("error");
List<String> errors = (List<String>) request.getAttribute("errors");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Successful</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .success-container { text-align: center; margin: 50px auto; max-width: 600px; padding: 30px; background: white; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .success-icon { color: #27ae60; font-size: 64px; margin-bottom: 20px; }
        .error-icon { color: #e74c3c; font-size: 64px; margin-bottom: 20px; }
        .session-id { background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0; font-family: monospace; word-break: break-all; }
        .error-list { background: #fdeaea; padding: 15px; border-radius: 5px; margin: 20px 0; text-align: left; color: #e74c3c; }
    </style>
</head>
<body>
<%@ include file="../header.jsp" %>

<div class="success-container">
    <% if (error != null && !error.isEmpty()) { %>
        <div class="error-icon">⚠️</div>
        <h2 style="color: #e74c3c;">Payment Issue Detected</h2>
        <p style="color: #e74c3c; margin: 20px 0;"><%= error %></p>
    <% } else { %>
        <div class="success-icon">✅</div>
        <h2 style="color: #27ae60;">Payment Successful!</h2>
        <p style="font-size: 18px; margin: 20px 0;"><%= message != null ? message : "Your booking has been confirmed." %></p>
    <% } %>
    
    <% if (errors != null && !errors.isEmpty()) { %>
        <div class="error-list">
            <p><strong>Issues encountered:</strong></p>
            <ul style="margin-top: 10px; padding-left: 20px;">
                <% for (String err : errors) { %>
                    <li style="margin: 5px 0;"><%= err %></li>
                <% } %>
            </ul>
        </div>
    <% } %>
    
    <div style="margin-top: 30px;">
        <a href="${pageContext.request.contextPath}/profile" class="book-btn" style="margin-right: 10px;">View My Bookings</a>
        <a href="${pageContext.request.contextPath}/" class="btn-outline">Return Home</a>
    </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>