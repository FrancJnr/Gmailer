package com.dewcis.aua;

import java.util.Enumeration;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import org.baraza.web.BWeb;
import org.baraza.xml.BElement;
import org.baraza.DB.BQuery;


public class AuaData {

	public AuaData(BWeb web, String deskKey, HttpServletRequest request) {
		BElement root = web.getRoot();
		BElement desk = root.getElementByKey(deskKey);
		BElement view = desk.getFirst();
		BElement form = view.getFirst();
System.out.println("BASE 1010 : " + form.toString());

		BQuery rsForm = new BQuery(web.getDB(), form, null, null);
		
		rsForm.recAdd();
		
		Map<String, String[]> reqParams = new HashMap<String, String[]>();
		Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
			String elName = (String)e.nextElement();
			reqParams.put(elName, request.getParameterValues(elName));
		}

		String saveMsg = rsForm.updateFields(reqParams, web.getViewData(), null, null);
		
		rsForm.close();
	}
		
}
