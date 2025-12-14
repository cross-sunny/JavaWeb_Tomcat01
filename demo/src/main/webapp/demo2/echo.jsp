<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>异步读取结果</title>
    <style>
        body { font-family: "Microsoft YaHei", sans-serif; margin: 40px; background: #f5f5f5; }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 30px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        .msg-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 0 5px 5px 0;
            font-size: 18px;
            line-height: 1.5;
        }
        .status-icon {
            color: #4caf50;
            font-size: 24px;
            margin-right: 8px;
        }
        .back-link {
            display: inline-block;
            margin-top: 20px;
            padding: 8px 16px;
            background: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            transition: background 0.3s;
        }
        .back-link:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
<div class="container">
    <h1 style="color: #1976d2; display: flex; align-items: center; margin-bottom: 25px;">
        <span class="status-icon">✓</span>
        <span>异步读取成功</span>
    </h1>

    <div class="msg-box">
        <p><strong>收到的消息：</strong></p>
        <p style="color: #212121; margin-top: 8px;">
            <%= request.getAttribute("message") == null ? "无消息" : request.getAttribute("message") %>
        </p>
    </div>

    <p style="color: #666; font-size: 14px; margin: 15px 0;">
        💡 提示：如果看到乱码，请检查服务器编码设置和表单提交方式
    </p>

    <!-- ✅ 修复路径：使用绝对路径 -->
    <a href="<%= request.getContextPath() %>/demo2/read-form.html" class="back-link">
        ← 返回发送页面
    </a>
</div>
</body>
</html>