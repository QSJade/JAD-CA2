<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Services List</title>

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

/* --- SERVICE CARD CONTAINER --- */
.service-row {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 40px;
    margin-bottom: 40px;
}

/* --- SERVICE CARD --- */
.card {
    width: 280px;
    background: white;
    padding: 30px 20px;
    border-radius: 10px;
    box-shadow: 0 0 8px rgba(0,0,0,0.08);
    text-align: center;
}

.card img {
    width: 60px;
    height: 60px;
    margin-bottom: 10px;
}

.card-title {
    font-weight: bold;
    margin: 5px 0;
}

.card-sub {
    font-size: 12px;
    color: gray;
}

/* --- BUTTONS --- */
.btn {
    padding: 10px 25px;
    color: white;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 15px;
}

.btn-delete {
    background: #df3c3c;
}

.btn-edit {
    background: #47a34b;
}

.btn-add {
    background: #47a34b;
    margin: 0 auto;
    display: block;
    margin-top: 20px;
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
    <h2>Services list</h2>

    <%
        try {
            Class.forName("org.postgresql.Driver");
            String connURL = "jdbc:postgresql://ep-hidden-sound-a186ebzs-pooler.ap-southeast-1.aws.neon.tech/neondb?user=neondb_owner&password=npg_qlwo4uHmbj7F&sslmode=require&channelBinding=require";
            Connection conn = DriverManager.getConnection(connURL);

            String sql = "SELECT service_id, service_name, description FROM services WHERE is_active = TRUE ORDER BY service_id";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);

            while(rs.next()) {

                int serviceId = rs.getInt("service_id");
                String serviceName = rs.getString("service_name");
                String description = rs.getString("description");

                String imgSrc = "images/default-service.jpg";
                String pageLink = "#";

                if(serviceName.equalsIgnoreCase("In-Home Care")) {
                    imgSrc = "images/care.jpg";
                    pageLink = "serviceHome.jsp";
                } else if(serviceName.equalsIgnoreCase("Meal Support")) {
                    imgSrc = "images/meal-service.jpg";
                    pageLink = "serviceMeal.jsp";
                } else if(serviceName.equalsIgnoreCase("Transportation Assistance")) {
                    imgSrc = "images/transportation.jpg";
                    pageLink = "serviceTransport.jsp";
                }
    %>

    <!-- DYNAMIC CARD -->
    <div class="service-row">
        <div class="card">
            <img src="<%= imgSrc %>" alt="service icon">
            <div class="card-title"><%= serviceName %></div>
            <div class="card-sub"><%= description %></div>
        </div>

        <div>
            <!-- DELETE -->
            <form action="deleteService.jsp" method="post">
                <input type="hidden" name="id" value="<%= serviceId %>">
                <button class="btn btn-delete">Delete</button>
            </form>

            <br>

            <!-- EDIT -->
            <a href="editService.jsp?id=<%= serviceId %>">
                <button class="btn btn-edit" type="button">Edit</button>
            </a>
        </div>
    </div>

    <%
            }
            conn.close();
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    %>

    <!-- ADD BUTTON -->
    <a href="addService.jsp">
        <button class="btn btn-add">Add</button>
    </a>

</div>

</body>
</html>
