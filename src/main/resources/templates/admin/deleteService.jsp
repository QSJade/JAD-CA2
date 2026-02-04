<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%

String cp = request.getContextPath(); 

String id = request.getParameter("id");

if (id != null) {
    try {
        Class.forName("org.postgresql.Driver");

        String connURL =
         "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";

        Connection conn = DriverManager.getConnection(connURL);

        String sql = "DELETE FROM services WHERE service_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(id));

        int rows = ps.executeUpdate();

        ps.close();
        conn.close();

        if (rows > 0) {
            // Redirect back to service list page
  
            response.sendRedirect("adminService.jsp");
        } else {
            out.println("<p style='color:red;'>Failed to delete service.</p>");
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
} else {
    out.println("<p style='color:red;'>Invalid service ID.</p>");
}
%>
