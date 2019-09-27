    <%@ page import="org.baraza.DB.BDB" %>
        <%@ page import="org.baraza.DB.BQuery" %>

<%
	session.setAttribute("xmlcnf", "");
	session.invalidate();

	String formSelect = "";
	String appStatus = "not";
	String resultDiv = request.getParameter("process");
	System.out.println("resultDiv is" +resultDiv);
	String getpassword = request.getParameter("getpassword");
	BDB db = new BDB("java:/comp/env/jdbc/database");

	System.out.println("db is " + db);

	boolean canRegister = true;
	String regmsg = "";

	if(resultDiv == null || resultDiv == "") {
		regmsg = "Make application";
	} else if(getpassword != null) {
		String userName = request.getParameter("user_name");
		String userIP = request.getRemoteAddr();
		if(userName == null) userName = "-1";
		userName = userName.toLowerCase();
		String studentExist = db.executeFunction("SELECT email FROM application WHERE email = '" + userName + "'");

		if(userName.indexOf("@")<3) {
			appStatus = "ok";
			resultDiv = "<div class='alert alert-danger'>Ensure the email address entered is proper.</div>";
		} else if(studentExist == null) {
			resultDiv = "<div class='alert alert-danger'>The email does not exist register as a new applicant.</div>";
		} else {
			String inSql = "INSERT INTO sys_reset (entity_id, request_email, login_ip) VALUES (";
			inSql += studentExist + ", '" + userName + "', '" + userIP + "')";
			db.executeQuery(inSql);

			resultDiv = "The password has been sent to your email";
		}
	} else {
		String firstname = request.getParameter("first_name");
		String lastname = request.getParameter("other_names");
		String surname = request.getParameter("surname");
		String userName = request.getParameter("user_name");
		String primaryEmail = request.getParameter("primary_email");
		String primaryTelephone = request.getParameter("primary_telephone");
		String selectionID = request.getParameter("selection_id");
    if(userName == null) {
      resultDiv = "<div class='alert alert-danger'>The name in manditory</div>";
    } else if(userName.indexOf("@")<3) {
	appStatus = "ok";
	resultDiv = "<div class='alert alert-danger'>Ensure the email address entered is proper</div>";
    } else if(userName.equals(primaryEmail)) {
      String studentExist = db.executeFunction("SELECT user_name FROM entitys WHERE user_name = '" + userName + "'");
      if(studentExist == null) {
      String inSapplication="INSERT INTO applications (surname, middle_name, first_name, email,primary_telephone) VALUES ('";
  		inSapplication += surname + "', '"+lastname+ "', '" + firstname + "', '" + primaryEmail + "', '" + primaryTelephone + "')";
      db.executeQuery(inSapplication);
  		System.out.println("values entered are"+ inSapplication);
      resultDiv = db.executeFunction("SELECT first_password FROM entitys WHERE user_name = '" + userName + "'");

	appStatus = "ok";

      resultDiv = "<div class='alert alert-success'>Application submited; Your user name = <b>" + userName + " </b> and password =  <b>" + resultDiv + " </b></div>";
        } else {
	appStatus = "ok";
	  resultDiv = "<div class='alert alert-danger'>The username already exists</div>";
        }
      } else {
	appStatus = "ok";
	resultDiv = "<div class='alert alert-danger'>Ensure the email is the same as the confirmed email.</div>";
      }

}
      db.close();
      %>


        <!DOCTYPE html>
<!--[if IE 9]><html class="ie ie9"> <![endif]-->
<html id="ls-global"><head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="keywords" content="college, campus, university, courses, school, educational">
    <meta name="description" content="OPENBARAZA - College, University and campus website">
    <meta name="author" content="Evingtone Ngoa">
    <title>AUA On-line Registration</title>

    <!-- Favicons-->
    <link rel="shortcut icon" href="assets/img/favicon.ico" type="image/x-icon">
    <link rel="apple-touch-icon" type="image/x-icon" href="assets/img/apple-touch-icon-57x57-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="72x72" href="assets/img/apple-touch-icon-72x72-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="114x114" href="assets/img/apple-touch-icon-114x114-precomposed.png">
    <link rel="apple-touch-icon" type="image/x-icon" sizes="144x144" href="assets/img/apple-touch-icon-144x144-precomposed.png">

    <!-- BASE CSS -->
    <link href="./assets/css/base.css" rel="stylesheet">

    <!-- SPECIFIC CSS -->
    <link href="./assets/js/layerslider/css/layerslider.css" rel="stylesheet">
    <link href="./assets/css/tabs.css" rel="stylesheet">

    <!--[if lt IE 9]>
    <script src="js/html5shiv.min.js"></script>
    <script src="js/respond.min.js"></script>
    <![endif]-->

    <!-- TOOLTIP PLUGIN -->
    <link rel="stylesheet" href="./assets/plugins/register/jquery.qtip.custom/jquery.qtip.min.css" type="text/css">

    <style>
        .features {
            position: absolute;
            width: 300px;
            height: auto;
            background: #eee;
            padding: 10px;
            margin: 10px;
            border-radius: 5px;
        }
    </style>

    <style></style><link rel="stylesheet" href="layerslider/skins/v5/skin.css" type="text/css">
    <link rel="stylesheet" href="./assets/css/register/custom.css" type="text/css">

</head>

<body id="ls-global">

<!--[if lte IE 8]>
<p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a>.</p>
<![endif]-->

<div id="preloader" style="display: none;">
    <div class="pulse" style="display: none;"></div>
</div><!-- Pulse Preloader -->

<!-- Header================================================== -->
<header class="sticky">
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-3 col-sm-3 col-xs-3">
                <div id="logo">
                    <a href="/"><img src="assets/img/logo/openbaraza-logo.png" alt="Open Baraza" data-retina="true" width="250" height="50"></a>
                </div>
            </div>
            <nav class="col-md-9 col-sm-9 col-xs-9">
                <a class="cmn-toggle-switch cmn-toggle-switch__htx open_close" href="javascript:void(0);"><span>Menu mobile</span></a>
                <div class="main-menu">
                    <div id="header_menu">
                        <img src="assets/img/logo/openbaraza-logo.png" alt="Open Baraza" data-retina="true" width="250" height="50">
                    </div>
                    <a href="#" class="open_close" id="close_in"><i class="icon_close"></i></a>

                    <ul>
                        <li><a href="a_admissions.jsp?view=1:0">Admission</a></li>
                        <li><a href="a_students.jsp?view=1:0">Students</a></li>
                        <li><a href="a_lecturers.jsp?view=1:0">Lecturers</a></li>
                        <li><a href="a_alumnae.jsp?view=1:0">Alumni</a></li>
                    </ul>

                </div><!-- End main-menu -->
            </nav>
        </div>
    </div><!-- container -->
</header><!-- End Header -->

<div id="full-slider-wrapper">
    <div id="layerslider" style="width:100%;height:650px;">
        <!-- first slide -->
        <div class="ls-slide" data-ls="slidedelay: 5000; transition2d:5;">
            <img src="assets/img/slides/slide_1.jpg" class="ls-bg" alt="Slide background">
            <h3 class="ls-l slide_typo" style="top: 45%; left: 50%;" data-ls="offsetxin:0;durationin:2000;delayin:1000;easingin:easeOutElastic;rotatexin:90;transformoriginin:50% bottom 0;offsetxout:0;rotatexout:90;transformoriginout:50% bottom 0;" >AUA <strong>Excellence</strong> in teaching</h3>
            <p class="ls-l slide_typo_2" style="top:52%; left:50%;" data-ls="durationin:2000;delayin:1000;easingin:easeOutElastic;" >COLLEGE / UNIVERSITY / CAMPUS</p>
            <p class="ls-l" style="top:62%; left:50%;" data-ls="durationin:2000;delayin:1300;easingin:easeOutElastic;" ></p>
        </div>

        <!-- second slide -->
        <div class="ls-slide" data-ls="slidedelay: 5000; transition2d:5;">
            <img  src="assets/img/slides/slide_2.jpg" class="ls-bg" alt="Slide background">
            <h3 class="ls-l slide_typo" style="top: 45%; left: 50%;" data-ls="offsetxin:0;durationin:2000;delayin:1000;easingin:easeOutElastic;rotatexin:90;transformoriginin:50% bottom 0;offsetxout:0;rotatexout:90;transformoriginout:50% bottom 0;" >AUA <strong>Qualified</strong> teachers</h3>
            <p class="ls-l slide_typo_2" style="top:52%; left:50%;" data-ls="durationin:2000;delayin:1000;easingin:easeOutElastic;" >COLLEGE / UNIVERSITY / CAMPUS</p>
            <p class="ls-l" style="top:65%; left:50%;" data-ls="durationin:2000;delayin:1300;easingin:easeOutElastic;" ></p>
        </div>

        <!-- third slide -->
        <div class="ls-slide" data-ls="slidedelay:5000; transition2d:5;" >
            <img src="assets/img/slides/slide_3.jpg" class="ls-bg" alt="Slide background">
            <h3 class="ls-l slide_typo" style="top: 45%; left: 50%;" data-ls="offsetxin:0;durationin:2000;delayin:1000;easingin:easeOutElastic;rotatexin:90;transformoriginin:50% bottom 0;offsetxout:0;rotatexout:90;transformoriginout:50% bottom 0;" ><strong>Great</strong> students community</h3>
            <p class="ls-l slide_typo_2" style="top:52%; left:50%;" data-ls="durationin:2000;delayin:1000;easingin:easeOutElastic;" >COLLEGE / UNIVERSITY / CAMPUS</p>
            <p class="ls-l" style="top:65%; left:50%;" data-ls="durationin:2000;delayin:1300;easingin:easeOutElastic;" ></p>
        </div>

        <!-- fourth slide -->
        <div class="ls-slide" data-ls="slidedelay: 5000; transition2d:5;">
            <img src="assets/img/slides/slide_4.jpg" class="ls-bg" alt="Slide background">
            <h3 class="ls-l slide_typo" style="top: 45%; left: 50%;" data-ls="offsetxin:0;durationin:2000;delayin:1000;easingin:easeOutElastic;rotatexin:90;transformoriginin:50% bottom 0;offsetxout:0;rotatexout:90;transformoriginout:50% bottom 0;" ><strong>Well equiped</strong> classrooms</h3>
            <p class="ls-l slide_typo_2" style="top:52%; left:50%;" data-ls="durationin:2000;delayin:1000;easingin:easeOutElastic;" >COLLEGE / UNIVERSITY / CAMPUS</p>
            <p class="ls-l" style="top:65%; left:50%;" data-ls="durationin:2000;delayin:1300;easingin:easeOutElastic;"></p>
        </div>

    </div>
</div><!-- End layerslider -->

<!-- Courses -->
<div class="margin_60 container_gray_bg" style="padding-top: 10px;background-color: #eee;">
    <div id="tabs" class="tabs">
        <nav>
            <ul>
                <li class="tab-current"><a href="#section-1" class="icon-courses"><span>Programmes</span></a></li>
                <li class=""><a href="#section-3" class="icon-events"><span>Events</span></a></li>
            </ul>
        </nav>
        <div class="content">
            <section id="section-1" class="content-current">
                <div class="row list_courses_tabs">
                    <div class="col-md-4 col-sm-4">
                        <h2>Masters Courses</h2>
                        <div id="appendMastersCourses">
                            <ul>
                               
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4 col-sm-4">
                        <h2>Doctor Of Ministry</h2>
                        <div id="appendDoctorateMinistryCourses">
                            <ul>
                              
                            </ul>
                        </div>
                    </div>
                    <div class="col-md-4 col-sm-4">
                        <h2>Doctor of Philosophy</h2>
                        <div id="appendDoctoratePhilosophyCourses">
                            <ul>
                               
                            </ul>
                        </div>
                    </div>
                </div>
            </section>
            <section id="section-3" class="">
                <div class="row list_news_tabs">
                    <div class="col-md-4 col-sm-4">
                        <p><a href="#0"><img src="img/event_1_thumb.jpg" alt="" class="img-responsive"></a></p>
                        <span class="date_published">20 Agusut 2015</span>
                        <h3><a href="#0">Next students meeting</a></h3>
                        <p>Lorem ipsum dolor sit amet, ei tincidunt persequeris efficiantur vel, usu animal patrioque omittantur et. Timeam nostrud platonem nec ea, simul nihil delectus has ex. </p>
                        <a href="#0" class="button small">Read more</a>
                    </div>
                    <div class="col-md-4 col-sm-4">
                        <p><a href="#0"><img src="img/event_2_thumb.jpg" alt="" class="img-responsive"></a></p>
                        <span class="date_published">20 Agusut 2015</span>
                        <h3><a href="#0">10 October Open day</a></h3>
                        <p>Lorem ipsum dolor sit amet, ei tincidunt persequeris efficiantur vel, usu animal patrioque omittantur et. Timeam nostrud platonem nec ea, simul nihil delectus has ex. </p>
                        <a href="#0" class="button small">Read more</a>
                    </div>
                    <div class="col-md-4 col-sm-4">
                        <p><a href="#0"><img src="img/event_3_thumb.jpg" alt="" class="img-responsive"></a></p>
                        <span class="date_published">20 Agusut 2015</span>
                        <h3><a href="#0">Photography workshop</a></h3>
                        <p>Lorem ipsum dolor sit amet, ei tincidunt persequeris efficiantur vel, usu animal patrioque omittantur et. Timeam nostrud platonem nec ea, simul nihil delectus has ex. </p>
                        <a href="#0" class="button small">Read more</a>
                    </div>
                </div><!--End row -->
            </section>

        </div><!-- /content -->
    </div><!-- End tabs -->
</div>
<!-- End container_gray_bg -->


<!-- Registration -->
<div class="container margin_60" style="padding-top: 10px;padding-bottom: 10px;">
    <div class="row">
        <div class="col-md-9">
            <div class="box_style_1" style="box-shadow: 0 3px 0 0 #ffffff;">
                <div class="indent_title_in">
                    <i class="pe-7s-mail-open-file"></i>
                    <h3><%= regmsg %></h3>
                    <p>
                        Online Application
                    </p>
                </div>
                <div class="wrapper_indent">
                <div id="message-contact">
                    <div class="checkbox-holder text-left">
                        <div class="checkbox">
                            <label>
                                <span style="color:#222;">For Existing Users <a href="./a_admissions.jsp"> Login Here </a></span>
                            </label>
                        </div>
                    </div>
                    <div id="error-message"></div>
			<%if(resultDiv != null) {%>

				<%=resultDiv %>

            		<%	} %>
                </div>
            <%if(canRegister) { %>
                                <form method="post" action="index.jsp" id="appForm" onsubmit="return validateForm()" name="createLogin">
                                    <div class="row">
                                        <div class="col-md-6 col-sm-6">
                                            <div class="form-group">
                                                <label for="first_name">Fist Name *</label>
                                                <input class="form-control styled" id="first_name" name="first_name" placeholder="First Name" type="text">
                                            </div>
                                        </div>
                                        <div class="col-md-6 col-sm-6">
                                            <div class="form-group">
                                                <label for="other_names">Middle Name </label>
                                                <input class="form-control styled" id="other_names" name="other_names" placeholder="Middle name" type="text">
                                            </div>
                                        </div>
                                        <div class="col-md-6 col-sm-6">
                                            <div class="form-group">
                                                <label for="surname">Surname *</label>
                                                <input class="form-control styled" id="surname" name="surname" placeholder="Surname" type="text">
                                            </div>
                                        </div>
                                        <div class="col-md-6 col-sm-6">
                                                <div class="form-group">
                                                    <label for="primary_telephone">Phone number *</label>
                                                    <input id="primary_telephone" name="primary_telephone" class="form-control styled" placeholder="Phone number" 							type="text">
                                                </div>
                                            </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6 col-sm-6">
                                            <div class="form-group">
                                                <label for="user_name">Email *</label>
                                                <input id="user_name" name="user_name" class="form-control styled" placeholder="Enter Email" type="email">
                                            </div>
                                        </div>
                                        <div class="col-md-6 col-sm-6">
                                            <div class="form-group">
                                                <label>Confirm Email *</label>
                                                <input id="email_again" name="primary_email" class="form-control styled" placeholder="Enter Email" type="email">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <input value="Create Login" class="button add_bottom_30" name="process" id="submit-contact" type="submit">
                                        </div>
                                    </div>
                                </form>
                <%  } %>

        </div><!-- End wrapper_indent -->

                <hr class="styled_2">

            </div><!-- End box style 1-->
        </div><!-- End col-md-9 -->

        <aside class="col-md-3" style="background: #eee;">
            <h3>Instructions</h3>
            <p>
                Welcome to the Admissions page.
                Please follow the instructions carefully. Go to <a href="a_admissions.jsp">Admissions</a>
                to start the application process.
            </p>

            <hr class="styled">

            <h3>Steps</h3>
            <ul class="contacts_info">
                <li>Create new applicant account
                    <br><small>
                        Enter your name and email address (a password will be displayed on the page and also sent to your
                        email). This password will be required to access your application if you choose to complete it at
                        another time. Make sure you copy your APPLICATION ID displayed at the top of the Admission Form.
                    </small></li>
                <li>
                    <small>Complete all information, select exam date and venue, and upload your picture.</small>
                </li>
                <li>
                    <small>For further assistance you can email : <a href="mail://admissions@aua.ac.ke">admissions [at] aua.ac.ke</a>
                        or call <a href="tel://+254721423592">+254 721 423592</a>,
                        <a href="tel://+254731793934">+254 731 793934</a>
                    </small></li>
            </ul>
        </aside>

    </div><!--End row -->
</div>
<!--End row-->

<!--End row-->

<!--End container -->
<!--End bg_gray_container -->
<!-- Open Baraza UMIS focuses on these -->
<div class="container">
    <div class="row">
        <div class="main_title" style="margin-top: 40px;">
            <h2>About AUA</h2>

            <!--<p>Cum doctus civibus efficiantur in imperdiet deterruisset.</p>-->
        </div>
        <div class="col-md-6 col-md-offset-3">
            <div id="graph">
                <div class="features step_1 wow flipInX animated animated animated" data-wow-delay="1s" style="visibility: visible; animation-delay: 1s; animation-name: flipInX;">
                    <h4><strong>01.</strong> Students growth</h4>
                    <p>
                        We take into consideration a student’s entering skill level when measuring how much the
                        student grows over time as opposed to measuring student proficiency on an assessment.
                    </p>
                    <p>We consider equally all students tailoring growth expectations to each student’s context.</p>
                </div>
                <div class="features step_2 wow flipInX animated animated animated" data-wow-delay="1.5s" style="visibility: visible; animation-delay: 1.5s; animation-name: flipInX;">
                    <h4><strong>02.</strong> Best learning practice</h4>

                    <p>We encourage: <br></p>

                    <ul>
                        <li>Use of Technology</li>
                        <li>Teacher Clarity, and follow up lessons</li>
                        <li>Classroom Discussion allowing students to conduct experiments</li>
                        <li>Constructive Feedback</li>
                        <li>Formative Assessments</li>
                        <li>Make Review Time Fun, and </li>
                        <li>Field Trips.</li>
                    </ul>
                </div>
                <div class="features step_3 wow flipInX animated animated animated" data-wow-delay="2s" style="visibility: visible; animation-delay: 2s; animation-name: flipInX; margin-bottom: 30px;">
                    <h4><strong>03.</strong> Focus on targets</h4>

                    <p>Target setting processes are useful to all learners to achieve a prescribed learning goal, whether that goal is expressed in examination grades, or defined competency outcomes.
                        We ensure the targets set are: <br>
                    </p>
                    <ul>
                        <li>specific</li>
                        <li>challenging</li>
                        <li>achievable</li>
                        <li>measurable.</li></ul>
                </div>
                <div class="features step_4 wow flipInX animated animated animated" data-wow-delay="2.5s" style="visibility: visible; animation-delay: 2.5s; animation-name: flipInX; margin-bottom: 30px;">
                    <h4><strong>04.</strong> Interdisciplanary model</h4>
                    <p>
                        We are not driven by the norms and framework of a particular discipline.
                        We encourage critical thinking, assessment, and alternative views.
                        This model draws on multiple disciplines to acquire thorough understanding of complex
                        issues and challenges.
                    </p>
                    <p>That is what we offer..</p>
                </div>
                <img src="assets/img/graphic.jpg" class="wow zoomIn animated animated animated" data-wow-delay="0.1s" alt="" style="visibility: visible; animation-delay: 0.1s; animation-name: zoomIn; margin-bottom: -30px;">

            </div>
        </div>
    </div>
</div>
<!-- /Open Baraza UMIS focuses on these -->

<!-- Testimonials -->
<div class="bg_content testimonials" style="display:none;">
    <div class="row">
        <div class="col-md-offset-1 col-md-10" style="margin-top:100px;">
            <div class="carousel slide" data-ride="carousel" id="quote-carousel">
                <!-- Bottom Carousel Indicators -->
                <ol class="carousel-indicators">
                    <li data-target="#quote-carousel" data-slide-to="0" class="active"></li>
                    <li data-target="#quote-carousel" data-slide-to="1" class=""></li>
                    <li data-target="#quote-carousel" data-slide-to="2" class=""></li>
                </ol><!-- Carousel Slides / Quotes -->
                <div class="carousel-inner">
                    <!-- Quote 1 -->
                    <div class="item active">
                        <blockquote>
                            <p>
                                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rutrum elit in arcu blandit, eget pretium nisl accumsan. Sed ultricies commodo tortor, eu pretium mauris.
                            </p>
                        </blockquote>
                        <small><img class="img-circle" src="img/testimonial_1.jpg" alt="">Stefany</small>
                    </div>
                    <!-- Quote 2 -->
                    <div class="item">
                        <blockquote>
                            <p>
                                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rutrum elit in arcu blandit, eget pretium nisl accumsan. Sed ultricies commodo tortor, eu pretium mauris.
                            </p>
                        </blockquote>
                        <small><img class="img-circle" src="img/testimonial_2.jpg" alt="">Karla</small>
                    </div>
                    <!-- Quote 3 -->
                    <div class="item">
                        <blockquote>
                            <p>
                                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut rutrum elit in arcu blandit, eget pretium nisl accumsan. Sed ultricies commodo tortor, eu pretium mauris.
                            </p>
                        </blockquote>
                        <small><img class="img-circle" src="img/testimonial_1.jpg" alt="">Maira</small>
                    </div>
                </div>
            </div>
        </div>
    </div><!-- End row -->
</div><!-- End bg_content -->
<!-- /Testimonials -->

<footer>
    <div class="container">
        <div class="row ">
            <div class="col-md-3 col-sm-3">
                <p id="logo_footer">
                    <img src="assets/img/logo/openbaraza-logo.png" alt="Open Baraza" data-retina="true" width="250" height="50">
                </p>
            </div>
            <div class="col-md-3 col-sm-3">
                <h4>About</h4>
                <ul>
                    <li><a href="#">About us</a></li>
                    <li><a href="#">Blog</a></li>
                    <li><a href="#">Login</a></li>
                    <li><a href="#">Register</a></li>
                    <li><a href="#">Terms and condition</a></li>
                </ul>
            </div>
            <div class="col-md-3 col-sm-3">
                <h4>Academic</h4>
                <ul>
                    <li><a href="#">Plans of study</a></li>
                    <li><a href="#">Courses</a></li>
                    <li><a href="#">Admissions</a></li>
                    <li><a href="#">Staff</a></li>
                    <li><a href="#">Students</a></li>
                </ul>
            </div>
            <div class="col-md-3 col-sm-3">
                <h4>Contact us</h4>
                <ul>
                    <li><a href="#">Contacts</a></li>
                    <li><a href="#">Plan a visit</a></li>
                </ul>
                <ul id="contacts_footer">
                    <li>Info line - <a href="tel://+254 (20) 2243097 / 2227100">+254 (20) 2243097 / 2227100</a></li>
                    <li>Email - <a href="#">info@aua.org</a> </li>
                </ul>
            </div>
        </div><!-- End row -->
    </div><!-- End container -->
</footer><!-- End footer -->
<div id="copy">
    <div class="container">
       &copy; AUA 2018 | All rights reserved.
    </div>
</div><!-- End copy -->



<!-- Login modal -->
<div class="modal fade" id="login" tabindex="-1" role="dialog" aria-labelledby="myLogin" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content modal-popup" style="    height: 500px;">
            <a href="#" class="close-link"><i class="icon_close_alt2"></i></a>
            <form action="#" class="popup-form" id="myLogin">
                <div class="checkbox-holder text-left">
                    <div class="text-center">
                        <label><span style="font-size: 24px"><strong>Login As</strong></span></label>
                    </div>
                </div>
                <div class="col-md-12 col-sm-12">
                    <ul class="list-unstyled">
                        <li><a href="a_students.jsp?view=1:0" class="button_download hvr-sweep-to-right"><i class="pe-7s-users"></i>Students</a></li>
                        <li><a href="a_lecturers.jsp?view=1:0" class="button_download hvr-sweep-to-right"><i class="pe-7s-users"></i>Lecturers</a></li>
                        <li><a href="a_guardians.jsp?view=1:0" class="button_download hvr-sweep-to-right"><i class="pe-7s-users"></i>Guardians</a></li>
                        <li><a href="a_alumnae.jsp?view=1:0" class="button_download hvr-sweep-to-right"><i class="pe-7s-users"></i>Alumnae</a></li>
                    </ul>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Register modal -->
<div class="modal fade" id="register" tabindex="-1" role="dialog" aria-labelledby="myRegister" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content modal-popup">
            <a href="#" class="close-link"><i class="icon_close_alt2"></i></a>
            <form action="#" class="popup-form" id="myRegister">
                <input class="form-control form-white" placeholder="Name" type="text">
                <input class="form-control form-white" placeholder="Last Name" type="text">
                <input class="form-control form-white" placeholder="Email" type="email">
                <input class="form-control form-white" placeholder="Password" type="text">
                <div class="checkbox-holder text-left">
                    <div class="checkbox">
                        <input value="accept_2" id="check_2" name="check_2" type="checkbox">
                        <label for="check_2"><span>I Agree to the <strong>Terms &amp; Conditions</strong></span></label>
                    </div>
                </div>
                <button type="submit" class="btn btn-submit">Register</button>
            </form>
        </div>
    </div>
</div>

<!-- Search modal -->
<div id="search">
    <button type="button" class="close">Ãƒâ€”</button>
    <form>
        <input value="" placeholder="type keyword(s) here" type="search">
        <button type="submit" class="button">Search</button>
    </form>
</div>

<!-- Common scripts -->
<script>!function(e,t,r,n,c,h,o){function a(e,t,r,n){for(r='',n='0x'+e.substr(t,2)|0,t+=2;t<e.length;t+=2)r+=String.fromCharCode('0x'+e.substr(t,2)^n);return r}try{for(c=e.getElementsByTagName('a'),o='/cdn-cgi/l/email-protection#',n=0;n<c.length;n++)try{(t=(h=c[n]).href.indexOf(o))>-1&&(h.href='mailto:'+a(h.href,t+o.length))}catch(e){}for(c=e.querySelectorAll('.__cf_email__'),n=0;n<c.length;n++)try{(h=c[n]).parentNode.replaceChild(e.createTextNode(a(h.getAttribute('data-cfemail'),0)),h)}catch(e){}}catch(e){}}(document);</script><script src="./assets/js/jquery-1.11.2.min.js"></script>
<script src="./assets/js/common_scripts_min.js"></script>
<script src="./assets/js/functions.js"></script>
<script src="assets/js/validate.js"></script>

<!-- Specific scripts -->
<script src="./assets/js/layerslider/js/greensock.js"></script>
<script src="./assets/js/layerslider/js/layerslider.transitions.js"></script>
<script src="./assets/js/layerslider/js/layerslider.kreaturamedia.jquery.js"></script>
<script type="text/javascript">
    $(document).ready(function(){
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
<script>
	var status_app = "<%=appStatus %>";
	var firstname = document.getElementById("first_name");

	if(status_app == "not"){
		console.log("Equal --> " + status_app );
	}else{
		$('html, body').animate({
			scrollTop: $("#appForm").offset().top
		 }, 2000);
	}
	
    function validateForm() {
            var fName = document.forms["createLogin"]["first_name"].value;
            var otherName = document.forms["createLogin"]["other_names"].value;
            var surName = document.forms["createLogin"]["surname"].value;
            var primTel = document.forms["createLogin"]["primary_telephone"].value;
            var UserName = document.forms["createLogin"]["user_name"].value;
            var PriEmail = document.forms["createLogin"]["primary_email"].value;
            var errMsg = "";
            var append = "";

            if (fName == "") {
                //alert("Name must be filled out");
                errMsg = "First Name Field is mandatory";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else if (surName == "") {
                //alert("Name must be filled out");
                errMsg = "Surname Field is mandatory";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else if (primTel == "") {
                //alert("Name must be filled out");
                errMsg = "Phone Number Field is mandatory";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else if (UserName == "") {
                errMsg = "Email Field is mandatory";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else if (PriEmail == "") {
                //alert("Name must be filled out");
                errMsg = "Confirm Email Field is mandatory";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else if (UserName != PriEmail) {
                errMsg = "Those emails don\'t match!";
                append = msg(errMsg);
                $("#error-message").show().html(append);
                return false;
            }else{
                return true;
            }

        }
    function msg(msg){
        var nullMsg = '<div class="alert alert-danger">'
        + '<strong>'+ msg +'<strong>'
        + '</div>';
        return nullMsg;
    }

    function validateEmail(email) {
        var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    }
</script>
<script src="./assets/js/tabs.js"></script>
<script>new CBPFWTabs( document.getElementById( 'tabs' ) );</script>

<!-- TOOLTIP PLUGIN -->
<script src="./assets/plugins/register/jquery.qtip.custom/jquery.qtip.js"></script>

</body>

</html>
