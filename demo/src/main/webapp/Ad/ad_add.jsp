<%@ page pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>添加广告</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<div class="card">
    <h3>添加广告</h3>
    <!-- 关键：表单必须加 enctype="multipart/form-data"，action 指向处理页 -->
    <form action="<%= request.getContextPath() %>/Ad/ad_add_do.jsp" method="post" enctype="multipart/form-data">
        <div class="input-group">
            <label>广告标题</label>
            <input type="text" name="title" required />
        </div>
        <div class="input-group">
            <label>跳转链接（可选）</label>
            <input type="text" name="link" placeholder="http://..." />
        </div>
        <div class="input-group">
            <label>广告图片</label>
            <input type="file" name="imgfile" accept="image/*" required />
        </div>
        <div class="input-group">
            <label>是否显示</label>
            <select name="status">
                <option value="1" selected>显示</option>
                <option value="0">隐藏</option>
            </select>
        </div>
        <button type="submit" class="btn">提交</button>
        <a href="<%= request.getContextPath() %>/Ad/ad_list.jsp" class="btn btn-secondary" style="margin-left:10px;">返回</a>
    </form>
</div>
</body>
</html>