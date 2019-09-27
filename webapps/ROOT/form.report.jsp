<%@ page import="org.baraza.web.*" %>

<%
	BForms forms = new BForms("java:/comp/env/jdbc/database");

	String action = request.getParameter("action");
	String formid = request.getParameter("actionvalue");
	String startdate = request.getParameter("startdate");
	String enddate = request.getParameter("enddate");
	String reportLevel = request.getParameter("reportlevel");
	String reportField = request.getParameter("reportfield");
	String sdv = ""; String sdva = ""; String edv = ""; String edva = "";
	String rla = ""; String rfa = "";

	if(action == null) action = "FORMREPORT";
	if(startdate != null) {sdv = "value='" + startdate + "'"; sdva = "&startdate=" + startdate; }
	if(enddate != null) {edv = "value='" + enddate + "'"; edva = "&enddate=" + enddate; }
	if(reportLevel != null) rla = "&reportlevel=" + reportLevel;
	if(reportField  != null) rfa = "&reportfield=" + reportField;
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1"/>
	<title>CCK Form Report</title>
	
	<link rel="stylesheet" type="text/css" href="resources/css/form.css"/>
	<link rel="stylesheet" type="text/css" href="resources/css/scroll_table.css"/>
	<link rel="stylesheet" type="text/css" href="resources/css/scroll_table_jui.css"/>
	<link rel="stylesheet" type="text/css" href="resources/css/smoothness/jquery-ui-1.8.4.custom.css"/>

	<style type="text/css" title="currentStyle">
		div.giveHeight {
			min-height: 380px;
		}
	</style>

	<script type="text/javascript" src="resources/js/CalendarPopup.js"></script>
	<script type="text/javascript" src="resources/js/jquery.js"></script>
	<script type="text/javascript" src="resources/js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="resources/js/jquery-ui-1.8.5.custom.min.js"></script>
	<script type="text/javascript" src="resources/js/body.js"></script>

	<script type="text/javascript">
		var cal = new CalendarPopup();
	</script>

</head>
<body>

<form id="baraza" name="baraza" method="post" action="form.report.jsp">
<div id='header_contents'>
	<table><tr>
	<td>Level : <select name='reportlevel'><option>Basic</option><option>Detailed</option><option>Sub Field</option></select></td>
	<td>Starting from : 
	<a href="#" onclick="cal.select(document.forms[0].startdate,'anchor1','dd/MM/yyyy'); return false;" name="anchor1" id="anchor1"> select </a>
	<input type='text' name='startdate' size='15' <%= sdv %>/>
	</td>
	<td>Ending at : 
	<a href="#" onclick="cal.select(document.forms[0].enddate,'anchor1','dd/MM/yyyy'); return false;" name="anchor1" id="anchor1"> select </a>
	<input type='text' name='enddate' size='15' <%= edv %>/>
	</td>
	<%= forms.getFormField(formid) %>
	<td><input type="submit" name="filter" value="Filter" class="altProcessButtonFormat"/></td>
	<td><a href="form.exel.jsp?formid=<%=formid + sdva + edva + rla + rfa %>">Export</a></td>
	</tr></table>
</div>

<input type="hidden" name="action" value="<%= action %>"/>
<input type="hidden" name="actionvalue" value="<%= formid %>"/>

</form>

<% if(action.equals("FORMREPORT")) { %>

<div id='body_content'>
	<%=	forms.getFormReport(formid, startdate, enddate, reportLevel, reportField) %>
</div>

<% }

	forms.close(); 
%>

</body>
</html>
