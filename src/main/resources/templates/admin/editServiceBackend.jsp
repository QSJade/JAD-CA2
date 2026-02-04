<%@ page import="java.sql.*" %>

<%
String id = request.getParameter("id");
String name = request.getParameter("serviceName");
String details = request.getParameter("serviceDetails");
String price = request.getParameter("price");

if (id != null && name != null && details != null && price != null) {
    try {
        Class.forName("org.postgresql.Driver");

        Connection conn = DriverManager.getConnection(
            "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require"
        );

        String sql = "UPDATE services SET service_name = ?, description = ?, price_per_day = ? WHERE service_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, name);
        ps.setString(2, details);
        ps.setBigDecimal(3, new java.math.BigDecimal(price));
        ps.setInt(4, Integer.parseInt(id));

        int rows = ps.executeUpdate();

        ps.close();
        conn.close();

        response.sendRedirect("adminService.jsp?msg=updated");

    } catch (Exception e) {
        out.print("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
}
%>
