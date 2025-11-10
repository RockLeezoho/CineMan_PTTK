<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.example.cineman.model.Showtime, com.example.cineman.model.Room" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý lịch chiếu</title>
    <link rel="stylesheet" href="assets/css/manage_showtimes.css">
    <script>
        // Biến mất sau 1s nếu không dùng animation
        window.onload = function() {
            var alertBox = document.getElementById('success-alert');
            if (alertBox) {
                setTimeout(function() {
                    alertBox.style.display = "none";
                }, 1000);
            }
        }
    </script>
</head>
<body>
<div class="container">
    <h2>Quản lý lịch chiếu</h2>

    <%-- Thông báo lưu thành công nếu có success=true --%>
    <%
        String success = request.getParameter("success");
        if ("true".equals(success)) {
    %>
        <div class="alert-success" id="success-alert">
            Lưu lịch chiếu thành công!
        </div>
    <%
        }
    %>

    <div class="btn-row">
        <form action="showtimes" method="get" style="margin:0;">
            <input type="hidden" name="action" value="addShowtimes"/>
            <button class="add-btn" type="submit">Thêm lịch chiếu</button>
        </form>
    </div>

    <div class="table-title">Các lịch chiếu khả dụng</div>
    <div class="table-wrapper">
        <table>
            <thead>
            <tr>
                <th>STT</th>
                <th>Ngày</th>
                <th>Giờ</th>
                <th>Phòng</th>
                <th>Phim</th>
            </tr>
            </thead>
            <tbody>
            <%
                List<Showtime> showtimeList = (List<Showtime>) request.getAttribute("showtimeList");
                if (showtimeList != null && !showtimeList.isEmpty()) {
                    int stt = 1;
                    for (Showtime showtime : showtimeList) {
                        for (Room room: showtime.getRooms()) {
                            String showDate = showtime.getShowDate() != null ? showtime.getShowDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
                            String showTime = showtime.getTimeSlot() != null ? showtime.getTimeSlot().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")) : "";
            %>
            <tr>
                <td><%= stt++ %></td>
                <td><%= showDate %></td>
                <td><%= showTime %></td>
                <td><%= room.getId() %></td>
                <td><%= showtime.getMovie().getTitle() %></td>
            </tr>
            <%
                        }
                    }
                } else {
            %>
            <tr>
                <td colspan="5">Không có lịch chiếu nào khả dụng</td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <div class="pagination">
        <button class="pagination-btn" type="button" disabled>&lt;</button>
        <span class="page-number">1</span>
        <button class="pagination-btn" type="button" disabled>&gt;</button>
    </div>

    <div class="bottom-row">
        <button class="back-btn" type="submit" onclick="window.location.href='ManagerMainView.jsp'">Quay lại</button>
    </div>
</div>
</body>
</html>