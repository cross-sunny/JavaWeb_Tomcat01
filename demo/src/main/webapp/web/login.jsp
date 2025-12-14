<%@ page pageEncoding="UTF-8" %>
<html>
<head>
  <%-- 匹配web目录下的logo.png --%>
  <%--  拉取测试 --%>
  <link rel="icon" href="${pageContext.request.contextPath}/web/logo.png" type="image/png">
  <link rel="shortcut icon" href="${pageContext.request.contextPath}/web/logo.png" type="image/png">
  <title>用户登录</title>
  <%-- 匹配web目录下的styles.css --%>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/web/styles.css">
</head>
<body>
<canvas id="particle-canvas"></canvas>
<%-- 匹配web目录下的styles.css --雷霆%>
<div class="main-container">
  <div class="glass-card">
    <div class="content-section">
      <div class="form-header">
        <h3 class="form-title">用户登录</h3>
        <p class="form-subtitle">输入账号密码，安全登录账户</p>
      </div>

      <%-- 错误/成功提示 --%>
      <%
        String error = request.getParameter("error");
        String registerSuccess = request.getParameter("registerSuccess");
        if ("1".equals(error)) out.print("<p class='error-text'>登录失败，请检查用户名或密码！</p>");
        if ("2".equals(error)) out.print("<p class='error-text'>数据库连接失败！</p>");
        if ("4".equals(error)) out.print("<p class='error-text'>验证码错误！</p>");
        if ("1".equals(registerSuccess)) out.print("<p class='success-text'>注册成功，请登录！</p>");
      %>

      <%-- 表单action匹配web目录下的check.jsp --%>
      <form method="post" action="${pageContext.request.contextPath}/web/check.jsp" novalidate>
        <div class="input-group">
          <input type="text" name="username" required placeholder="用户名" autocomplete="off">
        </div>

        <div class="input-group">
          <input type="password" name="password" required placeholder="密码" autocomplete="off">
        </div>

        <%-- 验证码图片匹配web目录下的captcha.jsp --%>
        <div class="code-row">
          <input type="text" name="verify" required placeholder="验证码" autocomplete="off" maxlength="4">
          <img src="${pageContext.request.contextPath}/web/captcha.jsp"
               onclick="this.src='${pageContext.request.contextPath}/web/captcha.jsp?'+Math.random()"
               class="captcha-img" alt="验证码" title="点击刷新">
        </div>

        <div class="form-submit">
          <button type="submit" class="btn-primary">登录</button>
        </div>

        <%-- 注册链接匹配web目录下的register.jsp --%>
        <p class="footer-text">没有账号？<a href="${pageContext.request.contextPath}/web/register.jsp">立即注册</a></p>
      </form>
    </div>
  </div>
</div>

<%-- 粒子背景脚本 --%>
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

  function animateParticles() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
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
