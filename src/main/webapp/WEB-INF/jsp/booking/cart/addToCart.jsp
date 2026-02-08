<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.BookingCartItem" %>
<%
Integer customerId = (Integer) session.getAttribute("sessCustomerId");
if (customerId == null) {
    response.sendRedirect("../login.jsp?errCode=notLoggedIn");
    return;
}

// Get form data
int serviceId = Integer.parseInt(request.getParameter("serviceId"));
int packageId = Integer.parseInt(request.getParameter("packageId"));
String serviceName = request.getParameter("serviceName");
String packageName = request.getParameter("packageName");
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");
String notes = request.getParameter("notes");
String address = request.getParameter("address");

double basePrice = 0;
double multiplier = 1;

try {
    Class.forName("org.postgresql.Driver");
    String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
    Connection conn = DriverManager.getConnection(connURL);
    
    // Get service price
    PreparedStatement psService = conn.prepareStatement("SELECT price_per_day FROM services WHERE service_id=?");
    psService.setInt(1, serviceId);
    ResultSet rsService = psService.executeQuery();
    if(rsService.next()) {
        basePrice = rsService.getDouble("price_per_day");
    }

    // Get package multiplier
    PreparedStatement psPackage = conn.prepareStatement("SELECT multiplier FROM packages WHERE package_id=?");
    psPackage.setInt(1, packageId);
    ResultSet rsPackage = psPackage.executeQuery();
    if(rsPackage.next()) {
        multiplier = rsPackage.getDouble("multiplier");
    }

    conn.close();
} catch(Exception e) {
    out.println("Error: " + e.getMessage());
}

// Calculate final price per day
double pricePerDay = basePrice * multiplier;

// Add to cart
ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");
if (cart == null) {
    cart = new ArrayList<>();
    session.setAttribute("cart", cart);
}
cart.add(new BookingCartItem(serviceId, packageId, serviceName, packageName, startDate, endDate, notes, address, pricePerDay));

response.sendRedirect("viewCart.jsp");
%>
