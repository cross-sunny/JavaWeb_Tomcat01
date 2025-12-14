<%@ page pageEncoding="UTF-8"
         isELIgnored="false"
         import="java.io.*,
                 jakarta.servlet.http.*,
                 java.nio.file.Paths,
                 java.sql.Connection,
                 java.sql.PreparedStatement,
                 java.sql.ResultSet,
                 java.util.*,
                 com.example.demo1.DBUtil" %>

<%
    // 登录验证
//    if (session.getAttribute("loginUser") == null) {
//        response.sendRedirect(request.getContextPath() + "/web/login.jsp?error=3");
//        return;
//    }

    String loginUsername = (String) session.getAttribute("loginUser");

    String message = null;
    String username = "";

    // 固定 uploads 目录
    String uploadPath = "D:\\code.html\\Day02\\demo\\src\\main\\webapp\\uploads";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    // 自动清理数据库中已不存在的文件
    try (Connection cleanConn = DBUtil.getConnection();
         PreparedStatement cleanSelect = cleanConn.prepareStatement(
                 "SELECT id, file_name FROM upload");
         ResultSet cleanRs = cleanSelect.executeQuery()) {

        while (cleanRs.next()) {
            int id = cleanRs.getInt("id");
            String name = cleanRs.getString("file_name");
            File f = new File(uploadPath, name);

            if (!f.exists()) {
                PreparedStatement del = cleanConn.prepareStatement("DELETE FROM upload WHERE id=?");
                del.setInt(1, id);
                del.executeUpdate();
                del.close();
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // 删除功能
    if ("GET".equalsIgnoreCase(request.getMethod()) && request.getParameter("deleteId") != null) {
        String deleteId = request.getParameter("deleteId");
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT username, file_name FROM upload WHERE id=?")) {

            ps.setString(1, deleteId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String uploader = rs.getString("username");
                String fileName = rs.getString("file_name");

                if (uploader.equals(loginUsername)) {
                    File f = new File(uploadPath, fileName);
                    if (f.exists()) f.delete();

                    PreparedStatement del = conn.prepareStatement("DELETE FROM upload WHERE id=?");
                    del.setString(1, deleteId);
                    del.executeUpdate();
                    del.close();
                }
            }

            rs.close();

        } catch (Exception e) { e.printStackTrace(); }

        response.sendRedirect("file_upload.jsp?successDelete=1");
        return;
    }

    // 上传功能
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            username = request.getParameter("username").trim();

            Part filePart = request.getPart("file");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            if (fileName.isEmpty()) throw new Exception("请选择文件");

            // 处理文件名重复问题，避免缓存冲突
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + File.separator + uniqueFileName);

            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "INSERT INTO upload (username, file_name, file_type) VALUES (?, ?, ?)")) {
                ps.setString(1, loginUsername);
                ps.setString(2, uniqueFileName); // 存储唯一文件名
                ps.setString(3, filePart.getContentType());
                ps.executeUpdate();
            }
            response.sendRedirect("file_upload.jsp?success=1");
            return;

        } catch (Exception e) {
            message = "错误：" + e.getMessage();
        }
    }

    // 获取文件列表
    List<Map<String, Object>> fileList = new ArrayList<>();
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(
                 "SELECT id, username, file_name, file_type, upload_time FROM upload ORDER BY upload_time DESC");
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            String fileName = rs.getString("file_name");
            File f = new File(uploadPath, fileName);

            if (!f.exists()) continue;

            Map<String, Object> m = new HashMap<>();
            m.put("id", rs.getInt("id"));
            m.put("uploader", rs.getString("username"));
            m.put("fileName", fileName);
            // 获取原始文件名（去掉时间戳前缀）
            String originalFileName = fileName.contains("_") ? fileName.substring(fileName.indexOf("_") + 1) : fileName;
            m.put("originalFileName", originalFileName);
            m.put("fileSize", f.length() / 1024);
            m.put("uploadTime", rs.getString("upload_time"));
            m.put("fileType", rs.getString("file_type"));
            fileList.add(m);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>文件上传</title>

    <style>
        /* ---------------- global reset ---------------- */
        *{margin:0;padding:0;box-sizing:border-box}
        html,body{height:100%; overflow-x:hidden}
        body{
            font-family: "SF Pro Text","Microsoft YaHei",system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
            color:#2b1f17;
            background: linear-gradient(180deg,#0f1023 0%, #101323 10%, rgba(12,10,20,0.8) 100%);
            overflow-y:auto;
            -webkit-font-smoothing:antialiased;
            -moz-osx-font-smoothing:grayscale;
            background-attachment: fixed;
        }

        /* ---------- particle canvas sits behind everything ---------- */
        #particle-canvas{
            position:fixed;
            inset:0;
            z-index:0;
            pointer-events:none;
        }

        /* ---------- page layout ---------- */
        .page-wrap{
            min-height:100vh;
            display:flex;
            align-items:flex-start;
            justify-content:center;
            padding:56px 20px;
            position:relative;
            z-index:2; /* above canvas */
        }

        /* ---------- glass card container (Apple-like minimal + neon accents) ---------- */
        .container{
            width:820px;
            max-width:96%;
            padding:44px;
            border-radius:20px;
            background: linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.03));
            border:1px solid rgba(255,255,255,0.06);
            box-shadow:
                    0 10px 30px rgba(4,6,22,0.6),
                    0 6px 18px rgba(16,10,40,0.4),
                    0 2px 6px rgba(255,160,100,0.03) inset;
            position:relative;
            overflow:hidden;
            backdrop-filter: blur(8px) saturate(1.05);
        }

        /* soft neon glow decoration */
        .container::before{
            content:'';
            position:absolute;
            width:420px;height:420px;
            right:-120px; top:-160px;
            background: radial-gradient(circle at 30% 30%, rgba(120,80,255,0.18), rgba(120,200,255,0.06) 35%, transparent 60%);
            transform:rotate(8deg);
            filter: blur(30px);
            pointer-events:none;
        }
        .container::after{
            content:'';
            position:absolute;
            width:320px;height:320px;
            left:-140px; bottom:-160px;
            background: radial-gradient(circle at 40% 40%, rgba(255,140,80,0.10), transparent 60%);
            filter:blur(30px);
            pointer-events:none;
        }

        /* ---------- header ---------- */
        .header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            gap:12px;
            margin-bottom:20px;
        }
        .title{
            color:#f5f5fb;
            font-size:22px;
            font-weight:700;
            letter-spacing:0.2px;
        }
        .top-buttons{ text-align:right; }
        .admin-btn{
            display:inline-flex;
            align-items:center;
            gap:8px;
            padding:8px 16px;
            background:rgba(255,255,255,0.04);
            color:#dfe7ff;
            border-radius:12px;
            font-weight:600;
            text-decoration:none;
            border:1px solid rgba(255,255,255,0.04);
            transition:transform .18s ease, background .18s ease;
        }
        .admin-btn:hover{ transform:translateY(-3px); background:linear-gradient(90deg, rgba(255,255,255,0.06), rgba(120,90,255,0.06)); }

        /* ---------- form layout ---------- */
        .form{
            margin-top:6px;
        }
        .form-group{ margin-bottom:20px; }
        label{
            display:block;
            margin-bottom:8px;
            color:rgba(255,255,255,0.85);
            font-size:13px;
            font-weight:600;
        }

        /* inputs - Google/Apple minimal feel */
        .form-control{
            width:100%;
            padding:12px 14px;
            border-radius:12px;
            border:1px solid rgba(255,255,255,0.06);
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            color:#f8f8ff;
            outline:none;
            transition:box-shadow .18s, border-color .18s, transform .12s;
            font-size:14px;
        }
        /* 移除用户名输入框的背景固定样式，恢复默认行为 */
        .form-control:focus{
            box-shadow:0 6px 20px rgba(80,60,200,0.14);
            border-color: rgba(120,90,255,0.55);
            transform:translateY(-1px);
        }

        /* ---------- file input wrapper (important: position:relative!) ---------- */
        .file-input-wrapper{
            position:relative; /* FIX: make absolute input confined here */
            padding:18px;
            border-radius:14px;
            border:2px dashed rgba(255,255,255,0.06);
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            color:#e6d8c8;
            text-align:center;
            cursor:pointer;
            transition:background .18s, border-color .18s, box-shadow .18s, transform .12s;
            user-select:none;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:12px;
            min-height:62px;
        }
        .file-input-wrapper:hover{
            border-color: rgba(120,90,255,0.28);
            transform: translateY(-2px);
            box-shadow: 0 8px 30px rgba(80,60,200,0.06);
        }

        /* hidden native input - confined to wrapper by position relative */
        #fileInput{
            position:absolute;
            inset:0;
            width:100%;
            height:100%;
            opacity:0;
            cursor:pointer;
            z-index:3;
        }

        /* show drag over state */
        .file-input-wrapper.dragover{
            border-color: rgba(80,200,255,0.8);
            background: linear-gradient(180deg, rgba(80,200,255,0.03), rgba(120,90,255,0.02));
            box-shadow: 0 12px 40px rgba(80,200,255,0.06), 0 8px 18px rgba(120,90,255,0.03);
        }

        /* file placeholder text */
        .file-placeholder{
            font-size:15px;
            color:rgba(235,230,230,0.95);
            display:inline-flex;
            align-items:center;
            gap:10px;
            max-width: 90%;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* small icon next to placeholder */
        .file-icon{
            width:36px;height:36px;border-radius:8px;
            background:linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01));
            display:inline-flex;align-items:center;justify-content:center;
            box-shadow: 0 6px 18px rgba(120,80,255,0.06);
        }

        /* ---------- buttons row ---------- */
        .actions{
            margin-top:16px;
            display:flex;
            gap:12px;
            align-items:center;
        }
        .btn{
            padding:10px 18px;
            border-radius:12px;
            font-weight:700;
            border:0;
            cursor:pointer;
            font-size:14px;
            transition:transform .14s, box-shadow .14s, opacity .12s, background .18s;
        }
        /* 上传按钮与背景贴合样式 */
        .btn-primary{
            background: linear-gradient(90deg, rgba(120,90,255,0.3), rgba(80,200,255,0.2));
            color:#e0e8ff;
            border:1px solid rgba(120,90,255,0.2);
            box-shadow: 0 10px 30px rgba(92,200,255,0.06), 0 6px 18px rgba(108,99,255,0.08);
        }
        .btn-primary:hover{
            transform:translateY(-3px);
            background: linear-gradient(90deg, rgba(120,90,255,0.4), rgba(80,200,255,0.3));
            box-shadow: 0 12px 36px rgba(92,200,255,0.08), 0 8px 20px rgba(108,99,255,0.1);
        }
        .btn-reset{
            background: rgba(255,255,255,0.03);
            color: #dfe7ff;
            border:1px solid rgba(255,255,255,0.03);
        }
        .btn-reset:hover{ transform:translateY(-2px); }

        /* ---------- progress bar (smooth) ---------- */
        .progress-wrap{
            width:100%;
            height:8px;
            background: rgba(255,255,255,0.03);
            border-radius:8px;
            overflow:hidden;
            margin-top:14px;
        }
        #uploadProgress{
            height:100%;
            width:0%;
            background: linear-gradient(90deg,#6c63ff,#5ec8ff);
            transition: width 0.25s linear;
        }

        /* ---------- file list ---------- */
        .file-list{ margin-top:28px; }
        .file-item{
            display:flex;
            gap:14px;
            align-items:center;
            justify-content:space-between;
            padding:14px;
            border-radius:12px;
            background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            border:1px solid rgba(255,255,255,0.03);
            box-shadow: 0 8px 22px rgba(16,12,40,0.5);
            margin-bottom:12px;
            /* 丝滑悬浮动效 */
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            transform: translateY(0);
        }
        /* 丝滑悬浮动效 */
        .file-item:hover{
            transform: translateY(-4px);
            background: linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.02));
            border-color: rgba(120,90,255,0.15);
            box-shadow: 0 12px 28px rgba(16,12,40,0.6), 0 4px 12px rgba(120,90,255,0.05);
        }
        .file-left{ display:flex; gap:12px; align-items:center; max-width:75%; }
        .ft-icon{
            width:44px;height:44px;border-radius:8px;
            display:flex;align-items:center;justify-content:center;
            background:linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            border:1px solid rgba(255,255,255,0.02);
            overflow: hidden;
            position: relative;
        }
        /* 文件预览样式 */
        .file-preview{
            width:100%;
            height:100%;
            object-fit: cover;
            display: block;
        }
        .file-icon-svg{
            width:22px;
            height:22px;
            fill:none;
        }
        .file-name{
            color:#e9e9ff;font-weight:700;font-size:15px;text-decoration:none; word-break:break-all;
        }
        .file-name:hover{
            color:#c4c8ff;
            text-decoration:underline;
            text-underline-offset: 2px;
        }
        .file-meta{ font-size:12px;color:rgba(255,255,255,0.65); margin-top:6px; }

        /* delete button */
        .delete-btn{
            padding:8px 14px;border-radius:10px;background:rgba(255,255,255,0.03);
            color:#ffd6c1;border:1px solid rgba(255,120,80,0.08);
            cursor:pointer; font-weight:700;
            transition: all 0.2s ease;
        }
        .delete-btn:hover{
            transform:scale(1.04);
            box-shadow:0 8px 20px rgba(255,100,60,0.06);
            background:rgba(255,120,80,0.08);
            border-color:rgba(255,120,80,0.15);
        }

        /* empty state */
        .empty-message{
            padding:18px;border-radius:12px;background:rgba(255,255,255,0.02);
            color:rgba(255,255,255,0.7);text-align:center;
        }

        /* toast */
        #successToast{
            position:fixed;left:50%;top:50%;
            transform:translate(-50%,-50%) scale(0.92);
            background:linear-gradient(90deg, rgba(255,255,255,0.04), rgba(255,255,255,0.02));
            color:#fff;padding:14px 22px;border-radius:12px;
            box-shadow:0 12px 36px rgba(92,60,200,0.18);opacity:0;transition:opacity .2s, transform .2s;z-index:9999;
        }

        /* responsive */
        @media (max-width:640px){
            .container{ padding:20px; border-radius:14px; }
            .title{ font-size:18px; }
            .file-placeholder{ font-size:14px; }
            .file-left{ max-width:65%; }
        }
    </style>
</head>

<body>
<canvas id="particle-canvas"></canvas>

<div class="page-wrap">
    <div class="container">

        <div class="header">
            <div class="title">文件上传</div>
            <div class="top-buttons">
                <a href="<%=request.getContextPath()%>/web/success.jsp" class="admin-btn">回到首页</a>
            </div>
        </div>

        <% if (message != null) { %>
        <div style="margin-bottom:18px;">
            <div class="file-item" style="background: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01)); border:1px solid rgba(255,255,255,0.04);">
                <div style="color:#ffe8d6;font-weight:700"><%= message %></div>
            </div>
        </div>
        <% } %>

        <form id="uploadForm" class="form" action="file_upload.jsp" method="post" enctype="multipart/form-data" novalidate>
            <div class="form-group">
                <label>用户名：</label>
                <input type="text" name="username" class="form-control" value="<%= username %>" required>
            </div>

            <div class="form-group">
                <label>选择文件：</label>
                <div id="fileBox" class="file-input-wrapper" aria-label="文件上传区域">
          <span class="file-placeholder">
            <span class="file-icon" id="placeholderIcon">
              <!-- small upload SVG -->
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M12 3v12" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M8 7l4-4 4 4" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M21 21H3" stroke="#fff" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </span>
            <span id="filePlaceholderText">点击或拖拽选择文件</span>
          </span>
                    <input id="fileInput" type="file" name="file" required>
                </div>
            </div>

            <div class="progress-wrap" aria-hidden="false">
                <div id="uploadProgress"></div>
            </div>

            <div class="actions">
                <button class="btn btn-primary" type="submit">上传文件</button>
                <button class="btn btn-reset" type="reset">重置</button>
            </div>
        </form>

        <hr style="margin:28px 0; border:none; border-top:1px solid rgba(255,255,255,0.03)">

        <h3 style="color: #e9e9ff; margin-bottom:12px;">已上传文件</h3>

        <div class="file-list">
            <% if (fileList.size() == 0) { %>
            <div class="empty-message">暂无文件</div>
            <% } else {
                for (Map<String,Object> f : fileList) {
                    String fileName = (String) f.get("fileName");
                    String originalFileName = (String) f.get("originalFileName");
                    String fileType = (String) f.get("fileType");
                    boolean isOwn = f.get("uploader").equals(loginUsername);
                    String fileExt = originalFileName.substring(originalFileName.lastIndexOf(".") + 1).toLowerCase();
            %>
            <div class="file-item">
                <div class="file-left">
                    <div class="ft-icon" id="icon-<%=fileName.hashCode()%>">
                        <%-- 图片文件显示预览（添加时间戳避免缓存） --%>
                        <% if (fileType != null && fileType.startsWith("image/")) { %>
                        <img src="<%=request.getContextPath()%>/uploads/<%=fileName%>?t=<%=System.currentTimeMillis()%>"
                             class="file-preview"
                             alt="<%=originalFileName%>"
                             onerror="this.style.display='none'; this.parentElement.innerHTML='<svg class=\'file-icon-svg\' viewBox=\'0 0 24 24\'><path d=\'M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z\' stroke=\'#fff\' stroke-width=\'1.2\' stroke-linecap=\'round\' stroke-linejoin=\'round\'/></svg>';">
                        <% } else { %>
                        <%-- 其他文件显示对应图标 --%>
                        <% if (Arrays.asList("pdf").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M20 2H8a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M16 13h-4v4h-4v-4H8v-4h4V8h4v4h4v4z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else if (Arrays.asList("doc", "docx").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M14 2v6h6M8 13h8M8 17h8" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else if (Arrays.asList("xls", "xlsx").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M8 10h8M8 14h8M8 18h8" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else if (Arrays.asList("ppt", "pptx").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M8 10h8M8 14h4M8 18h8" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else if (Arrays.asList("zip", "rar", "7z").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M12 12v6M16 12l-4 4-4-4M8 16h8" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else if (Arrays.asList("txt").contains(fileExt)) { %>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M16 13h-4v4h-4v-4H8v-4h4V8h4v4h4v4z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } else { %>
                        <%-- 默认文件图标 --%>
                        <svg class="file-icon-svg" viewBox="0 0 24 24">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6z" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M12 16v-6M15 13H9" stroke="#fff" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <% } %>
                        <% } %>
                    </div>

                    <div>
                        <a class="file-name" href="<%=request.getContextPath()%>/uploads/<%=fileName%>?t=<%=System.currentTimeMillis()%>" target="_blank"><%= originalFileName %></a>
                        <div class="file-meta">
                            上传人：<%= f.get("uploader") %>　
                            大小：<%= f.get("fileSize") %>KB　
                            时间：<%= f.get("uploadTime").toString().substring(0,16) %>
                        </div>
                    </div>
                </div>

                <% if (isOwn) { %>
                <div>
                    <button class="delete-btn" onclick="confirmDelete(<%=f.get("id")%>, '<%=originalFileName%>')">删除</button>
                </div>
                <% } %>
            </div>
            <% }} %>
        </div>

    </div>
</div>

<div id="successToast">✨ 上传成功！</div>

<script>
    // ========= 文件名显示 =========
    const fileInput = document.getElementById("fileInput");
    const filePlaceholderText = document.getElementById("filePlaceholderText");
    const uploadForm = document.getElementById("uploadForm");
    const uploadProgressBar = document.getElementById("uploadProgress");

    fileInput.addEventListener("change", function () {
        const f = fileInput.files[0];
        filePlaceholderText.innerText = f ? f.name : "点击或拖拽选择文件";
    });

    // ========= 拖拽文件处理 =========
    const fileWrapper = document.querySelector(".file-input-wrapper");

    fileWrapper.addEventListener("dragenter", e => {
        e.preventDefault();
        fileWrapper.classList.add("dragover");
    });

    fileWrapper.addEventListener("dragover", e => {
        e.preventDefault();
    });

    fileWrapper.addEventListener("dragleave", e => {
        e.preventDefault();
        fileWrapper.classList.remove("dragover");
    });

    fileWrapper.addEventListener("drop", e => {
        e.preventDefault();
        fileWrapper.classList.remove("dragover");

        const droppedFile = e.dataTransfer.files[0];
        if (droppedFile) {
            fileInput.files = e.dataTransfer.files;
            filePlaceholderText.innerText = droppedFile.name;
        }
    });

    // ========= 上传进度条动画 =========
    uploadForm.addEventListener("submit", () => {
        let progress = 0;
        const timer = setInterval(() => {
            progress += Math.random() * 12;
            if (progress >= 95) {
                clearInterval(timer);
                progress = 95;
            }
            uploadProgressBar.style.width = progress + "%";
        }, 120);
    });

    // ========= 重置 =========
    document.querySelector(".btn-reset").addEventListener("click", () => {
        uploadProgressBar.style.width = "0";
        setTimeout(() => {
            filePlaceholderText.innerText = "点击或拖拽选择文件";
        }, 150);
    });

    // ========= 删除确认 =========
    function confirmDelete(id, name) {
        if (confirm("确定删除 " + name + " 吗？")) {
            location.href = "file_upload.jsp?deleteId=" + id;
        }
    }
    window.confirmDelete = confirmDelete;

    // ========= 上传成功 Toast =========
    <% if ("1".equals(request.getParameter("success"))) { %>
    setTimeout(() => {
        const t = document.getElementById("successToast");
        t.style.opacity = "1";
        t.style.transform = "translate(-50%, -50%) scale(1)";
        setTimeout(() => { t.style.opacity = "0"; }, 1800);
    }, 200);
    <% } %>

    // ========= Cyberpunk 粒子背景 =========
    const canvas = document.getElementById("particle-canvas");
    const ctx = canvas.getContext("2d");
    let particles = [];

    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    resizeCanvas();
    window.addEventListener("resize", resizeCanvas);

    function createParticles() {
        particles = [];
        for (let i = 0; i < 50; i++) {
            particles.push({
                x: Math.random() * canvas.width,
                y: Math.random() * canvas.height,
                r: Math.random() * 2 + 1,
                dx: (Math.random() - 0.5) * 0.6,
                dy: (Math.random() - 0.5) * 0.6
            });
        }
    }
    createParticles();

    function animateParticles() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillStyle = "rgba(255,255,255,0.5)";

        particles.forEach(p => {
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fill();

            p.x += p.dx;
            p.y += p.dy;

            if (p.x < 0 || p.x > canvas.width) p.dx *= -1;
            if (p.y < 0 || p.y > canvas.height) p.dy *= -1;
        });

        requestAnimationFrame(animateParticles);
    }
    animateParticles();

    // ========= 图片预览加载优化 =========
    document.querySelectorAll('.file-preview').forEach(img => {
        img.style.opacity = '0';
        img.addEventListener('load', function() {
            this.style.transition = 'opacity 0.3s ease';
            this.style.opacity = '1';
        });
        // 强制触发加载
        if (img.complete) {
            img.style.opacity = '1';
        }
    });
</script>

</body>
</html>