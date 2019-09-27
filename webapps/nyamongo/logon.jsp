<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%@ page import="com.dewcis.UrlResolver" %>

<%
   
    // session.removeAttribute("xmlcnf");
    

    UrlResolver rsv = new UrlResolver();
    
    String url = rsv.tryAgain(request, response);
    session.setAttribute("try_url", url);
    
    // session.invalidate();

    
%>

<!-- pageContext -->
<!DOCTYPE html>
<html>
    <title><%= pageContext.getServletContext().getInitParameter("web_title") %></title>
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
        <div class="container" style="width: 40%; height:80%;">
        <div class="row">
            <div class="col-md-8 login-sec" style="margin-left: 15%;">
                <h2 class="text-center"><%= pageContext.getServletContext().getInitParameter("login_title") %></h2>
                <form class="login-form"  method="POST" action="j_security_check" method="post">
                    <div class="form-group text-center">
                        
                        <input type="text" class="form-control" autocomplete="off" placeholder="Username" 
                        id="j_username" name="j_username" autofocus required>
                        
                    </div>
                    <div class="form-group">
                        
                        <input type="password" class="form-control" autocomplete="off" placeholder="Password" 
                        id="j_password" name="j_password" required>
                    </div>
                    
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="checkbox" class="form-check-input">
                            <small>Remember Me</small>
                        </label>
                        <button type="submit" class="btn btn-login float-right">Submit</button>
                    </div>
      
                </form>
                
            </div>
            
    </div>
    </section>

</body>
</html> 

