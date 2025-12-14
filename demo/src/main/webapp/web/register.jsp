<%@ page pageEncoding="UTF-8" %>
<html>
<head>
  <link rel="icon" href="logo.png" type="image/png">
  <link rel="shortcut icon" href="logo.png" type="image/png">
  <title>用户注册</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
<canvas id="particle-canvas"></canvas>

<div class="main-container">
  <div class="glass-card">
    <div class="content-section">
      <div class="form-header">
        <h3 class="form-title">用户注册</h3>
        <p class="form-subtitle">填写以下信息，创建你的专属账户</p>
      </div>

      <%-- 错误提示 --%>
      <%
        String error = request.getParameter("error");
        if ("1".equals(error)) out.print("<p class='error-text'>密码和确认密码不一致！</p>");
        if ("2".equals(error)) out.print("<p class='error-text'>用户名已存在！</p>");
        if ("3".equals(error)) out.print("<p class='error-text'>注册失败，请重试！</p>");
      %>

      <%-- 注册表单 --%>
      <form method="post" action="${pageContext.request.contextPath}/user?action=register" novalidate>
        <%-- 用户名输入框 --%>
        <div class="input-group">
          <input type="text" name="username" required placeholder="用户名" autocomplete="off" maxlength="16">
        </div>

        <%-- 真实姓名输入框 --%>
        <div class="input-group">
          <input type="text" name="realname" required placeholder="真实姓名" autocomplete="off" maxlength="8">
        </div>

        <%-- 密码输入框（已移除眼睛图标） --%>
        <div class="input-group">
          <input type="password" name="password" required placeholder="密码" autocomplete="off" minlength="6" maxlength="16">
        </div>

        <%-- 确认密码输入框（已移除眼睛图标） --%>
        <div class="input-group">
          <input type="password" name="repassword" required placeholder="确认密码" autocomplete="off" minlength="6" maxlength="16">
        </div>

        <%-- 注册按钮（宽度50%，高度缩10%） --%>
        <div class="form-submit">
          <button type="submit" class="btn-primary">注册</button>
        </div>

        <%-- 底部登录链接 --%>
        <p class="footer-text">已有账号？<a href="login.jsp">立即登录</a></p>
      </form>
    </div>
  </div>
</div>

<%-- 粒子背景脚本 --%>
<script>
  const canvas = document.getElementById("particle-canvas");
  const ctx = canvas.getContext("2d");
  let particles = [];

  // 适配窗口大小
  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  // 创建粒子
  function createParticles() {
    particles = [];
    for (let i = 0; i < 80; i++) {
      const colors = [
        'rgba(120, 90, 255, 0.4)',
        'rgba(80, 200, 255, 0.35)',
        'rgba(150, 120, 255, 0.38)'
      ];
      particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        r: Math.random() * 4 + 1.5,
        dx: (Math.random() - 0.5) * 0.7,
        dy: (Math.random() - 0.5) * 0.7,
        color: colors[Math.floor(Math.random() * colors.length)]
      });
    }
  }
  createParticles();

  // 动画循环
  function animateParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = p.color;
      ctx.fill();

      // 粒子移动
      p.x += p.dx;
      p.y += p.dy;

      // 边界反弹
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