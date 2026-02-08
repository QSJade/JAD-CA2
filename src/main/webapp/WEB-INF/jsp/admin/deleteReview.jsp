<%@ page import="java.sql.*" %>

<%
    int id = Integer.parseInt(request.getParameter("id"));

    try {
        Class.forName("org.postgresql.Driver");
        String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
        Connection conn = DriverManager.getConnection(connURL);

        String sql = "DELETE FROM feedbacks WHERE feedback_id = ?";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, id);

        pstmt.executeUpdate();
        conn.close();

        response.sendRedirect("http://localhost:8080/ST0510-JAD-Practical/JAD-assignment-1/src/main/webapp/assignment1/reviewAdmin.jsp");

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
