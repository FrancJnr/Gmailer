<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<%
	String try_url= "";
    try{
     try_url = session.getAttribute("try_url").toString();
    System.out.println(try_url);

    }catch(Exception e){
    System.out.println("This "+ e);
}
    
    
%>

<!DOCTYPE html>
<html>
    <title><%= pageContext.getServletContext().getInitParameter("login_title") %></title>
        <link href="${contextPath}/assets/global/plugins/bootstrap-4.1.1/dist/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
        <link href="${contextPath}/assets/global/plugins/font-awesome/css/font-awesome.min.css" rel="stylesheet" id="bootstrap-css">
        <script src="${contextPath}/assets/global/plugins/bootstrap-4.1.1/dist/js/bootstrap.min.js"></script>
        <script src="${contextPath}/assets/global/plugins/jquery-3.2.1/dist/jquery.min.js"></script>
        <link href="https://fonts.googleapis.com/css?family=Lato|Open+Sans|Oswald|Roboto" rel="stylesheet"> 
        <!-- <link href="${contextPath}/assets/css/custom.css" rel="stylesheet" type="text/css"/> -->
        <link href="${contextPath}/assets/global/css/custom.css" rel="stylesheet" type="text/css"/>
        <!------ Include the above in your HEAD tag ---------->
<body>

    <section class="login-block">
        <div class="container" style="width: 40%; height:80%;>
        <div class="row">
            <div class="col-md-8 login-sec" style="margin-left: 15%;">
                <h2 class="text-center"><%= pageContext.getServletContext().getInitParameter("login_title") %></h2>
                <form class="login-form"  method="POST" action="j_security_check" method="post">
                    <div class="alert alert-danger alert-dismissible">
                        <button type="button" class="close" data-dismiss="alert">&times;</button>
                           <strong>Error!</strong> Invalid Username / Password.
                    </div>
                    
                    <div class="form-group text-center">
                            <a class="btn btn-success" href="<%=try_url%>"><i class="fa fa-hand-o-up"></i>&nbsp;Try Again</a>
                    </div>
      
                </form>
                <div class="copy-text">Created with <i class="fa fa-heart"></i> by <a href="http://www.openbaraza.org" target="_blank">OpenBaraza</a> &copy; 2019  <br> <a href="https://www.dewcis.com/privacy-policy/" target="_blank">Privacy Policy</a></div>
            </div>
            
			</div>
    </div>

</body>
</html> 
