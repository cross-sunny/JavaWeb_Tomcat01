<%@ page language="java" import="java.util.*,java.awt.*,java.awt.image.*,javax.imageio.*" pageEncoding="UTF-8"%>
<%
    // 禁止缓存
    response.setHeader("Pragma", "No-cache");
    response.setHeader("Cache-Control", "no-cache");
    response.setDateHeader("Expires", 0);
    response.setContentType("image/jpeg");

    // 验证码基本参数
    int width = 120;
    int height = 40;
    int codeCount = 4;
    char[] codeSequence = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".toCharArray();

    // 生成图像缓冲区
    BufferedImage buffImg = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    Graphics2D g = buffImg.createGraphics();

    Random random = new Random();

    // 背景渐变 + 颜色
    g.setColor(new Color(230, 230, 255));
    g.fillRect(0, 0, width, height);

    // 字体
    g.setFont(new Font("Arial", Font.BOLD, 28));

    // 干扰线
    for (int i = 0; i < 6; i++) {
        g.setColor(new Color(random.nextInt(200), random.nextInt(200), random.nextInt(200)));
        g.drawLine(random.nextInt(width), random.nextInt(height), random.nextInt(width), random.nextInt(height));
    }

    // 随机验证码文本
    StringBuilder randomCode = new StringBuilder();
    for (int i = 0; i < codeCount; i++) {
        String str = String.valueOf(codeSequence[random.nextInt(codeSequence.length)]);
        randomCode.append(str);

        // 字体颜色随机，略微扰动
        g.setColor(new Color(50 + random.nextInt(150), 50 + random.nextInt(150), 50 + random.nextInt(150)));
        int x = 20 + i * 22;
        int y = 30 + random.nextInt(5);
        g.drawString(str, x, y);
    }

    // 保存验证码到 session
    session.setAttribute("captcha", randomCode.toString().toLowerCase());

    g.dispose();

    // 输出图片
    ImageIO.write(buffImg, "jpeg", response.getOutputStream());
%>