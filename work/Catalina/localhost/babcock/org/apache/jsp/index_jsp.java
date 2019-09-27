/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: Apache Tomcat/8.5.37
 * Generated at: 2019-09-06 08:11:13 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class index_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent,
                 org.apache.jasper.runtime.JspSourceImports {

  private static final javax.servlet.jsp.JspFactory _jspxFactory =
          javax.servlet.jsp.JspFactory.getDefaultFactory();

  private static java.util.Map<java.lang.String,java.lang.Long> _jspx_dependants;

  private static final java.util.Set<java.lang.String> _jspx_imports_packages;

  private static final java.util.Set<java.lang.String> _jspx_imports_classes;

  static {
    _jspx_imports_packages = new java.util.HashSet<>();
    _jspx_imports_packages.add("javax.servlet");
    _jspx_imports_packages.add("javax.servlet.http");
    _jspx_imports_packages.add("javax.servlet.jsp");
    _jspx_imports_classes = null;
  }

  private volatile javax.el.ExpressionFactory _el_expressionfactory;
  private volatile org.apache.tomcat.InstanceManager _jsp_instancemanager;

  public java.util.Map<java.lang.String,java.lang.Long> getDependants() {
    return _jspx_dependants;
  }

  public java.util.Set<java.lang.String> getPackageImports() {
    return _jspx_imports_packages;
  }

  public java.util.Set<java.lang.String> getClassImports() {
    return _jspx_imports_classes;
  }

  public javax.el.ExpressionFactory _jsp_getExpressionFactory() {
    if (_el_expressionfactory == null) {
      synchronized (this) {
        if (_el_expressionfactory == null) {
          _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
        }
      }
    }
    return _el_expressionfactory;
  }

  public org.apache.tomcat.InstanceManager _jsp_getInstanceManager() {
    if (_jsp_instancemanager == null) {
      synchronized (this) {
        if (_jsp_instancemanager == null) {
          _jsp_instancemanager = org.apache.jasper.runtime.InstanceManagerFactory.getInstanceManager(getServletConfig());
        }
      }
    }
    return _jsp_instancemanager;
  }

  public void _jspInit() {
  }

  public void _jspDestroy() {
  }

  public void _jspService(final javax.servlet.http.HttpServletRequest request, final javax.servlet.http.HttpServletResponse response)
      throws java.io.IOException, javax.servlet.ServletException {

    final java.lang.String _jspx_method = request.getMethod();
    if (!"GET".equals(_jspx_method) && !"POST".equals(_jspx_method) && !"HEAD".equals(_jspx_method) && !javax.servlet.DispatcherType.ERROR.equals(request.getDispatcherType())) {
      response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "JSPs only permit GET POST or HEAD");
      return;
    }

    final javax.servlet.jsp.PageContext pageContext;
    javax.servlet.http.HttpSession session = null;
    final javax.servlet.ServletContext application;
    final javax.servlet.ServletConfig config;
    javax.servlet.jsp.JspWriter out = null;
    final java.lang.Object page = this;
    javax.servlet.jsp.JspWriter _jspx_out = null;
    javax.servlet.jsp.PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;


	session.removeAttribute("xmlcnf");
	session.invalidate();

      out.write("\n");
      out.write("\n");
      out.write("<!DOCTYPE html>\n");
      out.write("<html xmlns=\"http://www.w3.org/1999/xhtml\">\n");
      out.write("<head>\n");
      out.write("\n");
      out.write("\n");
      out.write("\t<!-- General meta information -->\n");
      out.write("\t<title>Babcock University On-line Registration</title>\n");
      out.write("\t<meta name=\"description\" content=\"Babcock University On-line Registration\">\n");
      out.write("    <meta name=\"viewport\" content=\"width=device-width\">\n");
      out.write("\t<meta name=\"author\" content=\"Dew CIS Solutions LTD\">\n");
      out.write("\t<link href=\"landing/images/favicon.ico\" rel=\"shortcut icon\">\n");
      out.write("\t<!-- // General meta information -->\n");
      out.write("\t\n");
      out.write("\t\n");
      out.write("\t<!-- Load stylesheets -->\n");
      out.write("\t\t<link type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/960.css\" media=\"screen\" /><!-- no need to edit, 960.gs Framework -->\n");
      out.write("\t\t<link type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/screen.css\" media=\"screen\" />\n");
      out.write("\t\t<link id=\"theme-colors\" type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/themes/default.css\" media=\"screen\" /><!-- replace css/themes/xxxxxx.css with the theme you want to use -->\n");
      out.write("\t\t<link type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/print.css\" media=\"print\" />\n");
      out.write("\t\t<link type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/jquery.fancybox-1.3.4.css\" media=\"screen\" /><!-- no need to edit, lightbox css -->\n");
      out.write("\t\t<!--[if lt IE 7]><link type=\"text/css\" rel=\"stylesheet\" href=\"landing/css/ie6.css\" media=\"screen\" /><![endif]-->\n");
      out.write("\t<!-- // Load stylesheets -->\n");
      out.write("\t\n");
      out.write("\t\n");
      out.write("\t<!-- Load Javascript / jQuery -->\n");
      out.write("\t\t<!--[if lt IE 7]><script src=\"http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE7.js\"></script><![endif]-->    \n");
      out.write("\t\t<script type=\"text/javascript\" src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js\"></script>\n");
      out.write("\t\t<script type=\"text/javascript\" src=\"landing/js/superfish-combined.js\"></script>\n");
      out.write("\t\t<script type=\"text/javascript\" src=\"landing/js/jquery.cycle.all.min.js\"></script>\n");
      out.write("\t\t<script type=\"text/javascript\" src=\"landing/js/jquery.fancybox-1.3.4.pack.js\"></script>\n");
      out.write("        <script type=\"text/javascript\" src=\"landing/js/jquery.tweet.js\"></script>\n");
      out.write("\t\t<script type=\"text/javascript\" src=\"landing/js/general.js\"></script>\n");
      out.write("\t<!-- // Load Javascript / jQuery -->\n");
      out.write("\t\n");
      out.write("\n");
      out.write("\t\n");
      out.write("</head>\n");
      out.write("<body>\n");
      out.write("\t\n");
      out.write("    \n");
      out.write("\t<div id=\"outer\" class=\"clearfix\">\n");
      out.write("     \n");
      out.write("\t\t<div id=\"header\" class=\"clearfix\">          \n");
      out.write("        \t\n");
      out.write("        \t<div class=\"container_12\">\n");
      out.write("            \t\n");
      out.write("           \t\t<div class=\"grid_12\" id=\"header-container\">\n");
      out.write("                    \n");
      out.write("                    <div id=\"logo\">\n");
      out.write("                        <h1><a href=\"index.html\" title=\"Go to the home page\"><img src=\"landing/images/babcock_logo.png\" alt=\"Logo\" /></a></h1>\n");
      out.write("                    </div><!-- //logo -->\n");
      out.write("                    \n");
      out.write("                    <ul class=\"sf-menu\">\n");
      out.write("\t\t\t\t\t\t<li><a href=\"index.jsp\">Home</a></li>\n");
      out.write("                        <li><a href=\"a_general.jsp?view=1:0\">General Information</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"index_app.jsp\">Admission</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"a_students.jsp?view=1:0\">Students</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"a_lecturers.jsp?view=1:0\">Lecturers</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"a_guardians.jsp?view=1:0\">Guardians</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"a_alumnae.jsp?view=1:0\">Alumnae</a></li>\n");
      out.write("\t\t\t\t\t\t<li><a href=\"a_industry.jsp?view=1:0\">Industry</a></li>\n");
      out.write("\t\t\t\t\t</ul>\n");
      out.write("            \t</div><!-- //grid_12 -->\n");
      out.write("            \n");
      out.write("\t\t\t</div><!-- //container_12 -->\n");
      out.write("            \n");
      out.write("        \n");
      out.write("        </div><!-- //header -->\n");
      out.write("        \n");
      out.write("        \n");
      out.write("        <div id=\"main\" class=\"clearfix\">\n");
      out.write("        \t\n");
      out.write("            <div class=\"container_12\">\n");
      out.write("            \t\n");
      out.write("\t\t\t\t<div class=\"grid_12\">\n");
      out.write("\t\t\t\t\t\t\t\n");
      out.write("\t\t\t\t\t\t\t<!-- To be safe, specify a width/height when using HTML slides -->\n");
      out.write("\t\t\t\t\t\t\t<div class=\"clearfix\" style=\"width:940px; height:186px;\">\n");
      out.write("\t\t\t\t\t\t\t\t<div class=\"grid_4 alpha\"><a href=\"landing/images/custom/front-full-1.jpg\"><img src=\"landing/images/custom/front-300by180-1.jpg\" alt=\"Student Studying\" /></a></div>\n");
      out.write("\t\t\t\t\t\t\t\t<div class=\"grid_4\"><a href=\"landing/images/custom/front-full-3.jpg\"><img src=\"landing/images/custom/front-300by180-3.jpg\" alt=\"University Library\" /></a></div>\n");
      out.write("\t\t\t\t\t\t\t\t<div class=\"grid_4 omega\"><a href=\"landing/images/custom/front-full-2.jpg\"><img src=\"landing/images/custom/front-300by180-2.jpg\" alt=\"Chemistry Lab\" /></a></div>\n");
      out.write("\n");
      out.write("\t\t\t\t\t\t\t</div>\n");
      out.write("\t\t\t\t\n");
      out.write("\t\t\t\t\n");
      out.write("\t\t\t\t</div><!--//grid_12-->\n");
      out.write("                \n");
      out.write("                \n");
      out.write("                <div class=\"clear\"></div><!--//clear columns-->\n");
      out.write("                \n");
      out.write("                \n");
      out.write("                \n");
      out.write("                <div id=\"main\" class=\"grid_8\">\n");
      out.write("                    <h2>Welcome to Babcock University UMIS</h2>\n");
      out.write("                    <p>We want to make it easy for our lecturers, students, alumnae and employers to access information as securely and accurately as possible. Students can register for classes, make online payments, access grades and use many other features.</p>\n");
      out.write("                \t\n");
      out.write("                    <div class=\"grid_4 alpha\">\n");
      out.write("                    \t<ul class=\"iconlist clean\">\n");
      out.write("                        \t<li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/check32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>Register for class</h5>\n");
      out.write("                            </li>\n");
      out.write("                            <li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/star32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>Check your personal details</h5>\n");
      out.write("                            </li>\n");
      out.write("                            <li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/check32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>View/print GPA reports</h5>\n");
      out.write("                            </li>\n");
      out.write("\t\t\t\t\t\t\t<li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/star32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>View your degree details</h5>\n");
      out.write("                            </li>\n");
      out.write("\n");
      out.write("                        </ul>\n");
      out.write("                    </div><!-- grid_4 alpha (nested column start)-->\n");
      out.write("                    \n");
      out.write("                    <div class=\"grid_4 omega\">\n");
      out.write("                    \t<ul class=\"iconlist clean\">\n");
      out.write("                        \t<li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/star32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>View/print a copy of your class and exam time table</h5>\n");
      out.write("                            </li>\n");
      out.write("                            <li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/check32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>View a student copy of your unofficial transcript</h5>\n");
      out.write("                            </li>\n");
      out.write("                            <li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/star32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>View your student account</h5>\n");
      out.write("                            </li>\n");
      out.write("\t\t\t\t\t\t\t<li class=\"clearfix\">\n");
      out.write("                            \t<img src=\"landing/images/icons/check32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("                            \t<h5>Pay your student account</h5>\n");
      out.write("                            </li>\n");
      out.write("                        </ul>\n");
      out.write("                    </div><!-- grid_4 omega (nested column end)-->\n");
      out.write("                \t<div id=\"main\" class=\"grid_8\">\n");
      out.write("\t\t\t\t\t    <hr>\n");
      out.write("\t\t\t\t\t    <h3>Online Registration</h3>\n");
      out.write("\n");
      out.write("\t\t\t\t\t\t<ol>\n");
      out.write("\t\t\t\t\t\t\t<li>Go to any bank and present the 16 digits number  TO LOAD THE ACCOUNT. Obtain your receipt.</li>\n");
      out.write("\t\t\t\t\t\t\t<li>Access the registration system (University Management Information System-UMIS) by opening the browser preferably Mozilla Firefox.</li>\n");
      out.write("\t\t\t\t\t\t\t<li>Type in <a href=\"http://umis.babcock.edu.ng\" target=\"_blank\"><strong>umis.babcock.edu.ng</strong></a>  in the address bar of your browser and press enter key.</li>\n");
      out.write("\t\t\t\t\t\t\t<li>PROCEDURES </li>\n");
      out.write("\t\t\t\t\t\t\t    <ol type=\"i\">\n");
      out.write("\t\t\t\t\t\t\t\t<li>Click on the <strong>Student</strong> Menu</li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>Login with your <strong><u>username</u></strong> and <strong><u>password</u></strong> obtained from your email box.</li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>Once you login kindly change your password by clicking on the <strong>Change Password</strong> link at the top right hand of your page</li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>Input the old password in the first text box, then input your new password you desire to use in the second and third text box. Then click on <strong>Update</strong> to effectively change the password.</li>\n");
      out.write("\t\t\t\t\t\t\t    </ol>\n");
      out.write("\t\t\t\t\t\t\t<li>Financial Registration</li>\n");
      out.write("\t\t\t\t\t\t\t    <ol type=\"i\">\n");
      out.write("\t\t\t\t\t\t\t\t<li>Click on <strong>Financial Registration</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>Click on <strong>Current Charges</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>The current charges shows the <u>acceptance fees</u> paid and <u>fees</u> to pay for the session/semester.</li>\n");
      out.write("\t\t\t\t\t\t\t\t<li>Click on the arrow beside <strong>GO</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t<li> Click on <strong>Apply to Make Payment</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t    <ol type=\"a\">\n");
      out.write("\t\t\t\t\t\t\t\t    <li>Click on <strong>Make Payment</strong>  tab</li>\n");
      out.write("\t\t\t\t\t\t\t\t    <li>Click on the etranzact Logo<strong>(make sure the card balance is equal or greater than the Amount to be paid in the boxes)</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t    <li>Click on <strong>Pay</strong> button</li>\n");
      out.write("\t\t\t\t\t\t\t\t    </ol>\n");
      out.write("\t\t\t\t\t\t\t\t    After making successful payment  and your finance is approved. Click on the <strong>current charges.</strong>\n");
      out.write("\t\t\t\t\t\t\t\t    <li>Click on the arrow beside <strong>GO</strong></li>\n");
      out.write("\t\t\t\t\t\t\t\t    <li>Click on <strong>Receipt</strong> tab. Click on <strong>PDF</strong> to download and print your online receipt.</li>\n");
      out.write("\t\t\t\t\t\t\t    </ol>\n");
      out.write("\t\t\t\t\t\t\t\n");
      out.write("\t\t\t\t\t\t</ol>\n");
      out.write("\t\t\t\t\t\t\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\n");
      out.write("\n");
      out.write("\t\t\t\t\t</div><!--//grid_8-->\n");
      out.write("\n");
      out.write("    \n");
      out.write("                </div><!--//grid_8-->\n");
      out.write("                \n");
      out.write("                 \n");
      out.write("                <div id=\"main\" class=\"grid_4\">\n");
      out.write("                    <div class=\"widget\">\n");
      out.write("                    \t<h3 class=\"widgettitle\">New Applicants</h3>\n");
      out.write("                        <p>Fill out an application form online by: </p>\n");
      out.write("\t\t\t\t\t\t<p>1. Click <a href=\"http://application.babcock.edu.ng/babcock/index.jsp\">here</a> to make application</p>\n");
      out.write("\t\t\t\t\t\t<p>2. Check your email for your password then click <a href=\"http://application.babcock.edu.ng/babcock/a_admissions.jsp?view=1:0\">here</a> to fill in the form</p>\n");
      out.write("\t\t\t\t\t\t<p>3. Upload the the picure, select exam center</p>\n");
      out.write("\t\t\t\t\t\t<p>4. Make payment using eTranzact</p>\n");
      out.write("\t\t\t\t\t\t<p>5. Submit your completed application form</p>\n");
      out.write("\t\t\t\t\t\t<p>For more information access the tutorial <a href=\"tutorial/admisions.pdf\" target=\"_blank\">here</a>.</p>\n");
      out.write("                    </div>\n");
      out.write("\n");
      out.write("                \t<div class=\"widget\">\n");
      out.write("                    \t<h3 class=\"widgettitle\">Student Registration</h3>\n");
      out.write("                        <p>All payment must be received before you can register for courses (except for financial aid students). Registration must be completed at least 24 hrs. before the course start date</p>\n");
      out.write("\n");
      out.write("\t\t\t\t\t\t<div class=\"grid_2 alpha\">\n");
      out.write("\t\t\t\t\t\t\t<ul class=\"iconlist clean\">\n");
      out.write("\t\t\t\t\t\t    \t<li class=\"clearfix\">\n");
      out.write("\t\t\t\t\t\t        \t<a href=\"http://www.etranzact.net/eTranzact/Interfaces/NewRegisterSecurityQuestion.jsp\"><img src=\"landing/images/icons/user32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("\t\t\t\t\t\t        \tClick here to verify your Details</a>\n");
      out.write("\t\t\t\t\t\t        </li>\n");
      out.write("\t\t\t\t\t\t    </ul>\n");
      out.write("\t\t\t\t\t\t</div><!-- grid_4 alpha (nested column start)-->\n");
      out.write("\n");
      out.write("\t\t\t\t\t\t<div class=\"grid_2 omega\">\n");
      out.write("\t\t\t\t\t\t\t<ul class=\"iconlist clean\">\n");
      out.write("\t\t\t\t\t\t    \t<li class=\"clearfix\">\n");
      out.write("\t\t\t\t\t\t        \t<a href=\"http://www.etranzact.net/eTranzact/Interfaces/PinResend.jsp\"><img src=\"landing/images/icons/exchange32.png\" alt=\"Icon\" class=\"left\" />\n");
      out.write("\t\t\t\t\t\t        \tClick here to request for PIN Change</a>\n");
      out.write("\t\t\t\t\t\t        </li>\n");
      out.write("\t\t\t\t\t\t    </ul>\n");
      out.write("\t\t\t\t\t\t</div>\n");
      out.write("  \t\t\t\t\t\t<br /> <br />\n");
      out.write("                    </div>\n");
      out.write("      \n");
      out.write("                    <div class=\"widget\">\n");
      out.write("                    \t<h3 class=\"widgettitle\">Common Errors to Avoid</h3>\n");
      out.write("\t\t\t\t\t\t<ol>\n");
      out.write("\t\t\t\t\t\t\t\n");
      out.write("\t\t\t\t\t\t\t<li>1. Make sure you supply correct expiry date.</li>\n");
      out.write("\t\t\t\t\t\t\t<li>2. Click 'PayNow' Only Once</li>\n");
      out.write("\t\t\t\t\t\t\t<li>3. Do it your self.</li>\n");
      out.write("\t\t\t\t\t\t\t<li>4. Do not give your PIN number to somebody else.</li>\n");
      out.write("\t\t\t\t\t\t</ol>\n");
      out.write("                    </div>\n");
      out.write("\n");
      out.write("\n");
      out.write("                    <div class=\"widget\">\n");
      out.write("\n");
      out.write("                    \t<h3 class=\"widgettitle\">Campus Location</h3>\n");
      out.write("\t\t\t\t\t\t<iframe width=\"300\" height=\"350\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"http://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=en&amp;geocode=&amp;q=Babcock+University,+Ilishan,+Ogun+State,+Nigeria&amp;aq=0&amp;oq=babcock+univer&amp;sll=-1.297321,36.788515&amp;sspn=0.006393,0.011362&amp;t=h&amp;ie=UTF8&amp;hq=Babcock+University,+Ilishan,+Ogun+State,+Nigeria&amp;ll=6.892344,3.724194&amp;spn=0.022155,0.032015&amp;output=embed\"></iframe><br /><small><a href=\"http://maps.google.com/maps?f=q&amp;source=embed&amp;hl=en&amp;geocode=&amp;q=Babcock+University,+Ilishan,+Ogun+State,+Nigeria&amp;aq=0&amp;oq=babcock+univer&amp;sll=-1.297321,36.788515&amp;sspn=0.006393,0.011362&amp;t=h&amp;ie=UTF8&amp;hq=Babcock+University,+Ilishan,+Ogun+State,+Nigeria&amp;ll=6.892344,3.724194&amp;spn=0.022155,0.032015\" style=\"color:#0000FF;text-align:left\">View Larger Map</a></small>\n");
      out.write("\n");
      out.write("                    </div>\n");
      out.write("                    \n");
      out.write("                \n");
      out.write("                </div><!--//grid_4-->         \n");
      out.write("        \n");
      out.write("                \n");
      out.write("                \n");
      out.write("                <div class=\"clear\"></div><!--//clear columns-->\n");
      out.write("                \n");
      out.write("                <div class=\"grid_12\">\n");
      out.write("                    <p class=\"quotebox\">\n");
      out.write("                        The future is bright - Babcock University; A Seventh Day Adventist Institution of Higher Learning; since 1959\n");
      out.write("                    </p>\n");
      out.write("                </div><!--//grid_12-->                \n");
      out.write("                \n");
      out.write("            </div><!-- //container_12 -->\n");
      out.write("        \n");
      out.write("        </div><!-- //main -->\n");
      out.write("  \n");
      out.write("       \t\n");
      out.write("        <div id=\"footer-bottom\" class=\"clearfix\">\n");
      out.write("            <div class=\"container_12\">\n");
      out.write("            \t<div class=\"grid_12\">\n");
      out.write("                    <p class=\"left\">&copy; 2013 - <a href=\"http://www.babcockuni.edu.ng/\" title=\"Babcock Website\">Babcock University</a> | Powered by \t\t<a href=\"http://www.dewcis.com/products/baraza-product-family\" title=\"Openbaraza\"> Openbaraza</a></p>\n");
      out.write("                    <p class=\"right\"><a href=\"#\" class=\"scroll-top\" title=\"Back to the Top\">TOP</a></p>\n");
      out.write("                </div>\n");
      out.write("            </div><!--//container_12-->\n");
      out.write("        </div>\n");
      out.write("        \n");
      out.write("        \n");
      out.write("\t</div><!-- //outer -->\n");
      out.write("\t\n");
      out.write("\t<!-- insert analytics -->\n");
      out.write("</body>\n");
      out.write("</html>\n");
    } catch (java.lang.Throwable t) {
      if (!(t instanceof javax.servlet.jsp.SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try {
            if (response.isCommitted()) {
              out.flush();
            } else {
              out.clearBuffer();
            }
          } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
