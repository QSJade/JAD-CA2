<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="model.BookingCartItem"%>
<%@ page import="java.sql.*"%>
<%
ArrayList<BookingCartItem> cart = (ArrayList<BookingCartItem>) session.getAttribute("cart");
if (cart == null) {
    response.sendRedirect("viewCart.jsp");
    return;
}

String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";

for (int i = 0; i < cart.size(); i++) {
    String startParam = request.getParameter("startDate_" + i);
    String endParam = request.getParameter("endDate_" + i);
    String packageParam = request.getParameter("packageId_" + i);

    if (startParam != null && endParam != null) {
        BookingCartItem item = cart.get(i);
        item.setStartDate(startParam);
        item.setEndDate(endParam);

        if (packageParam != null) {
            int newPackageId = Integer.parseInt(packageParam);
            if (item.getPackageId() != newPackageId) {
                item.setPackageId(newPackageId);

                try {
                    Class.forName("org.postgresql.Driver");
                    Connection conn = DriverManager.getConnection(connURL);

                    // Get package info
                    PreparedStatement psPackage = conn.prepareStatement("SELECT package_name, multiplier FROM packages WHERE package_id=?");
                    psPackage.setInt(1, newPackageId);
                    ResultSet rsPackage = psPackage.executeQuery();
                    String packageName = "";
                    double multiplier = 1;
                    if (rsPackage.next()) {
                        packageName = rsPackage.getString("package_name");
                        multiplier = rsPackage.getDouble("multiplier");
                    }
                    item.setPackageName(packageName);
                    rsPackage.close();
                    psPackage.close();

                    // Get original service price
                    PreparedStatement psService = conn.prepareStatement("SELECT price_per_day FROM services WHERE service_id=?");
                    psService.setInt(1, item.getServiceId());
                    ResultSet rsService = psService.executeQuery();
                    double basePrice = 0;
                    if (rsService.next()) {
                        basePrice = rsService.getDouble("price_per_day");
                    }
                    item.setPricePerDay(basePrice * multiplier);
                    rsService.close();
                    psService.close();

                    conn.close();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error updating package for item " + i + ": " + e.getMessage() + "</p>");
                }
            }
        }
    }
}

session.setAttribute("cart", cart);
response.sendRedirect("viewCart.jsp");
%>
