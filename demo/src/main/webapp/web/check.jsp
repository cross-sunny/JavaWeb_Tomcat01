<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.example.demo1.DBUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<html>
<head>
  <%-- 修复静态资源路径：使用绝对路径确保样式加载 --%>
  <link rel="icon" href="${pageContext.request.contextPath}/web/logo.png" type="image/png">
  <link rel="shortcut icon" href="${pageContext.request.contextPath}/web/logo.png" type="image/png">
  <title>登录验证</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/web/styles.css">
</head>
<body>
<canvas id="particle-canvas"></canvas>

<div class="main-container">
  <div class="glass-card">
    <div class="verify-container">
      <%
        // ===================== 核心逻辑：登录验证 + 剔除功能初始化 =====================
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String inputCode = request.getParameter("verify");
        String realCode = (String) session.getAttribute("captcha");
        boolean loginSuccess = false;

        // 1. 验证码校验
        if (realCode == null || inputCode == null || !realCode.equals(inputCode.toLowerCase())) {
          response.sendRedirect("${pageContext.request.contextPath}/web/login.jsp?error=4");
          return;
        }

        // 2. 数据库校验（真实业务逻辑）
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
          conn = DBUtil.getConnection();
          String sql = "SELECT * FROM user WHERE username = ? AND password = ?";
          pstmt = conn.prepareStatement(sql);
          pstmt.setString(1, username);
          pstmt.setString(2, password);
          rs = pstmt.executeQuery();

          if (rs.next()) {
            loginSuccess = true;
            // 保存登录用户标识（供Filter判断）
            session.setAttribute("loginUser", username);
            // 额外：管理员标识（如果需要区分管理员）
            if ("admin".equals(username) || "zjy".equals(username)) {
              session.setAttribute("admin", username);
            }
          }
        } catch (SQLException e) {
          e.printStackTrace();
          response.sendRedirect("${pageContext.request.contextPath}/web/login.jsp?error=2");
          return;
        } finally {
          DBUtil.close(rs, pstmt, conn);
        }

        // 3. 登录成功：初始化在线用户列表（剔除功能核心）
        if (loginSuccess) {
          String ONLINE_USERS = "onlineUsers";
          Map<String, Boolean> onlineUsers = (Map<String, Boolean>) application.getAttribute(ONLINE_USERS);

          // 初始化在线用户Map（线程安全，替换HashMap为ConcurrentHashMap更佳）
          if (onlineUsers == null) {
            onlineUsers = new HashMap<>(); // 若需多线程安全可改为：new java.util.concurrent.ConcurrentHashMap<>();
            application.setAttribute(ONLINE_USERS, onlineUsers);
          }

          // 设置用户默认状态：未被剔除（false）
          onlineUsers.put(username, false);
          System.out.println("【登录成功】用户 " + username + " 加入在线列表，剔除状态：未剔除");
        }
        // ===================== 核心逻辑结束 =====================
      %>

      <%-- 登录成功：显示美化提示 + 跳转成功页 --%>
      <% if (loginSuccess) { %>
      <div class="loader"></div>
      <h3 class="success-text">登录成功，欢迎光临！</h3>
      <meta http-equiv="refresh" content="1.5;url=${pageContext.request.contextPath}/web/success.jsp">
      <% } else { %>
      <%-- 登录失败：显示美化提示 + 跳转登录页 --%>
      <div class="loader error"></div>
      <h3 class="error-text">登录失败，请重新登录！</h3>
      <meta http-equiv="refresh" content="1.5;url=${pageContext.request.contextPath}/web/login.jsp?error=1">
      <% } %>
    </div>
  </div>
</div>

<%-- 粒子背景脚本（保留原有美化效果） --%>
<script>
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
    for (let i = 0; i < 80; i++) {
      const colors = [
        'rgba(120, 90, 255, 0.4)',
        'rgba(80, 200, 255, 0.35)',
        'rgba(150, 120, 255, 0.38)'
      ];
      particles.push({
        x: window.Math.random() * canvas.width,
        y: window.Math.random() * canvas.height,
        r: window.Math.random() * 4 + 1.5,
        dx: (window.Math.random() - 0.5) * 0.7,
        dy: (window.Math.random() - 0.5) * 0.7,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  }
  createParticles();

  function animateParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, window.Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.fill();

      p.x += p.dx;
      p.y += p.dy;

      if (p.x < 0 || p.x > canvas.width) p.dx *= -1;
      if (p.y < 0 || p.y > canvas.height) p.dy *= -0.95;
      p.dy += 0.02;
    });

    requestAnimationFrame(animateParticles);
  }
  animateParticles();
</script>
</body>
</html>