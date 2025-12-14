package com.example.demo1;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

// 注解配置Servlet，映射路径为"/life"（访问时用 http://localhost:8080/demo/life）
@WebServlet("/life")
public class LifeCycleServlet extends HttpServlet {

    // 1. 实例化阶段：构造方法
    public LifeCycleServlet() {
        System.out.println("[LifeCycleServlet] 调用构造方法 → 实例化Servlet对象");
    }

    // 2. 初始化阶段：init()
    @Override
    public void init() throws ServletException {
        System.out.println("[LifeCycleServlet] 调用init()方法 → 初始化Servlet");
    }

    // 3. 服务阶段：处理GET请求
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html;charset=utf-8");
        resp.getWriter().write("<h3>Servlet生命周期展示（GET请求）</h3>");
        resp.getWriter().write("<p>当前阶段：处理请求（doGet）</p>");
        resp.getWriter().write("<p>可查看控制台输出，查看完整生命周期</p>");
        System.out.println("[LifeCycleServlet] 调用doGet()方法 → 处理GET请求");
    }

    // 3. 服务阶段：处理POST请求（可选，测试用）
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp); // 复用GET逻辑
        System.out.println("[LifeCycleServlet] 调用doPost()方法 → 处理POST请求");
    }

    // 4. 销毁阶段：destroy()
    @Override
    public void destroy() {
        System.out.println("[LifeCycleServlet] 调用destroy()方法 → 销毁Servlet，释放资源");
    }
}