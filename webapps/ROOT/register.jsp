<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="mainPage" value="register.jsp" scope="page" />
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.baraza.DB.BQuery" %>
<%@ page import="org.baraza.web.*" %>
<%@ page import="org.baraza.xml.BElement" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>





<%
    String denomination_select="";
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

    String jForm = web.getJSONForm(request);
    System.out.println(jForm);

%>







<!DOCTYPE html>
<!--
Template Name: Metronic - Responsive Admin Dashboard Template build with Twitter Bootstrap 3.3.4
Version: 3.9.0
Author: KeenThemes
Website: http://www.keenthemes.com/
Contact: support@keenthemes.com
Follow: www.twitter.com/keenthemes
Like: www.facebook.com/keenthemes
Purchase: http://themeforest.net/item/metronic-responsive-admin-dashboard-template/4021469?ref=keenthemes
License: You must have a valid license purchased only from themeforest(the above link) in order to legally use the theme for your project.
-->
<!--[if IE 8]>
<html lang="en" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]>
<html lang="en" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<!-- DOC: Apply "page-sidebar-hide" class to the body to make the sidebar completely hidden on toggle -->
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
    <title>Open Baraza University | Registration</title>

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
    <link href="./assets/plugins/register/bootstrap-switch/css/bootstrap-switch.min.css" rel="stylesheet"
          type="text/css"/>
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
<header class="sticky">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-3 col-sm-3 col-xs-3">
                <div id="logo">
                    <a href="/umis/"><img src="assets/img/logo/openbaraza-logo.png" alt="Open Baraza" data-retina="true" width="125" height="40"></a>
                </div>
            </div>
            <nav class="col-md-9 col-sm-9 col-xs-9">
                <a class="cmn-toggle-switch cmn-toggle-switch__htx open_close" href="javascript:void(0);"><span>Menu mobile</span></a>

                <div class="main-menu">
                    <div id="header_menu">
                        <img src="assets/img/logo/openbaraza-logo.png" alt="Open Baraza" data-retina="true" width="125" height="40">
                    </div>
                    <a href="#" class="open_close" id="close_in"><i class="icon_close"></i></a>
                    <ul>
                        <li><a href="index.jsp" class="active">Home</a></li>
                        <li><a href="a_general.jsp?view=1:0">General Information</a></li>
                        <li><a href="a_admissions.jsp?view=1:0">Admission</a></li>
                        <li><a href="a_industry.jsp?view=1:0">Industry</a></li>
                        <li><a href="a_students.jsp?view=1:0">Students</a></li>
                        <li><a href="a_lecturers.jsp?view=1:0">Lecturers</a></li>
                        <li><a href="a_guardians.jsp?view=1:0">Guardians</a></li>
                        <li><a href="a_alumnae.jsp?view=1:0">Alumnae</a></li>
                    </ul>
                </div>
                <!-- End main-menu -->
            </nav>
        </div>
    </div>
    <!-- container -->
</header>
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
            <!-- BEGIN PAGE HEADER-->
            <!-- BEGIN PAGE HEAD -->
            <div class="page-head">
                <!-- BEGIN PAGE TITLE -->
                <div class="page-title">
                    <h1>Registration Form
                        <small>Student registration</small>
                    </h1>
                </div>
                <!-- END PAGE TITLE -->

            </div>
            <!-- END PAGE HEAD -->
            <!-- BEGIN PAGE BREADCRUMB -->
            <ul class="page-breadcrumb breadcrumb">
                <li>
                    <a href="#">Home</a>
                    <i class="fa fa-circle"></i>
                </li>
                <li>
                    <a href="#">Student registration</a>
                    <!--<i class="fa fa-circle"></i>-->
                </li>
                <!--<li>-->
                <!--<a href="#">Form Wizard</a>-->
                <!--</li>-->
            </ul>
            <!-- END PAGE BREADCRUMB -->
            <!-- END PAGE HEADER-->
            <!-- BEGIN PAGE CONTENT-->
            <div class="row">
                <div class="col-md-12">
                    <div class="portlet box blue" id="form_wizard_1">
                        <div class="portlet-title">
                            <div class="caption">
                                <i class="fa fa-gift"></i> Registration Form - <span class="step-title">
                                Step 1 of 4 </span>
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
                            <form action="#" class="form-horizontal" id="submit_form" method="POST">
                                <div class="form-wizard">
                                    <div class="form-body">
                                        <ul class="nav nav-pills nav-justified steps">
                                            <li>
                                                <a href="#tab1" data-toggle="tab" class="step">
                                                <span class="number">
                                                1 </span>
                                                <span class="desc">
                                                <i class="fa fa-check"></i> SECTION A </span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="#tab2" data-toggle="tab" class="step">
                                                <span class="number">
                                                2 </span>
                                                <span class="desc">
                                                <i class="fa fa-check"></i> SECTION B </span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="#tab3" data-toggle="tab" class="step">
                                                <span class="number">
                                                3 </span>
                                                <span class="desc">
                                                <i class="fa fa-check"></i> SECTION C </span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="#tab4" data-toggle="tab" class="step">
                                                <span class="number">
                                                4 </span>
                                                <span class="desc">
                                                <i class="fa fa-check"></i> SECTION D </span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="#tab5" data-toggle="tab" class="step">
                                                <span class="number">
                                                5 </span>
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
                                            <div class="alert alert-danger display-none">
                                                <button class="close" data-dismiss="alert"></button>
                                                You have not filled some compulsory fields. Go Back and confirm.
                                            </div>
                                            <div class="alert alert-success display-none">
                                                <button class="close" data-dismiss="alert"></button>
                                                Your form validation is successful!
                                            </div>

                                            <div class="tab-pane active" id="tab1">
                                                <form action="#" class="form-horizontal" id="submit_form_one" method="POST">
                                                    <h3 class="block">Provide your account details</h3>
                                                    <div class="row">
                                                        <div class="col-md-4">
                                                            <div class="form-group">
                                                                <label class="control-label col-md-4">Surname <span class="required"
                                                                                                                    aria-required="true">
                                                                    * </span>
                                                                </label>

                                                                <div class="col-md-8">
                                                                    <input class="form-control" name="surname" type="text">
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
                                                                <input class="form-control" name="firstname" type="text">
                                                                    <span class="help-block">
                                                                    Provide your Firstname </span>
                                                            </div>
                                                        </div>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="form-group">
                                                            <label class="control-label col-md-4">Lastname <span
                                                                    class="required" aria-required="true">
                                                                * </span>
                                                            </label>

                                                            <div class="col-md-8">
                                                                <input class="form-control" name="lastname" type="text">
                                                                    <span class="help-block">
                                                                    Provide your Lastname </span>
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
                                                                    <input type="text" class="form-control" name="email"
                                                                           id="submit_form_email"/>
                                                                <span class="help-block">
                                                                Provide your email address </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="form-group">
                                                            <label class="control-label col-md-4">Confirm Email <span
                                                                    class="required">
                                                            * </span>
                                                            </label>

                                                            <div class="col-md-8">
                                                                <input type="text" class="form-control" name="remail"/>
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
                                                                <input class="form-control" name="tel_no" type="text">
                                                                <span class="help-block">
                                                                Provide your telephone number </span>
                                                            </div>
                                                        </div>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <div class="form-group ">
                                                            <label class="control-label col-md-4">Mobile No <span
                                                                    class="required" aria-required="true">
                                                                * </span>
                                                            </label>

                                                            <div class="col-md-8">
                                                                <input class="form-control" name="mobile_no" type="text">
                                                                    <span class="help-block">
                                                                    Provide your Mobile No</span>
                                                            </div>
                                                        </div>
                                                        </div>
                                                    </div>
                                                    <a href="javascript:;" style="visibility: hidden" class="btn green button-save">
                                                        Save <i class="m-icon-swapright m-icon-white"></i>
                                                    </a>
                                                </form>
                                            </div>

                                            <div class="tab-pane" id="tab2">
                                                <h3 class="block">Provide your Profile Information</h3>

                                                <div class="row">

                                                    <div class="col-md-12">
                                                        <div class="form-group col-md-4">
                                                            <label class="control-label col-md-4">Gender <span
                                                                    class="required">
                                                            * </span>
                                                            </label>

                                                            <div class="col-md-8">
                                                                <select name="gender" class="form-control">
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
                                                                <input type="text" class="form-control"
                                                                       name="marital_status"/>
                                                                <span class="help-block">
                                                                Provide your Marital Status </span>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-4">
                                                            <label class="control-label col-md-4">Religious Affiliation <span
                                                                    class="required">
                                                            * </span>
                                                            </label>

                                                            <div class="col-md-8">

                                                                         <select id="denomination" class="form-control">
                                                                            <option>Choose a denomination</option>
                                                                         </select>


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
                                                                <input type="text" class="form-control"
                                                                       name="passport_id_no"/>
                                                                <span class="help-block">
                                                                Provide your Passport No/ ID No </span>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="col-md-12">
                                                        <div class="form-group col-md-4">
                                                            <label class="control-label col-md-4">
                                                                Physical Disability <span class="required">
                                                            * </span>
                                                            </label>

                                                            <div class="col-md-8">
                                                                <div id="form_disability_bool_error"></div>
                                                                <select name="disability_bool" class="form-control">
                                                                    <option selected value="">Select</option>
                                                                    <option value="Y">Yes</option>
                                                                    <option value="N">No</option>
                                                                </select>

                                                                <input type="text" class="form-control"
                                                                       name="disability"/>
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
                                                                          name="current_address"></textarea>
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
                                                                          name="permanent_address"></textarea>
                                                                <span class="help-block">
                                                                Provide your Permanent Address </span>
                                                            </div>
                                                        </div>
                                                    </div>

                                                </div>
                                            </div>

                                            <div class="tab-pane" id="tab3">
                                                <h3 class="block">Provide your Education Information</h3>

                                                <div class="row">
                                                    <!--Qualification-->
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">QUALIFICATIONS ( <em>Highest
                                                            Degrees Earned</em> )</h4>
                                                        <label class="control-label col-md-2">1. <span class="required">
                                                         </span>
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="degree_1"/>
                                                            <span class="help-block">
                                                            Provide your Degree earned </span>
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
                                                                   name="university_1"/>
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
                                                                   name="completion_yr_1"/>
                                                        <span class="help-block">
                                                        Provide your year of completion </span>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title text-center">GRADES <br>OBTAINED </h4>
                                                        <label class="control-label col-md-2">
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="grades_1"/>
                                                            <span class="help-block">
                                                            Provide your grade </span>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-3">
                                                        <!--<h4 class="col-title">QUALIFICATIONS ( <em>Highest Degrees Earned</em> )</h4>-->
                                                        <label class="control-label col-md-2">2. <span class="required">
                                                         </span>
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="degree_2"/>
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
                                                                   name="university_2"/>
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
                                                                   name="completion_yr_2"/>
                                                        <span class="help-block">
                                                        Provide your year of completion </span>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <!--<h4 class="col-title">GRADES <br>OBTAINED </h4>-->
                                                        <label class="control-label col-md-2">
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="grades_2"/>
                                                            <span class="help-block">
                                                            Provide your grade </span>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-3">
                                                        <!--<h4 class="col-title">QUALIFICATIONS ( <em>Highest Degrees Earned</em> )</h4>-->
                                                        <label class="control-label col-md-2">3. <span class="required">
                                                         </span>
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="degree_3"/>
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
                                                                   name="university_3"/>
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
                                                                   name="completion_yr_3"/>
                                                        <span class="help-block">
                                                        Provide your year of completion </span>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <!--<h4 class="col-title">GRADES <br>OBTAINED </h4>-->
                                                        <label class="control-label col-md-2">
                                                        </label>

                                                        <div class="col-md-10">
                                                            <input type="text" class="form-control" name="grades_3"/>
                                                            <span class="help-block">
                                                            Provide your grade </span>
                                                        </div>
                                                    </div>
                                                    <!--/Qualification-->

                                                    <!--Degree desired:-->
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title">Degree desired: </h4>
                                                        <label class="control-label col-md-4">School of Postgraduate
                                                            Studies <span class="required">
                                                         </span>
                                                        </label>

                                                        <div class="col-md-8">
                                                            <select name="post_grad" class="form-control" id="degree">
                                                                <option selected value="">Select</option>

                                                            </select>

                                                            <div id="form_post_grad_error"></div>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title" style="visibility: hidden">Degree
                                                            desired: </h4>
                                                        <label class="control-label col-md-4">Theological Seminary <span
                                                                class="required">
                                                         </span>
                                                        </label>

                                                        <div class="col-md-8">
                                                            <select name="theology_seminary" class="form-control" id="degree2">
                                                                <option selected value="">Select</option>

                                                            </select>
                                                            <div id="form_theology_seminary_error"></div>
                                                        </div>
                                                    </div>
                                                    <!--/Degree desired:-->
                                                    <div class="form-group col-md-3">
                                                        <h4 class="col-title" style="visibility: hidden;">Accomodation </h4>
                                                        <label class="control-label col-md-6" for="accomodation">
                                                            Accomodation - On Campus
                                                        </label>

                                                        <div class="col-md-6">
                                                            <select name="accomodation" id="accomodation" class="form-control">
                                                                <option selected value="">Select</option>
                                                                <option value="Yes">Yes</option>
                                                                <option value="No">No</option>
                                                            </select>
                                                            <div id="form_accomodation_error"></div>
                                                        </div>
                                                    </div>

                                                    <!--English Proficiency:-->

                                                        <div class="form-group col-md-3">
                                                            <h4 class="col-title" style="visibility: hidden;">Finance: </h4>
                                                            <label class="control-label col-md-6">
                                                                Self Sponsored?
                                                            </label>

                                                            <div class="col-md-6">
                                                                <select name="self_sponsored" class="form-control">
                                                                    <option selected value="">Select</option>
                                                                    <option value="Yes">Yes</option>
                                                                    <option value="No">No</option>
                                                                </select>
                                                                <div id="form_self_sponsored_error"></div>
                                                            </div>
                                                        </div>
                                                    <div class="row">
                                                        <div class="form-group col-md-6">
                                                            <h4 class="col-title">English Proficiency: </h4>
                                                            <label class="control-label col-md-8">
                                                                Graduated from English-speaking College/University?
                                                            </label>

                                                            <div class="col-md-4">
                                                                <select name="is_english" class="form-control">
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
                                                                <select name="prof_test" class="form-control">
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
                                                                           name="test_name"/>
                                                                </div>
                                                                <label class="control-label col-md-6">
                                                                    Score
                                                                </label>

                                                                <div class="col-md-6">
                                                                    <input type="text" class="form-control" name="score"/>
                                                                </div>
                                                                <label class="control-label col-md-6">
                                                                    Date
                                                                </label>

                                                                <div class="col-md-6">
                                                                    <input type="text" class="form-control date"
                                                                           name="date_test"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>


                                                    <!--/English Proficiency:-->


                                                </div>
                                            </div>

                                            <div class="tab-pane" id="tab4">
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
                                                                           name="occupation_1"/>
                                                                    <span class="help-block">
                                                                    Provide your occupation </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="employer_1"/>
                                                                    <span class="help-block">
                                                                    Provide your employer </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="workstation_1"/>
                                                                    <span class="help-block">
                                                                    Provide your work station </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="duration_1"/>
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
                                                                           name="occupation_2"/>
                                                                    <span class="help-block">
                                                                    Provide your occupation </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="employer_2"/>
                                                                    <span class="help-block">
                                                                    Provide your employer </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="workstation_2"/>
                                                                    <span class="help-block">
                                                                    Provide your work station </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="duration_2"/>
                                                                <span class="help-block">
                                                                Provide your duration </span>
                                                                </div>
                                                            </div>

                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">2.
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="occupation_3"/>
                                                                    <span class="help-block">
                                                                    Provide your occupation </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="employer_3"/>
                                                                    <span class="help-block">
                                                                    Provide your employer </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="workstation_3"/>
                                                                    <span class="help-block">
                                                                    Provide your work station </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="duration_3"/>
                                                                <span class="help-block">
                                                                Provide your duration </span>
                                                                </div>
                                                            </div>

                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">3.
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="occupation_4"/>
                                                                    <span class="help-block">
                                                                    Provide your occupation </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="employer_4"/>
                                                                    <span class="help-block">
                                                                    Provide your employer </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="workstation_4"/>
                                                                    <span class="help-block">
                                                                    Provide your work station </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-3">
                                                                <label class="control-label col-md-2">
                                                                </label>

                                                                <div class="col-md-10">
                                                                    <input type="text" class="form-control"
                                                                           name="duration_4"/>
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
                                                                           name="num_yrs"/>
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
                                                                <label class="control-label col-md-3">1. Name
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_name_1"/>
                                                                    <span class="help-block">
                                                                    Provide your referee name </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-4">
                                                                <label class="control-label col-md-3">2. Name
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_name_2"/>
                                                                    <span class="help-block">
                                                                    Provide your referee name </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-4">
                                                                <label class="control-label col-md-3">3. Name
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_name_3"/>
                                                                    <span class="help-block">
                                                                    Provide your referee name </span>
                                                                </div>
                                                            </div>
                                                            <!--Address-->
                                                            <div class="form-group col-md-4">
                                                                <label class="control-label col-md-3">Address
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_address_1"/>
                                                                    <span class="help-block">
                                                                    Provide your referee address </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-4">
                                                                <label class="control-label col-md-3">Address
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_address_2"/>
                                                                    <span class="help-block">
                                                                    Provide your referee address </span>
                                                                </div>
                                                            </div>
                                                            <div class="form-group col-md-4">
                                                                <label class="control-label col-md-3">Address
                                                                </label>

                                                                <div class="col-md-9">
                                                                    <input type="text" class="form-control"
                                                                           name="ref_address_3"/>
                                                                    <span class="help-block">
                                                                    Provide your referee address </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <!--/Professional information-->
                                                </div>
                                            </div>

                                            <div class="tab-pane" id="tab5">
                                                <h3 class="block">Confirm your details</h3>
                                                <!--Section A-->
                                                <h4 class="form-section background">Section A</h4>

                                                <div class="col-md-12 white" >
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Surname:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="surname">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4 ">
                                                        <label class="control-label col-md-3 text-left">Firstname:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="firstname">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Lastname:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="lastname">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Telephone
                                                            No:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="tel_no">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Mobile
                                                            No:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="mobile_no">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Email:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="email">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section B-->
                                                <h4 class="form-section background">Section B</h4>

                                                <div class="col-md-12 white" >
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Date Of
                                                            Birth:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="dob">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Nationality:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="nationality">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Marital
                                                            Status:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="marital_status">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Religious
                                                            Affiliation:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="religion">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3 text-left">Physical
                                                            Disability:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="disability_bool">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Gender:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="gender">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-6">
                                                        <label class="control-label col-md-3 text-left">Current
                                                            Address:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="current_address">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-6">
                                                        <label class="control-label col-md-3 text-left">Permanent
                                                            Address:</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="permanent_address">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!--Section C-->
                                                <h4 class="form-section background">Section C</h4>
                                                <!--QUALIFICATIONS-->
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">QUALIFICATIONS</h5>
                                                        <label class="control-label col-md-2">1. </label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="degree_1">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">UNIVERSITY / COLLEGE
                                                            ATTENDED </h5>
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="university_1">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">GRADES OBTAINED</h5>
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="grades_1">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <h5 class="col-title text-center">YEAR OF COMPLETION </h5>
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static"
                                                               data-display="completion_yr_1">
                                                            </p>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2">2. </label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="degree_2">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="university_2">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="grades_2">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static"
                                                               data-display="completion_yr_2">
                                                            </p>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2">3. </label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="degree_3">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="university_3">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static" data-display="grades_3">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-3">
                                                        <label class="control-label col-md-2"></label>

                                                        <div class="col-md-10">
                                                            <p class="form-control-static"
                                                               data-display="completion_yr_3">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Degree desired-->
                                                <div class="col-md-12 white">
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">School of
                                                            Postgraduate Studies: </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="post_grad">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">Theological
                                                            Seminary: </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="theology_seminary">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">Graduated from
                                                            English-speaking College/University? </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="is_english">
                                                            </p>
                                                        </div>
                                                    </div>

                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">If No, Passed an
                                                            English proficiency test?</label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="prof_test">
                                                            </p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Name of
                                                            Test </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="test_name">
                                                            </p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Score </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="score">
                                                            </p>
                                                        </div>
                                                        <label class="control-label col-md-8 text-left">Date </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="date_test">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">Accomodation On
                                                            Campus? </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static" data-display="accomodation">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-8 text-left">How will you
                                                            finance your studies? </label>

                                                        <div class="col-md-4">
                                                            <p class="form-control-static"
                                                               data-display="self_sponsored">
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!--Section D-->
                                                <h4 class="form-section background">Section D</h4>
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
                                                                   data-display="occupation_1">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="employer_1">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="workstation_1">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="duration_1">
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
                                                                   data-display="occupation_2">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="employer_2">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="workstation_2">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="duration_2">
                                                                </p>
                                                            </div>
                                                        </div>

                                                        <!--Record 3-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">2.
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="occupation_3">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="employer_3">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="workstation_3">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="duration_3">
                                                                </p>
                                                            </div>
                                                        </div>

                                                        <!--Record 4-->
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">2.
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="occupation_4">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="employer_4">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="workstation_4">
                                                                </p>
                                                            </div>
                                                        </div>
                                                        <div class="form-group col-md-3">
                                                            <label class="control-label col-md-2">
                                                            </label>

                                                            <div class="col-md-10">
                                                                <p class="form-control-static"
                                                                   data-display="duration_4">
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
                                                                <p class="form-control-static" data-display="num_yrs">
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
                                                            <p class="form-control-static" data-display="ref_name_1">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">2. Name
                                                        </label>

                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_name_2">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">3. Name
                                                        </label>

                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_name_3">
                                                            </p>
                                                        </div>
                                                    </div>

                                                    <!--Address-->
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>

                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_1">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>

                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_2">
                                                            </p>
                                                        </div>
                                                    </div>
                                                    <div class="form-group col-md-4">
                                                        <label class="control-label col-md-3">Address
                                                        </label>

                                                        <div class="col-md-9">
                                                            <p class="form-control-static" data-display="ref_address_3">
                                                            </p>
                                                        </div>
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
                                    <div class="form-actions">
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
        FormWizard.init();

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
     var json = <%=jForm%>;
     var denominations=json.form[0].list;
     var nationalities=json.form[1].list;
     var degrees=json.form[2].list;
     var obj = JSON.parse(denominations);
     var obj2 = JSON.parse(nationalities);
     var obj3 = JSON.parse(degrees);
     console.log(obj2);
    var denomination=document.getElementById("denomination")
        for(var i=0;i<obj.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj[i].denomination_name);
            option.appendChild(txt);
            option.setAttribute("value",obj[i].denomination_name);
            denomination.insertBefore(option,denomination.lastChild);
        }
         var nationality=document.getElementById("country_list")
        for(var i=0;i<obj2.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj2[i].sys_country_name);
            option.appendChild(txt);
            option.setAttribute("value",obj2[i].sys_country_name);
            nationality.insertBefore(option,nationality.lastChild);
        }
         var degree=document.getElementById("degree")
        for(var i=0;i<obj3.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj3[i].degree_name);
            option.appendChild(txt);
            option.setAttribute("value",obj3[i].degree_name);
            degree.insertBefore(option,degree.lastChild);
        }
         var degree2=document.getElementById("degree2")
        for(var i=0;i<obj3.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj3[i].degree_name);
            option.appendChild(txt);
            option.setAttribute("value",obj3[i].degree_name);
            degree2.insertBefore(option,degree2.lastChild);
        }

</script>
<script type="text/javascript">
    $(document).ready(function () {
        'use strict';
        $('#layerslider').layerSlider({
            autoStart: true,
            responsive: true,
            responsiveUnder: 1280,
            layersContainer: 1170,
            skinsPath: 'layerslider/skins/'
            // Please make sure that you didn't forget to add a comma to the line endings
            // except the last line!
        });
    });
</script>
<script src="./assets/js/tabs.js"></script>
<script>new CBPFWTabs(document.getElementById('tabs'));</script>
<!-- END JAVASCRIPTS -->

</body>
<!-- END BODY -->
</html>
<%  web.close(); %>
