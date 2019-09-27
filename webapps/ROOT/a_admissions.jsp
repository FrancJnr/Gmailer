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
   		out.println("	<script>");
   		out.println("		window.open('show_report?report=" + reportexport + "');");
   		out.println("	</script>");
   	}



   %>
		<!--[if IE 8]>
		<html lang="en" class="ie8 no-js">
		<![endif]-->
		<!--[if IE 9]>
		<html lang="en" class="ie9 no-js">
		<![endif]-->
		<!--[if !IE]><!-->
		<html lang="en" class="no-js">
		<!--<![endif]-->
		<!-- BEGIN HEAD -->
		<head>
		<meta charset="utf-8"/>
		<title><%= pageContext.getServletContext().getInitParameter("web_title") %></title>
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta content="width=device-width, initial-scale=1" name="viewport"/>
		<meta content="Open Baraza Framework" name="description"/>
		<meta content="Open Baraza" name="author"/>
		<!-- BEGIN GLOBAL MANDATORY STYLES -->
		<link href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700&subset=all" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/font-awesome/css/font-awesome.min.css"  rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/simple-line-icons/simple-line-icons.min.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/uniform/css/uniform.default.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet" type="text/css"/>
		<!-- END GLOBAL MANDATORY STYLES -->
		<!-- BEGIN PAGE LEVEL PLUGIN STYLES -->
		<link href="./assets/global/plugins/bootstrap-daterangepicker/daterangepicker-bs3.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/fullcalendar/fullcalendar.min.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/jqvmap/jqvmap/jqvmap.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/morris/morris.css" rel="stylesheet" type="text/css">
		<!-- END PAGE LEVEL PLUGIN STYLES -->
		<!-- BEGIN PAGE STYLES -->
		<link href="./assets/admin/pages/css/tasks.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/clockface/css/clockface.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/bootstrap-datepicker/css/bootstrap-datepicker3.min.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/bootstrap-timepicker/css/bootstrap-timepicker.min.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/bootstrap-colorpicker/css/colorpicker.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/bootstrap-daterangepicker/daterangepicker-bs3.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/bootstrap-datetimepicker/css/bootstrap-datetimepicker.min.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/jquery-tags-input/jquery.tagsinput.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/select2/select2.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/jquery-multi-select/css/multi-select.css" rel="stylesheet" type="text/css" />
		<link href="./assets/global/plugins/fullcalendar/fullcalendar.min.css" rel="stylesheet"/>
		<link href="./assets/global/plugins/bootstrap-toastr/toastr.min.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/bootstrap-fileinput/bootstrap-fileinput.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/admin/pages/css/profile.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/plugins/jstree/dist/themes/default/style.min.css" rel="stylesheet" type="text/css"/>
		<!-- CSS to style the file input field as button and adjust the Bootstrap progress bars -->
		<link href="./assets/global/plugins/jquery-file-upload/css/jquery.fileupload.css" rel="stylesheet">
		<!-- END PAGE STYLES -->
		<!-- BEGIN THEME STYLES -->
		<!-- DOC: To use 'rounded corners' style just load 'components-rounded.css' stylesheet instead of 'components.css' in the below style tag -->
			<% if(web.isMaterial()) { %>
		<script >console.info("Material Design") </script>
		<link href="./assets/global/css/components-md.css" id="style_components" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/css/plugins-md.css" rel="stylesheet" type="text/css"/>
			<% } else { %>
		<script >console.info("Default Design") </script>
		<link href="./assets/global/css/components-rounded.css" id="style_components" rel="stylesheet" type="text/css"/>
		<link href="./assets/global/css/plugins.css" rel="stylesheet" type="text/css"/>
			<% } %>
		<link href="./assets/admin/layout4/css/layout.css" rel="stylesheet" type="text/css"/>
		<link href="./assets/admin/layout4/css/themes/light.css" rel="stylesheet" type="text/css" id="style_color"/>
		<!-- END THEME STYLES -->
		<link rel="shortcut icon" href="./assets/logos/favicon.png"/>
		<link href="./assets/global/plugins/jquery-ui/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css" media="screen" />
		<link href="./assets/jqgrid/css/ui.jqgrid.css" rel="stylesheet" type="text/css" media="screen" />
		<!-- jsgrid css -->
		<link type="text/css" rel="stylesheet" href="./assets/jsgrid/jsgrid.min.css" />
		<link type="text/css" rel="stylesheet" href="./assets/jsgrid/jsgrid-theme.min.css" />
		<link href="./assets/css/register/custom.css" rel="stylesheet" type="text/css"/>
		<style type="text/css">
		.radio-node{
		display: none;
		margin-top: 20px;
		}
		.form-wizard .steps {
		padding: 0px;
		margin-bottom: 0px;
		background-color: #fff;
		background-image: none;
		filter: none;
		border: 0px;
		box-shadow: none;
		}
		.form-wizard .progress {
		margin-bottom: 0px;
		}
		.progress {
		height: 5px;
		}
		.portlet.box.blue > .portlet-title {
		background-color: #283842;
		}
		h3.block {
		padding:0px;
		}
		h3 {
		margin: 0px;
		margin-bottom: 10px;
		}
		</style>
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
		<body class="page-header-fixed page-sidebar-closed-hide-logo page-sidebar-closed-hide-logo page-footer-fixed">
		<!-- BEGIN HEADER -->
		<div class="page-header navbar navbar-fixed-top">
		<!-- BEGIN HEADER INNER -->
		<div class="page-header-inner">
		<!-- BEGIN LOGO -->
		<div class="page-logo">
		<a href="index.jsp">
		<img src="./assets/img/logo/openbaraza-logo.png" alt="logo" style="margin: 20px 10px 0 10px; width: 185px;" class="logo-default"/>
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
			<%= web.getOrgName() %> | <%= web.getEntityName() %>  </span>
		<!-- DOC: Do not remove below empty space(&nbsp;) as its purposely used -->
		<img alt="" class="img-circle" src="./assets/admin/layout4/img/avatar.png"/>
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
		<div class="clearfix"></div>
		<!-- BEGIN CONTAINER -->
		<div class="page-container">
		<!-- BEGIN SIDEBAR -->
		<div class="page-sidebar-wrapper">
		<!-- DOC: Set data-auto-scroll="false" to disable the sidebar from auto scrolling/focusing -->
		<!-- DOC: Change data-auto-speed="200" to adjust the sub menu slide up/down speed -->
		<div class="page-sidebar navbar-collapse collapse">
		<!-- BEGIN SIDEBAR MENU -->
		<!-- DOC: Apply "page-sidebar-menu-light" class right after "page-sidebar-menu" to enable light sidebar menu style(without borders) -->
		<!-- DOC: Apply "page-sidebar-menu-hover-submenu" class right after "page-sidebar-menu" to enable hoverable(hover vs accordion) sub menu mode -->
		<!-- DOC: Apply "page-sidebar-menu-closed" class right after "page-sidebar-menu" to collapse("page-sidebar-closed" class must be applied to the body element) the sidebar sub menu mode -->
		<!-- DOC: Set data-auto-scroll="false" to disable the sidebar from auto scrolling/focusing -->
		<!-- DOC: Set data-keep-expand="true" to keep the submenues expanded -->
		<!-- DOC: Set data-auto-speed="200" to adjust the sub menu slide up/down speed -->
		<!-- END SIDEBAR MENU -->
		</div>
		</div>
		<!-- END SIDEBAR -->
		<!-- BEGIN CONTENT -->
		<div class="page-content-wrapper">
		<div class="page-content" style="margin-left:20px;">
			<% if(web.getViewType().equals("DASHBOARD")) { %>
			<%= web.getDashboard() %>
			<% if(web.hasDashboardItem("ATTENDANCE")) {%>
		<%@ include file="./assets/include/attendance.jsp" %>
			<% } %>
			<% if(web.hasDashboardItem("TASK")) {%>
		<%@ include file="./assets/include/task.jsp" %>
			<% } %>
			<% } else { %>
		<!-- BEGIN PAGE CONTENT-->
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
		<!-- BEGIN PAGE HEADER--
		<!-- END PAGE HEADER-->
		<!-- BEGIN PAGE CONTENT-->
		<div class="row">
		<div class="col-md-12">
		<div class="portlet box blue" id="form_wizard_1">
		<div class="portlet-title">
		<div class="caption">
		<i class="fa fa-file-text"></i> Admission Form - <span class="step-title">
		Step 1 of 5 </span>
		</div>
		<div class="tools hidden-xs">
		<a href="javascript:;" class="collapse">
		</a>
		<a href="#portlet-config" data-toggle="modal" class="config">
		</a>
		<a href="javascript:;" class="reload">
		</a>
		</div>
		</div>
		<div class="portlet-body form">
		<form action="#" class="form-horizontal" id="submit_form_1" method="POST">
		<input type="hidden" name="org_name" id="org_name" value="">
		<input type="hidden" name="org_email" id="org_email" value="">
		<input type="hidden" name="org_country" id="org_country" value="">
		<input type="hidden" name="org_address" id="org_address" value="">
		<input type="hidden" name="org_sponsoring_division" id="org_sponsoring_division" value="">
		<div class="form-wizard">
		<div class="form-body">
		<ul class="nav nav-pills nav-justified steps" id="nav_pills">
		<li id="li_prog_1">
		<a href="#tab1"  data-toggle="tab" class="step">
		<span class="number">
		1 </span>
		<span class="desc">
		<i class="fa fa-check"></i> SECTION A </span>
		</a>
		</li>
		<li id="li_prog_2">
		<a href="#tab2"  data-toggle="tab" class="step">
		<span class="number">
		2 </span>
		<span class="desc">
		<i class="fa fa-check"></i> SECTION B </span>
		</a>
		</li>
		<li id="li_prog_3">
		<a href="#tab3" data-toggle="tab" class="step">
		<span class="number">
		3 </span>
		<span class="desc">
		<i class="fa fa-check"></i> SECTION C </span>
		</a>
		</li>
		<li id="li_prog_4">
		<a href="#tab4" data-toggle="tab" class="step">
		<span class="number">
		4 </span>
		<span class="desc">
		<i class="fa fa-check"></i> SECTION D </span>
		</a>
		</li>
		<li id="li_prog_5">
		<a href="#tab5" data-toggle="tab" class="step">
		<span class="number">
		5 </span>
		<span class="desc">
		<i class="fa fa-check"></i> SECTION E </span>
		</a>
		</li>
		<li id="li_prog_6">
		<a href="#tab6" data-toggle="tab" class="step">
		<span class="number">
		6 </span>
		<span class="desc">
		<i class="fa fa-check"></i> CONFIRM </span>
		</a>
		</li>
		</ul>
		<div id="bar" class="progress progress-striped" role="progressbar">
		<div class="progress-bar progress-bar-success">
		</div>
		</div>
		<div class="tab-content">
		<div class="alert alert-danger alert-danger-validation display-none" id="failedSubmission">
		<%--<button class="close" data-dismiss="alert"></button>--%>
		You have not filled some compulsory fields.
		</div>
		<%--<div class="alert alert-danger alert-danger-server display-none">--%>
		<%--<button class="close" data-dismiss="alert"></button>--%>
		<%--Something Went Wrong. Contact the administrator.--%>
		<%--</div>--%>
		<div class="alert alert-success confirm display-none" id="successSubmission">
		<%--<button class="close" data-dismiss="alert"></button>--%>
		Your form has been submitted successfully!
		</div>
		<div class="alert alert-success progress-step display-none">
		<%--<button class="close" data-dismiss="alert"></button>--%>
		Progress saved successfully!
		</div>
		<div class="tab-pane active" id="tab1">
		<form action="#" class="form-horizontal" id="submit_form_one" method="POST">
		<h3 class="block">Your Account Details</h3>
		<div class="row">
		<div class="col-md-4">
		<div class="form-group">
		<label class="control-label col-md-4">Surname <span class="required"
		aria-required="true">
		* </span>
		</label>
		<div class="col-md-8">
		<input class="form-control" name="surname" id="surname" type="text" disabled>
		<input class="form-control" name="submit_form" id="submit_form" value="1" type="hidden">
		<span class="help-block">
		Provide your Surname </span>
		</div>
		</div>
		</div>
		<div class="col-md-4">
		<div class="form-group">
		<label class="control-label col-md-4">Firstname <span
		class="required" aria-required="true">
		* </span>
		</label>
		<div class="col-md-8">
		<input class="form-control" name="firstname" id="firstname" type="text" disabled>
		<span class="help-block">
		Provide your First Name </span>
		</div>
		</div>
		</div>
		<div class="col-md-4">
		<div class="form-group">
		<label class="control-label col-md-4">Middle Name <span
		class="required" aria-required="true">
		* </span>
		</label>
		<div class="col-md-8">
		<input class="form-control" name="lastname" id="lastname" type="text" disabled>
		<span class="help-block">
		Provide your Middle Name </span>
		</div>
		</div>
		</div>
		</div>
		<div class="row">
		<div class="col-md-4">
		<div class="form-group">
		<label class="control-label col-md-4">Email <span class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control" name="email" id="email"
		id="submit_form_email" disabled/>
		<span class="help-block">
		Provide your email address </span>
		</div>
		</div>
		</div>
		<div class="col-md-4">
		<div class="form-group">
		<label class="control-label col-md-4">Telephone Number <span
		class="required"></span>
		</label>
		<div class="col-md-8">
		<input class="form-control" name="tel_no" id="tel_no" type="text"disabled>
		<span class="help-block">
		Provide your telephone number </span>
		</div>
		</div>
		</div>
		</div>
		<!--Payment-->
		<h3 class="block">Payment </h3>
		<h5>You cannot proceed until payment is concluded. Select one of the applicable ways to complete your payment.</h5>
		<!-- PAYMENT-->
		<div class="row" id="updatePaymentNotification">
		</div>
		<div class="row" >
		<!--HeRe-->
		<div class="col-md-5">
		<div class="md-radio-list">
		<div class="md-radio">
		<input type="radio" id="self_sponsored" name="chosen_payment" class="md-radiobtn">
		<label for="self_sponsored">
		<span></span>
		<span class="check"></span>
		<span class="box"></span>
		Online Payment for Self Sponsored students </label>
		</div>
		<div class="md-radio">
		<input type="radio" id="sponsorship_letter" name="chosen_payment" class="md-radiobtn">
		<label for="sponsorship_letter">
		<span></span>
		<span class="check"></span>
		<span class="box"></span>
		For sponsored students Upload Sponsorship letter </label>
		</div>
		<div class="md-radio">
		<input type="radio" id="bank_letter" name="chosen_payment" class="md-radiobtn">
		<label for="bank_letter">
		<span></span>
		<span class="check"></span>
		<span class="box"></span>
		Already Paid? Upload Bank Slips</label>
		</div>
		</div>
		</div>
		<div class="col-md-6">
		<div class="radio-node" id="paypal_div">
		<div id="aua-paypal-btn"  style="padding-top:20px;"></div>
		</div>
		<div class="radio-node" id="sponsor_slip">
		<!--sponsorship upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Sponsorship Slip </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="sponsor_slip_upload" id="sponsor_slip_upload" class="sponsor_slip_upload"
		accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>
		</form>
		<!--/sponsorship upload-->
		</div>
		<div class="radio-node" id="bank_slip">
		<!--Bank upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Bank Slip </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="bank_slip_upload" id="bank_slip_upload" class="bank-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>
		</form>
		<!--/Bank upload-->
		</div>
		</div>
		</div>
		<!-- /PAYMENT -->
		<a href="javascript:;" style="visibility: hidden" class="btn green button-save">
		Save <i class="m-icon-swapright m-icon-white"></i>
		</a>
		</form>
		</div>
		<div class="tab-pane" id="tab2">
		<h3 class="block">Upload All your documents as stated below.</h3>
		<div class="row form">
		<div class="form-horizontal form-bordered">
		<div class="form-body">
		<div class="form-group ">
		<label class="control-label col-md-3">Profile Image <span class="required">
		* </span></label>
		<div class="col-md-9">
		<div id="profileImageAlert"></div>
		<div class="fileinput fileinput-new" data-provides="fileinput" id="profileImage">
		<div class="fileinput-new thumbnail" style="width: 200px; height: 150px;">
		<img src="http://www.placehold.it/200x150/EFEFEF/AAAAAA&amp;text=no+image" alt=""> </div>
		<div class="fileinput-preview fileinput-exists thumbnail" style="max-width: 200px; max-height: 150px;"> </div>
		<div>
		<span class="btn default btn-file">
		<span class="fileinput-new"> Select Profile Image </span>
		<span class="fileinput-exists"> Change </span>
		<input type="file" name="file" id="file" class="profile-image-upload" value="cv_slip_upload" accept="image/*">
		</span>
		<a href="javascript:;" class="btn red fileinput-exists" data-dismiss="fileinput"> Remove </a>
		</div>
		</div>
		<%--Render Image--%>
		<div class="clearfix margin-top-10" id="profImageUploaded">

		</div>
		</div>
		</div>
		<div class="form-group">
		<label class="control-label col-md-3">Upload purpose to join AUA <span class="required">
		* </span></label>
		<div class="col-md-9">
		<div id="purposeAlert"></div>
		<!--Purpose upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput" id="purposeSlip">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Purpose Letter </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="purpose_slip_upload" id="purpose_slip_upload" class="purpose-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>

		</form>
		<!--/Purpose upload-->
		<div  id="purposeSlipUploaded" class="clearfix margin-top-10"></div>
		</div>
		</div>
		<div class="form-group">
		<label class="control-label col-md-3">Upload Academic Transcripts <span class="required">
		* </span></label>
		<div class="col-md-9">
		<div class="clearfix margin-top-10">
		<span class="label label-success">NOTE!</span> <b>Ask the concerned institution to send the transcripts directly to the University</b>
		</div>
		</div>
		</div>
		<div class="form-group">
		<label class="control-label col-md-3">Upload Current Appointment Letter</label>
		<div class="col-md-9">
		<!--Appointment upload-->
		<div id="appointmentSlipAlert"></div>
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput" id="appointmentSlip">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Appointment Letter </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="appointment_slip_upload" value="cv_slip_upload" id="appointment_slip_upload" class="appointment-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>
		</form>
		<!--/Appointment upload-->
		<div class="clearfix margin-top-10">
		<span class="label label-success">NOTE!</span> Where Applicable
		</div>

		<%--Render Appointment--%>
		<div class="clearfix margin-top-10" id="appointmentSlipUploaded">

		</div>
		</div>
		</div>
		<div class="form-group">
		<label class="control-label col-md-3">Upload Updated CV <span class="required">
		* </span></label>
		<div class="col-md-9">
		<!--CV upload-->
		<div id="cvSlipAlert"></div>
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput" id="cvSlip">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select CV </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="cv_slip_upload" id="cv_slip_upload" value="cv_slip_upload" class="cv-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>
		</form>
		<!--/CV upload-->
		<%--Render Cv--%>
		<div class="clearfix margin-top-10" id="cvSlipUploaded">

		</div>
		</div>
		</div>
		<div class="form-group last">
		<label class="control-label col-md-3">Upload National Identity Card or Passport <span class="required">
		* </span></label>
		<div class="col-md-9">
		<!--CV upload-->
		<div id="identificationSlipAlert"></div>
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput" id="identificationSlip">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select ID </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="id_slip_upload" id="id_slip_upload" value="id_slip_upload" class="id-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove </a>
		</span>
		</div>
		</div>
		</form>
		<!--/CV upload-->
		<%--Render ID--%>
		<div class="clearfix margin-top-10" id="identificationSlipUploaded">

		</div>
		</div>
		</div>
		</div>
		</div>
		</div>
		</div>
		<div class="tab-pane" id="tab3">
		<h3 class="block">Provide your Profile Information</h3>
		<div class="row" id="form_wizard_3">
		<%--<form action="#" class="form-horizontal" id="submit_form_3" method="POST">--%>
		<div class="col-md-12">
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Gender <span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<select name="gender" class="form-control" id="gender">
		<option selected value="">Select</option>
		<option value="M">Male</option>
		<option value="F">Female</option>
		</select>
		<div id="form_gender_error">
		</div>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Marital Status <span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<select class="form-control" name="marital_status" id="marital_status"/>
		<span class="help-block">
		Provide your Marital Status </span>
		<option selected value="">Select</option>
		<option value="S">Single</option>
		<option value="M">Married</option>
		</select>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Religious Affiliation <span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<select id="denomination" name="denomination" class="form-control">
		<option  value="" selected>Select denomination</option>
		</select>
		<div id="form_denomination_error">
		</div>
		</div>
		</div>
		</div>
		<div class="col-md-12">
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Date Of Birth<span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control" id="dob"
		name="dob"/>
		<span class="help-block">
		Provide your Date Of Birth </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Nationality <span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<select name="nationality" id="country_list" class="form-control">
		<option value="">Select Nationality</option>
		</select>
		<span class="help-block">
		Provide your Nationality </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Passport No/ ID
		No <span class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control" id="passport_id_no"
		name="passport_id_no"/>
		<span class="help-block">
		Provide your Passport No/ ID No </span>
		</div>
		</div>
		</div>
		<div class="col-md-12">
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">
		Physical Disability / Special needs <span class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<div id="form_disability_bool_error"></div>
		<select name="disability_bool" id="disability_bool" class="form-control" onchange='showInput(this.value, "disability")'>
		<option selected value="">Select</option>
		<option value="Y">Yes</option>
		<option value="N">No</option>
		</select>
		<input type="text" class="form-control"
		name="disability" id="disability"/>
		<span class="help-block">
		If so indicate the form of disability </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Current Address <span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<textarea class="form-control"
		name="current_address" id="current_address"></textarea>
		<span class="help-block">
		Provide your Current Address
		</span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Permanent Address<span
		class="required">
		* </span>
		</label>
		<div class="col-md-8">
		<textarea class="form-control"
		name="permanent_address" id="permanent_address"></textarea>
		<span class="help-block">
		Provide your Permanent Address </span>
		</div>
		</div>
		</div>
		<%--</form> <!--End form 3-->--%>
		</div>
		</div>
		<div class="tab-pane" id="tab4">
		<h3 class="block">Provide your Education Information</h3>
		<div class="row">
		<!--Qualification-->
		<div class="row">
		<div class="form-group col-md-3">
		<h4 class="col-title text-center">QUALIFICATIONS ( <em>Highest
		Degrees Earned</em> )</h4>
		<label class="control-label col-md-2">1. <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control" name="degree_1" id="degree_1"/>
		<span class="help-block">
		Provide your Degree earned  *</span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h4 class="col-title text-center">UNIVERSITY / COLLEGE
		ATTENDED </h4>
		<label class="control-label col-md-2"> <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="university_1" id="university_1"/>
		<span class="help-block">
		Provide your learning institution </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h4 class="col-title text-center">YEAR OF <br>COMPLETION </h4>
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control years"
		name="completion_yr_1" id="completion_yr_1"/>
		<span class="help-block">
		Provide your year of completion </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h4 class="col-title text-center">GRADES <br>OBTAINED </h4>
		<div class="col-md-10">
		<input type="text" class="form-control" name="grades_1" id="grades_1"/>
		<span class="help-block">
		Provide your grade </span>
		</div>
		</div>
		</div>

		<div class="row">
		<!-- Upload Certificate -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionOneCertAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Certificate </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_one_cert_slip_upload" id="institution_one_cert_slip_upload" class="institution-one-cert-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionOneCertUploaded"></div>
		</div>

		<!-- Upload Transcript -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionOneTransAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Transcript </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_one_trans_slip_upload" id="institution_one_trans_slip_upload" class="institution-one-trans-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionOneTransUploaded"></div>
		</div>
		</div>

		<div class="row">
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">QUALIFICATIONS ( <em>Highest Degrees Earned</em> )</h4>-->
		<label class="control-label col-md-2">2. <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control" name="degree_2" id="degree_2"/>
		<span class="help-block">
		Provide your Degree earned </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">UNIVERSITY / COLLEGE ATTENDED </h4>-->
		<label class="control-label col-md-2"> <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="university_2" id="university_2"/>
		<span class="help-block">
		Provide your learning institution </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">YEAR OF <br>COMPLETION </h4>-->
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control years"
		name="completion_yr_2" id="completion_yr_2"/>
		<span class="help-block">
		Provide your year of completion </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">GRADES <br>OBTAINED </h4>-->
		<div class="col-md-10">
		<input type="text" class="form-control" name="grades_2" id="grades_2"/>
		<span class="help-block">
		Provide your grade </span>
		</div>
		</div>
		</div>

		<div class="row">
		<!-- Upload Certificate -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionTwoCertAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Certificate </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_two_cert_slip_upload" id="institution_two_cert_slip_upload" class="institution-two-cert-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionTwoCertUploaded"></div>
		</div>

		<!-- Upload Transcript -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionTwoTransAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Transcript </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_two_trans_slip_upload" id="institution_two_trans_slip_upload" class="institution-two-trans-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionTwoTransUploaded"></div>
		</div>
		</div>

		<div class="row">
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">QUALIFICATIONS ( <em>Highest Degrees Earned</em> )</h4>-->
		<label class="control-label col-md-2">3. <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control" name="degree_3" id="degree_3"/>
		<span class="help-block">
		Provide your Degree earned </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">UNIVERSITY / COLLEGE ATTENDED </h4>-->
		<label class="control-label col-md-2"> <span class="required">
		</span>
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="university_3" id="university_3"/>
		<span class="help-block">
		Provide your learning institution </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">YEAR OF <br>COMPLETION </h4>-->
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control years"
		name="completion_yr_3" id="completion_yr_3"/>
		<span class="help-block">
		Provide your year of completion </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<!--<h4 class="col-title">GRADES <br>OBTAINED </h4>-->
		<div class="col-md-10">
		<input type="text" class="form-control" name="grades_3" id="grades_3"/>
		<span class="help-block">
		Provide your grade </span>
		</div>
		</div>
		</div>

		<div class="row">
		<!-- Upload Certificate -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionThreeCertAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Certificate </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_three_cert_slip_upload" id="institution_three_cert_slip_upload" class="institution-three-cert-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionThreeCertUploaded"></div>
		</div>

		<!-- Upload Transcript -->
		<div class="col-md-3" style="margin-left:50px;margin-bottom: 20px;">
		<div id="institutionThreeTransAlert"></div>

		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Transcript </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="institution_three_trans_slip_upload" id="institution_three_trans_slip_upload" class="institution-three-trans-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<div class="clearfix margin-top-10" id="institutionThreeTransUploaded"></div>
		</div>
		</div>

		<!--/Qualification-->
		<!--Degree desired:-->
		<div class="row">
		<div class="form-group col-md-5">
		<h4 class="col-title">Degree desired: </h4>
		<label class="control-label col-md-5">Degree offered: <span
		class="required">
		* </span>
		</label>
		<div class="col-md-7">
		<select name="school" class="form-control" id="school" onchange='filterDegrees(this.value)'>
		<option selected value="">Select School</option>
		<option value="thsm">Theological Seminary</option>
		<option value="pgs">Post Graduate Studies</option>
		</select>
		<div id="form_school_error"></div>
		<select name="thsm" class="form-control" id="thsm" style="display:none">
		<option selected value="">Select Degree in THSM</option>
		</select>
		<div id="form_thsm_error"></div>
		<select name="pgs" class="form-control" id="pgs" style="display:none">
		<option selected value="">Select Degree in PGS</option>
		</select>
		<div id="form_pgs_error"></div>
		<select name="special" class="form-control" id="special" style="display:none">
		<option selected value="">Select Specialization</option>
		</select>
		<div id="form_special_error"></div>

		<%--<select name="post_grad" class="form-control" id="degree">--%>
		<%--<option selected value="">Select Degree</option>--%>
		<%--</select>--%>
		<%--<div id="form_post_grad_error"></div>--%>
		</div>
		</div>
		<!--/Degree desired:-->
		<div class="form-group col-md-3">
		<h4 class="col-title" style="visibility: hidden;">Accomodation </h4>
		<label class="control-label col-md-6" for="accomodation">
		Accomodation - On Campus <span class="required"> * </span>
		</label>
		<div class="col-md-6">
		<select name="accomodation" id="accomodation" class="form-control">
		<option selected value="">Select</option>
		<option value="Y">Yes</option>
		<option value="N">No</option>
		</select>
		<div id="form_accomodation_error"></div>
		</div>
		</div>
		<div class="form-group col-md-4">
		<h4 class="col-title" style="visibility: hidden;">Finance: </h4>
		<label class="control-label col-md-4">
		Sponsored? <span class="required"> * </span>
		</label>
		<div class="col-md-8">
		<select name="sponsored" id="selfSponsored" onchange='showInput(this.value, "self_sponsores_wrapper")' class="form-control">
		<option selected value="">Select</option>
		<option value="Y">Yes</option>
		<option value="N">No</option>
		</select>
		<div id="self_sponsores_wrapper">
		<select name="sponsores" id="self_sponsores" class="form-control">
		<option selected value="1">Select Sponsors</option>
		</select>
		<input type="text" class="form-control" name="other_sponsors" id="other_sponsors" placeholder="Enter Other Sponsors">
		<span class="help-block">
		Enter sponsors if not listed </span>
		</div>
		<div id="form_self_sponsored_error"></div>
		</div>
		</div>
		</div>
		<div class="row">
		<div class="col-md-offset-2 col-md-6">
		<div class="form-group">
		<!--Campus Site-->
		<label class="control-label col-md-6" for="campus_site">
		Campus Site <span class="required"> * </span>
		</label>
		<div class="col-md-6">
		<select name="campus_site" id="campus_site" class="form-control">
		<option selected value="">Select Campus Site</option>
		</select>
		<div id="form_campus_site_error"></div>
		</div>
		<!--Campus Site-->
		</div>
		</div>
		</div>

		<!--English Proficiency:-->
		<div class="row">
		<div class="col-md-offset-2 col-md-6">
		<div class="form-group">
		<h4 class="col-title">English Proficiency: </h4>
		<label class="control-label col-md-8">
		Graduated from English-speaking College/University? <span class="required"> * </span>
		</label>
		<div class="col-md-4">
		<select name="is_english" id="is_english" class="form-control">
		<option selected value="">Select</option>
		<option value="Yes">Yes</option>
		<option value="No">No</option>
		</select>
		<div id="form_is_english_error"></div>
		</div>
		<label class="control-label col-md-8">
		If No, Passed an English proficiency test?
		</label>
		<div class="col-md-4">
		<select name="prof_test" id="prof_test" class="form-control">
		<option selected value="">Select</option>
		<option value="Yes">Yes</option>
		<option value="No">No</option>
		</select>
		<div id="form_prof_test_error"></div>
		</div>
		<div class="col-md-12">
		<label class="control-label col-md-6">
		Name of Test
		</label>
		<div class="col-md-6">
		<input type="text" class="form-control"
		name="test_name" id="test_name"/>
		</div>
		<label class="control-label col-md-6">
		Upload Certificate
		</label>
		<div class="col-md-6">
		<!--Add File here-->
		<div id="englishCertAlert"></div>
		<!--English Cert upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class=""></span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp;
		<span class="fileinput-filename"></span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select English Transcript </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="english_cert_slip_upload" id="english_cert_slip_upload" class="english-cert-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<!--/English Cert upload-->
		<div id="englishCertuploaded" class="clearfix margin-top-10"></div>
		</div>
		<label class="control-label col-md-6">
		Score
		</label>
		<div class="col-md-6">
		<input type="text" class="form-control" name="score" id="score"/>
		</div>
		<label class="control-label col-md-6">
		Date
		</label>
		<div class="col-md-6">
		<input type="text" class="form-control date"
		name="date_test" id="date_test"/>
		</div>
		</div>
		</div>
		</div>
		</div>
		<!--/English Proficiency:-->
		</div>
		</div>
		<div class="tab-pane" id="tab5">
		<h3 class="block">Provide your Working Information</h3>
		<div class="row">
		<!--Professional information-->
		<div class="col-md-12">
		<div class="form-group col-md-3">
		<h4 class="col-title text-center">OCCUPATION</h4>
		<h5 class="col-title text-center"><em>Current Position
		held</em></h5>
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
		<div class="col-md-12">
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">1.
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="occupation_1" id="occupation_1"/>
		<span class="help-block">
		Provide your occupation </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="employer_1" id="employer_1"/>
		<span class="help-block">
		Provide your employer </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="workstation_1" id="workstation_1"/>
		<span class="help-block">
		Provide your work station </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="duration_1" id="duration_1"/>
		<span class="help-block">
		Provide your duration </span>
		</div>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h4 style="visibility: hidden"
		class="col-title text-center">OCCUPATION</h4>
		<h5 class="col-title text-center"><em>Previous position
		held</em></h5>
		</div>
		<div style="visibility: hidden" class="form-group col-md-3">
		<h4 class="col-title text-center">EMPLOYER </h4>
		</div>
		<div style="visibility: hidden" class="form-group col-md-3">
		<h4 class="col-title text-center">WORK STATION </h4>
		</div>
		<div style="visibility: hidden" class="form-group col-md-3">
		<h4 class="col-title text-center">DURATION </h4>
		</div>
		<div class="col-md-12">
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">1.
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="occupation_2" id="occupation_2"/>
		<span class="help-block">
		Provide your occupation </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="employer_2" id="employer_2"/>
		<span class="help-block">
		Provide your employer </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="workstation_2" id="workstation_2"/>
		<span class="help-block">
		Provide your work station </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="duration_2" id="duration_2"/>
		<span class="help-block">
		Provide your duration </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">2.
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="occupation_3" id="occupation_3"/>
		<span class="help-block">
		Provide your occupation </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="employer_3" id="employer_3"/>
		<span class="help-block">
		Provide your employer </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="workstation_3" id="workstation_3"/>
		<span class="help-block">
		Provide your work station </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="duration_3" id="duration_3"/>
		<span class="help-block">
		Provide your duration </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">3.
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="occupation_4" id="occupation_4"/>
		<span class="help-block">
		Provide your occupation </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="employer_4" id="employer_4"/>
		<span class="help-block">
		Provide your employer </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="workstation_4" id="workstation_4"/>
		<span class="help-block">
		Provide your work station </span>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<input type="text" class="form-control"
		name="duration_4" id="duration_4"/>
		<span class="help-block">
		Provide your duration </span>
		</div>
		</div>
		</div>
		<div class="col-md-12">
		<div class="form-group col-md-5">
		<label class="control-label col-md-7">Total Number of
		years worked
		</label>
		<div class="col-md-7">
		<input type="text" class="form-control"
		name="num_yrs" id="num_yrs"/>
		<span class="help-block">
		Provide your worked years </span>
		</div>
		</div>
		</div>
		<!--Referee Title-->
		<div class="col-md-12">
		<div class="form-group col-md-5">
		<h4 class="col-title text-left"><b>Names and Addresses
		of three referees</b></h4>
		<!--<h5 class="col-title text-center"><em>Previous position held</em></h5>-->
		</div>
		</div>
		<!--Referees -->
		<div class="col-md-12">
		<!--Name-->
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">1. Name <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_name_1" id="ref_name_1"/>
		<span class="help-block">
		Provide your referee name </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">2. Name <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_name_2" id="ref_name_2"/>
		<span class="help-block">
		Provide your referee name </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">3. Name <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_name_3" id="ref_name_3"/>
		<span class="help-block">
		Provide your referee name </span>
		</div>
		</div>
		<!--Address-->
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Address <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_address_1" id="ref_address_1"/>
		<span class="help-block">
		Provide your referee address </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Address <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_address_2" id="ref_address_2"/>
		<span class="help-block">
		Provide your referee address </span>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Address <span class="required" aria-required="true"> * </span>
		</label>
		<div class="col-md-8">
		<input type="text" class="form-control"
		name="ref_address_3" id="ref_address_3"/>
		<span class="help-block">
		Provide your referee address </span>
		</div>
		</div>
		<!--Uploads Referee-->
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Attach letter <span class="required" aria-required="true"> * </span> Recommendation</label>

		<div class="col-md-8">
		<!--Add File here-->
		<div id="ref1UploadAlert" ></div>

		<!--Ref 1 upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Referee letter </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="ref_1_slip_upload" id="ref_1_slip_upload" class="ref-1-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<!--/Ref 1 upload-->
		<div id="ref1Uploaded" class="clearfix margin-top-10"></div>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Attach letter <span class="required" aria-required="true"> * </span> Recommendation</label>

		<div class="col-md-8">
		<!--Add File here-->
		<div id="ref2UploadAlert"></div>
		<!--Ref 2 upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Referee letter </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="ref_2_slip_upload" id="ref_2_slip_upload" class="ref-2-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<!--/Ref 2 upload-->
		<div id="ref2Uploaded" class="clearfix margin-top-10"></div>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-4">Attach letter  <span class="required" aria-required="true"> * </span> Recommendation</label>

		<div class="col-md-8">
		<!--Add File here-->
		<div id="ref3UploadAlert"></div>
		<!--Ref 3 upload-->
		<form>
		<div class="fileinput fileinput-new" data-provides="fileinput">
		<div>
		<span class="">
		</span>
		<div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">
		<i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">
		</span>
		</div>
		<span class="input-group-addon btn default btn-file">
		<span class="fileinput-new">Select Referee letter </span>
		<span class="fileinput-exists">Change </span>
		<input type="file" name="ref_3_slip_upload" id="ref_3_slip_upload" class="ref-3-slip-upload" accept="application/pdf">
		</span>
		<a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">
		Remove
		</a>
		</div>
		</div>

		</form>
		<!--/Ref 3 upload-->
		<div id="ref3Uploaded" class="clearfix margin-top-10"></div>
		</div>
		</div>
		</div>
		</div>
		<!--/Professional information-->
		</div>
		</div>
		<div class="tab-pane" id="tab6">
		<h3 class="block">Confirm your details</h3>
		<!--Section A-->
		<h4 class="form-section background">Section A</h4>
		<div class="col-md-12 white" >
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Surname:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="surnameShow" data-display="surname">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4 ">
		<label class="control-label col-md-6 text-left">Firstname:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="firstnameShow" data-display="firstname">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Middle Name:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="lastnameShow" data-display="lastname">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Telephone
		No:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="tel_noShow" data-display="tel_no">
		</p>
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
		<p class="form-control-static" id="emailShow" data-display="email">
		</p>
		</div>
		</div>
		</div>

		<!--Section C -->
		<h4 class="form-section background">Section C</h4>
		<div class="col-md-12 white" >
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Date Of
		Birth:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="dobShow" data-display="dob">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Nationality:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="nationalityShow" data-display="nationality">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Marital
		Status:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="marital_statusShow"
		data-display="marital_status">
		</p>
		</div>
		</div>
		</div>
		<div class="col-md-12 white">
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Religious
		Affiliation:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="denominationShow" data-display="denomination">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Passport No/ ID No:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="passport_id_noShow"
		data-display="passport_id_no">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6">Gender:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="genderShow" data-display="gender">
		</p>
		</div>
		</div>
		</div>
		<div class="col-md-12 white">
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Physical
		Disability:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="disability_boolShow"
		data-display="disability_bool">
		<p class="form-control-static" id="disabilityShow"
		data-display="disability">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Current
		Address:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="current_addressShow"
		data-display="current_address">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-6 text-left">Permanent
		Address:</label>
		<div class="col-md-6">
		<p class="form-control-static" id="permanent_addressShow"
		data-display="permanent_address">
		</p>
		</div>
		</div>
		</div>
		<!--Section D-->
		<h4 class="form-section background">Section D</h4>
		<!--QUALIFICATIONS-->
		<div class="col-md-12 white">
		<div class="form-group col-md-3">
		<h5 class="col-title text-center">QUALIFICATIONS</h5>
		<label class="control-label col-md-2">1. </label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="degree_1" id="degree_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h5 class="col-title text-center">UNIVERSITY / COLLEGE
		ATTENDED </h5>
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="university_1" id="university_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h5 class="col-title text-center">GRADES OBTAINED</h5>
		<div class="col-md-10">
		<p class="form-control-static" data-display="grades_1" id="grades_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<h5 class="col-title text-center">YEAR OF COMPLETION </h5>
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" id="completion_yr_1Show"
		data-display="completion_yr_1">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">2. </label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="degree_2" id="degree_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="university_2" id="university_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="grades_2" id="grades_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="completion_yr_2" id="completion_yr_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">3. </label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="degree_3" id="degree_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="university_3" id="university_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static" data-display="grades_3" id="grades_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2"></label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="completion_yr_3" id="completion_yr_3Show">
		</p>
		</div>
		</div>
		</div>
		<!--Degree desired-->
		<div class="col-md-12 white">
		<div class="form-group col-md-4">
		<label class="control-label col-md-5 text-left">Degree offered: </label>
		<div class="col-md-7">
		<p class="form-control-static" data-display="school" id="schoolShow"> -</p>
		<p class="form-control-static" data-display="thsm" id="thsmShow"></p>
		<p class="form-control-static" data-display="pgs" id="pgsShow">
		<p class="form-control-static" data-display="special" id="specialShow">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-8 text-left">Accomodation - On Campus: </label>
		<div class="col-md-4">
		<p class="form-control-static" id="accomodationShow"
		data-display="accomodation">
		</p>
		</div>
		</div>

		<div class="form-group col-md-4">
		<label class="control-label col-md-4 text-left">Sponsors: </label>
		<div class="col-md-8">
		<p class="form-control-static" id="sponsoredShow"
		data-display="sponsored">
		</p> -
		<p class="form-control-static" id="sponsoresShow"
		data-display="sponsores">
		</p>
		</div>
		</div>

		</div>
		<div class="col-md-12 white">
		<div class="col-md-offset-3  col-md-6">
		<label class="control-label col-md-4 text-left">Campus Site: </label>
		<div class="col-md-8">
		<p class="form-control-static" id="campus_siteShow"
		data-display="campus_site">
		</p>
		</div>
		</div>
		</div>
		<div class="col-md-12 white">
		<div class="col-md-offset-3  col-md-6">
		<label class="control-label col-md-8 text-left">Graduated from
		English-speaking College/University? </label>
		<div class="col-md-4">
		<p class="form-control-static" data-display="is_english" id="is_englishShow">
		</p>
		</div>
		<label class="control-label col-md-8 text-left">If No, Passed an
		English proficiency test?</label>
		<div class="col-md-4">
		<p class="form-control-static" data-display="prof_test" id="prof_testShow">
		</p>
		</div>
		<label class="control-label col-md-8 text-left">Name of
		Test </label>
		<div class="col-md-4">
		<p class="form-control-static" data-display="test_name" id="test_nameShow">
		</p>
		</div>
		<label class="control-label col-md-8 text-left">Score </label>
		<div class="col-md-4">
		<p class="form-control-static" data-display="score" id="scoreShow">
		</p>
		</div>
		<label class="control-label col-md-8 text-left">Date </label>
		<div class="col-md-4">
		<p class="form-control-static" data-display="date_test" id="date_testShow">
		</p>
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
		<p class="form-control-static"
		data-display="occupation_1" id="occupation_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="employer_1" id="employer_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="workstation_1" id="workstation_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="duration_1" id="duration_1Show">
		</p>
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
		<label class="control-label col-md-2">1.
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="occupation_2" id="occupation_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="employer_2" id="employer_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="workstation_2" id="workstation_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="duration_2" id="duration_2Show">
		</p>
		</div>
		</div>
		<!--Record 3-->
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">2.
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="occupation_3" id="occupation_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="employer_3" id="employer_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="workstation_3" id="workstation_3Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="duration_3" id="duration_3Show">
		</p>
		</div>
		</div>
		<!--Record 4-->
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">2.
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="occupation_4" id="occupation_4Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="employer_4" id="employer_4Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="workstation_4" id="workstation_4Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-3">
		<label class="control-label col-md-2">
		</label>
		<div class="col-md-10">
		<p class="form-control-static"
		data-display="duration_4" id="duration_4Show">
		</p>
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
		<p class="form-control-static" data-display="num_yrs" id="num_yrsShow">
		</p>
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
		<p class="form-control-static" data-display="ref_name_1" id="ref_name_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-3">2. Name
		</label>
		<div class="col-md-9">
		<p class="form-control-static" data-display="ref_name_2" id="ref_name_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-3">3. Name
		</label>
		<div class="col-md-9">
		<p class="form-control-static" data-display="ref_name_3" id="ref_name_3Show">
		</p>
		</div>
		</div>
		<!--Address-->
		<div class="form-group col-md-4">
		<label class="control-label col-md-3">Address
		</label>
		<div class="col-md-9">
		<p class="form-control-static" data-display="ref_address_1" id="ref_address_1Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-3">Address
		</label>
		<div class="col-md-9">
		<p class="form-control-static" data-display="ref_address_2" id="ref_address_2Show">
		</p>
		</div>
		</div>
		<div class="form-group col-md-4">
		<label class="control-label col-md-3">Address
		</label>
		<div class="col-md-9">
		<p class="form-control-static" data-display="ref_address_3" id="ref_address_3Show">
		</p>
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
		<h4 class="form-section">DECLARATION BY THE APPLICANT</h4>
		<div class="form-group">
		<label class="control-label col-md-5 text-left">I hereby declare that to the
		best of my knowledge that the information I have provided  above is
		correct. <span
		class="required">
		* </span>
		</label>
		<div class="col-md-4">
		<input class="form-control" id="declare_agree" name="declare_agree" type="checkbox">
		<div id="form_agree_error"></div>
		</div>
		</div>
		</div>
		</div>
		</div>
		<div class="form-actions" id="form-actions">
		<div class="row">
		<div class="col-md-offset-3 col-md-9">
		<a href="javascript:;" class="btn default button-previous">
		<i class="m-icon-swapleft"></i> Back </a>
		<a href="javascript:;" class="btn green button-save">
		Save <i class="m-icon-swapright m-icon-white"></i>
		</a>
		<a href="javascript:;" class="btn blue button-next">
		Continue <i class="m-icon-swapright m-icon-white"></i>
		</a>
		<a href="javascript:;" class="btn green button-submit">
		Submit <i class="m-icon-swapright m-icon-white"></i>
		</a>
		</div>
		</div>
		</div>
		</div>
		<%--</form><!-- End Form 3 -->--%>
		</form>
		</div>
		</div>
		</div>
		</div>
		<!-- END PAGE CONTENT-->
			<% } %>
		<input type="hidden" id="users_name" value='<%= user_id %>' >
		</div>
		</div>
		<!-- END CONTENT -->
		</div>
		<!-- END CONTAINER -->
		<!-- BEGIN FOOTER -->
		<div class="page-footer">
		<div class="page-footer-inner">
		2017 &copy; Open Baraza. <a href="http://dewcis.com">Dew Cis Solutions Ltd.</a> All Rights Reserved
		</div>
		<div class="scroll-to-top">
		<i class="icon-arrow-up"></i>
		</div>
		</div>
		<!-- END FOOTER -->

		<!-- Modal -->
		<div class="modal fade" id="sponsorModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="margin-top: 60px;">
		<div class="modal-dialog modal-lg" role="document">
		<div class="modal-content">
		<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
		aria-hidden="true">&times;</span></button>
		<h4 class="modal-title" id="myModalLabel">Register Sponsor</h4>
		</div>
		<form id="org_form" class="form-horizontal" action="#" method="post">
		<div class="modal-body">
		<div class="row">
		<div class="col-md-12">
		<div class="form-group">
		<label class="control-label col-md-4">Organization Name <span class="required"
		aria-required="true">
		* </span>
		</label>

		<div class="col-md-8">
		<input class="form-control"  id="org_name_m" name="org_name_m" type="text">
		<span class="help-block">
		Provide Organization Name </span>
		</div>
		</div>
		</div>
		<div class="col-md-12">
		<div class="form-group">
		<label class="control-label col-md-4">Email <span class="required"
		aria-required="true">
		* </span>
		</label>

		<div class="col-md-8">
		<input class="form-control" name="org_email_m" id="org_email_m" type="email">
		<span class="help-block">
		Provide Email </span>
		</div>
		</div>
		</div>
		</div>
		<div class="row">
		<div class="col-md-12">
		<div class="form-group">
		<label class="control-label col-md-4">Country <span class="required"
		aria-required="true">
		* </span>
		</label>

		<div class="col-md-8">
		<input class="form-control" name="org_country_m" id="org_country_m" type="text" >
		<span class="help-block">
		Provide Country </span>
		</div>
		</div>
		</div>
		<div class="col-md-12">
		<div class="form-group">
		<label class="control-label col-md-4">Address <span class="required"
		aria-required="true">
		* </span>
		</label>

		<div class="col-md-8">
		<input class="form-control" name="org_address_m" id="org_address_m" type="text" >
		<span class="help-block">
		Provide  Address </span>
		</div>
		</div>
		</div>
		</div>
		<div class="row">
		<div class="col-md-12">
		<div class="form-group">
		<label class="control-label col-md-4">Sponsoring Division <span class="required"
		aria-required="true">
		* </span>
		</label>

		<div class="col-md-8">
		<input class="form-control" name="org_sponsoring_division_m" id="org_sponsoring_division_m" type="text" >
		<span class="help-block">
		Provide Sponsoring Division </span>
		</div>
		</div>
		</div>
		</div>
		</div>
		<div class="modal-footer">
		<span class="error"></span>
		<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		<button id="submit" type="submit" class="btn btn-primary" data-dismiss="modal" onclick="buildhidden()">Save</button>
		<%--<button id="submit" type="submit" class="btn btn-primary" data-dismiss="modal" onclick="inputFunction()">Save</button>--%>
		</div>
		</form>
		</div>
		</div>
		</div>
		<!-- Modal -->


		<!-- BEGIN JAVASCRIPTS(Load javascripts at bottom, this will reduce page load time) -->
		<!-- BEGIN CORE PLUGINS -->
		<!--[if lt IE 9]>
		<script src="./assets/global/plugins/respond.min.js"></script>
		<script src="./assets/global/plugins/excanvas.min.js"></script>
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
		<script type="text/javascript" src="./assets/global/plugins/bootstrap-fileinput/bootstrap-fileinput.js"></script>
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
		<!--UMIS SCRIPTS-->
		<!-- Common scripts -->
		<!--<script src="./assets/js/functions.js"></script>-->
		<!-- BEGIN PAGE LEVEL SCRIPTS -->
		<script src="./assets/js/register/metronic.js" type="text/javascript"></script>
		<script src="./assets/js/register/layout.js" type="text/javascript"></script>
		<script src="./assets/js/register/demo.js" type="text/javascript"></script>
		<script src="./assets/js/register/form-wizard.js"></script>

		<!-- END PAGE LEVEL SCRIPTS -->
		<script type="application/javascript">
		$('#self_sponsores').select2({
		placeholder: 'Select Sponsores'
		});
		$('#denomination').select2({
		placeholder: 'Select denomination'
		});
		</script>
		<script>
		jQuery(document).ready(function () {
		// initiate layout and plugins
		Metronic.init(); // init metronic core components
		Layout.init(); // init current layout
		Demo.init(); // init demo features
		//FormWizard.init();

		});
		</script>


		<!--Fill hidden modal to hidden fields-->
		<script  type="text/javascript">
		function buildhidden()
		{
		var orgName =  document.getElementById('org_name_m').value;
		var orgEmail =  document.getElementById('org_email_m').value;
		var orgCountry =  document.getElementById('org_country_m').value;
		var orgAddress =  document.getElementById('org_address_m').value;
		var orgSponsor =  document.getElementById('org_sponsoring_division_m').value;
		console.log("Passed data -> " + orgName + orgEmail + orgCountry + orgAddress + orgSponsor);
		document.getElementById('org_name').value = orgName ;
		document.getElementById('org_email').value = orgEmail ;
		document.getElementById('org_country').value = orgCountry ;
		document.getElementById('org_address').value = orgAddress ;
		document.getElementById('org_sponsoring_division').value = orgSponsor ;
		}

		function toJSONString(form) {
		var obj = {};
		var elements = form.querySelectorAll( "input, select, textarea" );
		for( var i = 0; i < elements.length; ++i ) {
		var element = elements[i];
		var name = element.name;
		var value = element.value;

		if( name ) {
		obj[ name ] = value;
		}
		}
		return JSON.stringify(obj);
		}

		function inputFunction() {
		var form = document.getElementById("org_form");
		var json = toJSONString(form);
		console.log("Org Form data => "+JSON.stringify(json));
		//document.getElementById('json').value = json;
		}
		</script>

		<!--Fill form-->
		<script  type="text/javascript">
		var user=document.getElementById("users_name").value;

		$.ajax({
		cache: false,
		url: '/jsongeneral?xml=web/general.xml&view=828:0',
		type: 'GET',
		dataType: "json",
		success: function (data) {
		console.log("User Above General data" + user);
		console.log("General data==> " + JSON.stringify(data));
		for(var i = 0; i < data.length; i++){
		if(data[i].entity_id === user){
		document.getElementById('surname').value = data[i].surname;
		document.getElementById('firstname').value = data[i].first_name;
		document.getElementById('lastname').value = data[i].middle_name;
		document.getElementById('email').value = data[i].email;
		document.getElementById('tel_no').value = data[i].primary_telephone;
		var paidStatus = data[i].paid;
		}

		}


		if(paidStatus == 'No'){
		console.log("Paid Status No ------> " + paidStatus);
		$('#form_wizard_1').find('.button-next').hide();
		$('#form_wizard_1').find('.button-submit').hide();
		}else{
		var notification = "";
		var appIdentity = <%=application_id%>;
		notification += '<div class="col-sm-12 col-md-12">'
		+'<div class="alert alert-success">Application fee paid. You may proceed</div>'
		+'</div>';

		$("#updatePaymentNotification").html(notification);

		console.log("Paid Status Yes ------> " + paidStatus);
		console.log("Region "+ <%=application_id%>);

		FormWizard.init([appIdentity]);
		FormSaveProgress.init([appIdentity]);

		$('#form_wizard_1').find('.button-next').show();
		$('#form_wizard_1').find('.button-submit').hide();
		}
		},
		error: function (r) {
		//alert('Error! Please try again.' + r.responseText);
		// console.log(r);
		}
		});

		</script>
		<script type="application/javascript">

		$("#thsm").change(function() {

		document.getElementById("special").style.display="block";

		console.log("Reached change Special thsm Value ===================> ");
		var el = $(this) ;
		var val = ''+ el.val() +'';
		console.log("SPecial thsm Value ===================> " + val);
		var specialUrl = '/jsongeneral?xml=web/general.xml&view=865:0&where=(degree_id=\''+ val +'\')';
		$.ajax({
		cache: false,
		url: specialUrl,
		type: 'GET',
		dataType: "json",
		success: function (data) {

		console.log("SPecial  DATA ===================> " + JSON.stringify(data));
		for (i = 0; i < data.length; i++) {
		var specialId = data[i].specialization_id;
		var specialName = data[i].specialization_name;

		var specialization=document.getElementById("special");
		//for(var i=0;i<obj.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(specialName);
		option.appendChild(txt);
		option.setAttribute("value",specialId);
		specialization.insertBefore(option,specialization.lastChild);
		//}
		}

		}
		});

		});

		$("#pgs").change(function() {
		document.getElementById("special").style.display="block";
		console.log("Reached change Special pgs Value ===================> ");
		var el = $(this) ;
		var val = ''+ el.val() +'';
		console.log("SPecial pgs  Value ===================> " + val);
		var specialUrl = '/jsongeneral?xml=web/general.xml&view=865:0&where=(degree_id=\''+ val +'\')';
		$.ajax({
		cache: false,
		url: specialUrl,
		type: 'GET',
		dataType: "json",
		success: function (data) {
		var downlaodFileUrl = '';
		var htmlDis = '';
		console.log("SPecial  DATA ===================> " + JSON.stringify(data));
		for (i = 0; i < data.length; i++) {
		var specialId = data[i].specialization_id;
		var specialName = data[i].specialization_name;

		var specialization = document.getElementById("special");
		//for(var i=0;i<obj.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(specialName);
		option.appendChild(txt);
		option.setAttribute("value",specialId);
		specialization.insertBefore(option,specialization.lastChild);
		//}
		}

		}
		});

		});

		</script>
		<!--Add File Input qaualifications-->
		<script  type="text/javascript">
		var idFormOne = 1;
		var idFormTwo = 1;
		var idFormThree = 1;
		var htmlTagOne = "";
		var htmlTagTwo = "";
		var htmlTagThree = "";

		/**
		* Add file uploads
		* @param idRow
		*/
		function addFile(id, idRow)
		{
		console.log("1 ===> " + idFormOne + " 2 ===> " + idFormTwo + " 3 ===> " + idFormThree);
		if(id == 1){
		if(idFormOne <= 1)
		{
		idFormOne = 1;
		}
		if(idFormOne >= 5)
		{
		//Don't do anything
		idFormOne = 4
		}
		else
		{
		htmlTagOne += '<div class="form-group col-md-3"id="qua_1_'+idFormOne+'" >'
		+'<label class="control-label col-md-2">'+idFormOne+'.</label>'
		+ '<div class="col-md-10">'
		+ ' <!--Add File here-->'
		+ '<div id="academic_1_'+idFormOne+'_UploadAlert"></div>'
		+ '<div class="alert alert-success" style="display:none">'
		+ ' Upload Successfully'
		+ ' </div>'
		+ ' <!--Ref 2 upload-->'
		+ ' <form>'
		+ ' <div class="fileinput fileinput-new" data-provides="fileinput">'
		+ ' <div>'
		+ ' <span class="">'
		+ ' </span>'
		+ ' <div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">'
		+ ' <i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">'
		+ ' </span>'
		+ ' </div>'
		+ ' <span class="input-group-addon btn default btn-file">'
		+ ' <span class="fileinput-new">Select transcript </span>'
		+ ' <span class="fileinput-exists">Change </span>'
		+ ' <input type="file" name="cert_1_'+idFormOne+'_slip_upload" id="cert_1-'+idFormOne+'_slip_upload" class="cert-1-'+idFormOne+'-slip-upload" accept="application/pdf">'
		+ ' </span>'
		+ ' <a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">'
		+ ' Remove'
		+ ' </a>'
		+ ' </div>'
		+ ' </div>'
		+ ' </form>'
		+ '  <!--/Ref 2 upload-->'
		+ '<div id="academic_1_'+idFormOne+'_Uploaded" class="clearfix margin-top-10"></div>'
		+ '</div>'
		+ '</div>';
		}
		<%--addDynamic(idFormOne, htmlTagOne);--%>
		$(idRow).html(htmlTagOne);
		idFormOne++;
		}
		else if(id == 2)
		{
		if(idFormTwo <= 1)
		{
		idFormTwo = 1;
		}
		if(idFormTwo >= 5)
		{
		//Don't do anything
		}
		else
		{
		htmlTagTwo += '<div class="form-group col-md-3"id="qua_2_'+idFormTwo+'" >'
		+'<label class="control-label col-md-2">'+idFormTwo+'.</label>'
		+ '<div class="col-md-10">'
		+ ' <!--Add File here-->'
		+ '<div id="academic_2_'+idFormTwo+'_UploadAlert"></div>'
		+ '<div class="alert alert-success" style="display:none">'
		+ ' Upload Successfully'
		+ ' </div>'
		+ ' <!--Ref 2 upload-->'
		+ ' <form>'
		+ ' <div class="fileinput fileinput-new" data-provides="fileinput">'
		+ ' <div>'
		+ ' <span class="">'
		+ ' </span>'
		+ ' <div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">'
		+ ' <i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">'
		+ ' </span>'
		+ ' </div>'
		+ ' <span class="input-group-addon btn default btn-file">'
		+ ' <span class="fileinput-new">Select transcript </span>'
		+ ' <span class="fileinput-exists">Change </span>'
		+ ' <input type="file" name="cert_'+idFormTwo+'_slip_upload" id="cert_2_'+idFormTwo+'_slip_upload" class="academic-slip-upload" accept="application/pdf">'
		+ ' </span>'
		+ ' <a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">'
		+ ' Remove'
		+ ' </a>'
		+ ' </div>'
		+ ' </div>'
		+ ' </form>'
		+ '  <!--/Ref 2 upload-->'
		+ '<div id=""academic_2_'+idFormTwo+'_Uploaded" class="clearfix margin-top-10"></div>'
		+ '</div>'
		+ '</div>';
		}
		<%--addDynamic(idFormTwo, htmlTagTwo);--%>
		$(idRow).html(htmlTagTwo);
		idFormTwo++;
		}
		else
		{
		if(idFormThree <= 1)
		{
		idFormThree = 1;
		}
		if(idFormThree >= 5)
		{
		//Don't do anything
		}
		else
		{
		htmlTagThree += '<div class="form-group col-md-3"id="qua_3_'+idFormThree+'" >'
		+'<label class="control-label col-md-2">'+idFormThree+'.</label>'
		+ '<div class="col-md-10">'
		+ ' <!--Add File here-->'
		+ '<div id="academic_3_'+idFormThree+'_UploadAlert"></div>'
		+ '<div class="alert alert-success" style="display:none">'
		+ ' Upload Successfully'
		+ ' </div>'
		+ ' <!--Ref 2 upload-->'
		+ ' <form>'
		+ ' <div class="fileinput fileinput-new" data-provides="fileinput">'
		+ ' <div>'
		+ ' <span class="">'
		+ ' </span>'
		+ ' <div class="form-control uneditable-input input-fixed input-medium" data-trigger="fileinput">'
		+ ' <i class="fa fa-file fileinput-exists"></i>&nbsp; <span class="fileinput-filename">'
		+ ' </span>'
		+ ' </div>'
		+ ' <span class="input-group-addon btn default btn-file">'
		+ ' <span class="fileinput-new">Select transcript </span>'
		+ ' <span class="fileinput-exists">Change </span>'
		+ ' <input type="file" name="cert_'+idFormThree+'_slip_upload" id="cert_3_'+idFormThree+'_slip_upload" class="academic-slip-upload" accept="application/pdf">'
		+ ' </span>'
		+ ' <a href="javascript:;" class="input-group-addon btn red fileinput-exists" data-dismiss="fileinput">'
		+ ' Remove'
		+ ' </a>'
		+ ' </div>'
		+ ' </div>'
		+ ' </form>'
		+ '  <!--/Ref 2 upload-->'
		+ '<div id=""academic_3_'+idFormThree+'_Uploaded" class="clearfix margin-top-10"></div>'
		+ '</div>'
		+ '</div>';
		}
		$(idRow).html(htmlTagThree);
		idFormThree++;
		}

		}
		/**
		* Delete all file uploads
		* @param idRow
		*/
		function deleteFile(id , idRow)
		{
		if(id == 1)
		{
		//Prevent going to negative
		if(idFormOne <= 1)
		{
		idFormOne = 1;
		}
		//reset the tag
		htmlTagOne = "";
		//Delete the individual div tags
		$('#qua_1_'+idFormOne).remove('#qua_1_'+idFormOne);
		//Delete from latest created upload tag
		idFormOne--;
		}
		else if(id == 2)
		{
		//Prevent going to negative
		if(idFormTwo <= 1)
		{
		idFormTwo = 1;
		}
		//reset the tag
		htmlTagTwo = "";
		//Delete the individual div tags
		$('#qua_2_'+idFormTwo).remove('#qua_2_'+idFormTwo);
		//Delete from latest created upload tag
		idFormTwo--;
		}
		else
		{
		//Prevent going to negative
		if(idFormThree <= 1)
		{
		idFormThree = 1;
		}
		//reset the tag
		htmlTagThree = "";
		//Delete the individual div tags
		$('#qua_3_'+idFormThree).remove('#qua_3_'+idFormThree);
		//Delete from latest created upload tag
		idFormThree--;
		}

		}

		</script>

		<!--Fill form2-->
		<script  type="text/javascript">

		$.ajax({
		cache: false,
		url: '/jsondata?view=828:0',
		type: 'GET',
		dataType: "json",
		success: function (data) {
		console.log("Session data==> " + JSON.stringify(data));
		console.log("Session data[0]==> " + JSON.stringify(data[0]));
		var appIdentification = data[0].application_id;
		var surname = data[0].surname;
		var fName = data[0].first_name;
		var lName = data[0].middle_name;
		var email = data[0].email;
		var pTel = data[0].primary_telephone;
		var emailed = data[0].emailed;
		var isPaid = data[0].paid;
		var status = data[0].status;
		console.log('Checking if form_data in data[0] object exists ===>' + data[0].hasOwnProperty('form_data'));
		console.log('Has Paid ===>' + isPaid);
		if(data[0].form_data != "" && data[0].hasOwnProperty('form_data')){
		var declare = data[0].form_data;
		var declare_agree = declare.declare_agree;
		console.log("declare_agree==> " + declare_agree);
		}


		var link = data[0].CL;
		var kf = data[0].KF;
		var fileUrl = '/jsondata?view=828:0:0&data='+ appIdentification;
		console.log("Application ID==> " + appIdentification);

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
		//$('#profileImage').hide();
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
		console.log('Has Paid 2 ===>' + isPaid);
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
		if(data[0].form_data != "" && data[0].hasOwnProperty('form_data')){

		var formData = JSON.parse(data[0].form_data);
		console.log("Form data==> " + JSON.stringify(formData));
		console.log("Form data Date of Birth ==> " + formData.dob);
		//SECTION C
		//Hidden fields

		document.getElementById('org_name').value = formData.org_name;
		document.getElementById('org_email').value = formData.org_email;
		document.getElementById('org_country').value = formData.org_country;
		document.getElementById('org_address').value = formData.org_address;
		document.getElementById('org_sponsoring_division').value = formData.org_sponsoring_division;

		//Visible field for sponsor modal
		document.getElementById('org_name_m').value = formData.org_name;
		document.getElementById('org_email_m').value = formData.org_email;
		document.getElementById('org_country_m').value = formData.org_country;
		document.getElementById('org_address_m').value = formData.org_address;
		document.getElementById('org_sponsoring_division_m').value = formData.org_sponsoring_division;
		document.getElementById('gender').value = formData.gender;
		console.log("Denomination Value ==> " + formData.denomination);
		console.log("Nationality Value ==> " + formData.nationality);
		document.getElementById('marital_status').value = formData.marital_status;
		$('#denomination').val(formData.denomination).trigger('change');
		$('#country_list').val(formData.nationality).trigger('change');
		document.getElementById('dob').value = formData.dob;
		document.getElementById('passport_id_no').value = formData.passport_id_no;
		if(formData.disability_bool == 'N')
		{
		//When Set No hide the description inputof the disability
		document.getElementById("disability").style.display="none";
		}else{
		document.getElementById("disability").style.display="block";
		}
		document.getElementById('disability_bool').value = formData.disability_bool;
		document.getElementById('disability').value = formData.disability;
		document.getElementById('current_address').value = formData.current_address;
		document.getElementById('permanent_address').value = formData.permanent_address;

		//SECTION D
		document.getElementById('degree_1').value = formData.degree_1;
		document.getElementById('university_1').value = formData.university_1;
		document.getElementById('completion_yr_1').value = formData.completion_yr_1;
		document.getElementById('grades_1').value = formData.grades_1;
		document.getElementById('degree_2').value = formData.degree_2;
		document.getElementById('university_2').value = formData.university_2;
		document.getElementById('completion_yr_2').value = formData.completion_yr_2;
		document.getElementById('grades_2').value = formData.grades_2;
		document.getElementById('degree_3').value = formData.degree_3;
		document.getElementById('university_3').value = formData.university_3;
		document.getElementById('completion_yr_3').value = formData.completion_yr_3;
		document.getElementById('grades_3').value = formData.grades_3;
		//	document.getElementById('degree').value = formData.post_grad;

		document.getElementById('accomodation').value = formData.accomodation;

		if(formData.sponsored == 'N')
		{
		//When Set No hide the description inputof the disability
		document.getElementById("self_sponsores_wrapper").style.display="none";
		}else{
		document.getElementById("self_sponsores_wrapper").style.display="block";
		}
		if(formData.sponsored == 'Y')
		{
		//When Set No hide the description inputof the disability
		//document.getElementById('self_sponsores').value = formData.sponsores;
		$('#self_sponsores').val(formData.sponsores).trigger('change');
		}
		document.getElementById('selfSponsored').value = formData.sponsored;


		//document.getElementById("self_sponsores").style.display="block";
		//document.getElementById('self_sponsores').value = formData.sponsores;
		$('#self_sponsores').val(formData.sponsores).trigger('change');

		document.getElementById('is_english').value = formData.is_english;
		document.getElementById('school').value = formData.school;
		if(formData.thsm != "")
		{
		document.getElementById('thsm').value = formData.thsm;
		$("#thsm").show();
		}
		if(formData.pgs != "")
		{
		document.getElementById('pgs').value = formData.pgs;
		$("#pgs").show();
		}
		if(formData.campus_site != "")
		{
		document.getElementById('campus_site').value = formData.campus_site;
		}

		document.getElementById('prof_test').value = formData.prof_test;

		document.getElementById('test_name').value = formData.test_name;

		document.getElementById('score').value = formData.score;

		document.getElementById('date_test').value = formData.date_test;
		//SECTION E

		document.getElementById('occupation_1').value = formData.occupation_1;

		document.getElementById('employer_1').value = formData.employer_1;

		document.getElementById('workstation_1').value = formData.workstation_1;

		document.getElementById('duration_1').value = formData.duration_1;

		document.getElementById('occupation_2').value = formData.occupation_2;

		document.getElementById('employer_2').value = formData.employer_2;

		document.getElementById('workstation_2').value = formData.workstation_2;

		document.getElementById('duration_2').value = formData.duration_2;

		document.getElementById('occupation_3').value = formData.occupation_3;

		document.getElementById('employer_3').value = formData.employer_3;

		document.getElementById('workstation_3').value = formData.workstation_3;

		document.getElementById('duration_3').value = formData.duration_3;

		document.getElementById('occupation_4').value = formData.occupation_4;

		document.getElementById('employer_4').value = formData.employer_4;

		document.getElementById('workstation_4').value = formData.workstation_4;

		document.getElementById('duration_4').value = formData.duration_4;

		document.getElementById('num_yrs').value = formData.num_yrs;

		document.getElementById('ref_name_1').value = formData.ref_name_1;

		document.getElementById('ref_address_1').value = formData.ref_address_1;

		document.getElementById('ref_name_2').value = formData.ref_name_2;

		document.getElementById('ref_address_2').value = formData.ref_address_2;

		document.getElementById('ref_name_3').value = formData.ref_name_3;

		document.getElementById('ref_address_3').value = formData.ref_address_3;

		if(formData.hasOwnProperty('declare_agree'))
		{
		if(formData.declare_agree == "on")
		{
		document.getElementById("declare_agree").checked = true;
		$("#declare_agree").prop("checked", true);
		$("#declare_agree").attr("checked", true);
		}else{
		document.getElementById("declare_agree").checked = false;
		}
		}
		console.log("Checking declare to view only::::::::::::::::::" + formData.declare_agree);
		if(formData.hasOwnProperty('declare_agree') && formData.declare_agree == "on"){
		//Hide Action Buttons
		$('#ref_address_2').hide();

		//Hide the whole step bar and progrees bar
		$('#nav_pills').hide();// Hide whole tab with steps name
		$('#bar').hide();// Hide proress line n bar

		var tab1 = $('#tab1');
		var tab6 = $('#tab6');

		//hide actions button
		$('#form-actions').hide();

		//<IRRELEVANT>
		<%--//Manage Tabs--%>
		<%--$('#li_prog_1').hide();// Hide Tab 1 in the list--%>
		<%--$('#li_prog_2').hide();// Hide Tab 2 in the list--%>
		<%--$('#li_prog_3').hide();// Hide Tab 3 in the list--%>
		<%--$('#li_prog_4').hide();// Hide Tab 4 in the list--%>
		<%--$('#li_prog_5').hide();// Hide Tab 5 in the list and leave only 6 to display--%>

		<%--//Make 6 Active--%>
		<%--$('#li_prog_1').removeClass('active');--%>
		<%--$('#li_prog_6').addClass('active');--%>
		//<IRRELEVANT>

		//Manage Body Tabs
		//Tab 1
		tab1.removeClass('tab-pane active');
		tab1.addClass('tab-pane');
		//Hide all other body tabs
		tab1.hide();// Hide Tab 1 in the list
		$('#tab2').hide();// Hide Tab 2 in the list
		$('#tab3').hide();// Hide Tab 3 in the list
		$('#tab4').hide();// Hide Tab 4 in the list
		$('#tab5').hide();// Hide Tab 5 in the list and leave only 6 to display

		//Tab 1
		tab6.show();
		tab6.removeClass('tab-pane');
		tab6.addClass('tab-pane active');
		console.log('Surname from session : -------> ' + surname);
		//Set Values In Confirm On SubMission
		$('#surnameShow').html(surname);
		$('#firstnameShow').html(fName);
		$('#lastnameShow').html(lName);
		$('#emailShow').html(email);
		$('#tel_noShow').html(pTel);
		$('#dobShow').html(formData.dob);
		$('#genderShow').html(formData.gender);
		$('#marital_statusShow').html(formData.marital_status);
		$('#denominationShow').html(formData.denomination);
		$('#nationalityShow').html(formData.nationality);
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

		}//end else formaData.form_data != ""

		},
		error: function (r) {
		//alert('Error! Please try again.' + r.responseText);
		// console.log(r);
		}
		});
		function cleanPrompt(tagId, FormDataValue){
		if(value != ""){
		document.getElementById(tagId).value = FormDataValue;
		}
		}
		function showInput(value, id){
		if(value=='N') {
		document.getElementById(id).style.display="none";
		}else {
		document.getElementById(id).style.display="block";
		}
		}

		</script>

		<script type="application/javascript">
		$('#other_sponsors').focus(function () {
		//open bootsrap modal
		$('#sponsorModal').modal({
		show: true
		});
		});

		$('#submit').click(function () {
		console.log('filled the sponsor form');
		<%--var inputs = [],--%>
		<%--input = $('#cities-form').serializeArray();--%>
		<%--for (i = 0; i < input.length; i++) {--%>
		<%--inputs.push(input[i].value);--%>
		<%--}--%>

		<%--console.log("inputs.length => " + inputs.length);--%>

		<%--if (inputs.length === 0) {--%>
		<%--$('.error').text('please fill in all required fields');--%>
		<%--} else {--%>
		<%--$('.error').text('');--%>
		<%--var data = JSON.stringify(inputs);--%>
		<%--console.log(data);--%>
		<%--}--%>
		});
		</script>
		<!-- Upload -->
		<script type="text/javascript">
		var appId = <%=application_id%>;
		var baseUrl = '/putbarazafiles?view=828:0:0&data='+ appId;
		var bankUrl =  baseUrl + '&narrative=bank_slip';
		var sponsorUrl = baseUrl + '&narrative=sponsor_slip';
		var profileUrl = baseUrl + '&narrative=profile_image';
		var purposeUrl = baseUrl + '&narrative=purpose_letter';
		var academicUrl11 = baseUrl + '&narrative=academicUrl_1_1_slip';
		var academicUrl12 = baseUrl + '&narrative=academicUrl_1_2_slip';
		var academicUrl13 = baseUrl + '&narrative=academicUrl_1_3_slip';
		var academicUrl14 = baseUrl + '&narrative=academicUrl_1_4_slip';
		var academicUrl21 = baseUrl + '&narrative=academicUrl_2_1_slip';
		var academicUrl22 = baseUrl + '&narrative=academicUrl_2_2_slip';
		var academicUrl23 = baseUrl + '&narrative=academicUrl_2_3_slip';
		var academicUrl24 = baseUrl + '&narrative=academicUrl_2_4_slip';
		var academicUrl31 = baseUrl + '&narrative=academicUrl_3_1_slip';
		var academicUrl32 = baseUrl + '&narrative=academicUrl_3_2_slip';
		var academicUrl33 = baseUrl + '&narrative=academicUrl_3_3_slip';
		var academicUrl34 = baseUrl + '&narrative=academicUrl_3_4_slip';
		var appointmentUrl = baseUrl + '&narrative=appointment_slip';
		var cvUrl = baseUrl + '&narrative=cv_slip';
		var idUrl = baseUrl + '&narrative=identification_slip';
		var engCertUrl = baseUrl + '&narrative=english_cert_slip';
		var refOneUrl = baseUrl + '&narrative=ref_one_letter';
		var refTwoUrl = baseUrl + '&narrative=ref_two_letter';
		var refThreeUrl = baseUrl + '&narrative=ref_three_letter';
		var saveUrl = '/putbarazafiles?view=828:0:0&data=1';
		var instituteCertOneUrl = baseUrl + '&narrative=instituteCertUrl_1';
		var instituteCertTwoUrl = baseUrl + '&narrative=instituteCertUrl_2';
		var instituteCertThreeUrl = baseUrl + '&narrative=instituteCertUrl_3';
		var instituteTransOneUrl = baseUrl + '&narrative=instituteTransUrl_1';
		var instituteTransTwoUrl = baseUrl + '&narrative=instituteTransUrl_2';
		var instituteTransThreeUrl = baseUrl + '&narrative=instituteTransUrl_3';

		$('.institution-one-cert-slip-upload').change(function(){
		previewURL(this);
		upload(instituteCertOneUrl, $(this).val(), $(this));
		});

		$('.institution-two-cert-slip-upload').change(function(){
		previewURL(this);
		upload(instituteCertTwoUrl, $(this).val(), $(this));
		});

		$('.institution-three-cert-slip-upload').change(function(){
		previewURL(this);
		upload(instituteCertThreeUrl, $(this).val(), $(this));
		});

		$('.institution-one-trans-slip-upload').change(function(){
		previewURL(this);
		upload(instituteTransOneUrl, $(this).val(), $(this));
		});

		$('.institution-two-trans-slip-upload').change(function(){
		previewURL(this);
		upload(instituteTransTwoUrl, $(this).val(), $(this));
		});

		$('.institution-three-trans-slip-upload').change(function(){
		previewURL(this);
		upload(instituteTransThreeUrl, $(this).val(), $(this));
		});

		$('.bank-slip-upload').change(function(){
		previewURL(this);
		upload(bankUrl, $(this).val(), $(this));
		});

		$('.sponsor_slip_upload').change(function(){
		previewURL(this);
		upload(sponsorUrl, $(this).val(), $(this));
		});

		$('.profile-image-upload').change(function(){
		previewURL(this);
		upload(profileUrl, $(this).val(), $(this));
		});
		$('.purpose-slip-upload').change(function(){
		previewURL(this);
		upload(purposeUrl, $(this).val(), $(this));
		});

		$('.cert-1-1-slip-upload').change(function(){
		console.log("Uploadging trying");
		previewURL(this);
		upload(academicUrl11, $(this).val(), $(this));
		});

		$('#cert_1_2_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl12, $(this).val(), $(this));
		});

		$('#cert_1_3_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl13, $(this).val(), $(this));
		});

		$('#cert_1_4_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl14, $(this).val(), $(this));
		});

		$('#cert_2_1_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl21, $(this).val(), $(this));
		});

		$('#cert_2_2_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl22, $(this).val(), $(this));
		});

		$('#cert_2_3_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl23, $(this).val(), $(this));
		});

		$('#cert_2_4_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl24, $(this).val(), $(this));
		});

		$('#cert_3_1_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl31, $(this).val(), $(this));
		});

		$('#cert_3_2_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl32, $(this).val(), $(this));
		});

		$('#cert_3_3_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl33, $(this).val(), $(this));
		});

		$('#cert_3_4_slip_upload').change(function(){
		previewURL(this);
		upload(academicUrl34, $(this).val(), $(this));
		});

		$('.appointment-slip-upload').change(function(){
		previewURL(this);
		upload(appointmentUrl, $(this).val(), $(this));
		});

		$('.cv-slip-upload').change(function(){
		previewURL(this);
		upload(cvUrl, $(this).val(), $(this));
		});

		$('.id-slip-upload').change(function(){
		previewURL(this);
		upload(idUrl, $(this).val(), $(this));
		});

		$('.english-cert-slip-upload').change(function(){
		previewURL(this);
		upload(engCertUrl, $(this).val(), $(this));
		});

		$('.ref-1-slip-upload').change(function(){
		previewURL(this);
		upload(refOneUrl, $(this).val(), $(this));
		});

		$('.ref-2-slip-upload').change(function(){
		previewURL(this);
		upload(refTwoUrl, $(this).val(), $(this));
		});

		$('.ref-3-slip-upload').change(function(){
		previewURL(this);
		upload(refThreeUrl, $(this).val(), $(this));
		});


		//Upload Action
		function upload(url, val, obj){
		var htmlAlert = "";
		var payAlert = "";
		if(val!='') {
		var formData = new FormData();
		formData.append('file', obj[0].files[0]);
		$.ajax({
		url: url,
		type: 'POST',
		data: formData,
		success: function (data) {
		console.log("Return ***> " + JSON.stringify(data));
		if(data.success == 1) {
		//success work
		htmlAlert += '<div class="alert alert-success" style="display:block">'
		+ data.message
		+'</div>';
		payAlert += '<div class="col-sm-12 col-md-12">'
		+'<div class="alert alert-success">Upload Successful. Kindly wait for approval to continue</div>'
		+'</div>';
		console.log("Success ***> " + JSON.stringify(data.narrative) );
		//Cert 1
		if(data.narrative == "instituteCertUrl_1") {
		$("#institutionOneCertAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		//Cert 2
		if(data.narrative == "instituteCertUrl_2") {
		$("#institutionTwoCertAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		//Cert 3
		if(data.narrative == "instituteCertUrl_3") {
		$("#institutionThreeCertAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		//Trans 1
		if(data.narrative == "instituteTransUrl_1") {
		$("#institutionOneTransAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		//Trans 2
		if(data.narrative == "instituteTransUrl_2") {
		$("#institutionTwoTransAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		//Trans 3
		if(data.narrative == "instituteTransUrl_3") {
		$("#institutionThreeTransAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}

		if(data.narrative == "appointment_slip") {
		$("#appointmentSlipAlert").html(htmlAlert);
		//$("#appointmentSlip").hide();
		}
		if(data.narrative == "profile_image") {
		$("#profileImageAlert").html(htmlAlert);
		//$("#profileImage").hide();
		}
		if(data.narrative == "purpose_letter") {
		$("#purposeAlert").html(htmlAlert);
		}
		if(data.narrative == "cv_slip") {
		$("#cvSlipAlert").html(htmlAlert);
		//$("#cvSlip").hide();
		}
		if(data.narrative == "identification_slip") {
		$("#identificationSlipAlert").html(htmlAlert);
		//$("#identificationSlip").hide();
		}
		if(data.narrative == "sponsor_slip") {
		$("#updatePaymentNotification").html(payAlert);
		}
		if(data.narrative == "bank_slip") {
		$("#updatePaymentNotification").html(payAlert);
		}
		if(data.narrative == "english_cert_slip") {
		$("#englishCertAlert").html(htmlAlert);
		}

		if(data.narrative == "ref_one_letter") {
		$("#ref1UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "ref_two_letter") {
		$("#ref2UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "ref_three_letter") {
		$("#ref3UploadAlert").html(htmlAlert);
		}

		if(data.narrative == "academicUrl_1_1_slip") {
		$("#academic_1_1_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_1_2_slip") {
		$("#academic_1_2_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_1_3_slip") {
		$("#academic_1_3_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_1_4_slip") {
		$("#academic_1_4_UploadAlert").html(htmlAlert);
		}

		if(data.narrative == "academicUrl_2_1_slip") {
		$("#academic_2_1_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_2_2_slip") {
		$("#academic_2_2_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_2_3_slip") {
		$("#academic_2_3_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_2_4_slip") {
		$("#academic_2_4_UploadAlert").html(htmlAlert);
		}

		if(data.narrative == "academicUrl_3_1_slip") {
		$("#academic_3_1_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_3_2_slip") {
		$("#academic_3_2_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_3_3_slip") {
		$("#academic_3_3_UploadAlert").html(htmlAlert);
		}
		if(data.narrative == "academicUrl_3_4_slip") {
		$("#academic_3_4_UploadAlert").html(htmlAlert);
		}

		}
		},
		cache: false,
		contentType: false,
		processData: false
		});

		}
		}
		//Upload Action
		function previewURL(input) {
		if (input.files && input.files[0]) {
		var reader = new FileReader();

		reader.onload = function (e) {
		//$('#prevImg').attr('src', e.target.result);
		$('#preview').css("background", "url(" + e.target.result +")" + " right top no-repeat");
		}

		reader.readAsDataURL(input.files[0]);
		}
		}
		</script>
		<script type="text/javascript">
		var json = <%=jForm%>;

		var denominations=json.form[0].list;
		var nationalities=json.form[1].list;
		var degrees=json.form[2].list;
		var sponsorsColleges=json.form[3].list;
		var campusSite=json.form[4].list;
		var thsm=json.form[5].list;
		<%--var psg=json.form[6].list;--%>
		var obj = JSON.parse(denominations);
		var obj2 = JSON.parse(nationalities);
		var obj3 = JSON.parse(degrees);
		var obj4 = JSON.parse(sponsorsColleges);
		var obj5 = JSON.parse(campusSite);
		var obj6 = JSON.parse(thsm);
		<%--var obj7 = JSON.parse(psg);--%>
		<%--console.log("**************0000--JSON FORM => " + JSON.stringify(JSON.parse(json)));--%>
		console.log("**************0000--JSON FORM => " + JSON.stringify(json));
		console.log("**************----Denominations => " + JSON.stringify(obj));
		console.log("**************----Nationalities => " + JSON.stringify(obj2));
		console.log("**************---- Sponsors=> " + JSON.stringify(obj3));
		console.log("**************----Campus Site => " + JSON.stringify(obj4));
		console.log("**************---- thsm => " + JSON.stringify(obj5));
		console.log("**************---- psg=> " + JSON.stringify(obj6));
		var denomination=document.getElementById("denomination")
		for(var i=0;i<obj.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj[i].denomination_name);
		option.appendChild(txt);
		option.setAttribute("value",obj[i].denomination_id);
		denomination.insertBefore(option,denomination.lastChild);
		}
		var nationality=document.getElementById("country_list")
		for(var i=0;i<obj2.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj2[i].sys_country_name);
		option.appendChild(txt);
		option.setAttribute("value",obj2[i].sys_country_id);
		nationality.insertBefore(option,nationality.lastChild);
		}
		<%--var degree=document.getElementById("degree")--%>
		<%--for(var i=0;i<obj3.length;i++){--%>
		<%--var option=document.createElement("OPTION"),--%>
		<%--txt=document.createTextNode(obj3[i].degree_name);--%>
		<%--option.appendChild(txt);--%>
		<%--option.setAttribute("value",obj3[i].degree_id);--%>
		<%--degree.insertBefore(option,degree.lastChild);--%>
		<%--}--%>
		var sponsorsCollege=document.getElementById("self_sponsores")
		for(var i=0;i<obj3.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj3[i].sponsor_name);
		option.appendChild(txt);
		option.setAttribute("value",obj3[i].sponsor_id);
		sponsorsCollege.insertBefore(option,sponsorsCollege.lastChild);
		}
		var campus_site=document.getElementById("campus_site")
		for(var i=0;i<obj4.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj4[i].site_name);
		option.appendChild(txt);
		option.setAttribute("value",obj4[i].site_id);
		campus_site.insertBefore(option,campus_site.lastChild);
		}

		function filterDegrees(value){
		if(value=='thsm') {
		//hide the pgs dorpdown and show thsm
		document.getElementById("pgs").style.display="none";
		document.getElementById("thsm").style.display="block";

		//populate the thsm dropdown
		var thsmC=document.getElementById("thsm");
		for(var i=0;i<obj5.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj5[i].degree_name);
		option.appendChild(txt);
		option.setAttribute("value",obj5[i].degree_id);
		thsmC.insertBefore(option,thsmC.lastChild);
		}
		}else if(value=='pgs'){
		//hide the thsm dorpdown and show pgs
		document.getElementById("thsm").style.display="none";
		document.getElementById("pgs").style.display="block";

		//populate the thsm dropdown
		var pgsC=document.getElementById("pgs")
		for(var i=0;i<obj6.length;i++){
		var option=document.createElement("OPTION"),
		txt=document.createTextNode(obj6[i].degree_name);
		option.appendChild(txt);
		option.setAttribute("value",obj6[i].degree_id);
		pgsC.insertBefore(option,pgsC.lastChild);
		}

		}else{
		// hide both dropdowns if select
		document.getElementById("thsm").style.display="none";
		document.getElementById("pgs").style.display="none";
		document.getElementById("special").style.display="none";
		}
		}

		</script>
		<script src="https://www.paypalobjects.com/api/checkout.js"></script>
		<script>
		var amount = 0.02;
		var student_id = <%=application_id%>;
		var user_id = <%=user_id%>;
		var currency = 'USD';
		var description = 'The university fees transaction description.';
		paypal.Button.render({

		env: 'sandbox', // sandbox | production

		style: {
		size: 'medium',
		color: 'blue',
		shape: 'rect',
		label: 'pay',
		tagline: 'false',
		branding: 'true'
		},

		client: {
		sandbox:    'AYSLFv1Z823G7Dod2hfm8IiVRPpbAvaMEMqZWhPrnFlIk4FDM62gd_P9_0GUh_zzEwpO_jkQhMah4ZYX',
		production: 'ASaA5UDVeUxwnSNaqJxcanmgjuA89cDGkuIs-kHKIJkpHmY5Lcy1j2mzCD3Gdp6Sj1lki0USM2JvkfYl'
		},

		payment: function(data, actions) {
		return actions.payment.create({
		payment:{
		transactions: [{
		amount: {
		total: amount,
		currency: currency,
		},
		description: description,
		invoice_number: student_id,
		//soft_descriptor: 'ECHI5786786',
		}],
		note_to_payer:"Contact us for any questions on your order.",
		redirect_urls:{
		return_url:"https://example.com/return",
		cancel_url:"https://example.com/cancel"
		}
		}
		});
		},

		// Wait for the payment to be authorized by the customer

		onAuthorize: function(data, actions) {

		// Get the payment details

		return actions.payment.get().then(function(data) {

		var strindata = JSON.stringify(data);
		console.log('Data JSON STRINGIFIED *******-> ' + strindata);

		// Display the payment details and a confirmation button

		var shipping = data.payer.payer_info.shipping_address;

		var userdata = JSON.stringify(data.payer);
		console.log('User JSON STRINGIFIED *******-> ' + userdata);

		<%--var EXECUTE_URL = 'https://demo.dewcis.com/paypal';--%>
		var EXECUTE_URL = '/paypal';

		//var payload_obj = JSON.parse(data);
		var payload_obj2 = JSON.parse(strindata);
		//console.log("payload_obj----->" + payload_obj);
		console.log("payload_obj2----->" + payload_obj2);

		// Make a call to your server to execute the payment -->
		return paypal.request.post(EXECUTE_URL,{json:JSON.stringify(data)})
		.then(function (res) {
		//window.alert( JSON.stringify(response) );
		//window.alert('Payment Complete! PaymentID => '+ response.paymentID + ' PayerID=>' + response.payerID + ' EXECUTE_URL=>' + EXECUTE_URL);

		location.reload();

		});

		location.reload();


		});
		}

		}, '#aua-paypal-btn');

		</script>
		<script type="text/javascript">
		var radio_self = $("#self_sponsored");
		var radio_sponsor = $("#sponsorship_letter");
		var radio_bank = $("#bank_letter");
		var btn_paypal = $("#paypal_div");
		var btn_spons = $("#sponsor_slip");
		var btn_bank = $("#bank_slip");
		radio_self.click(function() {
		btn_bank.hide();
		btn_spons.hide();
		btn_paypal.show();
		});
		radio_sponsor.click(function() {
		btn_bank.hide();
		btn_spons.show();
		btn_paypal.hide();
		});
		radio_bank.click(function() {
		btn_bank.show();
		btn_spons.hide();
		btn_paypal.hide();
		});



		</script>
		<!-- END JAVASCRIPTS -->
			<%
               String diaryJSON = "";
               if(web.getViewType().equals("DIARY")) diaryJSON = web.getCalendar();
               %>
		<%@ include file="./assets/include/calendar.jsp" %>
			<% if(web.hasPasswordChange()) { %>
		<%@ include file="./assets/include/password_change.jsp" %>
			<% } %>
		<%--<script src="./assets/js/validate.js"></script>--%>
		</body>
		<!-- END BODY -->
		</html>
			<% 	web.close(); %>


