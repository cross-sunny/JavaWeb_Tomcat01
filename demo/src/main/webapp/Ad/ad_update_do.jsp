<%@ page pageEncoding="UTF-8" import="java.sql.*, com.example.demo1.DBUtil, java.io.*, java.util.UUID" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    // 1. 配置两个目录：源码目录 + 部署目录 → 改为 ad_images
    String projectRoot = "D:\\code.html\\Day02\\demo"; // 你的项目根目录
    String srcUploadDir = projectRoot + "\\src\\main\\webapp\\uploads\\ad_images"; // ✅ 修改
    String deployUploadDir = application.getRealPath("/uploads/ad_images"); // ✅ 修改

    File srcDir = new File(srcUploadDir);
    if (!srcDir.exists()) srcDir.mkdirs();
    File deployDir = new File(deployUploadDir);
    if (!deployDir.exists()) deployDir.mkdirs();

    // 2. 获取表单参数
    int aid = 0;
    try {
        aid = Integer.parseInt(request.getParameter("aid"));
    } catch (Exception e) {
        out.println("<script>alert('参数错误！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
        return;
    }
    String title = request.getParameter("title");
    String link = request.getParameter("link");
    String status = request.getParameter("status");
    String oldImgPath = "";
    String newImgPath = "";

    // 3. 查询原图片路径
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
            oldImgPath = rs.getString("img_path");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('查询异常！');history.back();</script>");
        return;
    } finally {
        DBUtil.close(rs, pstmt, null);
    }

    // 4. 处理新上传的图片（字节流二次写入）
    Part imgPart = request.getPart("imgfile");
    if (imgPart != null && imgPart.getSize() > 0) {
        String originalFileName = imgPart.getSubmittedFileName();
        String ext = originalFileName.substring(originalFileName.lastIndexOf("."));
        String newFileName = UUID.randomUUID().toString() + ext;

        try {
            // 读取字节流（只读取一次）
            InputStream inputStream = imgPart.getInputStream();
            byte[] imgBytes = new byte[(int) imgPart.getSize()];
            inputStream.read(imgBytes);
            inputStream.close();

            // 写入源码目录
            String srcFilePath = srcUploadDir + File.separator + newFileName;
            OutputStream srcOut = new FileOutputStream(srcFilePath);
            srcOut.write(imgBytes);
            srcOut.flush();
            srcOut.close();

            // 写入部署目录
            String deployFilePath = deployUploadDir + File.separator + newFileName;
            OutputStream deployOut = new FileOutputStream(deployFilePath);
            deployOut.write(imgBytes);
            deployOut.flush();
            deployOut.close();

            // 验证保存成功
            File srcFile = new File(srcFilePath);
            File deployFile = new File(deployFilePath);
            if (!srcFile.exists() || !deployFile.exists() || srcFile.length() == 0) {
                out.println("<script>alert('图片更新失败！');history.back();</script>");
                return;
            }
            newImgPath = "/uploads/ad_images/" + newFileName; // ✅ 关键修改！

            // 删除旧图（两个目录都删除）
            if (oldImgPath != null && !oldImgPath.trim().isEmpty()) {
                // 源码目录旧图
                String srcOldFilePath = projectRoot + "\\src\\main\\webapp" + oldImgPath;
                File srcOldFile = new File(srcOldFilePath);
                if (srcOldFile.exists()) srcOldFile.delete();

                // 部署目录旧图
                String deployOldFilePath = application.getRealPath(oldImgPath);
                File deployOldFile = new File(deployOldFilePath);
                if (deployOldFile.exists()) deployOldFile.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('文件上传异常：" + e.getMessage() + "');history.back();</script>");
            return;
        }
    } else {
        newImgPath = oldImgPath; // 未上传新图，保留原图
    }

    // 5. 更新数据库
    try {
        String sql = "UPDATE ad SET title = ?, link = ?, img_path = ?, status = ? WHERE aid = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, link);
        pstmt.setString(3, newImgPath);
        pstmt.setInt(4, Integer.parseInt(status));
        pstmt.setInt(5, aid);

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('修改成功！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
        } else {
            out.println("<script>alert('修改失败！');history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('数据库异常：" + e.getMessage() + "');history.back();</script>");
    } finally {
        DBUtil.close(null, pstmt, conn);
    }
%>