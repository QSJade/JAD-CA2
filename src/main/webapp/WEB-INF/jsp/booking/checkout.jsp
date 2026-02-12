<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.BookingCartItem" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
List<BookingCartItem> cartItems = (List<BookingCartItem>) request.getAttribute("cartItems");
Double subtotal = (Double) request.getAttribute("subtotal");
Double gst = (Double) request.getAttribute("gst");
Double total = (Double) request.getAttribute("total");

if (cartItems == null) {
    response.sendRedirect(request.getContextPath() + "/cart/view");
    return;
}

Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect(request.getContextPath() + "/login?errCode=notLoggedIn");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Checkout</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
    .checkout-container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .checkout-table { width: 100%; border-collapse: collapse; margin: 20px 0; background: white; box-shadow: 0 2px 10px rgba(0,0,0,0.1); border-radius: 8px; }
    .checkout-table th { background: #2c8a3e; color: white; padding: 12px; text-align: left; }
    .checkout-table td { padding: 12px; border-bottom: 1px solid #eaeaea; }
    .checkout-table tr:last-child td { border-bottom: none; }
    .totals-table { width: 400px; margin-left: auto; background: white; box-shadow: 0 2px 10px rgba(0,0,0,0.1); border-radius: 8px; }
    .totals-table td { padding: 12px; border-bottom: 1px solid #eaeaea; }
    .totals-table tr:last-child td { border-bottom: none; font-weight: bold; font-size: 1.1em; color: #2c8a3e; }
    .payment-section { text-align: center; margin: 30px 0; padding: 20px; background: #f8f9fa; border-radius: 8px; }
    .pay-button { background-color: #4CAF50; color: white; padding: 15px 40px; border: none; border-radius: 8px; font-size: 18px; font-weight: bold; cursor: pointer; transition: background-color 0.3s; }
    .pay-button:hover { background-color: #23913f; }
    .pay-button:disabled { background-color: #cccccc; cursor: not-allowed; }
    .error-message { color: #e74c3c; background-color: #fdeaea; padding: 10px; border-radius: 5px; margin: 10px 0; display: none; }
</style>
</head>
<body>
<%@ include file="../header.jsp" %>

<div class="checkout-container">
    <h1>Checkout</h1>
    
    <div id="errorMessage" class="error-message"></div>
    
    <table class="checkout-table">
        <thead>
            <tr>
                <th>Service</th>
                <th>Package</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Days</th>
                <th>Price/Day</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
        <%
        for (BookingCartItem item : cartItems) {
            LocalDate start = LocalDate.parse(item.getStartDate());
            LocalDate end = LocalDate.parse(item.getEndDate());
            long days = ChronoUnit.DAYS.between(start, end) + 1;
            double itemTotal = item.getPricePerDay() * days;
        %>
            <tr>
                <td><%= item.getServiceName() %></td>
                <td><%= item.getPackageName() %></td>
                <td><%= item.getStartDate() %></td>
                <td><%= item.getEndDate() %></td>
                <td><%= days %></td>
                <td>$<%= String.format("%.2f", item.getPricePerDay()) %></td>
                <td>$<%= String.format("%.2f", itemTotal) %></td>
            </tr>
        <%
        }
        %>
        </tbody>
    </table>
    
    <table class="totals-table">
        <tr>
            <td style="text-align: right;"><strong>Subtotal:</strong></td>
            <td style="text-align: right;">$<%= String.format("%.2f", subtotal) %></td>
        </tr>
        <tr>
            <td style="text-align: right;"><strong>GST (9%):</strong></td>
            <td style="text-align: right;">$<%= String.format("%.2f", gst) %></td>
        </tr>
        <tr>
            <td style="text-align: right;"><strong>Total:</strong></td>
            <td style="text-align: right; color: #2c8a3e; font-size: 1.2em;">
                $<%= String.format("%.2f", total) %>
            </td>
        </tr>
    </table>
    
    <div class="payment-section">
        <button id="payBtn" class="pay-button">Pay Now with Stripe</button>
        <br><br>
        <a href="${pageContext.request.contextPath}/cart/view" class="btn-outline">Back to Cart</a>
    </div>
</div>

<script src="https://js.stripe.com/v3/"></script>
<script>
const stripe = Stripe("pk_test_51SsDLV7JAQOUwt4TDGl0QVyxrTkZgF1BU7kxqf8VXrz2OQh03mQ2igl4l4cLa7jJXeoL0VcdPnfEBaD1BXzyrGvQ001gVHC5iT");
const payBtn = document.getElementById('payBtn');
const errorDiv = document.getElementById('errorMessage');

payBtn.addEventListener('click', async function() {
    try {
        payBtn.disabled = true;
        payBtn.textContent = 'Redirecting to Stripe...';
        errorDiv.style.display = 'none';
        
        const response = await fetch('${pageContext.request.contextPath}/stripe/checkout', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        if (!response.ok) {
            throw new Error('Failed to create checkout session');
        }
        
        const data = await response.json();
        
        if (!data.id) {
            throw new Error('No session ID returned');
        }
        
        const result = await stripe.redirectToCheckout({
            sessionId: data.id
        });
        
        if (result.error) {
            throw new Error(result.error.message);
        }
        
    } catch (error) {
        errorDiv.textContent = 'Payment failed: ' + error.message;
        errorDiv.style.display = 'block';
        payBtn.disabled = false;
        payBtn.textContent = 'Pay Now with Stripe';
    }
});
</script>

<%@ include file="../footer.jsp" %>
</body>
</html>