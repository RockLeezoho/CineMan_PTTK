<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="com.example.cineman.model.Showtime" %>
<%@ page import="com.example.cineman.model.Room" %>
<%@ page import="com.example.cineman.model.Movie" %>
<%
    String success = request.getParameter("success");
    List<Showtime> tempShowtimes = (List<Showtime>) session.getAttribute("tempShowtimes");
    boolean allShowtimesHaveRoom = true;
    boolean showNextActive = true;
    boolean showSaveActive = false;
    Movie tempMovie = new Movie();

    if (tempShowtimes != null && !tempShowtimes.isEmpty()) {
        for (Showtime st : tempShowtimes) {
            if (st.getRooms() == null || st.getRooms().isEmpty()) {
                allShowtimesHaveRoom = false;
                showNextActive = false;
                break;
            }
        }
        for (Showtime st : tempShowtimes) {
            if (st.getRooms() == null || st.getRooms().isEmpty()) {
                showNextActive = false;
                break;
            }
        }
    } else {
        allShowtimesHaveRoom = false;
        showNextActive = false;
    }

    if (tempShowtimes != null && !tempShowtimes.isEmpty()) {
        for (Showtime st : tempShowtimes) {
            if (st.getMovie() != null) {
                tempMovie.setId(st.getMovie().getId());
                tempMovie.setTitle(st.getMovie().getTitle());
                showSaveActive = true;
                showNextActive = false;
                break;
            }
        }
    }
%>
<html>
<head>
    <title>Thêm lịch chiếu</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/add_showtimes.css?v=1.0"/>
</head>
<body>
<div class="container">
    <h2>Thêm lịch chiếu</h2>
    <form method="post" action="showtimes">
        <input type="hidden" name="action" value="confirmTime"/>
        <div class="form-row">
            <label for="date"> </label>
            <input type="date" id="date" name="date"
                   value="<%= request.getParameter("date") != null ? request.getParameter("date") : "" %>"
                   class="<%= request.getParameter("date") != null ? "filled" : "" %>" required />
        </div>
        <div class="form-row">
            <label for="time"> </label>
            <input type="time" id="time" name="time"
                   value="<%= request.getParameter("time") != null ? request.getParameter("time") : "" %>"
                   class="<%= request.getParameter("time") != null ? "filled" : "" %>" required />
        </div>
        <button type="submit" class="btn btn-confirm">Xác nhận</button>
    </form>

    <div class="section-title">Các lịch chiếu</div>
    <table>
        <tr>
            <th>STT</th>
            <th>Ngày</th>
            <th>Giờ</th>
            <th>Phòng</th>
            <th>Thao tác</th>
        </tr>
        <%
            boolean hasAnySelectable = false;
            if (tempShowtimes != null && !tempShowtimes.isEmpty()) {
                int idx = 1;
                for (Showtime st : tempShowtimes) {
        %>
        <tr>
            <td><%= idx %></td>
            <td><%= st.getShowDate() != null ? st.getShowDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "" %></td>
            <td><%= st.getTimeSlot() %></td>
            <td>
                <% if (st.getRooms() != null && !st.getRooms().isEmpty()) { %>
                    <%
                        List<Room> sortedRooms = new java.util.ArrayList<>(st.getRooms());
                        java.util.Collections.sort(sortedRooms, new java.util.Comparator<Room>() {
                            @Override
                            public int compare(Room o1, Room o2) {
                                return Integer.compare(o1.getRoomNumber(), o2.getRoomNumber());
                            }
                        });
                        for (Room r : sortedRooms) {%>

                        <span style="display:inline-block;background:#d9ead3;border-radius:6px;padding:3px 10px;margin:2px 4px;border:1px solid #6aa84f;font-weight:500;">
                            P<%= String.format("%02d", r.getRoomNumber())%>
                        </span>
                    <% } %>
                <% } else { %>
                    <% hasAnySelectable = true; %>
                    <form method="get" action="showtimes" style="display:inline;">
                      <input type="hidden" name="action" value="selectRoom"/>
                      <input type="hidden" name="date" value="<%= st.getShowDate() %>"/>
                      <input type="hidden" name="time" value="<%= st.getTimeSlot() %>"/>
                      <button type="submit" class="action-btn">Chọn</button>
                    </form>
                <% } %>
            </td>
            <td>
                <form method="get" action="showtimes" style="display:inline;">
                    <input type="hidden" name="action" value="deleteTempShowtime"/>
                    <input type="hidden" name="index" value="<%= idx-1 %>"/>
                    <button type="submit" class="action-btn">Xóa</button>
                </form>
            </td>
        </tr>
        <%
                    idx++;
                }
            } else {
        %>
        <tr>
            <td colspan="5">Chưa có lịch chiếu nào</td>
        </tr>
        <% } %>
    </table>

    <div class="movie-row">
        <div class="movie-label">Phim sẽ chiếu:</div>
        <div class="movie-info">
            <% if (tempMovie.getTitle() != null) { %>
                <span style="margin-left:10px;">
                <%= tempMovie.getId() %> - <%= tempMovie.getTitle() %></span>
            <% } else {%>
                <span style="margin-left:10px;color:#000;">Chưa có phim được chọn</span>
            <% } %>
        </div>
    </div>

    <div class="btn-group">
        <form method="get" action="movies" accept-charset="UTF-8">
            <input type="hidden" name="action" value="selectMovie"/>
            <button
                type="submit"
                class="btn btn-next"
                <%= (!hasAnySelectable && tempShowtimes != null && !tempShowtimes.isEmpty()) ? "" : "disabled" %>
            >Next</button>
        </form>
        <form method="post" action="showtimes" accept-charset="UTF-8">
            <input type="hidden" name="action" value="saveShowtimes"/>
            <button
                type="submit"
                class="btn btn-save"
                <%= showSaveActive ? "" : "disabled" %>
            >Lưu</button>
        </form>
        <form method="get" action="showtimes">
            <input type="hidden" name="action" value="manageShowtimes"/>
            <button
                type="submit"
                class="btn btn-cancel"
            >Hủy</button>
        </form>
    </div>
</div>
</body>
</html>