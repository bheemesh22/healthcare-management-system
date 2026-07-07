<%-- Automatically bounce root directory traffic straight into the login view --%>
<%
    response.sendRedirect("login.jsp");
%>