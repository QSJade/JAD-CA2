package servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dbaccess.User;

import java.io.IOException;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Entity;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.Response;

/**
 * Servlet implementation class CreateUserServlet
 */
@WebServlet("/CreateUserServlet")
public class CreateUserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CreateUserServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        //response.getWriter().append("Served at: ").append(request.getContextPath());
        
        String uid = request.getParameter("userId");
        Integer age = Integer.parseInt(request.getParameter("age"));
        String gender = request.getParameter("gender");
        
        if (uid == null || uid.isEmpty() ||
                age == null ||
                gender == null || gender.isEmpty()) {

                request.setAttribute("err", "MissingFields");
                RequestDispatcher rd = request.getRequestDispatcher("/pract8/testweb.jsp");
                rd.forward(request, response);
                return;
            }
        
        User user = new User();
        user.setUserId(uid);
        user.setAge(age);
        user.setGender(gender);
        
        //PrintWriter out = response.getWriter();
        Client client = ClientBuilder.newClient();
        //String resultUrl = "http://ec2-3-86-52-151.compute-1.amazonaws.com:8080/user-ws"; //"http://localhost:8080/RestWS/UserService";
        String resultUrl = "http://localhost:8081/user-ws";
        WebTarget target = client
            .target(resultUrl)
            .path("createUser");
        
        Invocation.Builder invocationBuilder = target.request();
        Response resp = invocationBuilder.post(Entity.json(user)); //https://www.programcreek.com/java-api-examples/?api=javax.ws.rs.client.WebTarget
        System.out.println("status: " + resp.getStatus());

        //https://stackoverflow.com/questions/18886621/read-response-body-in-jax-rs-client-from-a-post-request
        if (resp.getStatus() == Response.Status.OK.getStatusCode()) {
            System.out.println("success");
            Integer row = resp.readEntity(Integer.class);

            //write to request object for forwarding to target page
            request.setAttribute("rowsAffected", row);
            //System.out.print("......requestObj set...forwarding...");
            String url="/pract8/testweb.jsp";
            RequestDispatcher rd = request.getRequestDispatcher(url);
            rd.forward(request, response);
        } else {
            System.out.println("failed");
            String url="/pract8/testweb.jsp";
            request.setAttribute("err", "NotFound");
            RequestDispatcher rd = request.getRequestDispatcher(url);
            rd.forward(request, response);
        }
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
