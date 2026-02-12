<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Review Board</title>

<style>
/* --- GENERAL --- */
body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #f7f7f7;
}

/* --- SIDEBAR --- */
.sidebar {
    width: 160px;
    background: #e7f5e8;
    height: 100vh;
    position: fixed;
    top: 0;
    left: 0;
    padding: 25px 10px;
}

.sidebar h3 {
    text-align: center;
    margin-bottom: 20px;
}

.sidebar a {
    display: block;
    padding: 8px;
    background: white;
    text-decoration: none;
    color: black;
    border-radius: 4px;
    margin-bottom: 10px;
    text-align: center;
}

.sidebar a:hover {
    background: #d9eadb;
}

/* --- MAIN CONTENT --- */
.main {
    margin-left: 200px;
    padding: 20px;
}

.main h2 {
    text-align: center;
    margin-top: 10px;
    margin-bottom: 40px;
}

/* --- REVIEW CARD --- */
.review-card {
    width: 90%;
    background: white;
    padding: 20px 25px;
    border-radius: 10px;
    margin: 0 auto 20px auto;
    box-shadow: 0 0 8px rgba(0,0,0,0.08);
}

.review-header {
    display: flex;
    justify-content: space-between;
    font-weight: bold;
}

.review-sub {
    font-size: 13px;
    color: gray;
}

.rating {
    font-size: 18px;
    font-weight: bold;
    color: #47a34b;
}
</style>

<link rel="stylesheet" href="css/style.css">
</head>

<body>

<jsp:include page="<%= request.getContextPath() %>/header.jsp" />

<div class="sidebar">
    <h3>Menu</h3>
    <a href="adminService.jsp">Services</a>
    <a href="reviewAdmin.jsp">Review</a>
</div>


<!-- MAIN CONTENT -->
<div class="main">
    <h2>Customer Reviews</h2>

    <%
        try {
            Class.forName("org.postgresql.Driver");
            String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
            Connection conn = DriverManager.getConnection(connURL);

            // JOIN feedback + customers + services
            String sql =
            "SELECT f.feedback_id, f.rating, f.comments, f.created_at, " +
            "c.name AS customer_name, s.service_name " +
            "FROM feedbacks f " +
            "JOIN customers c ON f.customer_id = c.customer_id " +
            "JOIN services s ON f.service_id = s.service_id " +
            "ORDER BY f.created_at DESC";

            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while(rs.next()) {
                int id = rs.getInt("feedback_id");
                int rating = rs.getInt("rating");
                String comments = rs.getString("comments");
                String customer = rs.getString("customer_name");
                String service = rs.getString("service_name");
                Timestamp created = rs.getTimestamp("created_at");
    %>


			    <<!-- REVIEW CARD -->
			<div class="review-card">
			    <div class="review-header">
			        <div><%= customer %> <span class="review-sub"><%= service %></span></div>
			        <div class="rating"> Review: <%= rating %>/5</div>
			    </div>
			
			    <p style="margin-top:10px;"><%= comments %></p>
			
			    <div class="review-sub">
			        Submitted: <%= created %>
			    </div>
			
			    <!-- DELETE BUTTON -->
			    <form action="deleteFeedback.jsp" method="post" style="margin-top:10px;">
			        <input type="hidden" name="id" value="<%= id %>">
			        <button 
			            type="submit" 
			            style="background:#df3c3c; padding:8px 15px; border:none; border-radius:5px; color:white; cursor:pointer;">
			            Delete
			        </button>
			    </form>
			</div>


    <% 
            }
            conn.close();
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    %>

</div>

<jsp:include page="<%= request.getContextPath() %>/footer.jsp" />

</body>
</html>
