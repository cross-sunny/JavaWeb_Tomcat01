<%@ page pageEncoding="UTF-8"
         isELIgnored="false"
         import="java.io.*,
                 java.nio.file.Files,
                 java.nio.file.Paths" %>
<%
    // 已替换为你的绝对路径（无需再修改）
    String UPLOAD_DIR = "D:\\code.html\\Day02\\demo\\src\\main\\webapp\\uploads";

    // 获取要查看的文件名
    String fileName = request.getParameter("name");
    if (fileName == null || fileName.trim().isEmpty()) {
        out.println("<div style='padding:20px; color:red;'>错误：未指定文件名！</div>");
        return;
    }

    // 安全处理文件名（防止路径注入，只保留文件名）
    fileName = Paths.get(fileName).getFileName().toString();

    // 拼接文件绝对路径（直接指向项目源码中的 uploads 目录）
    String filePath = UPLOAD_DIR + File.separator + fileName;
    File file = new File(filePath);

    // 验证文件是否存在（本地看不到文件时，会提示这里）
    if (!file.exists() || !file.isFile()) {
        out.println("<div style='padding:20px; color:red;'>");
        out.println("错误：文件不存在！<br>");
        out.println("实际查找路径：" + filePath + "<br>");
        out.println("请检查路径是否正确，或文件是否已上传成功。");
        out.println("</div>");
        return;
    }

    // 获取文件MIME类型（用于判断文件类型）
    String mimeType = Files.probeContentType(file.toPath());
    if (mimeType == null) {
        mimeType = "application/octet-stream"; // 默认二进制类型
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>查看文件：<%= fileName %></title>
    <style>
        body { padding: 20px; font-family: sans-serif; }
        .file-info { color: #666; margin: 10px 0; }
        .file-content { margin-top: 20px; border: 1px solid #eee; padding: 20px; border-radius: 8px; }
        img { max-width: 100%; height: auto; border-radius: 4px; }
        video { max-width: 100%; height: auto; border-radius: 4px; }
        pre { white-space: pre-wrap; word-wrap: break-word; line-height: 1.6; color: #333; }
        a.download-btn { display: inline-block; padding: 8px 16px; background: #007bff; color: white; text-decoration: none; border-radius: 4px; margin-top: 10px; }
        a.download-btn:hover { background: #0056b3; }
    </style>
</head>
<body>
<h2>文件详情：<%= fileName %></h2>
<div class="file-info">
    大小：<%= file.length() / 1024 %> KB |
    类型：<%= mimeType %> |
    本地路径：<%= filePath %>
</div>

<div class="file-content">
    <%
        // 根据MIME类型展示不同内容（核心：图片/视频均用字节流输出，避免路径问题）
        if (mimeType.startsWith("image/")) {
            // 图片类型：直接输出字节流到浏览器（最稳定）
            response.setContentType(mimeType); // 设置响应类型为图片
            response.setContentLength((int) file.length()); // 设置文件大小
            FileInputStream fis = null;
            OutputStream os = null;
            try {
                fis = new FileInputStream(file);
                os = response.getOutputStream();
                byte[] buffer = new byte[4096]; // 4KB缓冲区，高效传输
                int len;
                while ((len = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, len); // 逐段输出字节流
                }
                os.flush(); // 确保所有字节输出完成
            } catch (Exception e) {
                out.println("<div style='color:red;'>错误：图片加载失败！原因：" + e.getMessage() + "</div>");
            } finally {
                if (fis != null) fis.close();
                if (os != null) os.close();
            }
            return; // 输出字节流后，直接结束页面，避免多余HTML
        } else if (mimeType.startsWith("text/") || mimeType.endsWith("markdown")) {
            // 文本类型（TXT、MD等）：展示文本内容
            try {
                BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));
                String line;
                out.println("<pre>");
                while ((line = br.readLine()) != null) {
                    out.println(line); // 用pre标签保留格式
                }
                br.close();
                out.println("</pre>");
            } catch (Exception e) {
                out.println("<div style='color:red;'>错误：文本读取失败！原因：" + e.getMessage() + "</div>");
            }
        } else if (mimeType.startsWith("video/")) {
            // 视频类型：字节流输出，支持浏览器预览（解决无法播放问题）
            response.setContentType(mimeType); // 设置视频MIME类型（如video/mp4）
            response.setHeader("Content-Length", String.valueOf(file.length())); // 告诉浏览器文件大小
            response.setHeader("Accept-Ranges", "bytes"); // 支持断点续传，优化播放体验

            FileInputStream fis = null;
            OutputStream os = null;
            try {
                fis = new FileInputStream(file);
                os = response.getOutputStream();
                byte[] buffer = new byte[8192]; // 8KB缓冲区，适合视频传输
                int len;
                while ((len = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                    os.flush(); // 实时输出，避免卡顿
                }
            } catch (Exception e) {
                out.println("<div style='color:red;'>错误：视频加载失败！原因：" + e.getMessage() + "</div>");
            } finally {
                if (fis != null) fis.close();
                if (os != null) os.close();
            }
            return; // 输出视频流后结束页面，避免多余HTML
        } else {
            // 其他类型：提供下载链接
    %>
    <p>该文件类型不支持在线查看，建议下载后打开：</p>
    <a href="<%= request.getContextPath() + "/uploads/" + fileName %>" download="<%= fileName %>" class="download-btn">
        下载 <%= fileName %>
    </a>
    <%
        }
    %>
</div>
</body>
</html>