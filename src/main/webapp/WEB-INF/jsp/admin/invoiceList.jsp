<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Invoice, model.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Invoice Management</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .invoice-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }
    .invoice-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    .filter-section {
        background: #f8f9fa;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 30px;
    }
    .invoice-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
    }
    .invoice-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .invoice-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .invoice-table tr:hover {
        background: #f5f5f5;
    }
    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
    }
    .status-paid {
        background: #d4edc9;
        color: #2c8a3e;
    }
    .status-pending {
        background: #fff3cd;
        color: #856404;
    }
    .status-overdue {
        background: #f8d7da;
        color: #721c24;
    }
    .btn-view {
        background: #3498db;
        color: white;
        padding: 4px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 12px;
    }
    .btn-view:hover {
        background: #2980b9;
    }
    .summary-stats {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .stat-card {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        text-align: center;
    }
    .stat-number {
        font-size: 28px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .stat-label {
        color: #666;
        margin-top: 5px;
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

List<Invoice> invoices = (List<Invoice>) request.getAttribute("invoices");

// Calculate summary stats
double totalRevenue = 0;
int paidCount = 0, pendingCount = 0, overdueCount = 0;
if (invoices != null) {
    for (Invoice inv : invoices) {
        totalRevenue += inv.getTotalAmount();
        if ("paid".equals(inv.getPaymentStatus())) paidCount++;
        else if ("pending".equals(inv.getPaymentStatus())) pendingCount++;
        else overdueCount++;
    }
}
%>

<div class="invoice-container">
    <div class="invoice-header">
        <h1>Invoice Management</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline">← Back to Dashboard</a>
        </div>
    </div>
    
    <!-- Summary Statistics -->
    <div class="summary-stats">
        <div class="stat-card">
            <div class="stat-number">$<%= String.format("%,.2f", totalRevenue) %></div>
            <div class="stat-label">Total Revenue</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= invoices != null ? invoices.size() : 0 %></div>
            <div class="stat-label">Total Invoices</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= paidCount %></div>
            <div class="stat-label">Paid</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><%= pendingCount %></div>
            <div class="stat-label">Pending</div>
        </div>
    </div>
    
    <!-- Filter Section -->
    <div class="filter-section">
        <h3 style="margin-bottom: 15px; color: #2c8a3e;">Filter Invoices</h3>
        <div style="display: flex; gap: 15px; align-items: center; flex-wrap: wrap;">
            <a href="${pageContext.request.contextPath}/admin/sales/invoices" class="btn-update">All</a>
            <a href="${pageContext.request.contextPath}/admin/sales/invoices?status=paid" class="btn-outline">Paid</a>
            <a href="${pageContext.request.contextPath}/admin/sales/invoices?status=pending" class="btn-outline">Pending</a>
            <a href="${pageContext.request.contextPath}/admin/sales/invoices?status=overdue" class="btn-outline">Overdue</a>
        </div>
    </div>
    
    <h2 style="margin-bottom: 20px;">All Invoices (<%= invoices != null ? invoices.size() : 0 %>)</h2>
    
    <table class="invoice-table">
        <thead>
            <tr>
                <th>Invoice #</th>
                <th>Client</th>
                <th>Date</th>
                <th>Due Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% if (invoices != null && !invoices.isEmpty()) { 
                for (Invoice inv : invoices) { 
                    User client = inv.getUser();
                    String statusClass = "";
                    if ("paid".equals(inv.getPaymentStatus())) statusClass = "status-paid";
                    else if ("pending".equals(inv.getPaymentStatus())) statusClass = "status-pending";
                    else statusClass = "status-overdue";
            %>
                <tr>
                    <td><strong><%= inv.getInvoiceNumber() %></strong></td>
                    <td><%= client != null ? client.getName() : "N/A" %></td>
                    <td><%= inv.getInvoiceDate() != null ? inv.getInvoiceDate().toLocalDate() : "N/A" %></td>
                    <td><%= inv.getDueDate() %></td>
                    <td><strong style="color: #2c8a3e;">$<%= String.format("%,.2f", inv.getTotalAmount()) %></strong></td>
                    <td><span class="status-badge <%= statusClass %>"><%= inv.getPaymentStatus() %></span></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/sales/invoices/<%= inv.getInvoiceId() %>" class="btn-view">View</a>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">
                        <div style="font-size: 24px; margin-bottom: 10px;">📄</div>
                        <h3 style="color: #666; margin-bottom: 10px;">No Invoices Found</h3>
                        <p style="color: #999;">Invoices will appear here after payments are completed.</p>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>