package com.dewcis;

import java.util.Enumeration;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.sql.*;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import org.baraza.DB.BDB;
import org.baraza.web.BWeb;
import org.baraza.xml.BElement;
import org.baraza.DB.BQuery;

import javax.servlet.annotation.WebServlet;
import javax.servlet.RequestDispatcher;

public class AuaRegistration extends HttpServlet {

	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response){
		doGet(request, response);
	}

	public void doGet(HttpServletRequest request, HttpServletResponse response){
		System.out.println("Starting application request");

System.out.println(request.getParameter("KF"));
System.out.println(request.getParameter("form_data"));

		ServletContext context = getServletContext();
		String dbconfig = "java:/comp/env/jdbc/database";
		String xmlcnf = "web/admissions.xml";
		String deskKey="900";
		String saveMsg="";
		BDB db = new BDB(dbconfig);

		String resp = null;
		String query="UPDATE applications SET form_data = ? WHERE application_id= ?";

		try{
			PreparedStatement st = db.getDB().prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
			st.setString(1, request.getParameter("form_data"));
			st.setInt(2, Integer.parseInt(request.getParameter("KF")));
			st.executeUpdate();
			st.close();
			resp = "{\"status\":\"OK\"}";
		}catch(SQLException e){
			System.out.println(e);
			resp="{\"status\":\"Failed\"}";
		}

		try{
			PrintWriter out = response.getWriter();
			out.print(resp);
			response.setContentType("text/JSON");
		} catch(Exception e){}

		db.close();

		System.out.println("Response " + resp);
	}

}
