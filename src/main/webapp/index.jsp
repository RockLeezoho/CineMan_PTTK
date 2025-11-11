<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- This version avoids JSTL taglibs so it won't fail if JSTL isn't available in WEB-INF/lib --%>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>ĐĂNG NHẬP QUẢN LÝ</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css?v=1.0">
    <style>

    </style>
</head>
<body>
    <div class="login-card">
        <h3 class="login-title">ĐĂNG NHẬP</h3>
        <p class="note">Đăng nhập để vào trang quản lý</p>

        <%-- show registration success message if present in query param --%>
        <%
            String reg = request.getParameter("registered");
            if ("true".equals(reg)) {
        %>
            <div class="small" style="background:#ecfdf5;border:1px solid rgba(6,95,70,0.08);padding:0.5rem;border-radius:6px;margin-bottom:0.8rem;color:#065f46;">
                Đăng ký thành công. Vui lòng đăng nhập.
            </div>
        <%
            }
        %>

        <%-- show server-side error if forwarded with request attribute "error" --%>
        <%
            String error = (String) request.getAttribute("error");
            if (error != null && !error.isBlank()) {
        %>
            <div id="errorBox" class="error" role="alert" aria-live="polite"><%=  StringEscapeUtils.escapeHtml4(error) %></div>
        <%
            }
        %>

        <%-- Login form posts to your servlet mapped at /cineman --%>
        <form id="loginForm" action="<%= request.getContextPath() %>/cineman" method="post" onsubmit="return submitLogin(event);">
            <%-- include hidden action so servlet knows which branch to run --%>
            <input type="hidden" name="action" value="login" />

            <label for="username" class="form-label">Tên đăng nhập hoặc Email</label>
            <input type="text" class="form-control" id="username" name="username"
                   placeholder="Nhập tên đăng nhập hoặc email" required autocomplete="username"
                   value="<%= StringEscapeUtils.escapeHtml4(request.getParameter("username")) %>">

            <label for="password" class="form-label">Mật khẩu</label>
            <input type="password" class="form-control" id="password" name="password"
                   placeholder="Nhập mật khẩu" required autocomplete="current-password">

            <div style="height:6px"></div>

            <button type="submit" class="btn-login">Đăng nhập</button>
        </form>

        <p class="center-sm">
            Bạn chưa có tài khoản?
            <a href="<%= request.getContextPath() %>/register.jsp" class="link">Đăng ký</a>
        </p>
    </div>

    <script>
        function submitLogin(e) {
            var user = document.getElementById('username').value.trim();
            var pass = document.getElementById('password').value;
            if (!user || !pass) {
                alert('Vui lòng nhập tên đăng nhập và mật khẩu.');
                return false;
            }
            var btn = document.querySelector('.btn-login');
            if (btn) btn.disabled = true;
            return true;
        }

        // Hide error box after 1 second (1000 ms) with fade-out transition
        (function hideErrorAfterDelay(){
            var box = document.getElementById('errorBox');
            if (!box) return;
            // Wait 1s then add hidden class to start fade
            setTimeout(function(){
                box.classList.add('hidden');
                // Remove from DOM after transition completes (0.5s transition + small buffer)
                setTimeout(function(){
                    if (box && box.parentNode) box.parentNode.removeChild(box);
                }, 650);
            }, 1000);
        })();
    </script>
</body>
</html>