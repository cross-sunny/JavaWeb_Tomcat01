<%@ page pageEncoding="UTF-8" %>
<%
    // 使用绝对路径，避免相对路径偏差
    response.sendRedirect(request.getContextPath() + "/web/login.jsp");
%>