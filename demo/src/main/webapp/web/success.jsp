<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.example.demo1.DBUtil" %>
<html>
<head>
    <link rel="icon" href="logo.png" type="image/png">
    <link rel="shortcut icon" href="logo.png" type="image/png">
    <title>程序首页</title>
    <!-- 引入图标库 -->
    <link rel="stylesheet" href="https://cdn.bootcdn.net/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>

        /* ========== 新增：右上角“用户列表”按钮样式 ========== */
        .admin-panel {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 10;
        }
        .admin-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.6rem 1.2rem;
            background: rgba(49, 50, 63, 0.7);
            color: #cbd5e1;
            text-decoration: none;
            border-radius: 20px;
            font-size: 0.95rem;
            font-weight: 500;
            border: 1px solid rgba(100, 116, 139, 0.2);
            backdrop-filter: blur(4px);
            transition: all 0.3s ease;
        }
        .admin-btn:hover {
            background: rgba(54, 55, 70, 0.9);
            color: #f8fafc;
            transform: translateY(-2px);
        }
        .admin-btn i {
            margin-right: 6px;
            font-size: 1rem;
        }
        /* ========== 结束新增样式 ========== */
        /* 全局样式重置 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
        }

        /* 深色主题基础样式 */
        body {
            min-height: 100vh;
            background: linear-gradient(145deg, #2a2b36 0%, #31323F 50%, #25262e 100%);
            color: #e0e0e0;
            overflow-x: hidden;
            position: relative;
            background-attachment: fixed;
        }

        /* 粒子画布样式 */
        #particle-canvas {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 0;
            pointer-events: none;
        }

        /* 容器样式 */
        .container {
            position: relative;
            z-index: 1;
            max-width: 900px;
            margin: 0 auto;
            padding: 3rem 2rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
            backdrop-filter: blur(2px);
        }

        /* 标题样式 */
        h2 {
            font-size: 2.2rem;
            margin-bottom: 1rem;
            background: linear-gradient(90deg, #c8d8e4, #f0f4f8);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            position: relative;
            animation: fadeIn 1s ease-out;
            letter-spacing: 0.5px;
            font-weight: 600;
        }

        h2::after {
            content: '';
            position: absolute;
            bottom: -6px;
            left: 50%;
            transform: translateX(-50%);
            width: 70px;
            height: 2px;
            background: linear-gradient(90deg, #94a3b8, #cbd5e1);
            border-radius: 1px;
        }

        /* 错误提示样式 */
        .error-text {
            color: #f87171;
            font-size: 1.2rem;
            margin-bottom: 1rem;
            animation: shake 0.5s ease-in-out;
            padding: 1rem 2rem;
            background: rgba(75, 25, 25, 0.2);
            border-radius: 8px;
            border: 1px solid rgba(248, 113, 113, 0.2);
        }

        /* 模块提示文字 */
        .module-tip {
            font-size: 1.1rem;
            color: #a0aec0;
            margin: 1.5rem 0 2rem;
            letter-spacing: 0.3px;
            position: relative;
            padding-bottom: 0.8rem;
        }

        .module-tip::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 1px;
            background: rgba(160, 174, 192, 0.3);
        }

        /* 功能按钮容器 - 网格布局 */
        .btn-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 2rem;
            width: 100%;
            max-width: 450px;
        }

        /* 圆角正方形按钮样式 */
        .func-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding-top: 100%; /* 1:1正方形 */
            position: relative;
            text-decoration: none;
            border-radius: 14px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            overflow: hidden;
        }

        /* 按钮内部容器（核心：完全移除黑边） */
        .func-card-inner {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 0.8rem;
            background: #31323F; /* 纯深色背景，无渐变干扰 */
            border: 1px solid rgba(100, 116, 139, 0.2); /* 极浅边框，避免深色边缘 */
            border-radius: 14px;
            box-shadow: none; /* 彻底移除所有阴影 */
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* 功能图标 */
        .func-icon {
            font-size: 2.2rem;
            color: #e0e0e0;
            margin-bottom: 0.6rem;
            transition: all 0.4s ease;
            z-index: 2;
        }

        /* 常驻显示的功能文字 */
        .func-text {
            font-size: 0.95rem;
            color: #cbd5e1;
            font-weight: 500;
            z-index: 2;
            transition: color 0.3s ease;
        }

        /* 悬停时的额外提示 */
        .page-preview {
            position: absolute;
            bottom: -30px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.85rem;
            color: #a0aec0;
            background: rgba(30, 30, 40, 0.9);
            padding: 0.3rem 0.9rem;
            border-radius: 20px;
            border: 1px solid rgba(100, 116, 139, 0.4);
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
            backdrop-filter: blur(4px);
            z-index: 3;
            white-space: nowrap;
        }

        .page-preview i {
            font-size: 0.9rem;
        }

        /* 光效流动效果（不影响边缘） */
        .func-card-inner::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.08), transparent);
            transition: all 0.8s ease;
            z-index: 1;
        }

        /* 点击波纹效果 */
        .func-card-inner::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s ease, height 0.6s ease, opacity 0.6s ease;
            z-index: 1;
            opacity: 0;
        }

        /* 悬停效果（无阴影增强） */
        .func-card:hover {
            transform: translateY(-6px);
        }

        .func-card:hover .func-card-inner {
            background: #363746; /* 略浅深色，无渐变干扰 */
            border-color: rgba(125, 140, 160, 0.3); /* 边框略亮，无深色边缘 */
            box-shadow: none; /* 保持无阴影 */
        }

        .func-card:hover .func-icon {
            color: #f0f4f8;
            transform: scale(1.05);
        }

        .func-card:hover .func-text {
            color: #f8fafc;
        }

        .func-card:hover .page-preview {
            bottom: -26px;
            opacity: 1;
            visibility: visible;
        }

        .func-card:hover .func-card-inner::before {
            left: 100%;
        }

        /* 点击效果（无阴影变化） */
        .func-card:active .func-card-inner {
            transform: scale(0.98);
            box-shadow: none;
        }

        .func-card:active .func-card-inner::after {
            width: 300px;
            height: 300px;
            opacity: 1;
        }

        /* 动画效果 */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }

        /* 响应式调整 */
        @media (max-width: 768px) {
            .btn-container {
                gap: 1.8rem;
                max-width: 400px;
            }

            .func-icon {
                font-size: 2rem;
            }

            .func-text {
                font-size: 0.9rem;
            }

            h2 {
                font-size: 2rem;
            }
        }

        @media (max-width: 576px) {
            .btn-container {
                grid-template-columns: 1fr;
                gap: 2rem;
                max-width: 250px;
            }

            .container {
                padding: 2rem 1rem;
            }

            h2 {
                font-size: 1.7rem;
            }

            .func-icon {
                font-size: 2.1rem;
            }
        }
    </style>
</head>
<body>
<canvas id="particle-canvas"></canvas>

<%
    String loginUser = (String) session.getAttribute("loginUser");
    boolean isAdmin = "zjy".equals(loginUser);
%>
<div class="container">
    <% if (isAdmin) { %>
    <div class="admin-panel">
        <a href="<%= request.getContextPath() %>/web/admin_online.jsp" class="admin-btn">
            <i class="fas fa-users"></i>用户列表
        </a>
    </div>
    <% } %>

    <%
        String realName = "用户";
        if (loginUser == null) {
    %>
    <h3 class="error-text">非法用户，不允许进行程序访问！</h3>
    <p style="color:rgba(255,255,255,0.8);text-align:center;margin:10px 0 0;">2秒后自动返回登录页...</p>
    <meta http-equiv="refresh" content="2;url=login.jsp">
    <%
    } else {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT realname FROM user WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginUser);
            rs = pstmt.executeQuery();
            if (rs.next()) realName = rs.getString("realname");
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBUtil.close(rs, pstmt, conn); }
    %>
    <h2>欢迎访问，<%= realName %>！</h2>

    <p class="module-tip">请选择功能模块：</p>

    <!-- 按钮容器 - 2x2网格布局 -->
    <div class="btn-container">
        <!-- 广告展示 -->
        <a href="<%= request.getContextPath() + "/Ad/index.jsp" %>" class="func-card">
            <div class="func-card-inner">
                <i class="fas fa-bullhorn func-icon"></i>
                <span class="func-text">广告展示</span>
            </div>
        </a>

        <!-- 上传文件 -->
        <a href="<%= request.getContextPath() + "/work1/file_upload.jsp" %>" class="func-card">
            <div class="func-card-inner">
                <i class="fas fa-cloud-upload-alt func-icon"></i>
                <span class="func-text">上传文件</span>
            </div>
        </a>

        <!-- 退出登录 -->
        <a href="logout_only.jsp" class="func-card">
            <div class="func-card-inner">
                <i class="fas fa-sign-out-alt func-icon"></i>
                <span class="func-text">退出登录</span>
            </div>
        </a>

        <!-- 系统注销 -->
        <a href="logout.jsp" class="func-card">
            <div class="func-card-inner">
                <i class="fas fa-power-off func-icon"></i>
                <span class="func-text">系统注销</span>
            </div>
        </a>
    </div>
    <%
        }
    %>
</div>

<!-- 粒子效果 JS -->
<script>
    window.onload = function() {
        const canvas = document.getElementById('particle-canvas');
        const ctx = canvas.getContext('2d');

        // 设置canvas尺寸
        function resizeCanvas() {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
        }

        resizeCanvas();
        window.addEventListener('resize', resizeCanvas);

        // 粒子类
        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 1.5 + 0.5;
                this.speedX = Math.random() * 0.5 - 0.25;
                this.speedY = Math.random() * 0.5 - 0.25;
            }

            update() {
                this.x += this.speedX;
                this.y += this.speedY;

                if (this.x < 0) this.x = canvas.width;
                if (this.x > canvas.width) this.x = 0;
                if (this.y < 0) this.y = canvas.height;
                if (this.y > canvas.height) this.y = 0;
            }

            draw() {
                ctx.fillStyle = 'rgba(255, 255, 255, 0.8)';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        // 粒子数组
        const particlesArray = [];
        const particleCount = Math.floor((canvas.width * canvas.height) / 15000);

        function initParticles() {
            particlesArray.length = 0;
            for (let i = 0; i < particleCount; i++) {
                particlesArray.push(new Particle());
            }
        }

        // 粒子连线
        function connectParticles() {
            for (let a = 0; a < particlesArray.length; a++) {
                for (let b = a; b < particlesArray.length; b++) {
                    const dx = particlesArray[a].x - particlesArray[b].x;
                    const dy = particlesArray[a].y - particlesArray[b].y;
                    const distance = Math.sqrt(dx * dx + dy * dy);

                    if (distance < 100) {
                        const opacity = 1 - (distance / 100);
                        ctx.strokeStyle = `rgba(255, 255, 255, ${opacity * 0.2})`;
                        ctx.lineWidth = 0.5;
                        ctx.beginPath();
                        ctx.moveTo(particlesArray[a].x, particlesArray[a].y);
                        ctx.lineTo(particlesArray[b].x, particlesArray[b].y);
                        ctx.stroke();
                    }
                }
            }
        }

        // 动画循环
        function animateParticles() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            for (let i = 0; i < particlesArray.length; i++) {
                particlesArray[i].update();
                particlesArray[i].draw();
            }

            connectParticles();
            requestAnimationFrame(animateParticles);
        }

        // 初始化
        initParticles();
        animateParticles();

        window.addEventListener('resize', function() {
            resizeCanvas();
            initParticles();
        });
    };
</script>
</body>
</html>