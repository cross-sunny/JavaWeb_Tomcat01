package com.example.demo2;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = "/demo2/read", asyncSupported = true)
public class EchoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // ✅ 1. 设置请求编码为 UTF-8
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        if (req.isAsyncSupported()) {
            AsyncContext asyncContext = req.startAsync();
            asyncContext.setTimeout(10000);

            ServletInputStream inputStream = req.getInputStream();
            ServletReadListener listener = new ServletReadListener(asyncContext, inputStream);
            inputStream.setReadListener(listener);
        } else {
            resp.getWriter().println("异步不支持");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        this.doPost(req, resp);
    }

    private static class ServletReadListener implements ReadListener {
        private final AsyncContext asyncContext;
        private final ServletInputStream servletInputStream;
        private StringBuilder builder = new StringBuilder();

        public ServletReadListener(AsyncContext asyncContext, ServletInputStream servletInputStream) {
            this.asyncContext = asyncContext;
            this.servletInputStream = servletInputStream;
        }

        @Override
        public void onDataAvailable() throws IOException {
            byte[] buffer = new byte[1024];
            int len;

            try {
                HttpServletRequest request = (HttpServletRequest) asyncContext.getRequest();

                // ✅ 2. 优先使用标准方式获取参数（自动处理URL解码）
                String message = request.getParameter("message");
                if (message == null || message.isEmpty()) {
                    // 备用方案：手动读取并解码
                    while (servletInputStream.isReady() && (len = servletInputStream.read(buffer)) != -1) {
                        builder.append(new String(buffer, 0, len, StandardCharsets.UTF_8));
                    }

                    String rawData = builder.toString();
                    System.out.println("[DEBUG] 原始数据: " + rawData);

                    // ✅ 3. 智能解析表单数据：处理URL编码
                    if (rawData.contains("message=")) {
                        int start = rawData.indexOf("message=") + 8;
                        int end = rawData.indexOf("&", start);
                        if (end == -1) end = rawData.length();

                        String encodedMessage = rawData.substring(start, end);
                        message = URLDecoder.decode(encodedMessage, StandardCharsets.UTF_8.name());
                    } else {
                        message = "未解析到消息";
                    }
                }

                System.out.println("[DEBUG] 解码后的消息: " + message);

                // ✅ 4. 正确设置属性
                asyncContext.getRequest().setAttribute("message", message);
                asyncContext.dispatch("/demo2/echo.jsp");
            } catch (UnsupportedEncodingException e) {
                System.err.println("[ReadListener] 编码不支持: " + e.getMessage());
                asyncContext.getRequest().setAttribute("message", "编码错误");
                asyncContext.dispatch("/demo2/echo.jsp");
            } catch (Exception e) {
                System.err.println("[ReadListener] 数据读取失败: " + e.getMessage());
                asyncContext.complete();
            }
        }

        @Override
        public void onAllDataRead() {
            System.out.println("[ReadListener] 所有数据已读完");
        }

        @Override
        public void onError(Throwable throwable) {
            System.err.println("[ReadListener] 错误: " + throwable.getMessage());
            asyncContext.complete();
        }
    }
}