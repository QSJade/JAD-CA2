<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Invoice, model.Booking" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Sales Dashboard</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .dashboard-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .stat-card {
        background: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        text-align: center;
    }
    .stat-card h3 {
        color: #666;
        font-size: 16px;
        margin-bottom: 10px;
    }
    .stat-number {
        font-size: 36px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .stat-label {
        color: #999;
        font-size: 14px;
        margin-top: 5px;
    }
    .report-section {
        background: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-bottom: 30px;
    }
    .report-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        padding-bottom: 15px;
        border-bottom: 2px solid #eaeaea;
    }
    .report-header h2 {
        color: #2c8a3e;
        margin: 0;
    }
    .table-responsive {
        overflow-x: auto;
    }
    table {
        width: 100%;
        border-collapse: collapse;
    }
    th {
        background: #f8f9fa;
        color: #333;
        padding: 12px;
        text-align: left;
    }
    td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    tr:hover {
        background: #f5f5f5;
    }
    .btn-view {
        background: #3498db;
        color: white;
        padding: 4px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 12px;
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

Double totalRevenue = (Double) request.getAttribute("totalRevenue");
Integer totalInvoices = (Integer) request.getAttribute("totalInvoices");
Long paidInvoices = (Long) request.getAttribute("paidInvoices");
List<Object[]> monthlyRevenue = (List<Object[]>) request.getAttribute("monthlyRevenue");
List<Object[]> topClients = (List<Object[]>) request.getAttribute("topClients");
%>

<div class="dashboard-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
        <h1>Sales Dashboard</h1>
        <a href="${pageContext.request.contextPath}/adminService" class="btn-outline">← Back to Admin</a>
    </div>
    
    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Total Revenue</h3>
            <div class="stat-number">$<%= String.format("%,.2f", totalRevenue != null ? totalRevenue : 0.0) %></div>
            <div class="stat-label">All time</div>
        </div>
        <div class="stat-card">
            <h3>Total Invoices</h3>
            <div class="stat-number"><%= totalInvoices != null ? totalInvoices : 0 %></div>
            <div class="stat-label">All invoices</div>
        </div>
        <div class="stat-card">
            <h3>Paid Invoices</h3>
            <div class="stat-number"><%= paidInvoices != null ? paidInvoices : 0 %></div>
            <div class="stat-label">Completed payments</div>
        </div>
    </div>
    
    <!-- Monthly Revenue -->
    <div class="report-section">
        <div class="report-header">
            <h2>Monthly Revenue</h2>
            <a href="${pageContext.request.contextPath}/admin/sales/invoices" class="btn-update">View All Invoices</a>
        </div>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Month</th>
                        <th>Year</th>
                        <th>Revenue</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (monthlyRevenue != null && !monthlyRevenue.isEmpty()) { 
                        for (Object[] row : monthlyRevenue) { 
                            Integer month = (Integer) row[0];
                            Integer year = (Integer) row[1];
                            Double revenue = (Double) row[2];
                    %>
                        <tr>
                            <td><%= String.format("%02d", month) %></td>
                            <td><%= year %></td>
                            <td><strong>$<%= String.format("%,.2f", revenue) %></strong></td>
                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="3" style="text-align: center; padding: 30px;">No revenue data available</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Top Clients -->
    <div class="report-section">
        <div class="report-header">
            <h2>Top Clients by Spending</h2>
            <a href="${pageContext.request.contextPath}/admin/sales/reports/top-clients" class="btn-update">View Full Report</a>
        </div>
        <div class="table-responsive">
            <table>
                <thead>
                    <tr>
                        <th>Client ID</th>
                        <th>Client Name</th>
                        <th>Total Spent</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (topClients != null && !topClients.isEmpty()) { 
                        for (Object[] client : topClients) { 
                            Integer clientId = (Integer) client[0];
                            String clientName = (String) client[1];
                            Double totalSpent = (Double) client[2];
                    %>
                        <tr>
                            <td><%= clientId %></td>
                            <td><strong><%= clientName %></strong></td>
                            <td>$<%= String.format("%,.2f", totalSpent) %></td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/clients/<%= clientId %>" class="btn-view">View</a>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 30px;">No client data available</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>