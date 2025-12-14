<%@ page pageEncoding="UTF-8" import="java.sql.*,com.example.demo1.DBUtil" %>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT aid,title,link,img_path FROM ad WHERE status=1 ORDER BY create_time DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>广告主页</title>

    <style>
        /* ===== 背景更有质感（分层渐变 + 轻颗粒噪声） ===== */
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            color: #fff;

            background:
                    radial-gradient(circle at top left, rgba(255,255,255,0.08), transparent 60%),
                    radial-gradient(circle at bottom right, rgba(255,255,255,0.06), transparent 70%),
                    linear-gradient(135deg, #352C50 0%, #5D4A80 100%);
            position: relative;
        }

        /* 覆盖噪点纹理（让背景更高级） */
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background: url('https://grainy-gradients.vercel.app/noise.svg');
            opacity: 0.15;
            pointer-events: none;
        }

        /* ===== 顶部按钮区域 ===== */
        .top-bar {
            display: flex;
            flex-direction: column;   /* 垂直排列 */
            align-items: flex-end;    /* 按钮依然靠右 */
            gap: 12px;                /* 按钮之间的间隔 */
            padding: 20px 40px;
        }


        .admin-btn {
            padding: 10px 22px;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.25);
            border-radius: 25px;
            color: #fff;
            font-size: 16px;
            text-decoration: none;
            transition: 0.3s;
            backdrop-filter: blur(8px);
        }

        .admin-btn:hover {
            background: rgba(255,255,255,0.25);
            box-shadow: 0 0 12px rgba(255,255,255,0.4);
        }

        /* ===== 轮播容器（更丝滑玻璃效果） ===== */
        .carousel-container {
            width: 80%;
            max-width: 850px;
            height: 430px;
            margin: 10px auto;
            border-radius: 22px;
            overflow: hidden;
            position: relative;

            background: rgba(255,255,255,0.08);
            backdrop-filter: blur(16px);
            border: 2px solid rgba(255,255,255,0.25);
            box-shadow: 0 0 25px rgba(0,0,0,0.3);
        }

        /* ===== 每一张轮播图：淡入淡出动画 ===== */
        .slide {
            width: 100%;
            height: 100%;
            opacity: 0;
            position: absolute;
            transition: opacity 1s ease-in-out;
        }

        .slide.show {
            opacity: 1;
            z-index: 5;
        }

        .slide img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* 左右箭头 */
        .arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            font-size: 48px;
            color: #fff;
            cursor: pointer;
            padding: 12px;
            opacity: 0.7;
            user-select: none;
            transition: 0.2s;
            z-index: 20;
        }
        #prev { left: 10px; }
        #next { right: 10px; }
        .arrow:hover { opacity: 1; transform: translateY(-50%) scale(1.1); }

        /* 小圆点 */
        .dots {
            text-align: center;
            margin-top: 10px;
        }
        .dots span {
            display: inline-block;
            width: 12px;
            height: 12px;
            margin: 4px;
            border-radius: 50%;
            background: rgba(255,255,255,0.4);
            cursor: pointer;
            transition: 0.3s;
        }
        .dots .active {
            background: #fff;
            transform: scale(1.3);
        }

        /* ===== 下半部分透明内容卡片 ===== */
        .info-box {
            width: 80%;
            max-width: 900px;
            margin: 40px auto 80px;
            padding: 28px 32px;

            background: rgba(255,255,255,0.08);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(255,255,255,0.28);
            border-radius: 22px;

            font-size: 18px;
            line-height: 1.8;
            box-shadow: 0 0 20px rgba(0,0,0,0.25);
        }
        .info-text {
            text-align: center;
        }
        .info-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 15px;
            text-align: center;
        }
    </style>
</head>

<body>

<!-- 顶部按钮 -->
<div class="top-bar">
    <!-- 回到首页按钮 -->
    <a href="<%= request.getContextPath() %>/web/success.jsp" class="admin-btn">
        回到首页
    </a>

    <!-- 后台管理按钮 -->
    <a href="<%= request.getContextPath() %>/Ad/ad_list.jsp" class="admin-btn">
        后台管理
    </a>

</div>


<!-- ===== 轮播图区域 ===== -->
<div class="carousel-container" id="carousel">
    <%
        int index = 0;
        while (rs.next()) {
            String img = rs.getString("img_path");
            String link = rs.getString("link");
    %>

    <a href="<%= link %>" target="_blank"
       class="slide <%= index==0 ? "show" : "" %>">
        <img src="<%= request.getContextPath() + (img.startsWith("/") ? img : ("/" + img)) %>">
    </a>

    <% index++; } %>
</div>

<!-- 左右切换箭头 -->
<div id="prev" class="arrow">&#10094;</div>
<div id="next" class="arrow">&#10095;</div>

<!-- 小圆点 -->
<div class="dots" id="dots"></div>

<!-- ===== 下半部分透明面板 ===== -->
<div class="info-box">
    <div class="info-title">欢迎来到广告展示系统</div>
    <div class="info-text">
        本系统用于展示后台上传的广告内容，支持自动播放、手动切换以及点击跳转。
        <br><br>
        您可以点击右上角“后台管理”进入管理界面，在那里可以添加、修改、删除广告。
    </div>
</div>

<!-- ===== JavaScript 控制轮播（加入淡入淡出） ===== -->
<script>
    let slides = document.querySelectorAll(".slide");
    let dotsContainer = document.getElementById("dots");

    slides.forEach((s, i) => {
        let d = document.createElement("span");
        d.onclick = () => showSlide(i);
        dotsContainer.appendChild(d);
    });

    let dots = dotsContainer.querySelectorAll("span");
    let current = 0;
    showSlide(0);

    function showSlide(n) {
        slides.forEach(s => s.classList.remove("show"));
        dots.forEach(d => d.classList.remove("active"));

        slides[n].classList.add("show");
        dots[n].classList.add("active");
        current = n;
    }

    document.getElementById("next").onclick = () => {
        current = (current + 1) % slides.length;
        showSlide(current);
    };

    document.getElementById("prev").onclick = () => {
        current = (current - 1 + slides.length) % slides.length;
        showSlide(current);
    };

    // 自动轮播
    setInterval(() => {
        current = (current + 1) % slides.length;
        showSlide(current);
    }, 3500);
</script>

</body>
</html>

<%
    } finally {
        DBUtil.close(rs, pstmt, conn);
    }
%>
