<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Service</title>
<link rel="stylesheet" href="css/style.css">

<style>
    body { font-family: Arial; background: #f7f7f7; margin: 0; }
    .main-content {
        display: flex; justify-content: center; align-items: flex-start;
        padding: 40px 0; min-height: calc(100vh - 100px);
    }
    .form-container {
        background: #fff; padding: 30px 40px; border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 400px; max-width: 90%;
    }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; font-size: 14px; margin-bottom: 5px; }
    .form-group input, .form-group textarea {
        width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 5px;
    }
    .btn-save { background: #007bff; color: #fff; border: none; padding: 10px 25px; border-radius: 5px; cursor: pointer; }
    .btn-save:hover { background: #0056b3; }
</style>
</head>
<body>

<jsp:include page="<%= request.getContextPath() %>/header.jsp" />

<div class="main-content">
    <div class="form-container">
        <h2>Edit Service</h2>

        <%
            String id = request.getParameter("id");
            String serviceName = "";
            String description = "";
            String price = "";

            if (id != null) {
                try {
                    Class.forName("org.postgresql.Driver");

                    Connection conn = DriverManager.getConnection(
                        "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require"
                    );

                    String sql = "SELECT service_name, description, price_per_day FROM services WHERE service_id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, Integer.parseInt(id));

                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        serviceName = rs.getString("service_name");
                        description = rs.getString("description");
                        price = rs.getString("price_per_day");
                    }

                    rs.close(); ps.close(); conn.close();

                } catch(Exception e) {
                    out.print("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                }
            }
        %>

        <!-- EDIT FORM -->
        <form action="editServiceBackend.jsp" method="post">
            <input type="hidden" name="id" value="<%= id %>">

            <div class="form-group">
                <label>Name:</label>
                <input type="text" name="serviceName" value="<%= serviceName %>" required>
            </div>

            <div class="form-group">
                <label>Description:</label>
                <textarea name="serviceDetails" required><%= description %></textarea>
            </div>

            <div class="form-group">
                <label>Price Per Day:</label>
                <input type="number" name="price" step="0.01" value="<%= price %>" required>
            </div>

            <button type="submit" class="btn-save">Save Changes</button>
        </form>

    </div>
</div>

<jsp:include page="<%= request.getContextPath() %>/footer.jsp" />

</body>
</html>
