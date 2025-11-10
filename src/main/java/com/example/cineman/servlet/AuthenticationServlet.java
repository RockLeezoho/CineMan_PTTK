package com.example.cineman.servlet;

import com.example.cineman.dao.UserDAO;
import com.example.cineman.model.SystemUser;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Optional;

@WebServlet(name="AuthenticationServlet", value="/cineman")
public class AuthenticationServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException{
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
            return;
        }

        try {
            switch (action) {
                case "login":
                    String username = req.getParameter("username");
                    String password = req.getParameter("password");
                    if (username == null || username.isBlank() || password == null || password.isBlank()) {
                        req.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu.");
                        req.getRequestDispatcher("/index.jsp").forward(req, resp);
                    }

                    Optional<SystemUser> userOpt = userDAO.findByUsernameOrEmail(username);

                    if (userOpt.isPresent()) {
                        SystemUser user = userOpt.get();

                        String hash = user.getPasswordHash();

                        if (BCrypt.checkpw(password, hash)) {
                            HttpSession session = req.getSession(true);
                            System.out.println("Login success");
                            session.setAttribute("currentUser", user);
                            req.getRequestDispatcher("/WEB-INF/manager/ManagerMainView.jsp").forward(req, resp);
                        }else {
                            req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
                            req.getRequestDispatcher("/index.jsp").forward(req, resp);
                        }
                    } else {
                        req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
                        req.getRequestDispatcher("/index.jsp").forward(req, resp);
                    }
                    break;
                case "register":
                    // Lấy dữ liệu từ form
                    String fullName = req.getParameter("fullname");
                    String dobStr = req.getParameter("dateofbirth"); // expected yyyy-MM-dd from <input type="date">
                    String phoneNumber = req.getParameter("phonenumber");
                    String email = req.getParameter("email");
                    String gender = req.getParameter("gender");
                    String username1 = req.getParameter("username");
                    String password1 = req.getParameter("password");
                    String confirm = req.getParameter("confirmpass");
                    String role = "manager";
                    // Preserve submitted values for prefilling in case of error
                    req.setAttribute("fullname", fullName);
                    req.setAttribute("dateofbirth", dobStr);
                    req.setAttribute("phonenumber", phoneNumber);
                    req.setAttribute("email", email);
                    req.setAttribute("gender", gender);
                    req.setAttribute("username", username1);
                    req.setAttribute("role", role);

                    // Basic validation
                    if (username1 == null || username1.isBlank()
                            || password1 == null || password1.isBlank()
                            || fullName == null || fullName.isBlank()
                            || email == null || email.isBlank()
                            || dobStr == null || dobStr.isBlank()) {
                        req.setAttribute("error", "Vui lòng điền đầy đủ các trường bắt buộc (Họ tên, Ngày sinh, Email, Tên đăng nhập, Mật khẩu).");
                        req.getRequestDispatcher("/register.jsp").forward(req, resp);
                        return;
                    }

                    if (!password1.equals(confirm)) {
                        req.setAttribute("error", "Mật khẩu và xác nhận mật khẩu không khớp.");
                        req.getRequestDispatcher("/register.jsp").forward(req, resp);
                        return;
                    }

                    // parse dateOfBirth
                    LocalDate dateOfBirth = null;
                    try {
                        dateOfBirth = LocalDate.parse(dobStr); // expects ISO yyyy-MM-dd
                    } catch (DateTimeParseException ex) {
                        req.setAttribute("error", "Ngày sinh không hợp lệ. Vui lòng dùng định dạng ngày hợp lệ.");
                        req.getRequestDispatcher("/register.jsp").forward(req, resp);
                    }

                    // Check existing username/email
                    try {
                        if (userDAO.existsByUsername(username1)) {
                            req.setAttribute("error", "Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.");
                            req.getRequestDispatcher("/register.jsp").forward(req, resp);
                            return;
                        }
                        if (email != null && !email.isBlank() && userDAO.existsByEmail(email)) {
                            req.setAttribute("error", "Email đã được sử dụng. Vui lòng sử dụng email khác.");
                            req.getRequestDispatcher("/register.jsp").forward(req, resp);
                            return;
                        }
                    } catch (SQLException ex) {
                        log("DB error when checking existing user", ex);
                        req.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại sau.");
                        req.getRequestDispatcher("/register.jsp").forward(req, resp);
                    }

                    // Hash password
                    String hashed = BCrypt.hashpw(password1, BCrypt.gensalt(12));

                    // Build SystemUser object
                    SystemUser user = new SystemUser();
                    user.setFullName(fullName);
                    user.setUsername(username1);
                    user.setPasswordHash(hashed);
                    user.setDateOfBirth(dateOfBirth);
                    user.setPhoneNumber(phoneNumber);
                    user.setEmail(email);
                    user.setGender(gender != null ? gender : "unknown");
                    user.setRole(role != null && !role.isBlank() ? role : "USER");

                    // Insert user
                    try {
                        int newId = userDAO.insertUser(user);
                        resp.sendRedirect(req.getContextPath() + "/index.jsp?registered=true");
                    } catch (SQLException ex) {
                        log("DB error when inserting user", ex);
                        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";
                        if (msg.contains("unique") || msg.contains("duplicate")) {
                            req.setAttribute("error", "Tên đăng nhập hoặc email đã tồn tại.");
                        } else {
                            req.setAttribute("error", "Lỗi khi lưu dữ liệu. Vui lòng thử lại.");
                        }
                        req.getRequestDispatcher("/register.jsp").forward(req, resp);
                        return;
                    }
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
                    break;
            }
        } catch (Exception e) {
            log("Unexpected error in register", e);
            req.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            e.printStackTrace();
        }
    }
}
