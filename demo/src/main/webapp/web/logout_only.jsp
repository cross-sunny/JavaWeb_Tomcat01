<%@ page pageEncoding="UTF-8" %>
<%
    // 获取退出原因参数
    String kicked = request.getParameter("kicked");
    String action = request.getParameter("action");

    // 销毁当前会话（清除登录状态）
    session.invalidate();

    // 根据退出原因设置提示消息
    String message;
    if ("true".equals(kicked)) {
        message = "您已被管理员强制退出系统。";
    } else if ("logout".equals(action)) {
        message = "您已成功退出登录。";
    } else {
        message = "会话已结束，请重新登录。";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>退出登录</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 100px;
            background-color: #f5f5f5;
        }
        .message {
            color: #d32f2f;
            font-size: 18px;
            margin-bottom: 20px;
        }
        .login-link {
            display: inline-block;
            padding: 10px 20px;
            background-color: #1976d2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .login-link:hover {
            background-color: #1565c0;
        }
    </style>
</head>
<body>
<div class="message"><%= message %></div>
<a href="login.jsp" class="login-link">返回登录页面</a>
</body>
</html>