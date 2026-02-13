<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Invoice, model.CareService, model.Booking" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Service Usage Report</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .report-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 20px;
    }
    .filter-section {
        background: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-bottom: 30px;
    }
    .service-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    .service-card {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        padding: 20px;
        transition: transform 0.3s, box-shadow 0.3s;
        cursor: pointer;
        border: 2px solid transparent;
    }
    .service-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 20px rgba(44, 138, 62, 0.2);
        border-color: #2c8a3e;
    }
    .service-card.selected {
        border: 3px solid #2c8a3e;
        background: #f0f9f0;
    }
    .service-icon {
        font-size: 40px;
        margin-bottom: 10px;
    }
    .service-name {
        font-size: 20px;
        font-weight: bold;
        color: #2c8a3e;
        margin-bottom: 10px;
    }
    .service-description {
        color: #666;
        font-size: 14px;
        margin-bottom: 15px;
        line-height: 1.5;
        height: 60px;
        overflow: hidden;
    }
    .stats-preview {
        display: flex;
        justify-content: space-between;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 1px solid #eaeaea;
        color: #999;
        font-style: italic;
    }
    .service-stats {
        display: flex;
        justify-content: space-between;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 1px solid #eaeaea;
    }
    .stat-item {
        text-align: center;
    }
    .stat-value {
        font-size: 24px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .stat-label {
        font-size: 12px;
        color: #666;
        margin-top: 5px;
    }
    .usage-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
        margin-top: 30px;
    }
    .usage-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .usage-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .usage-table tr:hover {
        background: #f5f5f5;
    }
    .summary-card {
        background: linear-gradient(135deg, #2c8a3e, #1f6a2f);
        color: white;
        padding: 30px;
        border-radius: 10px;
        margin-bottom: 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .summary-card h2 {
        color: white;
        margin: 0;
        font-size: 28px;
    }
    .summary-card .total-revenue {
        font-size: 36px;
        font-weight: bold;
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
    .no-selection {
        text-align: center;
        padding: 80px 60px;
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    .no-selection-icon {
        font-size: 64px;
        margin-bottom: 20px;
        color: #ccc;
    }
    .service-tag {
        display: inline-block;
        margin: 0 10px;
        padding: 8px 16px;
        background: #f8f9fa;
        border-radius: 30px;
        color: #666;
        font-size: 14px;
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

List<CareService> services = (List<CareService>) request.getAttribute("services");
List<Invoice> invoices = (List<Invoice>) request.getAttribute("invoices");
CareService selectedService = (CareService) request.getAttribute("selectedService");
Double totalAmount = (Double) request.getAttribute("totalAmount");

// Calculate service statistics ONLY if a service is selected
Map<Integer, Integer> bookingCountMap = new HashMap<>();
Map<Integer, Double> revenueMap = new HashMap<>();
Map<Integer, Integer> clientCountMap = new HashMap<>();

if (selectedService != null && invoices != null) {
    for (Invoice inv : invoices) {
        Booking booking = inv.getBooking();
        if (booking != null && booking.getService() != null) {
            Integer sid = booking.getService().getServiceId();
            if (sid.equals(selectedService.getServiceId())) {
                revenueMap.put(sid, revenueMap.getOrDefault(sid, 0.0) + inv.getTotalAmount());
                bookingCountMap.put(sid, bookingCountMap.getOrDefault(sid, 0) + 1);
                
                Set<Integer> uniqueClients = (Set<Integer>) session.getAttribute("serviceClients_" + sid);
                if (uniqueClients == null) uniqueClients = new HashSet<>();
                if (booking.getUser() != null) {
                    uniqueClients.add(booking.getUser().getCustomerId());
                    session.setAttribute("serviceClients_" + sid, uniqueClients);
                }
                clientCountMap.put(sid, uniqueClients.size());
            }
        }
    }
}
%>

<div class="report-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
        <h1 style="font-size: 32px;">📊 Service Usage Report</h1>
        <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline">← Back to Dashboard</a>
    </div>
    
    <!-- Service Selection Grid -->
    <div class="filter-section">
        <h2 style="color: #2c8a3e; margin-bottom: 20px; font-size: 24px;">Select a Service to View Details</h2>
        <div class="service-grid">
            <% if (services != null) {
                for (CareService service : services) { 
                    Integer sid = service.getServiceId();
                    boolean isSelected = selectedService != null && selectedService.getServiceId().equals(sid);
            %>
                <div class="service-card <%= isSelected ? "selected" : "" %>" 
                     onclick="location.href='${pageContext.request.contextPath}/admin/sales/reports/service-usage?serviceId=<%= sid %>'">
                    <div class="service-icon">
                        <% if (service.getServiceName().toLowerCase().contains("home")) { %>🏠
                        <% } else if (service.getServiceName().toLowerCase().contains("meal")) { %>🍲
                        <% } else if (service.getServiceName().toLowerCase().contains("transport")) { %>🚗
                        <% } else { %>🛠️<% } %>
                    </div>
                    <div class="service-name"><%= service.getServiceName() %></div>
                    <div class="service-description">
                        <%= service.getDescription() != null ? 
                            (service.getDescription().length() > 120 ? 
                                service.getDescription().substring(0, 120) + "..." : 
                                service.getDescription()) : "No description available" %>
                    </div>
                    
                    <% if (isSelected) { %>
                        <%-- Show actual stats when selected --%>
                        <div class="service-stats">
                            <div class="stat-item">
                                <div class="stat-value"><%= bookingCountMap.getOrDefault(sid, 0) %></div>
                                <div class="stat-label">Bookings</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value"><%= clientCountMap.getOrDefault(sid, 0) %></div>
                                <div class="stat-label">Clients</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">$<%= String.format("%,.0f", revenueMap.getOrDefault(sid, 0.0)) %></div>
                                <div class="stat-label">Revenue</div>
                            </div>
                        </div>
                    <% } else { %>
                        <%-- Show preview message when not selected --%>
                        <div class="stats-preview">
                            <span>👆 Click to view detailed statistics</span>
                        </div>
                    <% } %>
                </div>
            <% } } %>
        </div>
    </div>
    
    <% if (selectedService != null) { %>
        <!-- Service Summary - Only shows when a service is selected -->
        <div class="summary-card">
            <div>
                <h2><%= selectedService.getServiceName() %></h2>
                <p style="opacity: 0.9; margin-top: 10px; font-size: 16px;">
                    <%= selectedService.getDescription() != null ? selectedService.getDescription() : "No description available" %>
                </p>
            </div>
            <div style="text-align: right;">
                <div style="font-size: 14px; opacity: 0.9; margin-bottom: 5px;">Total Revenue</div>
                <div class="total-revenue">$<%= String.format("%,.2f", totalAmount != null ? totalAmount : 0.0) %></div>
            </div>
        </div>
        
        <!-- Invoice Details Table - Only shows when a service is selected -->
        <h2 style="margin-bottom: 20px; color: #2c8a3e;">Invoice Details for <%= selectedService.getServiceName() %></h2>
        
        <table class="usage-table">
            <thead>
                <tr>
                    <th>Invoice #</th>
                    <th>Client</th>
                    <th>Date</th>
                    <th>Booking Period</th>
                    <th>Amount</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (invoices != null && !invoices.isEmpty()) {
                    for (Invoice inv : invoices) {
                        Booking booking = inv.getBooking();
                        String statusClass = inv.getPaymentStatus().equals("paid") ? "status-paid" : "status-pending";
                %>
                    <tr>
                        <td><strong><%= inv.getInvoiceNumber() %></strong></td>
                        <td><%= inv.getUser() != null ? inv.getUser().getName() : "N/A" %></td>
                        <td><%= inv.getInvoiceDate() != null ? inv.getInvoiceDate().toLocalDate() : "N/A" %></td>
                        <td>
                            <%= booking != null ? booking.getStartDate() + " to " + booking.getEndDate() : "N/A" %>
                        </td>
                        <td><strong style="color: #2c8a3e;">$<%= String.format("%,.2f", inv.getTotalAmount()) %></strong></td>
                        <td><span class="status-badge <%= statusClass %>"><%= inv.getPaymentStatus() %></span></td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/sales/invoices/<%= inv.getInvoiceId() %>" class="btn-view">
                                View
                            </a>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 40px;">
                            <div style="font-size: 24px; margin-bottom: 10px;">📄</div>
                            <h3 style="color: #666; margin-bottom: 10px;">No Invoices Found</h3>
                            <p style="color: #999;">This service has no paid invoices yet.</p>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
        
    <% } else { %>
        <!-- No Service Selected - Only shows when no service is clicked -->
        <div class="no-selection">
            <div class="no-selection-icon">📊</div>
            <h2 style="color: #666; margin-bottom: 15px; font-size: 28px;">No Service Selected</h2>
            <p style="color: #999; font-size: 18px; margin-bottom: 30px; max-width: 600px; margin-left: auto; margin-right: auto;">
                Click on any service card above to view detailed statistics, invoice history, and revenue breakdown.
            </p>
            <div style="display: flex; gap: 15px; justify-content: center; flex-wrap: wrap; margin-top: 30px;">
                <% if (services != null) {
                    for (CareService service : services) { 
                        String icon = "🛠️";
                        if (service.getServiceName().toLowerCase().contains("home")) icon = "🏠";
                        else if (service.getServiceName().toLowerCase().contains("meal")) icon = "🍲";
                        else if (service.getServiceName().toLowerCase().contains("transport")) icon = "🚗";
                %>
                    <span class="service-tag">
                        <%= icon %> <%= service.getServiceName() %>
                    </span>
                <% } } %>
            </div>
        </div>
    <% } %>
    
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>