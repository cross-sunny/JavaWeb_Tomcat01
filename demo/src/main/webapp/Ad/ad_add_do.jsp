<%@ page pageEncoding="UTF-8" import="java.sql.*, com.example.demo1.DBUtil, java.io.*, java.util.UUID" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("text/html;charset=UTF-8");

    // 1. 配置两个目录：源码目录 + 部署目录 → 改为 ad_images
    String projectRoot = "D:\\code.html\\Day02\\demo"; // 你的项目根目录
    String srcUploadDir = projectRoot + "\\src\\main\\webapp\\uploads\\ad_images";
    String deployUploadDir = application.getRealPath("/uploads/ad_images");

    // 自动创建目录
    File srcDir = new File(srcUploadDir);
    if (!srcDir.exists()) srcDir.mkdirs();
    File deployDir = new File(deployUploadDir);
    if (!deployDir.exists()) deployDir.mkdirs();

    // 2. 处理表单参数
    String title = request.getParameter("title");
    String link = request.getParameter("link");
    String status = request.getParameter("status");
    String imgPath = "";

    // 3. 处理文件上传（字节流二次写入）
    Part imgPart = request.getPart("imgfile");
    if (imgPart != null && imgPart.getSize() > 0) {
        String originalFileName = imgPart.getSubmittedFileName();
        String ext = originalFileName.substring(originalFileName.lastIndexOf("."));
        String newFileName = UUID.randomUUID().toString() + ext;

        try {
            // 读取字节流（只读一次）
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
            if (srcFile.exists() && deployFile.exists() && srcFile.length() > 0) {
                imgPath = "/uploads/ad_images/" + newFileName; // ✅ 关键修改！
            } else {
                out.println("<script>alert('图片保存失败！');history.back();</script>");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('上传异常：" + e.getMessage() + "');history.back();</script>");
            return;
        }
    }

    // 4. 插入数据库
    Connection conn = null;
    PreparedStatement pstmt = null;
    try {
        conn = DBUtil.getConnection();
        String sql = "INSERT INTO ad (title, link, img_path, status, create_time) VALUES (?, ?, ?, ?, NOW())";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, title);
        pstmt.setString(2, link);
        pstmt.setString(3, imgPath);
        pstmt.setInt(4, Integer.parseInt(status));

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('添加成功！');location.href='" + request.getContextPath() + "/Ad/ad_list.jsp';</script>");
        } else {
            out.println("<script>alert('添加失败！');history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('数据库异常：" + e.getMessage() + "');history.back();</script>");
    } finally {
        DBUtil.close(null, pstmt, conn);
    }
%>