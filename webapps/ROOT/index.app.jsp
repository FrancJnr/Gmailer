<%@ page import="org.baraza.DB.BDB" %>
<%@ page import="org.baraza.DB.BQuery" %>

<%
	session.setAttribute("xmlcnf", "");
	session.invalidate();

	String formSelect = "";
	String resultDiv = request.getParameter("process");
	System.out.println("resultDiv is" +resultDiv);
	String getpassword = request.getParameter("getpassword");
	BDB db = new BDB("java:/comp/env/jdbc/database");

	System.out.println("db is " + db);

	boolean canRegister = true;
	String regmsg = "";

	String regsem = db.executeFunction("SELECT replace(cohort_name,' ','')  FROM cohorts WHERE is_active = true AND is_open=true");




	if(regsem == null) {
		canRegister = false;
		regsem = db.executeFunction("SELECT replace(cohort_name,' ','')  FROM cohorts WHERE is_active = true AND is_open=true");
		regsem = regsem.substring(0, 9);
		regmsg = "<h3 style='color:red;'>Applications for " + regsem +" Academic year are now closed</h3>";
	} else {
		regsem = regsem.substring(0, 9);
		regmsg = "<h3 style='color:blue;'>Application for " + regsem +  " Cohort is now open</h3>";
	}

	if((resultDiv == null) && (getpassword == null)) {
		BQuery rs = new BQuery(db, "SELECT form_id, form_name FROM forms WHERE (use_key = 1) ORDER BY form_id");
		while(rs.moveNext()) formSelect += "\n<option value='" + rs.getString("form_id") + "'>" + rs.getString("form_name") + "</option>";
		rs.close();
	} else if(getpassword != null) {
		String userName = request.getParameter("user_name");
		String userIP = request.getRemoteAddr();
		if(userName == null) userName = "-1";
		userName = userName.toLowerCase();
		String studentExist = db.executeFunction("SELECT entity_id FROM entitys WHERE user_name = '" + userName + "'");

		if(userName.indexOf("@")<3) {
			resultDiv = "Ensure the email address entered is proper";
		} else if(studentExist == null) {
			resultDiv = "The email does not exist register as a new applicant";
		} else {
			String inSql = "INSERT INTO sys_reset (entity_id, request_email, login_ip) VALUES (";
			inSql += studentExist + ", '" + userName + "', '" + userIP + "')";
			db.executeQuery(inSql);

			resultDiv = "The password has been sent to your email";
		}
	} else {
		String entityName = request.getParameter("entity_name");
		String userName = request.getParameter("user_name");
		String primaryEmail = request.getParameter("primary_email");
		String primaryTelephone = request.getParameter("primary_telephone");
		String selectionID = request.getParameter("selection_id");
		if(userName == null) userName = "-1";
		if(primaryEmail == null) entityName = "";
		if(primaryTelephone == null) primaryTelephone = "";
		if(selectionID == null) entityName = "1";

		userName = userName.toLowerCase();
		primaryEmail = primaryEmail.toLowerCase();

		if(entityName == null) {
			resultDiv = "The name in manditory";
		} else if(userName.indexOf("@")<3) {
			resultDiv = "Ensure the email address entered is proper";
		} else if(userName.equals(primaryEmail)) {
			String studentExist = db.executeFunction("SELECT user_name FROM entitys WHERE user_name = '" + userName + "'");
			if(studentExist == null) {
				String inSql = "INSERT INTO entitys (entity_type_id, org_id, entity_name, user_name, primary_email, primary_telephone, selection_id) VALUES (4, 0, '";
				inSql += entityName + "', '" + userName + "', '" + primaryEmail + "', '" + primaryTelephone + "', '" + selectionID + "')";
				db.executeQuery(inSql);

				System.out.println("values entered are" + userName + primaryEmail + primaryTelephone + selectionID);

				resultDiv = db.executeFunction("SELECT first_password FROM entitys WHERE user_name = '" + userName + "'");
				resultDiv = "Application submited; Your user name = " + userName + " and password " + resultDiv;
			} else {
				resultDiv = "The username already exists";
			}
		} else {
			resultDiv = "Ensure the email is the same as the confirmed email.";
		}
	}

	db.close();
%>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>


	<!-- General meta information -->
	<title>AUA On-line Registration</title>
	<meta name="description" content="Aua University On-line Registration">
    <meta name="viewport" content="width=device-width">
	<meta name="author" content="Dew CIS Solutions LTD">
	<link href="landing/images/favicon.ico" rel="shortcut icon">
	<!-- // General meta information -->


	<!-- Load stylesheets -->
		<link type="text/css" rel="stylesheet" href="landing/css/960.css" media="screen" /><!-- no need to edit, 960.gs Framework -->
		<link type="text/css" rel="stylesheet" href="landing/css/screen.css" media="screen" />
		<link id="theme-colors" type="text/css" rel="stylesheet" href="landing/css/themes/default.css" media="screen" /><!-- replace css/themes/xxxxxx.css with the theme you want to use -->
		<link type="text/css" rel="stylesheet" href="landing/css/print.css" media="print" />
		<link type="text/css" rel="stylesheet" href="landing/css/jquery.fancybox-1.3.4.css" media="screen" /><!-- no need to edit, lightbox css -->
		<!--[if lt IE 7]><link type="text/css" rel="stylesheet" href="landing/css/ie6.css" media="screen" /><![endif]-->
	<!-- // Load stylesheets -->


	<!-- Load Javascript / jQuery -->
		<!--[if lt IE 7]><script src="http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE7.js"></script><![endif]-->
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script>
		<script type="text/javascript" src="landing/js/superfish-combined.js"></script>
		<script type="text/javascript" src="landing/js/jquery.cycle.all.min.js"></script>
		<script type="text/javascript" src="landing/js/jquery.fancybox-1.3.4.pack.js"></script>
        <script type="text/javascript" src="landing/js/jquery.tweet.js"></script>
		<script type="text/javascript" src="landing/js/general.js"></script>
	<!-- // Load Javascript / jQuery -->

</head>
<body>


	<div id="outer" class="clearfix">

		<div id="header" class="clearfix">

        	<div class="container_12">

           		<div class="grid_12" id="header-container">

                    <div id="logo">
                        <h1><a href="index.jsp" title="Go to the home page"><img src="landing/images/openbaraza_logo.png" alt="Logo" /></a></h1>
                    </div><!-- //logo -->

                    <ul class="sf-menu">
						<li><a href="index.jsp">Home</a></li>
                        <li><a href="a_general.jsp?view=1:0">General Information</a></li>
						<li><a href="a_admissions.jsp?view=1:0">Admission</a></li>
					</ul>
            	</div><!-- //grid_12 -->

			</div><!-- //container_12 -->


        </div><!-- //header -->


        <div id="main" class="clearfix">

            <div class="container_12">

				<div class="grid_12">

					<!-- To be safe, specify a width/height when using HTML slides -->
					<div class="clearfix" style="width:940px; height:186px;">
						<div class="grid_4 alpha"><a href="landing/images/custom/front-full-1.jpg"><img src="landing/images/custom/front-300by180-1.jpg" alt="Student Studying" /></a></div>
						<div class="grid_4"><a href="landing/images/custom/front-full-3.jpg"><img src="landing/images/custom/front-300by180-3.jpg" alt="University Library" /></a></div>
						<div class="grid_4 omega"><a href="landing/images/custom/front-full-2.jpg"><img src="landing/images/custom/front-300by180-2.jpg" alt="Chemistry Lab" /></a></div>
					</div>

				</div><!--//grid_12-->

                <div class="clear"></div><!--//clear columns-->

                <div id="main" class="grid_8">
                    <h2>Online Application</h2>

					<%= regmsg %>

					<div class="grid_4 iconlist"><img src="landing/images/icons/user32.png" alt="Icon" class="left"><h5>For Existing Users</h5><a href="a_admissions.jsp?view=1:0"><p>Login Here</p></a></div>


<%			if(resultDiv == null) {
				if(canRegister) { %>
                	<div style="display:block;" id="main" class="grid_8">
						<div class="ui-widget ui-widget-content ui-corner-all form_content">
							<form class="standard" id="baraza" name="baraza" method="post" action="index.app.jsp">
								<table class="field" id="formtable">
								<tbody>
								<tr>
								<td style="width: 150px; vertical-align: top;">Full Name * : </td><td><input name="entity_name" class="w_50" size="50" type="text" required="true"></td></tr>
								<tr>
								<td style="width: 150px; vertical-align: top;">Email * : </td><td><input name="user_name" class="w_50" size="50" type="email" id="email" required="true"></td></tr>
								<tr>
								<td style="width: 150px; vertical-align: top;">Confirm Email * : </td><td><input name="primary_email" class="w_50" size="50" type="email" id="email_again" required="true"></td></tr>
								<tr>
								<td style="width: 150px; vertical-align: top;">Phone Number * : </td><td><input name="primary_telephone" class="w_50" size="50" type="text" required="true"></td></tr>
								<tr>
								<td style="width: 150px; vertical-align: top;">Application : </td><td><select class='combobox' name='selection_id'><%=formSelect%></select></td></tr>
								</tbody>
								</table>

								<input type="submit" class="button rounded shadow hovershadow" name="process" value="Create Login"/>
								<input type="submit" class="button rounded shadow hovershadow" name="getpassword" value="Forgot Password"/>
							</form>
						</div>
					</div><!--//grid_8-->
<%				}
			} else { %>
                	<div id="main" class="grid_8">
					<%=resultDiv %>
					</div><!--//grid_8-->
<%			} %>

				<div>

				</div>

              </div><!--//grid_8-->


                <div id="main" class="grid_4">
                    <div class="widget">
                    	<h3 class="widgettitle">Instructions:</h3>
                        <p>Welcome to the <%= regsem %> Undergraduate Admissions page. Please follow the instructions carefully. Go to http://registration.ueab.ac.ke/a_admissions.jsp to start the application process.</p>
                    	<h3 class="widgettitle">Step 1 </h3>
						<p>Create new applicant account.</p>
						<p>1. Enter your name and email address (a password will be displayed on the page and also sent to your email). This password will be required to access your application if you choose to complete it at another time. Make sure you copy your APPLICATION ID displayed at the top of the Admission Form.</p>
						<p>2. Complete all information, select exam date and venue, and upload your picture.</p>

						<h3 class="widgettitle"></h3>
						<p>For further assistance you can email : admissions [at] aua.ac.ke or call +254 721 423592, +254 731 793934</p>

                    </div>

                	<div class="widget">
                    </div>

                    <div class="widget">
                    </div>

                </div><!--//grid_4-->

                <div class="clear"></div><!--//clear columns-->

                <div class="grid_12">
                     <p class="quotebox">
                        <small class="right"> .. as said by <strong>George Bernard Shaw</strong></small>
                        We are made wise not by the recollection of our past, but by the responsibility for our future.
                    </p>
                </div><!--//grid_12-->

            </div><!-- //container_12 -->

        </div><!-- //main -->


        <div id="footer-bottom" class="clearfix">
            <div class="container_12">
            	<div class="grid_12">
                    <p class="left">&copy; 2015 - <a href="http://www.aua.ac.ke/" title="AUA">ADVENTIST UNIVERSITY OF AFRICA</a> | Powered by 		<a href="http://www.openbaraza.org" title="Openbaraza"> Openbaraza</a></p>
                    <p class="right"><a href="#" class="scroll-top" title="Back to the Top">TOP</a></p>
                </div>
            </div><!--//container_12-->
        </div>


	</div><!-- //outer -->

	<!-- insert analytics -->

</body>
</html>
