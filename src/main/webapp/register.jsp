<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%!
    // simple HTML escape helper
    public static String escapeHtml(String s){
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length());
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&': sb.append("&amp;"); break;
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#x27;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <title>ĐĂNG KÝ QUẢN LÝ</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/styles.css?v=1.0">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/register.css?v=1.0">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
  <div class="login-card">
    <h3 class="login-title">ĐĂNG KÝ</h3>
    <p class="note">Đăng ký để vào trang quản lý</p>

    <!-- Hiển thị thông báo lỗi server-side nếu có (được servlet setAttribute("error")) -->
    <%
        String error = (String) request.getAttribute("error");
        if (error != null && !error.isBlank()) {
    %>
        <div id="errorBox" class="error" role="alert" aria-live="polite"><%= escapeHtml(error) %></div>
    <%
        }
    %>

    <!-- Form gửi tới AuthenticationServlet mapped to /cineman -->
    <form id="registerForm" action="${pageContext.request.contextPath}/cineman" method="post" onsubmit="return validateRegister(event);">
      <!-- Nếu bạn muốn servlet biết đây là hành động đăng ký, gửi param action=register -->
      <input type="hidden" name="action" value="register" />

      <!-- Form grid: hai cột trên desktop, một cột trên mobile -->
      <div class="form-grid">
        <div class="form-group">
          <label for="fullname" class="form-label">Họ tên</label>
          <input type="text" class="form-control" id="fullname" name="fullname" placeholder="Nhập họ và tên" required autocomplete="name"
                 value="${fn:escapeXml(param.fullname != null ? param.fullname : (requestScope.fullname != null ? requestScope.fullname : ''))}" />
        </div>

        <div class="form-group">
          <label for="dateofbirth" class="form-label">Ngày sinh</label>
          <input type="date" class="form-control" id="dateofbirth" name="dateofbirth" required autocomplete="bday"
                 value="${param.dateofbirth != null ? param.dateofbirth : (requestScope.dateofbirth != null ? requestScope.dateofbirth : '')}" />
        </div>

        <div class="form-group">
          <label for="phonenumber" class="form-label">Số điện thoại</label>
          <input type="tel" class="form-control" id="phonenumber" name="phonenumber" placeholder="Nhập số điện thoại" required
                 pattern="\+?[0-9]{9,15}" autocomplete="tel"
                 value="${fn:escapeXml(param.phonenumber != null ? param.phonenumber : (requestScope.phonenumber != null ? requestScope.phonenumber : ''))}" />
        </div>

        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input type="email" class="form-control" id="email" name="email" placeholder="Nhập email" required autocomplete="email"
                 value="${fn:escapeXml(param.email != null ? param.email : (requestScope.email != null ? requestScope.email : ''))}" />
        </div>

        <div class="form-group">
          <label class="form-label">Giới tính</label>
          <div class="inline-options">
            <label class="option">
              <input type="radio" name="gender" value="female" id="genderFemale" ${param.gender == 'female' || requestScope.gender == 'female' ? 'checked' : ''} required> Nữ
            </label>
            <label class="option">
              <input type="radio" name="gender" value="male" id="genderMale" ${param.gender == 'male' || requestScope.gender == 'male' ? 'checked' : ''}> Nam
            </label>
          </div>
        </div>

        <div class="form-group">
          <label for="username" class="form-label">Tên đăng nhập</label>
          <input type="text" class="form-control" id="username" name="username" placeholder="Nhập tên đăng nhập" required autocomplete="username"
                 value="${fn:escapeXml(param.username != null ? param.username : (requestScope.username != null ? requestScope.username : ''))}" />
        </div>

        <div class="form-group password-group">
          <label for="password" class="form-label">Mật khẩu</label>
          <div class="password-wrapper">
            <input type="password" class="form-control" id="password" name="password" placeholder="Nhập mật khẩu" required minlength="6" autocomplete="new-password" />
            <button type="button" class="toggle-password" data-target="password" aria-label="Hiện/ẩn mật khẩu" title="Hiện/ẩn mật khẩu">
                <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>

        <div class="form-group password-group">
          <label for="confirmpass" class="form-label">Xác nhận Mật khẩu</label>
          <div class="password-wrapper">
            <input type="password" class="form-control" id="confirmpass" name="confirmpass" placeholder="Xác nhận mật khẩu" required autocomplete="new-password" />
            <button type="button" class="toggle-password" data-target="confirmpass" aria-label="Hiện/ẩn mật khẩu xác nhận" title="Hiện/ẩn mật khẩu xác nhận" aria-pressed="false">
              <i class="bi bi-eye"></i>
            </button>
          </div>
        </div>

        <div class="form-actions" style="grid-column: 1 / -1;">
          <div id="passError" class="field-error">Mật khẩu và xác nhận mật khẩu không khớp.</div>
          <button type="submit" class="btn-register">Đăng ký</button>
          <p class="mt-8 text-center text-sm">Bạn đã có tài khoản?
            <a href="${pageContext.request.contextPath}/index.jsp" class="text-red-500 hover-underline cursor-pointer">Đăng nhập</a>
          </p>
        </div>
      </div>
    </form>
  </div>

  <script>
    // Client-side validation: confirm password + simple phone/email hints
    function validateRegister(e) {
      document.getElementById('passError').style.display = 'none';

      var pass = document.getElementById('password').value;
      var conf = document.getElementById('confirmpass').value;
      if (pass !== conf) {
        document.getElementById('passError').style.display = 'block';
        document.getElementById('confirmpass').focus();
        return false;
      }

      var phone = document.getElementById('phonenumber');
      var phonePattern = /^\+?\d{9,15}$/;
      if (!phonePattern.test(phone.value)) {
        alert('Số điện thoại không hợp lệ. Vui lòng nhập 9-15 chữ số, có thể có dấu + ở đầu.');
        phone.focus();
        return false;
      }

      return true;
    }

    (function scrollToError() {
      var serverError = document.querySelector('.error');
      if (serverError) {
        serverError.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    })();

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

    // Password toggle: attach listeners to all .toggle-password buttons
    (function setupPasswordToggles(){
      function setIcon(btn, visible){
        // use CSS classes to style button; we'll toggle aria-pressed to reflect state
        if (visible) {
          btn.classList.add('visible');
        } else {
          btn.classList.remove('visible');
        }
      }

      var toggles = document.querySelectorAll('.toggle-password');
      toggles.forEach(function(btn){
        var targetId = btn.getAttribute('data-target');
        var input = document.getElementById(targetId);
        if (!input) return;

        // initialize icon based on initial type
        setIcon(btn, input.type === 'text');

        btn.addEventListener('click', function(e){
          e.preventDefault();
          var isPassword = input.type === 'password';
          input.type = isPassword ? 'text' : 'password';
          // move focus back to input so keyboard users continue typing
          input.focus();
          // update icon
          setIcon(btn, isPassword);
          // update aria-pressed for accessibility
          btn.setAttribute('aria-pressed', String(isPassword));
        });

        // allow toggle via keyboard (space/enter)
        btn.addEventListener('keydown', function(e){
          if (e.key === ' ' || e.key === 'Enter') {
            e.preventDefault();
            btn.click();
          }
        });
      });
    })();
  </script>
</body>
</html>
<!--hhanh-->
<!--hanh123-->