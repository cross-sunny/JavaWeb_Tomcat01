<%@ page pageEncoding="UTF-8" import="java.sql.*, com.example.demo1.DBUtil, java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    int aid = Integer.parseInt(request.getParameter("aid"));
    String imgPath = "";
    String projectRoot = "D:\\code.html\\Day02\\demo"; // 你的项目根目录

    // 1. 查询原图片路径
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT img_path FROM ad WHERE aid = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, aid);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            imgPath = rs.getString("img_path");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        DBUtil.close(rs, pstmt, null);
    }

    // 2. 删除数据库记录
    try {
        String sql = "DELETE FROM ad WHERE aid = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, aid);
        int rows = pstmt.executeUpdate();

        if (rows > 0) {
            // 同时删除两个目录的图片
            if (imgPath != null && !imgPath.trim().isEmpty()) {
                // 源码目录
                String srcFilePath = projectRoot + "\\src\\main\\webapp" + imgPath;
                File srcFile = new File(srcFilePath);
                if (srcFile.exists()) srcFile.delete();

                // 部署目录
                String deployFilePath = application.getRealPath(imgPath);
                File deployFile = new File(deployFilePath);
                if (deployFile.exists()) deployFile.delete();
            }
            out.println("<script>alert('删除成功！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
        } else {
            out.println("<script>alert('删除失败！');history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('删除异常：" + e.getMessage() + "');history.back();</script>");
    } finally {
        DBUtil.close(null, pstmt, conn);
    }
%>