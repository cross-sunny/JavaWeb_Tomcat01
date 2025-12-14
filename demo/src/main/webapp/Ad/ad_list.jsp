<%@ page pageEncoding="UTF-8" import="java.sql.*,com.example.demo1.DBUtil" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT aid,title,link,img_path,status,create_time FROM ad ORDER BY create_time DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>广告管理</title>
    <link rel="stylesheet" href="styles.css">
</head>

<body>

<div class="card" style="max-width:95%;">
    <div style="margin-bottom:20px;">
        <a href="<%= request.getContextPath() %>/Ad/ad_add.jsp" class="btn">添加广告</a>
        <a href="<%= request.getContextPath() %>/Ad/index.jsp" class="btn btn-secondary" style="margin-left:8px;">前台查看</a>
    </div>

    <table class="table">
        <thead>
        <tr>
            <th>序号</th>
            <th>标题</th>
            <th>图片</th>
            <th>链接</th>
            <th>状态</th>
            <th>创建时间</th>
            <th>操作</th>
        </tr>
        </thead>

        <tbody>
        <%
            int i = 1;
            while (rs.next()) {
        %>
        <tr>
            <td><%= i++ %></td>
            <td><%= rs.getString("title") %></td>
            <td>
                <%
                    String img = rs.getString("img_path");
                    if (img != null && !img.trim().isEmpty()) {
                %>
                <img class="thumb" src="<%= request.getContextPath() + (img.startsWith("/") ? img : ("/" + img)) %>" />
                <% } else { %>无图片 <% } %>
            </td>

            <td style="word-break:break-all;max-width:250px;"><%= rs.getString("link") %></td>
            <td><%= rs.getInt("status") == 1 ? "显示" : "隐藏" %></td>
            <td><%= rs.getTimestamp("create_time") %></td>

            <td>
                <a class="op-btn" href="<%= request.getContextPath() %>/Ad/ad_update.jsp?aid=<%= rs.getInt("aid") %>">修改</a>
                <a class="op-btn op-del" href="<%= request.getContextPath() %>/Ad/ad_delete_do.jsp?aid=<%= rs.getInt("aid") %>" onclick="return confirm('确认删除？');">删除</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</body>
</html>

<%
    } finally {
        DBUtil.close(rs, pstmt, conn);
    }
%>
