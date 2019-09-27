<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="mainPage" value="a_admissions.jsp" scope="page" />
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.baraza.DB.BQuery" %>
<%@ page import="org.baraza.web.*" %>
<%@ page import="org.baraza.xml.BElement" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.baraza.DB.BDB" %>
<%
BDB db = new BDB("java:/comp/env/jdbc/database");
ServletContext context = getServletContext();
String dbconfig = "java:/comp/env/jdbc/database";
String xmlcnf = "web/admissions.xml";
if(request.getParameter("logoff") == null) {
if(xmlcnf != null) session.setAttribute("xmlcnf", xmlcnf);
} else {
session.removeAttribute("xmlcnf");
session.invalidate();
}
String ps = System.getProperty("file.separator");
String xmlfile = context.getRealPath("WEB-INF") + ps + "configs" + ps + xmlcnf;
String reportPath = context.getRealPath("reports") + ps;
String projectDir = context.getInitParameter("projectDir");
if(projectDir != null) {
xmlfile = projectDir + ps + "configs" + ps + xmlcnf;
reportPath = projectDir + ps + "reports" + ps;
}
BWeb web = new BWeb(dbconfig, xmlfile, context);
web.init(request);
web.setMainPage(String.valueOf(pageContext.getAttribute("mainPage")));
String user_id = web.getUserID();
String application_id = " ";

String appSql = "SELECT applications.application_id, entitys.entity_id FROM applications ";
appSql += "INNER JOIN entitys ON applications.email=entitys.user_name  WHERE entity_id = '" + user_id + "'";

application_id = db.executeFunction("SELECT applications.application_id FROM applications INNER JOIN entitys ON applications.email=entitys.user_name  WHERE entitys.entity_id = '" + user_id + "'");

String jForm = web.getJSONForm(request);
System.out.println(jForm);

String entryformid = null;
String action = request.getParameter("action");
String value = request.getParameter("value");
String post = request.getParameter("post");
String process = request.getParameter("process");
String actionprocess = request.getParameter("actionprocess");
if(actionprocess != null) process = "actionProcess";
String reportexport = request.getParameter("reportexport");
String excelexport = request.getParameter("excelexport");
String actionOp = null;

String auditTable = null;

String contentType = request.getContentType();
if(contentType != null) {
if ((contentType.indexOf("multipart/form-data") >= 0)) {
web.updateMultiPart(request, context, context.getRealPath("WEB-INF" + ps + "tmp"));
}
}

String opResult = null;
if(process != null) {
if(process.equals("actionProcess")) {
opResult = web.setOperation(actionprocess, request);
} else if(process.equals("FormAction")) {
String actionKey = request.getParameter("actionkey");
opResult = web.setOperation(actionKey, request);
} else if(process.equals("Update")) {
web.updateForm(request);
} else if(process.equals("Delete")) {
web.deleteForm(request);
} else if(process.equals("Submit")) {
web.submitGrid(request);
} else if(process.equals("Check All")) {
web.setSelectAll();
} else if(process.equals("Audit")) {
auditTable = web.getAudit();
}
}

String fieldTitles = web.getFieldTitles();

if(excelexport != null) reportexport = excelexport;
if(reportexport != null) {
out.println("<script>");
out.println("window.open('show_report?report=" + reportexport + "');");
out.println("</script>");
}



%>
<!--[if IE 8]>
<html lang="en" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]>
<html lang="en" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en">
<!--<![endif]-->
<!-- BEGIN HEAD -->
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="keywords" content="college, campus, university, courses, school, educational">
    <meta name="description" content="OPENBARAZA - College, University and campus website">
    <meta name="author" content="Evingtone Ngoa">
    <title><%= pageContext.getServletContext().getInitParameter("web_title") %></title>

    <!-- Favicons-->
    <link rel="shortcut icon" href="assets/img/favicon.ico" type="image/x-icon">
    <link rel="apple-touch-icon" type="image/x-icon" href="assets/img/apple-touch-icon-57x57-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="72x72"
          href="assets/img/apple-touch-icon-72x72-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="114x114"
          href="assets/img/apple-touch-icon-114x114-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="144x144"
          href="assets/img/apple-touch-icon-144x144-precomposed.png">

    <!-- BASE CSS -->
    <link href="./assets/css/base.css" rel="stylesheet">

    <!-- SPECIFIC CSS -->
    <link href="./assets/css/tabs.css" rel="stylesheet">

    <!--[if lt IE 9]>
    <script src="./assets/js/html5shiv.min.js"></script>
    <script src="./assets/js/respond.min.js"></script>
    <![endif]-->
    <!-- BEGIN GLOBAL MANDATORY STYLES -->
    <link href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=all" rel="stylesheet"
          type="text/css">
    <link href="./assets/plugins/register/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="./assets/plugins/register/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css">
    <link href="./assets/plugins/register/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="./assets/plugins/register/uniform/css/uniform.default.css" rel="stylesheet" type="text/css">
    <link href="./assets/plugins/register/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet"  type="text/css"/>
    <link href="./assets/plugins/register/bootstrap-fileinput/bootstrap-fileinput.css" rel="stylesheet"  type="text/css"/>
    <!-- END GLOBAL MANDATORY STYLES -->
    <!-- BEGIN PAGE LEVEL STYLES -->
    <link rel="stylesheet" type="text/css" href="./assets/plugins/register/select2/select2.css"/>
    <!-- END PAGE LEVEL SCRIPTS -->
    <!-- BEGIN THEME STYLES -->
    <link href="./assets/plugins/register/bootstrap-datepicker/css/bootstrap-datepicker.min.css" rel="stylesheet"
          type="text/css"/>
    <link href="./assets/css/register/components-md.css" id="style_components" rel="stylesheet" type="text/css"/>
    <link href="./assets/css/register/plugins-md.css" rel="stylesheet" type="text/css"/>
    <link href="./assets/css/register/layout.css" rel="stylesheet" type="text/css"/>
    <link id="style_color" href="./assets/css/register/themes/light.css" rel="stylesheet" type="text/css"/>
    <link href="./assets/css/register/custom.css" rel="stylesheet" type="text/css"/>
    <!-- END THEME STYLES -->
    <link rel="shortcut icon" href="favicon.ico"/>
</head>
<!-- END HEAD -->
<!-- BEGIN BODY -->
<!-- DOC: Apply "page-header-fixed-mobile" and "page-footer-fixed-mobile" class to body element to force fixed header or footer in mobile devices -->
<!-- DOC: Apply "page-sidebar-closed" class to the body and "page-sidebar-menu-closed" class to the sidebar menu element to hide the sidebar by default -->
<!-- DOC: Apply "page-sidebar-hide" class to the body to make the sidebar completely hidden on toggle -->
<!-- DOC: Apply "page-sidebar-closed-hide-logo" class to the body element to make the logo hidden on sidebar toggle -->
<!-- DOC: Apply "page-sidebar-hide" class to body element to completely hide the sidebar on sidebar toggle -->
<!-- DOC: Apply "page-sidebar-fixed" class to have fixed sidebar -->
<!-- DOC: Apply "page-footer-fixed" class to the body element to have fixed footer -->
<!-- DOC: Apply "page-sidebar-reversed" class to put the sidebar on the right side -->
<!-- DOC: Apply "page-full-width" class to the body element to have full width page without the sidebar menu -->
<body class="page-md page-header-fixed page-sidebar-closed-hide-logo ">
<div id="preloader">
    <div class="pulse"></div>
</div><!-- Pulse Preloader -->
<!-- BEGIN HEADER -->
<div class="page-header navbar navbar-fixed-top">
    <!-- BEGIN HEADER INNER -->
    <div class="page-header-inner">
        <!-- BEGIN LOGO -->
        <div class="page-logo">
            <a href="index.jsp">
                <img src="./assets/img/logo/openbaraza-logo.png" alt="logo" style="margin: 20px 10px 0 10px; width: 185px;" class="logo-default">
            </a>
            <div class="menu-toggler sidebar-toggler">
                <!-- DOC: Remove the above "hide" to enable the sidebar toggler button on header -->
            </div>
        </div>
        <!-- END LOGO -->
        <!-- BEGIN RESPONSIVE MENU TOGGLER -->
        <a href="javascript:;" class="menu-toggler responsive-toggler" data-toggle="collapse" data-target=".navbar-collapse">
        </a>
        <!-- END RESPONSIVE MENU TOGGLER -->
        <!-- BEGIN PAGE TOP -->
        <div class="page-top">
            <!-- BEGIN TOP NAVIGATION MENU -->
            <div class="top-menu">
                <ul class="nav navbar-nav pull-right">
                    <!-- BEGIN USER LOGIN DROPDOWN -->
                    <!-- DOC: Apply "dropdown-dark" class after below "dropdown-extended" to change the dropdown styte -->
                    <li class="dropdown dropdown-user dropdown-dark">
                        <a href="javascript:;" class="dropdown-toggle" data-toggle="dropdown" data-hover="dropdown" data-close-others="true">
		<span class="username username-hide-on-mobile">
			 <%= web.getOrgName() %> | <%= web.getEntityName() %>   </span>
                            <!-- DOC: Do not remove below empty space(&nbsp;) as its purposely used -->
                            <img alt="" class="img-circle" src="./assets/admin/layout4/img/avatar.png">
                        </a>
                        <ul class="dropdown-menu dropdown-menu-default">
                            <li>
                                <a href="index.jsp?view=83:0">
                                    <i class="icon-rocket"></i> My Tasks
                                </a>
                            </li>
                            <% if(web.hasPasswordChange()) { %>
                            <li class="divider"></li>
                            <li>
                                <a data-toggle="modal" href="#basic">
                                    <i class="icon-rocket"></i> Change Password
                                </a>
                            </li>
                            <% } %>
                            <li class="divider"></li>
                            <li>
                                <a href="logout.jsp?logoff=yes">
                                    <i class="icon-key"></i> Log Out </a>
                            </li>
                        </ul>
                    </li>
                    <!-- END USER LOGIN DROPDOWN -->
                </ul>
            </div>
            <!-- END TOP NAVIGATION MENU -->
        </div>
        <!-- END PAGE TOP -->
    </div>
    <!-- END HEADER INNER -->
</div>
<!-- END HEADER -->
<div class="clearfix">
</div>
<!-- BEGIN CONTAINER -->
<div class="page-container">
    <!-- BEGIN CONTENT -->
    <div class="page-content-wrapper">
        <div class="page-content" style="margin-left: 0px;">
            <!-- BEGIN SAMPLE PORTLET CONFIGURATION MODAL FORM-->
            <div class="modal fade" id="portlet-config" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
                 aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-hidden="true"></button>
                            <h4 class="modal-title">Modal title</h4>
                        </div>
                        <div class="modal-body">
                            Widget settings form goes here
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn blue">Save changes</button>
                            <button type="button" class="btn default" data-dismiss="modal">Close</button>
                        </div>
                    </div>
                    <!-- /.modal-content -->
                </div>
                <!-- /.modal-dialog -->
            </div>
            <!-- /.modal -->
            <!-- END SAMPLE PORTLET CONFIGURATION MODAL FORM-->
            <!-- BEGIN PAGE CONTENT-->
            <div class="row">
                <div class="col-md-12">
                    <div class="portlet box blue" id="form_wizard_1" >
                        <div class="portlet-title">
                            <div class="caption">
                                <i class="fa fa-file-text"></i> View Application
                            </div>
                            <div class="tools hidden-xs">
                                <a href="javascript:;" class="collapse">
                                </a>
                                <a href="#portlet-config" data-toggle="modal" class="config">
                                </a>
                                <a href="javascript:;" class="reload">
                                </a>
                                <a href="javascript:;" class="remove">
                                </a>
                            </div>
                        </div>
                        <div class="portlet-body form">
                            <form action="#" class="form-horizontal" id="submit_form" method="POST"  enctype="multipart/form-data">
                                <div class="form-wizard">
                                    <div class="form-body">
                                        <div class="tab-content" style="padding-top: 0px;">
                                            <div class="alert alert-danger display-none">
                                                <button class="close" data-dismiss="alert"></button>
                                                You have not filled some compulsory fields. Go Back and confirm.
                                            </div>
                                            <div class="alert alert-success display-none">
                                                <button class="close" data-dismiss="alert"></button>
                                                Your form validation is successful!
                                            </div>

                                            <div class="tab-pane active" id="tab1">
                                                <h3 class="block" style="padding: 0px;">Application Details for <span id="appName"></span></h3>
                                                <!--Section A-->
                                                <h4 class="form-section background">Section A</h4>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Surname:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="surnameShow" data-display="surname"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4 ">
                                                        <label class="control-label col-md-6 text-left">Firstname:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="firstnameShow" data-display="firstname"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Middle Name:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="lastnameShow" data-display="lastname"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Telephone
                                                            No:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="tel_noShow" data-display="tel_no"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Mobile
                                                            No:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" data-display="tel_no">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Email:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="emailShow" data-display="email"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section C -->
                                                <h4 class="form-section background">Section C</h4>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Date Of
                                                            Birth:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="dobShow" data-display="dob"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Nationality:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="nationalityShow" data-display="nationality"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Marital
                                                            Status:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="marital_statusShow" data-display="marital_status"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Religious
                                                            Affiliation:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="denominationShow" data-display="denomination"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Passport No/ ID No:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="passport_id_noShow" data-display="passport_id_no"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6">Gender:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="genderShow" data-display="gender"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Physical
                                                            Disability:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="disability_boolShow" data-display="disability_bool"></p><p class="form-control-static" id="disabilityShow" data-display="disability"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Current
                                                            Address:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="current_addressShow" data-display="current_address"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-6 text-left">Permanent
                                                            Address:</label>
                                                        <div class="col-md-6">
                                                            <p class="form-control-static" id="permanent_addressShow" data-display="permanent_address"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section D-->
                                                <h4 class="form-section background">Section D</h4>
                                                <!--QUALIFICATIONS-->
                                                <div class="col-md-12 white">
                                                    <div class="row">
                                                        <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">QUALIFICATIONS</h5>
                                                        <label class="control-label col-md-2">1. </label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="degree_1" id="degree_1Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">UNIVERSITY / COLLEGE
                                                        ATTENDED </h5>
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="university_1" id="university_1Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">GRADES OBTAINED</h5>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="grades_1" id="grades_1Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">YEAR OF COMPLETION </h5>
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" id="completion_yr_1Show" data-display="completion_yr_1"></p>
                                                        </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2">2. </label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="degree_2" id="degree_2Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="university_2" id="university_2Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="grades_2" id="grades_2Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="completion_yr_2" id="completion_yr_2Show"></p>
                                                        </div>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2">3. </label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="degree_3" id="degree_3Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="university_3" id="university_3Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="grades_3" id="grades_3Show"></p>
                                                        </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>
                                                        <div class="col-md-10">
                                                        <p class="form-control-static" data-display="completion_yr_3" id="completion_yr_3Show"></p>
                                                        </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Degree desired-->
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-5 text-left">Degree offered: </label>
                                                        <div class="col-md-7">
                                                            <p class="form-control-static" data-display="school" id="schoolShow"></p>
                                                            <p class="form-control-static" data-display="thsm" id="thsmShow"></p>
                                                            <p class="form-control-static" data-display="pgs" id="pgsShow"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">Accomodation - On Campus: </label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" id="accomodationShow" data-display="accomodation"></p>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-4 text-left">Sponsors: </label>
                                                        <div class="col-md-8">
                                                            <p class="form-control-static" id="sponsoredShow" data-display="sponsored"></p> -
                                                            <p class="form-control-static" id="sponsoresShow" data-display="sponsores"></p>
                                                        </div>
                                                    </div>

                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="col-md-offset-3  col-md-6">
                                                        <label class="control-label col-md-4 text-left">Campus Site: </label>
                                                        <div class="col-md-8">
                                                            <p class="form-control-static" id="campus_siteShow" data-display="campus_site"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="col-md-offset-3  col-md-6">
                                                        <label class="control-label col-md-8 text-left">Graduated from
                                                            English-speaking College/University? </label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="is_english" id="is_englishShow"></p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">If No, Passed an
                                                            English proficiency test?</label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="prof_test" id="prof_testShow"></p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Name of
                                                            Test </label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="test_name" id="test_nameShow"></p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Score </label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="score" id="scoreShow">
                                                            </p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Date </label>
                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="date_test" id="date_testShow"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section E-->
                                                <h4 class="form-section background">Section E</h4>
                                                <!--Occupation-->
                                                <div class="col-md-12 white">
                                                    <!--Titles-->
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">OCCUPATION</h4>
                                                        <h5 class="col-title text-center"><em>Current Position held</em>
                                                        </h5>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">EMPLOYER </h4>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">WORK STATION </h4>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">DURATION </h4>
                                                    </div>
                                                    <!--inputs-->
                                                    <div class="col-md-12">
                                                        <!--Record 1-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">1.
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="occupation_1" id="occupation_1Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="employer_1" id="employer_1Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="workstation_1" id="workstation_1Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="duration_1" id="duration_1Show"></p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!--Titles Previous position held-->
                                                    <div class="form-group col-md-3">
                                                        <!--<h4 class="col-title text-center">OCCUPATION</h4>-->
                                                        <h5 class="col-title text-center"><em>Previous Position
                                                            held</em></h5>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center" style="visibility: hidden">
                                                            EMPLOYER </h4>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center" style="visibility: hidden">
                                                            WORK STATION </h4>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center" style="visibility: hidden">
                                                            DURATION </h4>
                                                    </div>
                                                    <div class="col-md-12">
                                                        <!--Record 2-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">2.
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="occupation_2" id="occupation_2Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="employer_2" id="employer_2Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="workstation_2" id="workstation_2Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="duration_2" id="duration_2Show"></p>
                                                            </div>
                                                        </div>
                                                        <!--Record 3-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">3.
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="occupation_3" id="occupation_3Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="employer_3" id="employer_3Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="workstation_3" id="workstation_3Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="duration_3" id="duration_3Show"></p>
                                                            </div>
                                                        </div>
                                                        <!--Record 4-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">4.
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="occupation_4" id="occupation_4Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="employer_4" id="employer_4Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="workstation_4" id="workstation_4Show"></p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>
                                                            <div class="col-md-10">
                                                                <p class="form-control-static" data-display="duration_4" id="duration_4Show"></p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!--Total Number of years-->
                                                    <div class="col-md-12">
                                                        <div class="form-group col-md-4">
                                                            <label class="control-label col-md-8 text-left">
                                                                Total Number of years worked
                                                            </label>
                                                            <div class="col-md-4">
                                                                <p class="form-control-static" data-display="num_yrs" id="num_yrsShow"></p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Referees-->
                                                <div class="col-md-12 white">
                                                    <h4 class="col-title text-left">REFEREES</h4>
                                                    <!--Name-->
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">1. Name
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_name_1" id="ref_name_1Show"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">2. Name
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_name_2" id="ref_name_2Show"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">3. Name
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_name_3" id="ref_name_3Show"></p>
                                                        </div>
                                                    </div>
                                                    <!--Address-->
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_1" id="ref_address_1Show"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_2" id="ref_address_2Show"></p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>
                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_3" id="ref_address_3Show"></p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section B  -->
                                                <h4 class="form-section background">Section B</h4>
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-3">
                                                <h5 class="col-title text-left">COMPULSORY UPLOADS</h5>
                                                </div>
                                                </div>
                                                <!--/Profile Image  -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">Profile Image</label>
                                                <div class="col-md-6" id="profImageUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">Current Appointment Letter</label>
                                                <div class="col-md-6" id="appointmentSlipUploadedShow"></div>
                                                </div>
                                                </div>
                                                <!--/Purpose Letter  -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">Purpose Letter</label>
                                                <div class="col-md-6" id="purposeSlipUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">Updated CV</label>
                                                <div class="col-md-6" id="cvSlipUploadedShow"></div>
                                                </div>
                                                </div>
                                                <!--/Id Upload  -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">National Identity Card or Passport</label>
                                                <div class="col-md-6" id="identificationSlipUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">1st Referee Letter</label>
                                                <div class="col-md-6" id="ref1UploadedShow"></div>
                                                </div>
                                                </div>
                                                <!--/Referee Upload letter  -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">2nd Referee Letter</label>
                                                <div class="col-md-6" id="ref2UploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">3rd Referee Letter</label>
                                                <div class="col-md-6" id="ref3UploadedShow"></div>
                                                </div>
                                                </div>

                                                <!--/College Certificate Upload   -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">1st College Certificate</label>
                                                <div class="col-md-6" id="institutionOneCertUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">1st College Transcript</label>
                                                <div class="col-md-6" id="institutionOneTransUploadedShow"></div>
                                                </div>
                                                </div>
                                                <!--/Optional Fields   -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-3">
                                                <h5 class="col-title text-left">OPTIONAL UPLOADS</h5>
                                                </div>
                                                </div>
                                                <!--/College Certificate Upload 2   -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">2nd College Certificate</label>
                                                <div class="col-md-6" id="institutionTwoCertUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">2nd College Transcript</label>
                                                <div class="col-md-6" id="institutionTwoTransUploadedShow"></div>
                                                </div>
                                                </div>

                                                <!--/College Certificate Upload 3   -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">3rd College Certificate</label>
                                                <div class="col-md-6" id="institutionThreeCertUploadedShow"></div>
                                                </div>
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">3rd College Transcript</label>
                                                <div class="col-md-6" id="institutionThreeTransUploadedShow"></div>
                                                </div>
                                                </div>
                                                <!--/English transcript Upload   -->
                                                <div class="col-md-12 white">
                                                <div class="form-group col-md-6">
                                                <label class="control-label col-md-6 text-left">English Transcript</label>
                                                <div class="col-md-6" id="englishCertUploadedShow"></div>
                                                </div>
                                                </div>

                                                <!--Section D-->
                                                <div class="form-group">

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <!-- END PAGE CONTENT-->
        </div>
    </div>
    <!-- END CONTENT -->
</div>
<!-- END CONTAINER -->

<!-- BEGIN JAVASCRIPTS(Load javascripts at bottom, this will reduce page load time) -->
<!-- BEGIN CORE PLUGINS -->
<!--[if lt IE 9]>
<!--Paypal-->
<script src="https://www.paypalobjects.com/api/checkout.js"></script>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>

<script src="./assets/plugins/register/respond.min.js"></script>
<script src="./assets/plugins/register/excanvas.min.js"></script>
<![endif]-->
<script src="./assets/plugins/register/jquery.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/jquery-migrate.min.js" type="text/javascript"></script>
<!-- IMPORTANT! Load jquery-ui.min.js before bootstrap.min.js to fix bootstrap tooltip conflict with jquery ui tooltip -->
<script src="./assets/plugins/register/jquery-ui/jquery-ui.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/bootstrap-hover-dropdown/bootstrap-hover-dropdown.min.js"
        type="text/javascript"></script>
<script src="./assets/plugins/register/jquery-slimscroll/jquery.slimscroll.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/jquery.blockui.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/jquery.cokie.min.js" type="text/javascript"></script>
<script src="./assets/plugins/register/uniform/jquery.uniform.min.js" type="text/javascript"></script>
<script type="text/javascript" src="./assets/plugins/register/bootstrap-fileinput/bootstrap-fileinput.js"></script>
<script src="./assets/plugins/register/bootstrap-switch/js/bootstrap-switch.min.js" type="text/javascript"></script>
<!-- END CORE PLUGINS -->
<!-- BEGIN PAGE LEVEL PLUGINS -->
<script type="text/javascript" src="./assets/plugins/register/jquery-validation/js/jquery.validate.min.js"></script>
<script type="text/javascript" src="./assets/plugins/register/jquery-validation/js/additional-methods.min.js"></script>
<script type="text/javascript" src="./assets/plugins/register/bootstrap-wizard/jquery.bootstrap.wizard.min.js"></script>
<!-- END PAGE LEVEL PLUGINS -->
<!-- BEGIN PAGE LEVEL PLUGINS -->
<script type="text/javascript" src="./assets/plugins/register/select2/select2.min.js"></script>
<script type="text/javascript"
        src="./assets/plugins/register/bootstrap-datepicker/js/bootstrap-datepicker.min.js"></script>
<!-- END PAGE LEVEL PLUGINS -->
<!-- BEGIN PAGE LEVEL SCRIPTS -->
<script src="./assets/js/register/metronic.js" type="text/javascript"></script>
<script src="./assets/js/register/layout.js" type="text/javascript"></script>
<script src="./assets/js/register/demo.js" type="text/javascript"></script>
<script src="./assets/js/register/form-wizard.js"></script>
<!-- END PAGE LEVEL SCRIPTS -->
<script>
    jQuery(document).ready(function () {
        // initiate layout and plugins
        Metronic.init(); // init metronic core components
        Layout.init(); // init current layout
        Demo.init(); // init demo features
//        FormWizard.init();
        FormWizard.init([23]);
        FormSaveProgress.init([23]);

    });
</script>


<!--UMIS SCRIPTS-->
<!-- Common scripts -->

<script src="./assets/js/functions.js"></script>
<script src="assets/js/validate.js"></script>
<!-- Specific scripts -->
<script src="./assets/js/layerslider/js/greensock.js"></script>
<script src="./assets/js/layerslider/js/layerslider.transitions.js"></script>
<script src="./assets/js/layerslider/js/layerslider.kreaturamedia.jquery.js"></script>
<script type="text/javascript">
    var urlString = location.search;
    var id = urlString.substring(urlString.lastIndexOf('=') + 1);

    var regId = id;
    console.log("UrlString ===================> " + urlString);
    console.log("Urlid ===================> " + id);
    var  url = '/jsongeneral?xml=web/general.xml&view=855:0&where=(registration_id='+ regId +')';
    $.ajax({
        cache: false,
        url: url,
        type: 'GET',
        dataType: "json",
        crossDomain : true,
        success: function (data) {
            console.log("Session data==> " + JSON.stringify(data));
            var appIdentification = data[0].application_id;
            var surname = data[0].surname;
            var fName = data[0].first_name;
            var lName = data[0].middle_name;
            var email = data[0].email;
            var pTel = data[0].primary_telephone;
            var emailed = data[0].emailed;
            var isPaid = data[0].paid;
            var status = data[0].status;
            var declare = JSON.parse(data[0].form_data);
            var declare_agree = declare.declare_agree;
            var full_name = fName + ' ' + lName;
            $("#appName").text(full_name);
            var denomination = data[0].denomination_name;
            var country = data[0].sys_country_name;

            var link = data[0].CL;
            var kf = data[0].KF;
            var fileUrl = '/jsondata?view=828:0:0&data='+ appIdentification;
            console.log("Application ID==> " + appIdentification);
            console.log("declare_agree==> " + declare_agree);

            $.ajax({
                cache: false,
                url: fileUrl,
                type: 'GET',
                dataType: "json",
                success: function (data) {
                    var downlaodFileUrl = '';
                    var htmlDis = '';
                    console.log("FILE DATA ===================> " + JSON.stringify(data));
                    for(var i = 0; i < data.length; i++){
                        if(data[i].narrative == "instituteCertUrl_1"){
                            downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                            htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Certificate 1</a></span>';
                            $('#institutionOneCertUploaded').html(htmlDis);
                            $('#institutionOneCertUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "instituteCertUrl_2"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Certificate 2</a></span>';
                        $('#institutionTwoCertUploaded').html(htmlDis);
                        $('#institutionTwoCertUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "instituteCertUrl_3"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Certificate 3</a></span>';
                        $('#institutionThreeCertUploaded').html(htmlDis);
                        $('#institutionThreeCertUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "instituteTransUrl_1"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Transcript 1</a></span>';
                        $('#institutionOneTransUploaded').html(htmlDis);
                        $('#institutionOneTransUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "instituteTransUrl_2"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Transcript 2</a></span>';
                        $('#institutionTwoTransUploaded').html(htmlDis);
                        $('#institutionTwoTransUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "instituteTransUrl_3"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Transcript 3</a></span>';
                        $('#institutionThreeTransUploaded').html(htmlDis);
                        $('#institutionThreeTransUploadedShow').html(htmlDis);
                        }
                    
                        if(data[i].narrative == "profile_image"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Image</a></span>';
                        $('#profImageUploaded').html(htmlDis);
                        $('#profImageUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        $('#profileImage').hide();
                        }
                        }
                        if(data[i].narrative == "purpose_letter"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Purpose Letter</a></span>';
                        $('#purposeSlipUploaded').html(htmlDis);
                        $('#purposeSlipUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#profileImage').hide();
                        }
                        }
                        if(data[i].narrative == "english_cert_slip"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View English Cert</a></span>';
                        $('#englishCertuploaded').html(htmlDis);
                        $('#englishCertUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#profileImage').hide();
                        }
                        }
                        if(data[i].narrative == "appointment_slip"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Appointment Letter</a></span>';
                        $('#appointmentSlipUploaded').html(htmlDis);
                        $('#appointmentSlipUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#appointmentSlip').hide();
                        }
                    
                        }
                        if(data[i].narrative == "cv_slip"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded CV</a></span>';
                        $('#cvSlipUploaded').html(htmlDis);
                        $('#cvSlipUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#cvSlip').hide();
                        }
                        }
                        if(data[i].narrative == "identification_slip"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded National Identity Card or Passport</a></span>';
                        $('#identificationSlipUploaded').html(htmlDis);
                        $('#identificationSlipUploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#identificationSlip').hide();
                        }
                        }
                        if(data[i].narrative == "ref_one_letter"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                        $('#ref1Uploaded').html(htmlDis);
                        $('#ref1UploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#identificationSlip').hide();
                        }
                        }
                        if(data[i].narrative == "ref_two_letter"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                        $('#ref2Uploaded').html(htmlDis);
                        $('#ref2UploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#identificationSlip').hide();
                        }
                        }
                        if(data[i].narrative == "ref_three_letter"){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<span class="btn btn-info"><a target="_blank" href="'+downlaodFileUrl+'" style="text-decoration:none;color: #fff;">View Uploaded Recommendation</a></span>';
                        $('#ref3Uploaded').html(htmlDis);
                        $('#ref3UploadedShow').html(htmlDis);
                        if (declare_agree !== undefined && declare_agree !== null) {
                        //$('#identificationSlip').hide();
                        }
                        }
                        if(data[i].narrative == "bank_slip" && isPaid == 'f'){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<div class="col-sm-12 col-md-12">'
                        +'<div class="alert alert-success">Upload Successful. Kindly wait for approval to continue</div>'
                        +'</div>';
                        $("#updatePaymentNotification").html(htmlDis);
                        }
                        if(data[i].narrative == "sponsor_slip" && isPaid == 'f'){
                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        htmlDis = '<div class="col-sm-12 col-md-12">'
                        +'<div class="alert alert-success">Upload Successful. Kindly wait for approval to continue</div>'
                        +'</div>';
                        $("#updatePaymentNotification").html(htmlDis);
                        }

                        downlaodFileUrl = '/barazafiles?view=828:0:0&fileid='+data[i].sys_file_id;
                        console.log(i +". HasPaid ===================> " + isPaid);
                        console.log(i +". sys_file_id ===================> " + data[i].sys_file_id);
                        console.log(i +". narrative ===================> " + data[i].narrative);
                        console.log(i +". downloadfileUrl ===================> " + downlaodFileUrl);
                    }
                }
            });
            var formData = JSON.parse(data[0].form_data);
            console.log("Form data==> " + JSON.stringify(formData));

            /*if(formData.declare_agree != "")
            {
                if(formData.declare_agree == "on")
                {
                    document.getElementById("declare_agree").checked = true;
                    $("#declare_agree").prop("checked", true);
                    $("#declare_agree").attr("checked", true);
                }else{
                    document.getElementById("declare_agree").checked = false;
                }
            }*/
            console.log("Checking declare to view only::::::::::::::::::" + formData.declare_agree);
            if(declare_agree == "on"){
                console.log("NDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANI");
                //Hide Action Buttons
                $('#ref_address_2').hide();
                //Set Values In Confirm On SubMission
                $('#surnameShow').html(surname);
                $('#firstnameShow').html(fName);
                $('#lastnameShow').html(lName);
                $('#emailShow').html(email);
                $('#tel_noShow').html(pTel);
                $('#dobShow').html(formData.dob);
                $('#genderShow').html(formData.gender);
                $('#marital_statusShow').html(formData.marital_status);
                $('#denominationShow').html(denomination);
                $('#nationalityShow').html(country);
                $('#passport_id_noShow').html(formData.passport_id_no);
                $('#disability_boolShow').html(formData.disability_bool);
                $('#disabilityShow').html(formData.disability);
                $('#current_addressShow').html(formData.current_address);
                $('#permanent_addressShow').html(formData.permanent_address);
                $('#degree_1Show').html(formData.degree_1);
                $('#university_1Show').html(formData.university_1);
                $('#completion_yr_1Show').html(formData.completion_yr_1);
                $('#grades_1Show').html(formData.grades_1);
                $('#degree_2Show').html(formData.degree_2);
                $('#university_2Show').html(formData.university_2);
                $('#completion_yr_2Show').html(formData.completion_yr_2);
                $('#grades_2Show').html(formData.grades_2);
                $('#degree_3Show').html(formData.degree_3);
                $('#university_3Show').html(formData.university_3);
                $('#completion_yr_3Show').html(formData.completion_yr_3);
                $('#grades_3Show').html(formData.grades_3);
                $('#post_gradShow').html(formData.post_grad);
                $('#accomodationShow').html(formData.accomodation);
                $('#sponsoredShow').html(formData.sponsored);
                $('#sponsoresShow').html(formData.sponsores);
                $('#is_englishShow').html(formData.is_english);
                $('#prof_testShow').html(formData.prof_test);
                $('#test_nameShow').html(formData.test_name);
                $('#date_testShow').html(formData.date_test);
                $('#occupation_1Show').html(formData.occupation_1);
                $('#employer_1Show').html(formData.employer_1);
                $('#workstation_1Show').html(formData.workstation_1);
                $('#duration_1Show').html(formData.duration_1);
                $('#occupation_2Show').html(formData.occupation_2);
                $('#employer_2Show').html(formData.employer_2);
                $('#workstation_2Show').html(formData.workstation_2);
                $('#duration_2Show').html(formData.duration_2);
                $('#occupation_3Show').html(formData.occupation_3);
                $('#employer_3Show').html(formData.employer_3);
                $('#workstation_3Show').html(formData.workstation_3);
                $('#duration_3Show').html(formData.duration_3);
                $('#occupation_4Show').html(formData.occupation_4);
                $('#employer_4Show').html(formData.employer_4);
                $('#workstation_4Show').html(formData.workstation_4);
                $('#duration_4Show').html(formData.duration_4);
                $('#num_yrsShow').html(formData.num_yrs);
                $('#ref_name_1Show').html(formData.ref_name_1);
                $('#ref_name_2Show').html(formData.ref_name_2);
                $('#ref_name_3Show').html(formData.ref_name_3);
                $('#ref_address_1Show').html(formData.ref_address_1);
                $('#ref_address_2Show').html(formData.ref_address_2);
                $('#ref_address_3Show').html(formData.ref_address_3);
                $('#campus_siteShow').html(formData.campus_site);
                $('#schoolShow').html(formData.school);
                $('#thsmShow').html(formData.thsm);
                $('#pgsShow').html(formData.pgs);
            }

        },
        error: function (r) {
            //alert('Error! Please try again.' + r.responseText);
            console.log("Error  data ==> " + r.res );
             console.log("Error  data ==> " + JSON.stringify(r));
        }
    });

</script>
<script src="./assets/js/tabs.js"></script>
<script>new CBPFWTabs(document.getElementById('tabs'));</script>
<script type="text/javascript">


</script>


<!-- END JAVASCRIPTS -->

</body>
<!-- END BODY -->
</html>
