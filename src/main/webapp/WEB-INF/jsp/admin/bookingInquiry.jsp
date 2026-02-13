<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.*, model.Booking, model.CareService, model.User" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking Inquiry</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .inquiry-container {
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
    .filter-form {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        align-items: flex-end;
    }
    .form-group {
        display: flex;
        flex-direction: column;
    }
    .form-group label {
        font-weight: bold;
        color: #2c8a3e;
        margin-bottom: 5px;
        font-size: 14px;
    }
    .form-group input,
    .form-group select {
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        font-size: 14px;
    }
    .bookings-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-radius: 8px;
        overflow: hidden;
    }
    .bookings-table th {
        background: #2c8a3e;
        color: white;
        padding: 12px;
        text-align: left;
    }
    .bookings-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .bookings-table tr:hover {
        background: #f5f5f5;
    }
    .status-badge {
        display: inline-block;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
    }
    .status-pending {
        background: #fff3cd;
        color: #856404;
    }
    .status-confirmed {
        background: #d4edc9;
        color: #2c8a3e;
    }
    .status-completed {
        background: #cce5ff;
        color: #004085;
    }
    .status-cancelled {
        background: #f8d7da;
        color: #721c24;
    }
    .summary-stats {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
        gap: 15px;
        margin-bottom: 20px;
    }
    .stat-box {
        background: #f8f9fa;
        padding: 15px;
        border-radius: 8px;
        text-align: center;
    }
    .stat-number {
        font-size: 24px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .btn-view {
        background: #3498db;
        color: white;
        padding: 4px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 12px;
        display: inline-block;
    }
    .btn-view:hover {
        background: #2980b9;
    }
    .btn-filter {
        background: #2c8a3e;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-filter:hover {
        background: #1f6a2f;
    }
    .btn-reset {
        background: #6c757d;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        text-decoration: none;
        display: inline-block;
    }
    .btn-reset:hover {
        background: #5a6268;
    }
    .no-invoice {
        color: #999;
        font-size: 12px;
        font-style: italic;
    }
    .export-btn {
        background: #6c757d;
        color: white;
        padding: 8px 16px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    .export-btn:hover {
        background: #5a6268;
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

List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
List<CareService> services = (List<CareService>) request.getAttribute("services");
String startDate = (String) request.getAttribute("startDate");
String endDate = (String) request.getAttribute("endDate");
Integer serviceId = (Integer) request.getAttribute("serviceId");
Integer customerId = (Integer) request.getAttribute("customerId");
String serviceName = (String) request.getAttribute("serviceName");
String period = request.getParameter("period");

// Get booking invoice map
Map<Integer, Integer> bookingInvoiceMap = (Map<Integer, Integer>) request.getAttribute("bookingInvoiceMap");
if (bookingInvoiceMap == null) {
    bookingInvoiceMap = new HashMap<>();
}

// Calculate summary stats
int pendingCount = 0, confirmedCount = 0, completedCount = 0, cancelledCount = 0;
double totalRevenue = 0;
int uniqueClients = 0;
Set<Integer> clientSet = new HashSet<>();

if (bookings != null) {
    for (Booking b : bookings) {
        if ("pending".equalsIgnoreCase(b.getStatus())) pendingCount++;
        else if ("confirmed".equalsIgnoreCase(b.getStatus())) {
            confirmedCount++;
            if (b.getTotalAmount() != null) totalRevenue += b.getTotalAmount();
        }
        else if ("completed".equalsIgnoreCase(b.getStatus())) {
            completedCount++;
            if (b.getTotalAmount() != null) totalRevenue += b.getTotalAmount();
        }
        else if ("cancelled".equalsIgnoreCase(b.getStatus())) cancelledCount++;
        
        if (b.getUser() != null) {
            clientSet.add(b.getUser().getCustomerId());
        }
    }
    uniqueClients = clientSet.size();
}

// Handle period filters
if (period != null) {
    LocalDate today = LocalDate.now();
    LocalDate start = null;
    LocalDate end = today;
    
    if ("today".equals(period)) {
        start = today;
    } else if ("week".equals(period)) {
        start = today.minusDays(7);
    } else if ("month".equals(period)) {
        start = today.minusDays(30);
    }
    
    if (start != null) {
        startDate = start.toString();
        endDate = end.toString();
    }
}
%>

<div class="inquiry-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
        <h1 style="font-size: 32px;">📅 Booking Inquiry</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline">← Back to Dashboard</a>
        </div>
    </div>
    
    <!-- Filter Form -->
    <div class="filter-section">
        <h3 style="color: #2c8a3e; margin-bottom: 20px; font-size: 20px;">Filter Bookings</h3>
        <form method="get" action="${pageContext.request.contextPath}/admin/sales/bookings" class="filter-form">
            <div class="form-group">
                <label>Start Date</label>
                <input type="date" name="startDate" value="<%= startDate != null ? startDate : "" %>">
            </div>
            <div class="form-group">
                <label>End Date</label>
                <input type="date" name="endDate" value="<%= endDate != null ? endDate : "" %>">
            </div>
            <div class="form-group">
                <label>Service</label>
                <select name="serviceId">
                    <option value="">All Services</option>
                    <% if (services != null) {
                        for (CareService s : services) { %>
                            <option value="<%= s.getServiceId() %>" <%= serviceId != null && serviceId.equals(s.getServiceId()) ? "selected" : "" %>>
                                <%= s.getServiceName() %>
                            </option>
                    <% } } %>
                </select>
            </div>
            <div class="form-group">
                <label>Customer ID</label>
                <input type="number" name="customerId" placeholder="Enter customer ID" value="<%= customerId != null ? customerId : "" %>">
            </div>
            <div class="form-group">
                <label>&nbsp;</label>
                <div style="display: flex; gap: 10px;">
                    <button type="submit" class="btn-filter">Apply Filters</button>
                    <a href="${pageContext.request.contextPath}/admin/sales/bookings" class="btn-reset">Reset</a>
                </div>
            </div>
        </form>
        
        <!-- Quick Filter Links -->
        <div style="margin-top: 20px; display: flex; gap: 10px; flex-wrap: wrap;">
            <span style="font-weight: bold; color: #666; padding: 8px 0;">Quick Filters:</span>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?period=today" class="btn-outline <%= "today".equals(period) ? "active" : "" %>">Today</a>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?period=week" class="btn-outline <%= "week".equals(period) ? "active" : "" %>">Last 7 Days</a>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?period=month" class="btn-outline <%= "month".equals(period) ? "active" : "" %>">Last 30 Days</a>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?status=pending" class="btn-outline">Pending</a>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?status=confirmed" class="btn-outline">Confirmed</a>
            <a href="${pageContext.request.contextPath}/admin/sales/bookings?status=completed" class="btn-outline">Completed</a>
        </div>
    </div>
    
    <!-- Summary Statistics -->
    <div class="summary-stats">
        <div class="stat-box">
            <div class="stat-number"><%= bookings != null ? bookings.size() : 0 %></div>
            <div style="color: #666;">Total Bookings</div>
        </div>
        <div class="stat-box">
            <div class="stat-number"><%= pendingCount %></div>
            <div style="color: #856404;">Pending</div>
        </div>
        <div class="stat-box">
            <div class="stat-number"><%= confirmedCount %></div>
            <div style="color: #2c8a3e;">Confirmed</div>
        </div>
        <div class="stat-box">
            <div class="stat-number"><%= completedCount %></div>
            <div style="color: #004085;">Completed</div>
        </div>
        <div class="stat-box">
            <div class="stat-number"><%= uniqueClients %></div>
            <div style="color: #666;">Unique Clients</div>
        </div>
        <div class="stat-box">
            <div class="stat-number">$<%= String.format("%,.0f", totalRevenue) %></div>
            <div style="color: #2c8a3e;">Total Revenue</div>
        </div>
    </div>
    
    <!-- Results Header -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <h2 style="font-size: 24px;">
            <%= bookings != null ? bookings.size() : 0 %> Bookings Found
            <% if (serviceName != null) { %>
                - <span style="color: #2c8a3e;"><%= serviceName %></span>
            <% } %>
            <% if (startDate != null && endDate != null) { %>
                - <span style="color: #666;"><%= startDate %> to <%= endDate %></span>
            <% } %>
            <% if (customerId != null) { %>
                - Customer #<%= customerId %>
            <% } %>
        </h2>
        
        <!-- Export Options -->
        <div>
            <button onclick="exportToCSV()" class="export-btn">📊 Export CSV</button>
        </div>
    </div>
    
    <!-- Bookings Table -->
    <table class="bookings-table">
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Client</th>
                <th>Service</th>
                <th>Package</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Days</th>
                <th>Status</th>
                <th>Amount</th>
                <th>Invoice</th>
            </tr>
        </thead>
        <tbody>
            <% if (bookings != null && !bookings.isEmpty()) { 
                for (Booking b : bookings) { 
                    User client = b.getUser();
                    String statusClass = "";
                    if ("pending".equalsIgnoreCase(b.getStatus())) statusClass = "status-pending";
                    else if ("confirmed".equalsIgnoreCase(b.getStatus())) statusClass = "status-confirmed";
                    else if ("completed".equalsIgnoreCase(b.getStatus())) statusClass = "status-completed";
                    else statusClass = "status-cancelled";
                    
                    long days = 0;
                    if (b.getStartDate() != null && b.getEndDate() != null) {
                        days = java.time.temporal.ChronoUnit.DAYS.between(b.getStartDate(), b.getEndDate()) + 1;
                    }
                    
                    // Get invoice ID for this booking
                    Integer invoiceId = bookingInvoiceMap.get(b.getBookingId());
            %>
                <tr>
                    <td><strong>#<%= b.getBookingId() %></strong></td>
                    <td>
                        <% if (client != null) { %>
                            <a href="${pageContext.request.contextPath}/admin/clients/<%= client.getCustomerId() %>" style="color: #2c8a3e; text-decoration: none; font-weight: bold;">
                                <%= client.getName() %>
                            </a>
                            <br><small style="color: #666;">ID: <%= client.getCustomerId() %></small>
                        <% } else { %>
                            N/A
                        <% } %>
                    </td>
                    <td><%= b.getService() != null ? b.getService().getServiceName() : "N/A" %></td>
                    <td><%= b.getServicePackage() != null ? b.getServicePackage().getPackageName() : "N/A" %></td>
                    <td><%= b.getStartDate() %></td>
                    <td><%= b.getEndDate() %></td>
                    <td style="text-align: center;"><%= days %></td>
                    <td><span class="status-badge <%= statusClass %>"><%= b.getStatus().toUpperCase() %></span></td>
                    <td><strong style="color: #2c8a3e;">$<%= b.getTotalAmount() != null ? String.format("%,.2f", b.getTotalAmount()) : "0.00" %></strong></td>
                    <td>
                        <% if (invoiceId != null) { %>
                            <a href="${pageContext.request.contextPath}/admin/sales/invoices/<%= invoiceId %>" class="btn-view">View Invoice</a>
                        <% } else { %>
                            <span class="no-invoice">No invoice</span>
                        <% } %>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="10" style="text-align: center; padding: 60px;">
                        <div style="font-size: 48px; margin-bottom: 20px;">📅</div>
                        <h3 style="color: #666; margin-bottom: 10px; font-size: 24px;">No Bookings Found</h3>
                        <p style="color: #999; font-size: 16px;">Try adjusting your filter criteria or create a new booking.</p>
                        <div style="margin-top: 30px;">
                            <a href="${pageContext.request.contextPath}/admin/sales" class="btn-outline" style="margin-right: 10px;">← Back to Dashboard</a>
                            <a href="${pageContext.request.contextPath}/admin/clients" class="btn-outline">👥 View Clients</a>
                        </div>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
</div>

<script>
function exportToCSV() {
    let csv = [];
    let rows = document.querySelectorAll(".bookings-table tr");
    
    for (let i = 0; i < rows.length; i++) {
        let row = [], cols = rows[i].querySelectorAll("td, th");
        for (let j = 0; j < cols.length; j++) {
            let text = cols[j].innerText.replace(/,/g, '').replace(/\n/g, ' ');
            row.push('"' + text + '"');
        }
        csv.push(row.join(','));
    }
    
    let csvContent = csv.join("\n");
    let blob = new Blob([csvContent], { type: 'text/csv' });
    let url = window.URL.createObjectURL(blob);
    let a = document.createElement("a");
    a.href = url;
    a.download = "bookings_<%= LocalDate.now() %>.csv";
    a.click();
    window.URL.revokeObjectURL(url);
}
</script>

<%@ include file="../footer.jsp" %>
</body>
</html>