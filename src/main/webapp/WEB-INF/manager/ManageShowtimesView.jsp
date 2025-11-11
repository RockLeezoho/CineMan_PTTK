<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.example.cineman.model.Showtime, com.example.cineman.model.Room, java.time.format.DateTimeFormatter, java.time.LocalDate" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quản lý lịch chiếu</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/manage_showtimes.css?v=1.0">
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
        <form action="${pageContext.request.contextPath}/showtimes" method="get" style="margin:0;">
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
                //NOTE: request.getAttribute(...) trả về Object, không trả về dữ liệu nguyên thủy (int/long)

                // Lấy thông tin phân trang từ servlet nếu có, nếu không dùng parameter / fallback
                Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                int currentPage = currentPageObj != null ? currentPageObj : 1;

                Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
                int pageSize = pageSizeObj != null ? pageSizeObj : 10;

                Long totalRecordsObj = (Long) request.getAttribute("totalRecords");
                long totalRecords = totalRecordsObj != null ? totalRecordsObj : 0L;

                Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
                int totalPages = totalPagesObj != null ? totalPagesObj : 1;

                DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");

                int sttStart = (currentPage - 1) * pageSize + 1;
                int stt = sttStart;

                List<Showtime> showtimeList = (List<Showtime>) request.getAttribute("showtimeList");
                if (showtimeList != null && !showtimeList.isEmpty()) {
                    for (Showtime showtime : showtimeList) {
                        List<Room> rooms = showtime.getRooms();
                        if (rooms == null || rooms.isEmpty()) {
            %>
            <tr>
                <td><%= stt++ %></td>
                <td><%= showtime.getShowDate() != null ? showtime.getShowDate().format(dateFmt) : "" %></td>
                <td><%= showtime.getTimeSlot() != null ? showtime.getTimeSlot().format(timeFmt) : "" %></td>
                <td>-</td>
                <td><%= showtime.getMovie() != null ? showtime.getMovie().getTitle() : "" %></td>
            </tr>
            <%
                        } else {
                        String roomOfShowtime = "";
                            for (int i = 0; i < rooms.size(); i++) {
                                roomOfShowtime += ("P" + rooms.get(i).getRoomNumber());
                                if(i < rooms.size() - 1){
                                     roomOfShowtime += ", ";
                                }
                            }
            %>
            <tr>
                <td><%= stt++ %></td>
                <td><%= showtime.getShowDate() != null ? showtime.getShowDate().format(dateFmt) : "" %></td>
                <td><%= showtime.getTimeSlot() != null ? showtime.getTimeSlot().format(timeFmt) : "" %></td>
                <td><%= roomOfShowtime %></td>
                <td><%= showtime.getMovie() != null ? showtime.getMovie().getTitle() : "" %></td>
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

    <!-- Pagination (Prev, current page, Next) -->
    <div class="pagination" aria-label="Pagination">
        <div class="pager-left">Tổng số: <strong><%= totalRecords %></strong></div>

        <div class="pager-center">
            <%
                boolean prevDisabled = currentPage <= 1;
                boolean nextDisabled = currentPage >= totalPages;
            %>

            <!-- Prev -->
            <form method="get" action="${pageContext.request.contextPath}/management" style="display:inline;">
                <input type="hidden" name="action" value="manageShowtimes"/>
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= prevDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.max(1, currentPage - 1) %>" <%= prevDisabled ? "disabled" : "" %> >&lt;</button>
            </form>

            <!-- Current page only -->
            <div class="page-number" aria-current="page">
                <%= currentPage %>
            </div>

            <!-- Next -->
            <form method="get" action="${pageContext.request.contextPath}/management" style="display:inline;">
                <input type="hidden" name="action" value="manageShowtimes"/>
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= nextDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.min(totalPages, currentPage + 1) %>" <%= nextDisabled ? "disabled" : "" %> >&gt;</button>
            </form>
        </div>

        <div class="pager-right">
            <form method="get" action="${pageContext.request.contextPath}/management" style="display:flex; align-items:center; gap:8px;">
                <input type="hidden" name="action" value="manageShowtimes"/>
                <select id="pageSize" name="pageSize" onchange="this.form.submit()">
                    <option value="5"  <%= pageSize==5 ? "selected" : "" %>>5</option>
                    <option value="10" <%= pageSize==10 ? "selected" : "" %>>10</option>
                    <option value="25" <%= pageSize==25 ? "selected" : "" %>>25</option>
                    <option value="50" <%= pageSize==50 ? "selected" : "" %>>50</option>
                    <option value="100"<%= pageSize==100 ? "selected" : "" %>>100</option>
                </select>
                <label for="pageSize">/ trang</label>
                <input type="hidden" name="page" value="1" />
            </form>
        </div>
    </div>

    <div class="bottom-row">
        <button class="back-btn" type="submit" onclick="window.location.href='ManagerMainView.jsp'">Quay lại</button>
    </div>
</div>
</body>
</html>