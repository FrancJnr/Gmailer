package com.dewcis;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class UrlResolver {
	
	public String tryAgain(HttpServletRequest req, HttpServletResponse response ) throws IOException{

		String url= ""; 
		HttpSession session = req.getSession();
    	
        try{
          url = req.getAttribute("javax.servlet.forward.request_uri").toString();
          session.setAttribute("url", url);

        }catch(Exception e){
        	System.out.println(e);
        }
		

		
        return url;
	}


}
   
  

  