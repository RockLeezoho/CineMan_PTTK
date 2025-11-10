<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- This version avoids JSTL taglibs so it won't fail if JSTL isn't available in WEB-INF/lib --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>ĐĂNG NHẬP QUẢN LÝ</title>
    <link rel="stylesheet" href="assets/css/styles.css">
    <style>
        /* Basic layout & utility classes */
        body {
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f5f6fa;
            font-family: Arial, Helvetica, sans-serif;
        }
        .login-card {
            background: #ffde7d;
            padding: 2.5rem 2rem 2rem 2rem;
            border-radius: 16px;
            box-shadow: 0 8px 32px rgba(30,60,114,0.18);
            width: 100%;
            max-width: 420px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .login-title {
            color: #222;
            font-size: 2rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 0.25rem;
            margin-top: 0.25rem;
        }
        .note {
            color: #222;
            font-size: 1rem;
            text-align: center;
            margin-bottom: 1.5rem;
        }
        form {
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: stretch;
        }
        .form-label {
            font-weight: 500;
            margin-bottom: 0.4rem;
            color: #222;
            display: block;
        }
        .form-control {
            width: 100%;
            padding: 0.7rem 1rem;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-size: 1rem;
            color: #222;
            background: #fff;
            box-sizing: border-box;
        }
        .form-control:focus {
            border-color: #28a745;
            outline: none;
            box-shadow: 0 0 0 3px rgba(40,167,69,0.07);
        }
        .btn-login {
            background: #28a745;
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 0.75rem 0;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            margin-top: 0.5rem;
            transition: background 0.15s;
        }
        .btn-login:hover { background: #218838; }

        .helper-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 0.5rem;
            font-size: 0.95rem;
        }

        .link {
            color: #e11d48; /* red-600 */
            text-decoration: none;
            cursor: pointer;
        }
        .link:hover { text-decoration: underline; }

        /* Error box + fade-out */
        .error {
            width: 100%;
            background: #fff3f2;
            color: #991b1b;
            border: 1px solid rgba(153,27,27,0.12);
            padding: 0.6rem;
            border-radius: 6px;
            margin-bottom: 0.75rem;
            box-sizing: border-box;
            opacity: 1;
            transition: opacity 0.5s ease, transform 0.5s ease, height 0.5s ease, margin 0.5s ease, padding 0.5s ease;
        }
        .error.hidden {
            opacity: 0;
            transform: translateY(-6px);
            height: 0;
            margin: 0;
            padding-top: 0;
            padding-bottom: 0;
            overflow: hidden;
        }

        .small {
            font-size: 0.9rem;
            color: #374151;
        }

        .center-sm {
            text-align: center;
            font-size: 0.95rem;
            margin-top: 1rem;
        }
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
            <div id="errorBox" class="error" role="alert" aria-live="polite"><%= escapeHtml(error) %></div>
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
                   value="<%= escapeHtml(request.getParameter("username")) %>">

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