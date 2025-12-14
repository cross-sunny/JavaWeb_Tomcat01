package com.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class EncodingFilter implements Filter {
    private static final String DEFAULT_CHARSET = "UTF-8";
    private String charset;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        this.charset = filterConfig.getInitParameter("charset");
        if (this.charset == null || this.charset.trim().isEmpty()) {
            this.charset = DEFAULT_CHARSET;
        }
        System.out.println("【编码过滤器】初始化成功！使用编码：" + this.charset);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // 1. 统一设置请求编码（所有请求都需要，包括静态资源）
        req.setCharacterEncoding(this.charset);
        // 2. 统一设置响应编码（所有响应都需要）
        resp.setCharacterEncoding(this.charset);

        // 3. 只给“文本类资源”设置Content-Type为text/html（避免影响图片/视频）
        String requestURI = req.getRequestURI().toLowerCase();
        // 定义静态资源后缀：图片、视频、CSS、JS等
        String[] staticSuffixes = {".png", ".jpg", ".jpeg", ".gif", ".mp4", ".mp3", ".css", ".js"};
        boolean isStaticResource = false;
        for (String suffix : staticSuffixes) {
            if (requestURI.endsWith(suffix)) {
                isStaticResource = true;
                break;
            }
        }
        // 非静态资源（JSP/HTML）才设置text/html
        if (!isStaticResource) {
            resp.setContentType("text/html;charset=" + this.charset);
        }

        // 4. 放行请求
        System.out.println("【编码过滤器】处理请求：" + requestURI + "（静态资源：" + isStaticResource + "）");
        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {
        System.out.println("【编码过滤器】已销毁！");
    }
}