<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 验证是否为管理员（现在是 zjy）
    String loginUser = (String) session.getAttribute("loginUser");
    if (loginUser == null || !"zjy".equals(loginUser)) {
        response.sendRedirect("login.jsp?error=4"); // 无权限
        return;
    }

    // 获取在线用户列表
    java.util.Map<String, Boolean> onlineUsers = (java.util.Map<String, Boolean>) application.getAttribute("onlineUsers");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>在线用户管理 - 后台</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #1e1e25; /* 比 #30303A 更深一点的背景 */
            color: #f0f0f5;
            min-height: 100vh;
            padding: 30px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background-color: #30303A;
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.5);
            overflow: hidden;
        }
        header {
            background-color: #25252f;
            padding: 20px;
            text-align: center;
            border-bottom: 2px solid #444455;
        }
        h2 {
            font-size: 24px;
            font-weight: 600;
            color: #e0e0ff;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            padding: 14px 16px;
            text-align: center;
            border-bottom: 1px solid #444;
        }
        th {
            background-color: #2a2a35;
            color: #d0d0e8;
            font-weight: 600;
        }
        tr:hover {
            background-color: #3a3a48;
        }
        .status-online {
            color: #66bb6a;
            font-weight: bold;
        }
        .status-kicked {
            color: #ff7043;
            font-weight: bold;
        }
        .btn {
            background-color: #d32f2f;
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.2s;
        }
        .btn:hover {
            background-color: #b71c1c;
        }
        .btn:disabled {
            background-color: #555;
            cursor: not-allowed;
        }
        .empty-row td {
            padding: 20px;
            color: #aaa;
            font-style: italic;
        }
        footer {
            text-align: center;
            padding: 16px;
            background-color: #25252f;
            border-top: 1px solid #444;
        }
        a.back-link {
            color: #64b5f6;
            text-decoration: none;
            font-weight: 500;
        }
        a.back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <h2>👥 在线用户管理面板</h2>
    </header>

    <table>
        <thead>
        <tr>
            <th>用户名</th>
            <th>状态</th>
            <th>操作</th>
        </tr>
        </thead>
        <tbody>
        <% if (onlineUsers != null && !onlineUsers.isEmpty()) { %>
        <% for (String username : onlineUsers.keySet()) {
            boolean kicked = onlineUsers.get(username); %>
        <tr>
            <td><strong><%= username %></strong></td>
            <td>
                <% if (kicked) { %>
                <span class="status-kicked">已踢出</span>
                <% } else { %>
                <span class="status-online">在线</span>
                <% } %>
            </td>
            <td>
                <% if (!kicked && !"zjy".equals(username)) { %>
                <!-- 管理员不能踢自己 -->
                <form action="admin/kickout" method="get" style="display:inline;">
                    <input type="hidden" name="userId" value="<%= username %>">
                    <button type="submit" class="btn">踢出</button>
                </form>
                <% } else if ("zjy".equals(username)) { %>
                <span style="color:#888;">— 自己 —</span>
                <% } else { %>
                <span style="color:#888;">— 已踢出 —</span>
                <% } %>
            </td>
        </tr>
        <% } %>
        <% } else { %>
        <tr class="empty-row">
            <td colspan="3">暂无在线用户</td>
        </tr>
        <% } %>
        </tbody>
    </table>

    <footer>
        <a href="success.jsp" class="back-link">← 返回首页</a>
    </footer>
</div>
</body>
</html>