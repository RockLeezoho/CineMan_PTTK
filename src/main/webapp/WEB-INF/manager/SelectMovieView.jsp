<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.example.cineman.model.Movie" %>
<%
    // Lấy danh sách phim từ servlet
    List<Movie> movieList = (List<Movie>) request.getAttribute("movieList");
    String message = request.getParameter("message");
%>
<html>
<head>
    <title>Chọn phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/select_movie.css?v=1.0">
    <script>
        window.onload = function() {
            var alert = document.getElementById('movie-success-alert');
            if (alert) {
                setTimeout(function() {
                    alert.style.opacity = "0";
                }, 1000);
                setTimeout(function() {
                    if (alert) alert.style.display = "none";
                }, 1600);
            }
        }
    </script>
</head>
<body>
<div class="container-movie">
    <div class="movie-header">Chọn phim</div>
    <% if ("success".equals(message)) { %>
        <div class="alert-success" id="movie-success-alert">
            Thêm phim thành công!
        </div>
    <% } %>
    <form method="get" action="movies" style="margin-bottom:8px;">
        <input type="hidden" name="action" value="addMovie"/>
        <button type="submit" class="btn-add-movie">Thêm mới</button>
    </form>
    <div class="movie-table-title">Danh sách phim khả dụng</div>
    <table class="movie-table">
        <tr>
            <th>STT</th>
            <th>Mã phim</th>
            <th>Tên phim</th>
            <th>Độ tuổi</th>
            <th>Thời lượng (phút)</th>
            <th>Trạng thái</th>
            <th>Chọn</th>
        </tr>
        <%
            if (movieList != null && !movieList.isEmpty()) {
                int idx = 1;
                for (Movie m : movieList) {
        %>
        <tr>
            <td><%= idx %></td>
            <td><%= m.getId() %></td>
            <td><%= m.getTitle() %></td>
            <td><%= m.getAgeRating() != 0 ? m.getAgeRating() : "Mọi độ tuổi" %></td>
            <td><%= m.getDuration() %></td>
            <td><%= m.getStatus() %></td>
            <td>
                <form method="post" action="movies" style="display:inline;">
                    <input type="hidden" name="action" value="chooseMovie"/>
                    <input type="hidden" name="selectedMovieId" value="<%= m.getId() %>"/>
                    <input type="hidden" name="selectedMovieTitle" value="<%= m.getTitle() %>"/>
                    <button type="submit" class="btn-choose-movie">Chọn</button>
                </form>
            </td>
        </tr>
        <% idx++; }} else { %>
        <tr>
            <td colspan="7" style="color:#c00;">Không có phim khả dụng</td>
        </tr>
        <% } %>
    </table>
    <form method="get" action="showtimes">
        <input type="hidden" name="action" value="addShowtimes"/>
        <button type="submit" class="btn-cancel-movie">Hủy</button>
    </form>
</div>
</body>
</html>