<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Top Clients Report</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .report-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    .report-header {
        background: linear-gradient(135deg, #2c8a3e, #1f6a2f);
        color: white;
        padding: 30px;
        border-radius: 10px;
        margin-bottom: 30px;
    }
    .rank-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
    }
    .rank-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .rank-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .rank-table tr:hover {
        background: #f5f5f5;
    }
    .rank-1 {
        background: #ffd700;
        font-weight: bold;
    }
    .rank-2 {
        background: #c0c0c0;
    }
    .rank-3 {
        background: #cd7f32;
    }
    .stat-card {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        margin-bottom: 20px;
    }
    .btn-print {
        background: #3498db;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-print:hover {
        background: #2980b9;
    }
    /* Print styles - hide navbar, footer, buttons when printing */
@media print {
    /* Hide header, footer, and navigation */
    header, footer, nav, .navbar, .header, .button-group, 
    .btn-outline, .btn-update, .btn-print, .logout-btn,
    a[href], .action-buttons, .sidebar, .dashboard-header {
        display: none !important;
    }
    
    /* Show only the invoice card */
    .invoice-card {
        box-shadow: none !important;
        padding: 0 !important;
        margin: 0 !important;
        border: none !important;
    }
    
    /* Ensure invoice takes full page */
    .invoice-container {
        padding: 0 !important;
        margin: 0 !important;
        max-width: 100% !important;
    }
    
    /* Ensure table borders print */
    .items-table th, .items-table td {
        border: 1px solid #000 !important;
    }
    
    /* Hide print button itself when printing */
    .btn-print, button[onclick*="print"] {
        display: none !important;
    }
    
    /* Add invoice title for print */
    .invoice-header h1 {
        color: black !important;
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

List<Object[]> topClients = (List<Object[]>) request.getAttribute("topClients");
Integer reportMonth = (Integer) request.getAttribute("reportMonth");
Integer reportYear = (Integer) request.getAttribute("reportYear");

double totalSpentAll = 0;
if (topClients != null) {
    for (Object[] client : topClients) {
        totalSpentAll += (Double) client[2];
    }
}
%>

<div class="report-container">
    <div class="report-header">
        <h1 style="color: white; margin-bottom: 10px;">🏆 Top Clients Report</h1>
        <p style="font-size: 18px; opacity: 0.9;">
            <%= reportMonth != null && reportYear != null ? 
                "For " + reportMonth + "/" + reportYear : "All Time" %>
        </p>
    </div>
    
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div>
            <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline">← Back to Dashboard</a>
        </div>
        <div>
            <button onclick="window.print()" class="btn-print">🖨️ Print Report</button>
        </div>
    </div>
    
    <!-- Summary Stats -->
    <div class="stat-card">
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; text-align: center;">
            <div>
                <div style="font-size: 14px; color: #666;">Total Clients</div>
                <div style="font-size: 32px; font-weight: bold; color: #2c8a3e;"><%= topClients != null ? topClients.size() : 0 %></div>
            </div>
            <div>
                <div style="font-size: 14px; color: #666;">Total Revenue</div>
                <div style="font-size: 32px; font-weight: bold; color: #2c8a3e;">$<%= String.format("%,.2f", totalSpentAll) %></div>
            </div>
            <div>
                <div style="font-size: 14px; color: #666;">Average per Client</div>
                <div style="font-size: 32px; font-weight: bold; color: #2c8a3e;">
                    $<%= topClients != null && topClients.size() > 0 ? 
                        String.format("%,.2f", totalSpentAll / topClients.size()) : "0.00" %>
                </div>
            </div>
        </div>
    </div>
    
    <h2 style="margin-bottom: 20px;">Top Spending Clients</h2>
    
    <table class="rank-table">
        <thead>
            <tr>
                <th style="width: 80px;">Rank</th>
                <th>Client ID</th>
                <th>Client Name</th>
                <th>Total Spent</th>
                <th>% of Total</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% if (topClients != null && !topClients.isEmpty()) { 
                int rank = 1;
                for (Object[] client : topClients) { 
                    Integer clientId = (Integer) client[0];
                    String clientName = (String) client[1];
                    Double totalSpent = (Double) client[2];
                    Double percentage = (totalSpentAll > 0) ? (totalSpent * 100 / totalSpentAll) : 0;
                    
                    String rankClass = "";
                    if (rank == 1) rankClass = "rank-1";
                    else if (rank == 2) rankClass = "rank-2";
                    else if (rank == 3) rankClass = "rank-3";
            %>
                <tr>
                    <td style="font-weight: bold; font-size: 18px;">
                        <%= rank == 1 ? "🥇" : (rank == 2 ? "🥈" : (rank == 3 ? "🥉" : rank)) %>
                    </td>
                    <td><%= clientId %></td>
                    <td><strong><%= clientName %></strong></td>
                    <td><%= client.length > 3 ? client[3] : "N/A" %></td>
                    <td><strong style="color: #2c8a3e;">$<%= String.format("%,.2f", totalSpent) %></strong></td>
                    <td><%= String.format("%.1f", percentage) %>%</td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/clients/<%= clientId %>" 
                           style="background: #3498db; color: white; padding: 4px 12px; border-radius: 4px; text-decoration: none; font-size: 12px;">
                            View Profile
                        </a>
                    </td>
                </tr>
            <%      rank++;
                } 
            } else { %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 40px;">
                        No client data available.
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
    
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>