<%@ page pageEncoding="UTF-8" import="java.sql.*, com.example.demo1.DBUtil" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    int aid = 0;
    try {
        aid = Integer.parseInt(request.getParameter("aid"));
    } catch (Exception e) {
        out.println("<script>alert('参数错误！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
        return;
    }

    // 查询广告信息
    String title = "", link = "", imgPath = "", status = "1";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT title, link, img_path, status FROM ad WHERE aid = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, aid);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            title = rs.getString("title");
            link = rs.getString("link");
            imgPath = rs.getString("img_path");
            status = String.valueOf(rs.getInt("status"));
        } else {
            out.println("<script>alert('未找到广告！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('查询异常！');history.back();</script>");
        return;
    } finally {
        DBUtil.close(rs, pstmt, conn);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>修改广告</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        /* 限制当前图片大小，保持比例不变 */
        .thumb {
            max-width: 300px; /* 最大宽度300px（可根据需求调整） */
            max-height: 200px; /* 最大高度200px（可根据需求调整） */
            width: auto; /* 自动适应宽度，保持比例 */
            height: auto; /* 自动适应高度，保持比例 */
            border: 1px solid #eee; /* 可选：添加轻微边框，更美观 */
            border-radius: 4px; /* 可选：圆角效果 */
            padding: 5px; /* 可选：内边距，避免图片贴边框 */
        }
    </style>
</head>
<body>
<div class="card">
    <h3>修改广告</h3>
    <form action="<%= request.getContextPath() %>/Ad/ad_update_do.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="aid" value="<%= aid %>" />
        <div class="input-group">
            <label>广告标题</label>
            <input type="text" name="title" value="<%= title %>" required />
        </div>
        <div class="input-group">
            <label>跳转链接</label>
            <input type="text" name="link" value="<%= link %>" />
        </div>
        <div class="input-group">
            <label>当前图片</label><br/>
            <% if (imgPath != null && !imgPath.trim().isEmpty()) { %>
            <img src="<%= request.getContextPath() + imgPath %>" class="thumb" style="margin-bottom:8px;" alt="广告图" />
            <% } else { %>无图片<br/><% } %>
            <label>重新上传图片（不选则保留原图）</label>
            <input type="file" name="imgfile" accept="image/*" />
        </div>
        <div class="input-group">
            <label>是否显示</label>
            <select name="status">
                <option value="1" <%= "1".equals(status) ? "selected" : "" %>>显示</option>
                <option value="0" <%= "0".equals(status) ? "selected" : "" %>>隐藏</option>
            </select>
        </div>
        <button type="submit" class="btn">保存</button>
        <a href="<%= request.getContextPath() %>/Ad/ad_list.jsp" class="btn btn-secondary" style="margin-left:10px;">返回</a>
    </form>
</div>
</body>
</html>