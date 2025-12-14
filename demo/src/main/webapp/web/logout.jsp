<%@ page pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.example.demo1.DBUtil" %>
<html>
<head>
    <link rel="icon" href="logo.png" type="image/x-icon">
    <link rel="shortcut icon" href="logo.png" type="image/x-icon">

    <title>系统注销</title>
    <style>
        /* ---------------- 全局重置 & 基础风格 ---------------- */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100%;
            overflow-x: hidden;
        }

        body {
            font-family: "SF Pro Text", "Microsoft YaHei", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
            color: #e0e0e7;
            /* 首页色系：深色渐变背景 */
            background: linear-gradient(145deg, #2a2b36 0%, #31323F 50%, #25262e 100%),
            radial-gradient(circle at 50% 50%, rgba(100, 116, 139, 0.05) 0%, transparent 70%);
            overflow-y: auto;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            background-attachment: fixed;
            position: relative;
        }

        /* 背景光斑（首页色系调整） */
        body::before {
            content: '';
            position: fixed;
            top: 15%;
            left: 15%;
            width: 750px;
            height: 750px;
            background: radial-gradient(circle, rgba(100, 116, 139, 0.22), rgba(148, 163, 184, 0.12) 40%, transparent 70%);
            filter: blur(105px);
            z-index: 0;
        }

        body::after {
            content: '';
            position: fixed;
            bottom: 15%;
            right: 15%;
            width: 675px;
            height: 675px;
            background: radial-gradient(circle, rgba(148, 163, 184, 0.2), rgba(100, 116, 139, 0.1) 40%, transparent 70%);
            filter: blur(105px);
            z-index: 0;
        }

        /* 粒子画布 */
        #particle-canvas {
            position: fixed;
            inset: 0;
            z-index: 1;
            pointer-events: none;
        }

        /* 主容器 */
        .main-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px;
            position: relative;
            z-index: 2;
        }

        /* 登录/注册容器（保持原有尺寸，仅调色系） */
        .glass-card {
            width: 120%;
            max-width: 384px;
            border-radius: 27px;
            /* 首页色系：深色玻璃背景 */
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.05), rgba(255, 255, 255, 0.03));
            border: 2px solid rgba(100, 116, 139, 0.3); /* 首页色系边框 */
            box-shadow:
                    0 23px 53px rgba(4, 6, 22, 0.65),
                    0 12px 30px rgba(16, 10, 40, 0.45),
                    0 5px 12px rgba(100, 116, 139, 0.08) inset, /* 首页色系内阴影 */
                    0 0 0 2px rgba(100, 116, 139, 0.05); /* 首页色系描边 */
            backdrop-filter: blur(18px) saturate(1.2);
            overflow: hidden;
            position: relative;
            transition: all 0.3s ease;
        }

        /* 容器hover效果（色系调整） */
        .glass-card:hover {
            transform: scale(1.02);
            box-shadow:
                    0 30px 60px rgba(4, 6, 22, 0.7),
                    0 18px 38px rgba(16, 10, 40, 0.5),
                    0 5px 12px rgba(100, 116, 139, 0.1) inset, /* 首页色系内阴影 */
                    0 0 0 2px rgba(100, 116, 139, 0.08); /* 首页色系描边 */
        }

        /* 容器装饰光效（首页色系调整） */
        .glass-card::before {
            content: '';
            position: absolute;
            top: -105px;
            right: -105px;
            width: 330px;
            height: 330px;
            background: radial-gradient(circle, rgba(100, 116, 139, 0.25), transparent 70%); /* 首页色系 */
            filter: blur(60px);
            z-index: 1;
        }

        .glass-card::after {
            content: '';
            position: absolute;
            bottom: -105px;
            left: -105px;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(148, 163, 184, 0.22), transparent 70%); /* 首页色系 */
            filter: blur(60px);
            z-index: 1;
        }

        /* 内容区（保持原有尺寸） */
        .content-section {
            padding: 50px 25px;
            position: relative;
            z-index: 2;
            text-align: center;
        }

        /* 注销提示文字（首页色系调整） */
        .logout-title {
            font-size: 24px;
            font-weight: 700;
            color: #f8fafc; /* 首页浅色文字 */
            margin-bottom: 15px;
            letter-spacing: 0.5px;
        }

        .logout-desc {
            font-size: 16px;
            color: #cbd5e1; /* 首页浅灰蓝文字 */
            line-height: 1.5;
            margin-bottom: 30px;
        }

        /* 加载圈（首页色系调整） */
        .loader {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(100, 116, 139, 0.3); /* 首页色系边框 */
            border-top: 4px solid rgba(148, 163, 184, 0.8); /* 首页色系高亮 */
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 25px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* 响应式适配（保持原有尺寸，仅调色系） */
        @media (max-width: 480px) {
            .glass-card {
                max-width: 308px;
            }

            .logout-title {
                font-size: 20px;
            }

            .logout-desc {
                font-size: 14px;
            }

            .loader {
                width: 41px;
                height: 41px;
                border-width: 3px;
            }
        }
    </style>
</head>
<body>
<canvas id="particle-canvas"></canvas>
<div class="main-container">
    <div class="glass-card">
        <div class="content-section">
            <%
                String loginUser = (String) session.getAttribute("loginUser");
                if (loginUser != null) {
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    try {
                        conn = DBUtil.getConnection();
                        String sql = "DELETE FROM user WHERE username = ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, loginUser);
                        pstmt.executeUpdate();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        DBUtil.close(null, pstmt, conn);
                    }
                }
                session.invalidate();
            %>
            <div class="loader"></div>
            <h3 class="logout-title">您已成功注销，下次再见！</h3>
            <p class="logout-desc">2秒后自动返回登录页...</p>
            <meta http-equiv="refresh" content="2;url=login.jsp">
        </div>
    </div>
</div>

<!-- 粒子效果 JS（与首页一致） -->
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

        // 粒子类（首页色系调整）
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
                ctx.fillStyle = 'rgba(148, 163, 184, 0.6)'; // 首页色系粒子
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        // 粒子数组
        const particlesArray = [];
        const particleCount = Math.floor((canvas.width * canvas.height) / 18000);

        function initParticles() {
            particlesArray.length = 0;
            for (let i = 0; i < particleCount; i++) {
                particlesArray.push(new Particle());
            }
        }

        // 粒子连线（首页色系调整）
        function connectParticles() {
            for (let a = 0; a < particlesArray.length; a++) {
                for (let b = a; b < particlesArray.length; b++) {
                    const dx = particlesArray[a].x - particlesArray[b].x;
                    const dy = particlesArray[a].y - particlesArray[b].y;
                    const distance = Math.sqrt(dx * dx + dy * dy);

                    if (distance < 80) {
                        const opacity = 1 - (distance / 80);
                        ctx.strokeStyle = `rgba(148, 163, 184, ${opacity * 0.1})`; // 首页色系连线
                        ctx.lineWidth = 0.3;
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