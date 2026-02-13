<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .dashboard-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }
    .dashboard-header {
        background: linear-gradient(135deg, #2c8a3e, #1f6a2f);
        color: white;
        padding: 40px;
        border-radius: 10px;
        margin-bottom: 30px;
    }
    .dashboard-header h1 {
        color: white;
        font-size: 32px;
        margin-bottom: 10px;
    }
    .dashboard-header p {
        font-size: 18px;
        opacity: 0.9;
    }
    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
        gap: 30px;
        margin-bottom: 40px;
    }
    .dashboard-card {
        background: white;
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        padding: 25px;
        transition: transform 0.3s;
    }
    .dashboard-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 6px 20px rgba(44, 138, 62, 0.15);
    }
    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 2px solid #eaeaea;
    }
    .card-header h2 {
        color: #2c8a3e;
        margin: 0;
        font-size: 22px;
    }
    .card-icon {
        font-size: 40px;
    }
    .menu-list {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    .menu-list li {
        margin-bottom: 12px;
    }
    .menu-list a {
        display: block;
        padding: 12px 15px;
        background: #f8f9fa;
        color: #333;
        text-decoration: none;
        border-radius: 6px;
        transition: all 0.3s;
        font-weight: 500;
    }
    .menu-list a:hover {
        background: #2c8a3e;
        color: white;
        transform: translateX(5px);
    }
    .stats-row {
        display: flex;
        gap: 20px;
        margin-top: 20px;
    }
    .stat-item {
        flex: 1;
        background: #f8f9fa;
        padding: 15px;
        border-radius: 8px;
        text-align: center;
    }
    .stat-number {
        font-size: 28px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .stat-label {
        font-size: 14px;
        color: #666;
        margin-top: 5px;
    }
    .welcome-section {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .logout-btn {
        background: rgba(255,255,255,0.2);
        color: white;
        padding: 10px 20px;
        border-radius: 5px;
        text-decoration: none;
        transition: background 0.3s;
    }
    .logout-btn:hover {
        background: rgba(255,255,255,0.3);
    }
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<%
String userRole = (String) session.getAttribute("sessUserRole");
String userName = (String) session.getAttribute("sessCustomerName");
if (!"admin".equals(userRole)) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=unauthorized");
    return;
}
%>

<div class="dashboard-container">
    <div class="dashboard-header">
        <div class="welcome-section">
        <!-- ===== MESSAGE SECTION ===== -->
<%
String msg = request.getParameter("msg");
String errCode = request.getParameter("errCode");
%>

<% if ("updated".equals(msg)) { %>
    <div style="background: #d4edc9; color: #2c8a3e; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">✅</span>
        <span style="font-weight: bold;">Service updated successfully!</span>
    </div>
<% } else if ("added".equals(msg)) { %>
    <div style="background: #d4edc9; color: #2c8a3e; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">✅</span>
        <span style="font-weight: bold;">Service added successfully!</span>
    </div>
<% } else if ("deleted".equals(msg)) { %>
    <div style="background: #d4edc9; color: #2c8a3e; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">✅</span>
        <span style="font-weight: bold;">Service deleted successfully!</span>
    </div>
<% } else if ("notFound".equals(errCode)) { %>
    <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">❌</span>
        <span style="font-weight: bold;">Service not found!</span>
    </div>
<% } else if ("updateFailed".equals(errCode)) { %>
    <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">❌</span>
        <span style="font-weight: bold;">Failed to update service. Please try again.</span>
    </div>
<% } else if ("error".equals(errCode)) { %>
    <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 20px;">❌</span>
        <span style="font-weight: bold;">An error occurred. Please try again.</span>
    </div>
<% } %>
            <div>
                <h1>Admin Dashboard</h1>
                <p>Welcome back, <%= userName != null ? userName : "Administrator" %>!</p>
            </div>
        </div>
    </div>
    
    <div class="dashboard-grid">
        <!-- ===== CLIENT MANAGEMENT CARD ===== -->
        <div class="dashboard-card">
            <div class="card-header">
                <h2>Client Management</h2>
                <span class="card-icon">👥</span>
            </div>
            <ul class="menu-list">
                <li><a href="${pageContext.request.contextPath}/admin/clients">📋 View All Clients</a></li>
                <li><a href="${pageContext.request.contextPath}/reviewAdmin">⭐ Manage Reviews</a></li>
            </ul>
        </div>
        
        <!-- ===== SALES MANAGEMENT CARD ===== -->
        <div class="dashboard-card">
            <div class="card-header">
                <h2>Sales Management</h2>
                <span class="card-icon">💰</span>
            </div>
            <ul class="menu-list">
                <li><a href="${pageContext.request.contextPath}/admin/sales">📊 Sales Dashboard</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/sales/invoices">📄 All Invoices</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/sales/bookings">📅 Booking Inquiry</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/sales/reports/top-clients">🏆 Top Clients</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/sales/reports/service-usage">📈 Service Usage</a></li>
            </ul>
        </div>
        
        <!-- ===== SERVICE MANAGEMENT CARD ===== -->
        <div class="dashboard-card">
            <div class="card-header">
                <h2>Service Management</h2>
                <span class="card-icon">🛠️</span>
            </div>
            <ul class="menu-list">
                <li><a href="${pageContext.request.contextPath}/admin/addService">➕ Add New Service</a></li>
                <li><a href="${pageContext.request.contextPath}/admin/selectServiceToEdit">✏️ Edit Services</a></li>
            </ul>
        </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>