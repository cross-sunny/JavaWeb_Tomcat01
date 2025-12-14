package com.example.demo2;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

/**
 * 基础过滤器：演示如何在 FORWARD 转发中接收属性
 * 通过 @WebFilter 注解配置，无需 web.xml
 */
@WebFilter(
        urlPatterns = "/*",                      // 匹配所有请求路径
        dispatcherTypes = DispatcherType.FORWARD  // 仅在 forward 转发时触发
)
public class BaseFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // 初始化方法，可读取配置参数
        String message = filterConfig.getInitParameter("message");
        System.out.println("[BaseFilter] 初始化参数: " + message);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;

        // 获取 request 和 session 属性（来自 Servlet）
        String requestMsg = (String) req.getAttribute("request-msg");
        String sessionMsg = (String) req.getSession().getAttribute("session-msg");

        System.out.println("[BaseFilter] Request属性: " + requestMsg +
                ", Session属性: " + sessionMsg);

        // 继续执行后续组件（Servlet/JSP）
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // 销毁方法
        System.out.println("[BaseFilter] 过滤器已销毁");
    }
}