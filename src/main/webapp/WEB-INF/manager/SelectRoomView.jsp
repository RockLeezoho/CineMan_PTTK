<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.cineman.model.Room" %>
<%
    LocalDate showDate = (LocalDate) request.getAttribute("date");
    LocalTime showTime = (LocalTime) request.getAttribute("time");
    List<Room> availableRoomList = (List<Room>) request.getAttribute("availableRoomList");

    List<Room> floor1 = new java.util.ArrayList<>();
    List<Room> floor2 = new java.util.ArrayList<>();
    if (availableRoomList != null && !availableRoomList.isEmpty()) {
        for (Room r : availableRoomList) {
            if (r.getRoomNumber() >= 1 && r.getRoomNumber() <= 5) floor1.add(r);
            else if (r.getRoomNumber() >= 6 && r.getRoomNumber() <= 10) floor2.add(r);
        }
    }
%>
<html>
<head>
    <title>Chọn phòng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/select_room.css?v=1.0">
    <script>
        let selectedRooms = [];
        function toggleRoom(roomId) {
            const idx = selectedRooms.indexOf(roomId);
            if (idx > -1) {
                selectedRooms.splice(idx, 1);
            } else {
                selectedRooms.push(roomId);
            }
            updateRoomButtons();
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
            document.getElementById('roomIdListInput').value = selectedRooms.join(',');
        }
        window.onload = function() {
            updateRoomButtons();
            updateRoomIdListInput();
        };
    </script>
</head>
<body>
<div class="container">
    <div class="main-content">
        <h2>Chọn phòng</h2>
        <div class="label-row">Ngày chiếu:
            <span><%= showDate != null ? showDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "" %></span>
        </div>
        <div class="label-row">Giờ chiếu:
            <span><%= showTime != null ? showTime.toString() : "" %></span>
        </div>
        <div class="phong-trong-title">Phòng trống</div>
        <form id="roomSelectForm" method="post" action="showtimes" onsubmit="updateRoomIdListInput()">
            <input type="hidden" name="action" value="chooseRooms"/>
            <input type="hidden" name="showDate" value="<%= showDate != null ? showDate.toString() : "" %>"/>
            <input type="hidden" name="timeSlot" value="<%= showTime != null ? showTime.toString() : "" %>"/>
            <input type="hidden" id="roomIdListInput" name="roomIdList" value="" />
            <div class="room-table-wrapper">
                <table class="room-table">
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
                        </td>
                    </tr>
                </table>
            </div>
        </form>
    </div>
    <div class="btn-group-room">
        <button type="submit" form="roomSelectForm" class="btn-confirm-room">Xác nhận</button>
        <a href="showtimes?action=addShowtimes" class="btn-cancel">Hủy</a>
    </div>
</div>
</body>
</html>