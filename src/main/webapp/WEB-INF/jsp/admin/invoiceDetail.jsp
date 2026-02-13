<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Invoice, model.InvoiceItem, model.User, model.Booking" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Invoice Details</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .invoice-container {
        max-width: 1000px;
        margin: 0 auto;
        padding: 20px;
    }
    .invoice-card {
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 15px rgba(0,0,0,0.1);
        padding: 40px;
        margin-bottom: 30px;
    }
    .invoice-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 40px;
        padding-bottom: 20px;
        border-bottom: 2px solid #eaeaea;
    }
    .invoice-title h1 {
        color: #2c8a3e;
        margin-bottom: 5px;
    }
    .invoice-status {
        text-align: right;
    }
    .status-badge {
        display: inline-block;
        padding: 8px 20px;
        border-radius: 30px;
        font-weight: bold;
        font-size: 14px;
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
    .info-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 30px;
        margin-bottom: 40px;
    }
    .info-section h3 {
        color: #2c8a3e;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 1px solid #eaeaea;
    }
    .info-row {
        display: flex;
        margin-bottom: 10px;
    }
    .info-label {
        width: 120px;
        font-weight: bold;
        color: #666;
    }
    .info-value {
        flex: 1;
    }
    .items-table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
    }
    .items-table th {
        background: #f8f9fa;
        padding: 12px;
        text-align: left;
    }
    .items-table td {
        padding: 12px;
        border-bottom: 1px solid #eaeaea;
    }
    .totals {
        margin-top: 30px;
        text-align: right;
    }
    .totals table {
        width: 300px;
        margin-left: auto;
    }
    .totals td {
        padding: 8px;
    }
    .totals .grand-total {
        font-size: 18px;
        font-weight: bold;
        color: #2c8a3e;
    }
    .button-group {
        display: flex;
        gap: 15px;
        margin-top: 30px;
        justify-content: flex-end;
    }
    .error-message {
        background: #f8d7da;
        color: #721c24;
        padding: 20px;
        border-radius: 8px;
        text-align: center;
        margin: 20px 0;
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

Invoice invoice = (Invoice) request.getAttribute("invoice");
if (invoice == null) {
    response.sendRedirect(request.getContextPath() + "/admin/sales/invoices");
    return;
}

// Safely get related entities with null checks
User client = null;
Booking booking = null;
List<InvoiceItem> invoiceItems = null;
boolean hasItems = false;

try {
    client = invoice.getUser();
    booking = invoice.getBooking();
    
    // Safely initialize the lazy collection
    if (invoice.getInvoiceItems() != null) {
        invoiceItems = invoice.getInvoiceItems();
        // Force initialization by calling size()
        hasItems = invoiceItems != null && invoiceItems.size() > 0;
    }
} catch (Exception e) {
    // Log the error but continue - we'll show an error message in the table
    System.err.println("Error loading invoice items: " + e.getMessage());
    hasItems = false;
}

DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");

String statusClass = "status-pending";
String statusText = "PENDING";
if (invoice.getPaymentStatus() != null) {
    statusText = invoice.getPaymentStatus().toUpperCase();
    if ("paid".equalsIgnoreCase(invoice.getPaymentStatus())) {
        statusClass = "status-paid";
    } else if ("pending".equalsIgnoreCase(invoice.getPaymentStatus())) {
        statusClass = "status-pending";
    } else {
        statusClass = "status-overdue";
    }
}
%>

<div class="invoice-container">    
    <div class="invoice-card">
        <div class="invoice-header">
            <div class="invoice-title">
                <h1>INVOICE</h1>
                <p style="color: #666; font-size: 18px;"><%= invoice.getInvoiceNumber() != null ? invoice.getInvoiceNumber() : "N/A" %></p>
            </div>
            <div class="invoice-status">
                <span class="status-badge <%= statusClass %>"><%= statusText %></span>
            </div>
        </div>
        
        <div class="info-grid">
            <div class="info-section">
                <h3>Bill To:</h3>
                <div class="info-row">
                    <div class="info-label">Client ID:</div>
                    <div class="info-value"><%= client != null ? client.getCustomerId() : "N/A" %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Name:</div>
                    <div class="info-value"><strong><%= client != null ? client.getName() : "N/A" %></strong></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Email:</div>
                    <div class="info-value"><%= client != null ? client.getEmail() : "N/A" %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Address:</div>
                    <div class="info-value"><%= (client != null && client.getAddress() != null) ? client.getAddress() : "N/A" %></div>
                </div>
            </div>
            
            <div class="info-section">
                <h3>Invoice Details:</h3>
                <div class="info-row">
                    <div class="info-label">Invoice Date:</div>
                    <div class="info-value"><%= invoice.getInvoiceDate() != null ? dateFormatter.format(invoice.getInvoiceDate()) : "N/A" %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Due Date:</div>
                    <div class="info-value"><%= invoice.getDueDate() != null ? dateFormatter.format(invoice.getDueDate()) : "N/A" %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Booking ID:</div>
                    <div class="info-value"><%= booking != null ? booking.getBookingId() : "N/A" %></div>
                </div>
                <div class="info-row">
                    <div class="info-label">Payment Date:</div>
                    <div class="info-value"><%= invoice.getPaymentDate() != null ? dateFormatter.format(invoice.getPaymentDate()) : "Not paid" %></div>
                </div>
            </div>
        </div>
        
        <h3 style="color: #2c8a3e; margin: 30px 0 15px;">Invoice Items</h3>
        
        <table class="items-table">
            <thead>
                <tr>
                    <th>Description</th>
                    <th style="text-align: right;">Quantity</th>
                    <th style="text-align: right;">Unit Price</th>
                    <th style="text-align: right;">Amount</th>
                </tr>
            </thead>
            <tbody>
                <% if (hasItems) { 
                    for (InvoiceItem item : invoiceItems) { 
                        if (item != null) {
                %>
                    <tr>
                        <td><%= item.getDescription() != null ? item.getDescription() : "N/A" %></td>
                        <td style="text-align: right;"><%= item.getQuantity() != null ? item.getQuantity() + " day(s)" : "0" %></td>
                        <td style="text-align: right;">$<%= item.getUnitPrice() != null ? String.format("%,.2f", item.getUnitPrice()) : "0.00" %></td>
                        <td style="text-align: right;">$<%= item.getAmount() != null ? String.format("%,.2f", item.getAmount()) : "0.00" %></td>
                    </tr>
                <%      } 
                    } 
                } else { %>
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 30px;">
                            <div style="font-size: 24px; margin-bottom: 10px;">📄</div>
                            <h3 style="color: #666; margin-bottom: 10px;">No Invoice Items Found</h3>
                            <p style="color: #999;">This invoice has no line items.</p>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
        
        <div class="totals">
            <table>
                <tr>
                    <td style="text-align: right;">Subtotal:</td>
                    <td style="text-align: right; width: 100px;">
                        $<%= invoice.getSubtotal() != null ? String.format("%,.2f", invoice.getSubtotal()) : "0.00" %>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: right;">GST (9%):</td>
                    <td style="text-align: right;">
                        $<%= invoice.getGst() != null ? String.format("%,.2f", invoice.getGst()) : "0.00" %>
                    </td>
                </tr>
                <tr class="grand-total">
                    <td style="text-align: right;"><strong>Total:</strong></td>
                    <td style="text-align: right;">
                        <strong>$<%= invoice.getTotalAmount() != null ? String.format("%,.2f", invoice.getTotalAmount()) : "0.00" %></strong>
                    </td>
                </tr>
            </table>
        </div>
        
        <div class="button-group">
            <button onclick="window.print()" class="btn-update">
                <span style="font-size: 16px;">🖨️</span> Print Invoice
            </button>
            <a href="${pageContext.request.contextPath}/admin/sales/invoices" class="btn-outline">
                ← Back to List
            </a>
        </div>
    </div>
</div>

<%@ include file="../footer.jsp" %>
</body>
</html>