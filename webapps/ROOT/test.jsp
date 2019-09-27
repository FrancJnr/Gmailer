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
</html>
<select id="denomination">
        <option value="default">default</option>
    </select>
<select id="nationality">
        <option value="default">default</option>
    </select>
<select id="degree">
        <option value="default">default</option>
    </select>

<script>
     var json = <%=jForm%>;
     var denominations=json.form[0].list;
     var nationalities=json.form[1].list;
     var degrees=json.form[2].list;
     var obj = JSON.parse(denominations);
     var obj2 = JSON.parse(nationalities);
     var obj3 = JSON.parse(degrees);


    var denomination=document.getElementById("denomination")
        for(var i=0;i<obj.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj[i].denomination_name);
            option.appendChild(txt);
            denomination.insertBefore(option,denomination.lastChild);
        }
         var nationality=document.getElementById("nationality")
        for(var i=0;i<obj2.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj2[i].sys_country_name);
            option.appendChild(txt);
            nationality.insertBefore(option,nationality.lastChild);
        }
         var degree=document.getElementById("degree")
        for(var i=0;i<obj3.length;i++){
            var option=document.createElement("OPTION"),
            txt=document.createTextNode(obj3[i].degree_name);
            option.appendChild(txt);
            degree.insertBefore(option,degree.lastChild);
        }
    
</script>


<body>
    

</body>
<%  web.close(); %>