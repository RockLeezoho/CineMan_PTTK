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

    // Data for embedded SelectRoom panel (these attributes may be set by servlet
    // when user clicked "Chọn" to select rooms for a particular showtime)
    LocalDate showDateAttr = (LocalDate) request.getAttribute("date");
    LocalTime showTimeAttr = (LocalTime) request.getAttribute("time");
    List<Room> availableRoomList = (List<Room>) request.getAttribute("availableRoomList");

    // Partition available rooms by floor (same logic as SelectRoomView.jsp)
    List<Room> floor1 = new java.util.ArrayList<>();
    List<Room> floor2 = new java.util.ArrayList<>();
    if (availableRoomList != null && !availableRoomList.isEmpty()) {
        for (Room r : availableRoomList) {
            if (r.getRoomNumber() >= 1 && r.getRoomNumber() <= 5) floor1.add(r);
            else if (r.getRoomNumber() >= 6 && r.getRoomNumber() <= 10) floor2.add(r);
        }
    }

    // Always show the right panel (per your request). Use flags for content.
    boolean panelHasRooms = (availableRoomList != null && !availableRoomList.isEmpty());
    boolean panelHasDateTime = (showDateAttr != null && showTimeAttr != null);
%>
<html>
<head>
    <title>Thêm lịch chiếu</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/add_showtimes.css?v=1.0"/>
    <script>
        // room selection logic reused from SelectRoomView.jsp
        let selectedRooms = [];

        function toggleRoom(roomId) {
            const idx = selectedRooms.indexOf(roomId);
            if (idx > -1) {
                selectedRooms.splice(idx, 1);
            } else {
                selectedRooms.push(roomId);
            }
            updateRoomButtons();
            updateRoomIdListInput();
        }

        function updateRoomButtons() {
            document.querySelectorAll('.room-btn').forEach(btn => {
                if (selectedRooms.includes(btn.dataset.roomid)) {
                    btn.classList.add('selected');
                } else {
                    btn.classList.remove('selected');
                }
            });
        }

        function updateRoomIdListInput() {
            const input = document.getElementById('roomIdListInput');
            if (input) input.value = selectedRooms.join(',');
        }

        window.onload = function() {
            // fade success alert if present (existing behavior)
            var alertBox = document.getElementById('success-alert');
            if (alertBox) {
                setTimeout(function() {
                    alertBox.style.display = "none";
                }, 1000);
            }

            // initialize selectedRooms if servlet provided preselected list (optional)
            var pre = document.getElementById('preselectedRoomIds');
            if (pre && pre.value.trim().length > 0) {
                selectedRooms = pre.value.split(',').filter(s => s.trim().length > 0);
            }
            updateRoomButtons();
            updateRoomIdListInput();
        };
    </script>
</head>
<body>
<div class="container">
    <h2>Thêm lịch chiếu</h2>

    <%-- Thông báo lưu thành công nếu có success=true --%>
    <%
        if ("true".equals(success)) {
    %>
        <div class="alert-success" id="success-alert">
            Lưu lịch chiếu thành công!
        </div>
    <%
        }
    %>

    <div class="btn-row">
        <form method="post" action="showtimes" style="margin:0;">
            <input type="hidden" name="action" value="confirmTime"/>
            <div style="display:flex; gap:8px; align-items:center;">
                <label for="date" style="margin-right:6px;">Ngày</label>
                <input type="date" id="date" name="date"
                       value="<%= request.getParameter("date") != null ? request.getParameter("date") : "" %>"
                       class="<%= request.getParameter("date") != null ? "filled" : "" %>" required />
                <label for="time" style="margin-left:12px; margin-right:6px;">Giờ</label>
                <input type="time" id="time" name="time"
                       value="<%= request.getParameter("time") != null ? request.getParameter("time") : "" %>"
                       class="<%= request.getParameter("time") != null ? "filled" : "" %>" required />
                <button type="submit" class="btn btn-confirm">Xác nhận</button>
            </div>
        </form>
    </div>

    <div class="split">
        <!-- LEFT: existing showtimes table -->
        <div class="left-panel">
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
                            <!-- keep original behavior: when clicking "Chọn" the servlet should prepare availableRoomList and forward back -->
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
        </div>

        <!-- Separator (visual) -->
        <div class="separator" aria-hidden="true"></div>

        <!-- RIGHT: embedded SelectRoom panel: ALWAYS VISIBLE per request -->
        <div class="right-panel">
            <div class="phong-trong-title" style="margin-top:8px; font-weight:700;">Phòng trống</div>

            <% if (!panelHasDateTime && !panelHasRooms) { %>
                <!-- No date/time selected or no rooms available: show hint message -->
                <div class="panel-empty">
                    Chưa chọn lịch cụ thể để xem phòng trống. Hãy nhấn "Chọn" ở một hàng lịch chiếu bên trái để hiển thị phòng trống tương ứng.
                </div>
            <% } else if (!panelHasRooms && panelHasDateTime) { %>
                <div class="panel-empty">
                    Không có phòng trống cho thời điểm này.
                </div>
            <% } else { %>
                <!-- room selection form (same as SelectRoomView.jsp) -->
                <form id="roomSelectForm" method="post" action="showtimes" onsubmit="updateRoomIdListInput()">
                    <input type="hidden" name="action" value="chooseRooms"/>
                    <input type="hidden" name="showDate" value="<%= showDateAttr != null ? showDateAttr.toString() : "" %>"/>
                    <input type="hidden" name="timeSlot" value="<%= showTimeAttr != null ? showTimeAttr.toString() : "" %>"/>
                    <input type="hidden" id="roomIdListInput" name="roomIdList" value="" />
                    <input type="hidden" id="preselectedRoomIds" value="<%= request.getAttribute("preselectedRoomIds") == null ? "" : request.getAttribute("preselectedRoomIds") %>" />

                    <div class="room-table-wrapper">
                        <table class="room-table" style="width:100%;">
                            <tr>
                                <td class="row-label">Tầng 1</td>
                                <td>
                                    <% for (Room r : floor1) { %>
                                        <button type="button" class="room-btn"
                                                data-roomid="<%= r.getId() %>"
                                                onclick="toggleRoom('<%= r.getId() %>')">
                                            P<%= String.format("%02d", r.getRoomNumber()) %>
                                        </button>
                                    <% } %>
                                    <% if (floor1.isEmpty()) { %>
                                        <div style="color:#777;">Không có</div>
                                    <% } %>
                                </td>
                            </tr>
                            <tr>
                                <td class="row-label">Tầng 2</td>
                                <td>
                                    <% for (Room r : floor2) { %>
                                        <button type="button" class="room-btn"
                                                data-roomid="<%= r.getId() %>"
                                                onclick="toggleRoom('<%= r.getId() %>')">
                                            P<%= String.format("%02d", r.getRoomNumber()) %>
                                        </button>
                                    <% } %>
                                    <% if (floor2.isEmpty()) { %>
                                        <div style="color:#777;">Không có</div>
                                    <% } %>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class="btn-group-room">
                        <button type="submit" class="btn-confirm-room">Xác nhận</button>
                        <a href="showtimes?action=addShowtimes" class="btn-cancel">Hủy</a>
                    </div>
                </form>
            <% } %>
        </div>
    </div>

    <div class="movie-row" style="margin-top:18px;">
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

    <div class="btn-group" style="margin-top:16px;">
        <form method="get" action="movies" accept-charset="UTF-8" style="display:inline;">
            <input type="hidden" name="action" value="selectMovie"/>
            <button
                type="submit"
                class="btn btn-next"
                <%= (!hasAnySelectable && tempShowtimes != null && !tempShowtimes.isEmpty()) ? "" : "disabled" %>
            >Next</button>
        </form>

        <form method="post" action="showtimes" accept-charset="UTF-8" style="display:inline;">
            <input type="hidden" name="action" value="saveShowtimes"/>
            <button
                type="submit"
                class="btn btn-save"
                <%= showSaveActive ? "" : "disabled" %>
            >Lưu</button>
        </form>

        <form method="get" action="showtimes" style="display:inline;">
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