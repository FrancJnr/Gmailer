/**
 * @author      Dennis W. Gichangi <dennis.gichangi@dewcis.com>
 * @version     2018.0329
 * @since       1.6
 * website		www.dewcis.com
 */
package com.dewcis;

import java.util.logging.Logger;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.json.JSONArray;

import org.baraza.utils.BWebUtils;
import org.baraza.DB.BDB;

public class DPaypal extends HttpServlet {
	Logger log = Logger.getLogger(DPaypal.class.getName());

	public void doGet(HttpServletRequest request, HttpServletResponse response) {
		doPost(request, response);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response) {
		log.info("Start paypal message");

		BWebUtils.showHeaders(request);
		BWebUtils.showParameters(request);

		String body = BWebUtils.requestBody(request);
		System.out.println(body);

		String sData = request.getParameter("json");

		System.out.println("BASE 2010 : " + sData);
		if(sData != null) {
			JSONObject jData = new JSONObject(sData);
System.out.println("BASE 2020 : " + jData.getJSONArray("transactions").toString());
System.out.println("BASE 2025 : " + jData.getJSONArray("transactions").getJSONObject(0).getString("invoice_number"));

			String psck = "UPDATE applications SET paid = true, pay_date = current_timestamp, "
				+ "paypal_response = '" + jData.toString() + "' "
				+ "WHERE application_id=" + jData.getJSONArray("transactions").getJSONObject(0).getString("invoice_number");
System.out.println("BASE 2020 : " + psck);

			BDB db = new BDB("java:/comp/env/jdbc/database");
			db.executeUpdate(psck);
			db.close();
		}	
	}

}

