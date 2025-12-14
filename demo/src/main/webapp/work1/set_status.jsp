<%@ page pageEncoding="UTF-8" %>
<%
    // ------------ 常用 HTTP 状态码（取消注释对应行即可切换，每次只保留一行生效）------------
    // 200 OK：请求成功（默认状态码，页面正常显示）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_OK);

    // 302 Found：临时重定向（会跳转到指定页面，需配合 response.sendRedirect 使用）
    response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
    response.sendRedirect("https://www.baidu.com"); // 重定向目标地址（可选）

    // 400 Bad Request：请求参数错误（如表单提交格式不正确）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_BAD_REQUEST);

    // 401 Unauthorized：未授权（需要登录才能访问）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_UNAUTHORIZED);

    // 403 Forbidden：禁止访问（服务器拒绝请求，无权限）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_FORBIDDEN);

    // 404 Not Found：页面未找到（最常用测试状态码）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_NOT_FOUND);

    // 405 Method Not Allowed：请求方法不支持（如用 GET 访问只允许 POST 的接口）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_METHOD_NOT_ALLOWED);

    // 500 Internal Server Error：服务器内部错误（如代码报错、数据库异常）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR);

    // 503 Service Unavailable：服务不可用（如服务器维护、过载）
    // response.setStatus(jakarta.servlet.http.HttpServletResponse.SC_SERVICE_UNAVAILABLE);
%>
<!-- 内嵌网站图标（解决 favicon.ico 404 错误） -->
<link rel="icon" href="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MTIgNTEyIj48cGF0aCBmaWxsPSIjMzQ5OGRiIiBkPSJNMjU2IDhDMTE5IDggOCAxMTkgOCAyNTZzMTExIDI0OCAyNDggMjQ4IDI0OC0xMTEgMjQ4LTI0OFMzOTMgOCAyNTYgOHptMCA0MzZjLTExMC41IDAtMjAwLTg5LjUtMjAwLTIwMFMxNDUuNSA1NiAyNTYgNTZzMjAwIDg5LjUgMjAwIDIwMC04OS41IDIwMC0yMDAgMjAwem0tMTYwLTMyMmMxNy43IDAgMzIgMTQuMyAzMiAzMnYxNjBjMCAxNy43LTE0LjMgMzItMzIgMzJzLTMyLTE0LjMtMzItMzJ2LTE2MGMwLTE3LjcgMTQuMy0zMiAzMi0zMnoiLz48cGF0aCBmaWxsPSIjZTBlMGUwIiBkPSJNMzUyIDE2MHYxNjBjMCAxNy43LTE0LjMgMzItMzIgMzJzLTMyLTE0LjMtMzItMzJ2LTE2MGMwLTE3LjcgMTQuMy0zMiAzMi0zMnoiLz48L3N2Zz4=" type="image/svg+xml">

<h1>沐言科技：<br>www.yootk.com</h1>