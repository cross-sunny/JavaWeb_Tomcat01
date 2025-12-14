<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>过滤器结果展示</title>
    <style>
        body { font-family: "Microsoft YaHei"; margin: 40px; background: #f5f5f5; }
        .container { padding: 30px; background: white; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .attr { padding: 10px; background: #e3f2fd; margin: 10px 0; }
    </style>
</head>
<body>
<div class="container">
    <h1>✅ 过滤器 FORWARD 转发结果</h1>

    <div class="attr">
        <p><strong>Request 属性：</strong> <%= request.getAttribute("request-msg") %></p>
        <p><strong>Session 属性：</strong> <%= session.getAttribute("session-msg") %></p>
    </div>

    <p><a href="/demo/demo2/filter">返回测试页</a></p>
</div>
</body>
</html>