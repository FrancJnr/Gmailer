<%--<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>--%>
<%--<c:set var="contextPath" value="${pageContext.request.contextPath}"/>--%>
    <!DOCTYPE html>
<!--[if IE 9]>
<html class="ie ie9"> <![endif]-->
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="keywords" content="college, campus, university, courses, school, educational">
    <meta name="description" content="OPENBARAZA - College, University and campus website">
    <meta name="author" content="Evingtone Ngoa">
    <title>Open Baraza University | Login</title>

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

</head>

<body>

<!--[if lte IE 8]>
<p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade
    your browser</a>.</p>
<![endif]-->

<div id="preloader">
    <div class="pulse"></div>
</div>
<!-- Pulse Preloader -->

<!-- Header================================================== -->
    <%@ include file="./menu.jsp" %>
<!-- End Header -->

<div class="sub_header_contact_home">
    <div id="intro_txt">
        <h1>Open Baraza UMIS Login</h1>

        <p>Please login with your Open Baraza username and Password.</p>

        <div class="container">
            <div class="sub_header_contact_home_wrapper">
                <form method="post" id="loginForm" action="j_security_check" autocomplete="off" novalidate="novalidate"
                      id="contactform_home">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <input type="text" autocomplete="off" placeholder="Username"
                                       class="form-control form-white"
                                       id="j_username" name="j_username" autofocus=""
                                       required=""/>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group">
                                <input autocomplete="off" placeholder="Password" class="form-control form-white"
                                       id="j_password" name="j_password" required=""
                                       type="password"/>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="form-group text-center">
                                <input type="submit" value="Submit" class="button" id="submit-contact-home">
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
<!--End sub_header -->


    <!--Body -->
    <%@ include file="./content.jsp" %>
    <!--End Body -->

    <%@ include file="./footer.jsp" %>
<!-- Common scripts -->
<script>!function (e, t, r, n, c, h, o) {
    function a(e, t, r, n) {
        for (r = '', n = '0x' + e.substr(t, 2) | 0, t += 2; t < e.length; t += 2)r += String.fromCharCode('0x' + e.substr(t, 2) ^ n);
        return r
    }

    try {
        for (c = e.getElementsByTagName('a'), o = '/cdn-cgi/l/email-protection#', n = 0; n < c.length; n++)try {
            (t = (h = c[n]).href.indexOf(o)) > -1 && (h.href = 'mailto:' + a(h.href, t + o.length))
        } catch (e) {
        }
        for (c = e.querySelectorAll('.__cf_email__'), n = 0; n < c.length; n++)try {
            (h = c[n]).parentNode.replaceChild(e.createTextNode(a(h.getAttribute('data-cfemail'), 0)), h)
        } catch (e) {
        }
    } catch (e) {
    }
}(document);</script>
<script src="./assets/js/jquery-1.11.2.min.js"></script>
<script src="./assets/js/common_scripts_min.js"></script>
<script src="./assets/js/functions.js"></script>
<script src="assets/js/validate.js"></script>

<!-- Specific scripts -->
<script src="./assets/js/layerslider/js/greensock.js"></script>
<script src="./assets/js/layerslider/js/layerslider.transitions.js"></script>
<script src="./assets/js/layerslider/js/layerslider.kreaturamedia.jquery.js"></script>
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
</body>
</html>