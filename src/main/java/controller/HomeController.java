package controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")  // maps the root URL http://localhost:8080/
    public String home() {
        return "homepage"; // matches the JSP file name
    }
}

