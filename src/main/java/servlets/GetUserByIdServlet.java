package servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dbaccess.User;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.Invocation;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
/**
 * Servlet implementation class GetUserById
 */
@WebServlet("/GetUserByIdServlet")
public class GetUserByIdServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GetUserByIdServlet() {
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
        PrintWriter out = response.getWriter();
        Client client = ClientBuilder.newClient();
        //String restUrl = "http://localhost:8080/restWs/UserService";
        //String restUrl = "http://ec2-107-21-4-146.compute-1.amazonaws.com:8080/user-ws";
        String restUrl = "http://localhost:8081/user-ws"; //<--changed port to 8081
        WebTarget target = client
                .target(restUrl)
                .path("getUser/"+uid);
        Invocation.Builder invocationBuilder = target.request(MediaType.APPLICATION_JSON);
        Response resp = invocationBuilder.get();
        System.out.println("status: " + resp.getStatus());

        //https://stackoverflow.com/questions/18886621/read-response-body-in-jax-rs-client-from-a-post-request
        if (resp.getStatus() == Response.Status.OK.getStatusCode()) {
            System.out.println("success");
            User user = resp.readEntity(User.class);
            request.setAttribute("user", user);
            //write to request object for forwarding to target page
            request.setAttribute("user", user);
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
