package com.example.listener;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.FilterRegistration;

import com.example.demo1.UserServlet;
import com.example.demo1.LifeCycleServlet;
import com.example.demo2.EchoServlet;
import com.example.demo2.AsyncServlet;
import com.example.filter.EncodingFilter;
import com.example.filter.LoginFilter;

@WebListener
public class DynamicRegistrationListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();

        // 注册 Servlet
        context.addServlet("userServlet", UserServlet.class).addMapping("/user/*");
        context.addServlet("lifeCycleServlet", LifeCycleServlet.class).addMapping("/lifecycle/*");
        context.addServlet("echoServlet", EchoServlet.class).addMapping("/echo/*");
        context.addServlet("asyncServlet", AsyncServlet.class).addMapping("/async/*");

        // 编码过滤器：全局
        context.addFilter("encodingFilter", EncodingFilter.class).addMappingForUrlPatterns(null, false, "/*");

        // 登录过滤器：拦截所有请求（/*），确保所有操作都被检查
        FilterRegistration.Dynamic loginFilter = context.addFilter("loginFilter", LoginFilter.class);
        loginFilter.setInitParameter("auth", "loginUser");
        loginFilter.addMappingForUrlPatterns(null, false, "/*"); // 关键：改为拦截所有请求

        System.out.println("✅ 动态注册完成：LoginFilter 已拦截所有请求（/*）");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("ℹ️ 应用已停止，动态注册组件已卸载");
    }
}