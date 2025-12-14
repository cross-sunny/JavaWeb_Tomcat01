package com.example.demo2;
// http://localhost:8080/demo/demo2/filter
// http://localhost:8080/demo/demo2/read-form.html
// http://localhost:8080/demo/demo2/async?info=Hello+from+AsyncServlet
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

@WebServlet(urlPatterns = "/demo2/async", asyncSupported = true) // 注意URL前缀
public class AsyncServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        if (req.isAsyncSupported()) {
            AsyncContext asyncContext = req.startAsync();
            asyncContext.setTimeout(10000); // 10秒超时

            // 启动异步线程
            new Thread(new WorkerThread(asyncContext)).start();
        } else {
            resp.getWriter().println("Async not supported");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        this.doPost(req, resp);
    }

    private static class WorkerThread implements Runnable {
        private final AsyncContext asyncContext;

        public WorkerThread(AsyncContext asyncContext) {
            this.asyncContext = asyncContext;
        }

        @Override
        public void run() {
            try {
                // 模拟耗时操作
                String info = asyncContext.getRequest().getParameter("info");
                TimeUnit.SECONDS.sleep(2);

                // 写入响应
                asyncContext.getResponse().getWriter()
                        .println("<h1>ECHO: " + (info != null ? info : "No message") + "</h1>");
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                asyncContext.complete(); // 必须调用完成
            }
        }
    }
}