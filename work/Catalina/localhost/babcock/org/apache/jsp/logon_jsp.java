/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: Apache Tomcat/8.5.37
 * Generated at: 2019-09-06 08:11:25 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class logon_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent,
                 org.apache.jasper.runtime.JspSourceImports {

  private static final javax.servlet.jsp.JspFactory _jspxFactory =
          javax.servlet.jsp.JspFactory.getDefaultFactory();

  private static java.util.Map<java.lang.String,java.lang.Long> _jspx_dependants;

  static {
    _jspx_dependants = new java.util.HashMap<java.lang.String,java.lang.Long>(4);
    _jspx_dependants.put("/WEB-INF/lib/standard.jar", Long.valueOf(1201570774000L));
    _jspx_dependants.put("/resources/include/init-login.jsp", Long.valueOf(1337161398000L));
    _jspx_dependants.put("jar:file:/opt/projects/tomcat/webapps/babcock/WEB-INF/lib/standard.jar!/META-INF/c.tld", Long.valueOf(1064323020000L));
    _jspx_dependants.put("/resources/include/footer.jsp", Long.valueOf(1327427220000L));
  }

  private static final java.util.Set<java.lang.String> _jspx_imports_packages;

  private static final java.util.Set<java.lang.String> _jspx_imports_classes;

  static {
    _jspx_imports_packages = new java.util.HashSet<>();
    _jspx_imports_packages.add("javax.servlet");
    _jspx_imports_packages.add("javax.servlet.http");
    _jspx_imports_packages.add("javax.servlet.jsp");
    _jspx_imports_classes = null;
  }

  private org.apache.jasper.runtime.TagHandlerPool _005fjspx_005ftagPool_005fc_005furl_0026_005fvar_005fvalue_005fnobody;

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
    _005fjspx_005ftagPool_005fc_005furl_0026_005fvar_005fvalue_005fnobody = org.apache.jasper.runtime.TagHandlerPool.getTagHandlerPool(getServletConfig());
  }

  public void _jspDestroy() {
    _005fjspx_005ftagPool_005fc_005furl_0026_005fvar_005fvalue_005fnobody.release();
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

      out.write("<!doctype html\">\n");
      out.write("<html lang=\"en-us\">\n");
      out.write(" <head>\n");
      out.write("\t<meta charset=\"utf-8\">\n");
      out.write("\t<title>Open Baraza</title>\n");
      out.write("\t<meta name=\"description\" content=\"Tamshi Domains and Hosting Services\">\n");
      out.write("\t<meta name=\"author\" content=\"dewcis.com\">\n");
      out.write("\n");
      out.write("\t<!-- Apple iOS and Android stuff -->\n");
      out.write("\t<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">\n");
      out.write("\t<meta name=\"apple-mobile-web-app-status-bar-style\" content=\"black\">\n");
      out.write("\t<link rel=\"apple-touch-icon-precomposed\" href=\"resources/themes/default/icon.png\">\n");
      out.write("\t<link rel=\"apple-touch-startup-image\" href=\"resources/themes/default/startup.png\">\n");
      out.write("\t<meta name=\"viewport\" content=\"width=device-width,initial-scale=1,user-scalable=no,maximum-scale=1\">\n");
      out.write("\n");
      out.write("    <link href=\"resources/themes/default/kendo.common.css\" rel=\"stylesheet\" />\n");
      out.write("    <link href=\"resources/themes/default/kendo.default.css\" rel=\"stylesheet\" />\n");
      out.write("    <link href=\"resources/themes/default/main.css\" rel=\"stylesheet\" >\n");
      out.write("\n");
      out.write("\t<!--[if lt IE 9]>\n");
      out.write("\t<script src=\"http://html5shim.googlecode.com/svn/trunk/html5.js\"></script>\n");
      out.write("\t<![endif]-->\n");
      out.write("\t\t\n");
      out.write("    <script src=\"resources/js/kendoui/jquery.min.js\" ></script>\n");
      out.write("    <script src=\"resources/js/kendoui/kendo.all.js\" ></script>\n");
      out.write("\t<script src=\"resources/js/jquery-ui-1.8.16.custom.min.js\"></script>\n");
      out.write("\t<script src=\"resources/js/custom.js\"></script>\n");
      out.write("\n");
      out.write("\t<!-- Loading JS Files this way is not recommended! Merge them but keep their order -->\n");
      out.write("\n");
      out.write("\t<!-- some basic functions -->\n");
      out.write("\t<script src=\"resources/js/functions.js\"></script>\n");
      out.write("\n");
      out.write("\t<!-- all Third Party Plugins -->\n");
      out.write("\t<script src=\"resources/js/plugins.js\"></script>\n");
      out.write("\n");
      out.write("\t<!-- Whitelabel Plugins -->\n");
      out.write("\t<script src=\"resources/js/wl_Alert.js\"></script>\n");
      out.write("\t<script src=\"resources/js/wl_Dialog.js\"></script>\n");
      out.write("\t<script src=\"resources/js/wl_Form.js\"></script>\n");
      out.write("\n");
      out.write("\t<!-- configuration to overwrite settings -->\n");
      out.write("\t<script src=\"resources/js/config.js\"></script>\n");
      out.write("\t<script src=\"resources/js/script.js\"></script>\n");
      out.write("\t\n");
      out.write("  \n");
      out.write("</head>\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("<body id=\"login\"> \r\n");
      if (_jspx_meth_c_005furl_005f0(_jspx_page_context))
        return;
      out.write("\r\n");
      out.write("\r\n");
      out.write("<header>\r\n");
      out.write("\t<div id=\"logo\"></div>\r\n");
      out.write("</header>\r\n");
      out.write("<section id=\"content\">\r\n");
      out.write("<form method=\"POST\" action=\"j_security_check\" id=\"loginform\">\r\n");
      out.write("\t<fieldset>\r\n");
      out.write("\t\t<section><label for=\"username\">Username <a href=\"index.jsp\">Home</a></label>\r\n");
      out.write("\t\t\t<div><input type=\"text\" id=\"username\" name=\"j_username\" autofocus></div>\r\n");
      out.write("\t\t</section>\r\n");
      out.write("\t\t<section>\r\n");
      out.write("\t\t\t<label for=\"password\">Password  <a href=\"a_general.jsp?view=21:0\">lost password?</a></label>\r\n");
      out.write("\t\t\t<div><input type=\"password\" id=\"password\" name=\"j_password\"></div>\r\n");
      out.write("\t\t</section>\r\n");
      out.write("\t\t<section>\r\n");
      out.write("\t\t\t<div><button class=\"fr\">Login</button></div>\r\n");
      out.write("\t\t</section>\r\n");
      out.write("\t</fieldset>\r\n");
      out.write("</form>\r\n");
      out.write("</section>\r\n");
      out.write("\r\n");
      out.write("\t<footer>&copy; 2012 - Dew CIS Solutions LTD, All Rights Reserved</footer>\n");
      out.write("</body>\n");
      out.write("</html>");
      out.write("\r\n");
      out.write("\r\n");
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

  private boolean _jspx_meth_c_005furl_005f0(javax.servlet.jsp.PageContext _jspx_page_context)
          throws java.lang.Throwable {
    javax.servlet.jsp.PageContext pageContext = _jspx_page_context;
    javax.servlet.jsp.JspWriter out = _jspx_page_context.getOut();
    //  c:url
    org.apache.taglibs.standard.tag.rt.core.UrlTag _jspx_th_c_005furl_005f0 = (org.apache.taglibs.standard.tag.rt.core.UrlTag) _005fjspx_005ftagPool_005fc_005furl_0026_005fvar_005fvalue_005fnobody.get(org.apache.taglibs.standard.tag.rt.core.UrlTag.class);
    boolean _jspx_th_c_005furl_005f0_reused = false;
    try {
      _jspx_th_c_005furl_005f0.setPageContext(_jspx_page_context);
      _jspx_th_c_005furl_005f0.setParent(null);
      // /logon.jsp(4,0) name = var type = java.lang.String reqTime = false required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_c_005furl_005f0.setVar("url");
      // /logon.jsp(4,0) name = value type = null reqTime = true required = false fragment = false deferredValue = false expectedTypeName = null deferredMethod = false methodSignature = null
      _jspx_th_c_005furl_005f0.setValue("/index.jsp");
      int _jspx_eval_c_005furl_005f0 = _jspx_th_c_005furl_005f0.doStartTag();
      if (_jspx_th_c_005furl_005f0.doEndTag() == javax.servlet.jsp.tagext.Tag.SKIP_PAGE) {
        return true;
      }
      _005fjspx_005ftagPool_005fc_005furl_0026_005fvar_005fvalue_005fnobody.reuse(_jspx_th_c_005furl_005f0);
      _jspx_th_c_005furl_005f0_reused = true;
    } finally {
      org.apache.jasper.runtime.JspRuntimeLibrary.releaseTag(_jspx_th_c_005furl_005f0, _jsp_getInstanceManager(), _jspx_th_c_005furl_005f0_reused);
    }
    return false;
  }
}
