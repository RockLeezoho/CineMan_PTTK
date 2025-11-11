<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.*, com.example.cineman.model.Movie" %>
<%@ page import="java.net.URLEncoder" %>
<%
    // Lấy danh sách phim từ servlet (được giả định là đã là page hiện tại)
    List<Movie> movieList = (List<Movie>) request.getAttribute("movieAvailableList");
    String message = request.getParameter("message");

    // Phân trang: ưu tiên attribute do servlet gán, nếu không có dùng param, nếu param không có thì fallback
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    int currentPage = currentPageObj != null ? currentPageObj : 1;
    try {
        currentPage = (request.getParameter("page") == null) ? currentPage : Integer.parseInt(request.getParameter("page"));
    } catch (Exception ex) {
        currentPage = currentPage;
    }

    Integer pageSizeObj = (Integer) request.getAttribute("pageSize");
    int pageSize = pageSizeObj != null ? pageSizeObj : 10;
    try {
        pageSize = (request.getParameter("pageSize") == null) ? pageSize : Integer.parseInt(request.getParameter("pageSize"));
    } catch (Exception ex) {
        pageSize = pageSize;
    }

    Long totalObj = (Long) request.getAttribute("totalAvailableMovie");
    long total = totalObj != null ? totalObj : ((movieList == null) ? 0L : (long) movieList.size());

    int totalPages = (int) ((total + pageSize - 1) / pageSize);
    if (totalPages == 0) totalPages = 1;

    int sttStart = (currentPage - 1) * pageSize + 1;
    int stt = sttStart;

    // Preserve any search/filter parameter if present (so pagination keeps context)
    String movieNameParam = request.getParameter("movieName") == null ? "" : request.getParameter("movieName");
    String encodedMovieName = "";
    try { encodedMovieName = URLEncoder.encode(movieNameParam, "UTF-8"); } catch(Exception e){ encodedMovieName = movieNameParam; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chọn phim</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/select_movie.css?v=1.0">
    <script>
        window.onload = function() {
            var alert = document.getElementById('movie-success-alert');
            if (alert) {
                setTimeout(function() { alert.style.opacity = "0"; }, 1000);
                setTimeout(function() { if (alert) alert.style.display = "none"; }, 1600);
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

    <form method="get" action="${pageContext.request.contextPath}/movies" style="margin-bottom:8px;">
        <input type="hidden" name="action" value="addMovie"/>
        <button type="submit" class="btn-add-movie">Thêm mới</button>
    </form>

    <div class="movie-table-title">Danh sách phim khả dụng</div>

    <table class="movie-table">
        <tr>
            <th>STT</th>
            <th>Mã phim</th>
            <th>Tên phim</th>
            <th>Độ tuổi (>=)</th>
            <th>Thời lượng (phút)</th>
            <th>Trạng thái</th>
            <th>Chọn</th>
        </tr>

        <%
            if (movieList != null && !movieList.isEmpty()) {
                for (Movie m : movieList) {
        %>
        <tr>
            <td><%= stt++ %></td>
            <td><%= "M" + m.getId() %></td>
            <td><%= m.getTitle() %></td>
            <td><%= m.getAgeRating() != 0 ? m.getAgeRating() : "Mọi độ tuổi" %></td>
            <td><%= m.getDuration() %></td>
            <td><%= m.getStatus() %></td>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/movies" style="display:inline;">
                    <input type="hidden" name="action" value="chooseMovie"/>
                    <input type="hidden" name="selectedMovieId" value="<%= m.getId() %>"/>
                    <input type="hidden" name="selectedMovieTitle" value="<%= m.getTitle() %>"/>
                    <!-- giữ lại trạng thái phân trang để servlet có thể chuyển hướng về trang đúng nếu cần -->
                    <input type="hidden" name="page" value="<%= currentPage %>"/>
                    <input type="hidden" name="pageSize" value="<%= pageSize %>"/>
                    <button type="submit" class="btn-choose-movie">Chọn</button>
                </form>
            </td>
        </tr>
        <%
                }
            } else {
        %>
        <tr>
            <td colspan="7" style="color:#c00;">Không có phim khả dụng</td>
        </tr>
        <% } %>
    </table>

    <!-- Pagination (Prev, current page, Next) -->
    <div class="pagination" aria-label="Pagination" style="display:flex; align-items:center; gap:12px; margin-top:12px;">
        <div class="pager-left">Tổng số: <strong><%= total %></strong></div>

        <div class="pager-center" style="display:flex; align-items:center; gap:12px; min-width:200px; justify-content:center;">
            <%
                boolean prevDisabled = currentPage <= 1;
                boolean nextDisabled = currentPage >= totalPages;
            %>

            <!-- Prev -->
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:inline;">
                <input type="hidden" name="action" value="selectMovie"/>
                <input type="hidden" name="movieName" value="<%= movieNameParam %>" />
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= prevDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.max(1, currentPage - 1) %>" <%= prevDisabled ? "disabled" : "" %> >&lt;</button>
            </form>

            <!-- Current page -->
            <div class="page-number" aria-current="page">
                <%= currentPage %>
            </div>

            <!-- Next -->
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:inline;">
                <input type="hidden" name="action" value="selectMovie"/>
                <input type="hidden" name="movieName" value="<%= movieNameParam %>" />
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= nextDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.min(totalPages, currentPage + 1) %>" <%= nextDisabled ? "disabled" : "" %> >&gt;</button>
            </form>
        </div>

        <div class="pager-right" style="margin-left:auto;">
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:flex; align-items:center; gap:8px;">
                <input type="hidden" name="action" value="selectMovie"/>
                <input type="hidden" name="movieName" value="<%= movieNameParam %>" />
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

    <form method="get" action="${pageContext.request.contextPath}/showtimes" style="margin-top:12px;">
        <input type="hidden" name="action" value="addShowtimes"/>
        <button type="submit" class="btn-cancel-movie">Hủy</button>
    </form>
</div>
</body>
</html>