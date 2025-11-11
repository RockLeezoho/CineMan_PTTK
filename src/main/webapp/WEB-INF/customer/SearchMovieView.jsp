<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.example.cineman.model.Movie, java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tìm thông tin phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/search_movie.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
<div class="container">
    <h2>Tìm thông tin phim</h2>

    <!-- Thanh tìm kiếm -->
    <form class="search-box" action="${pageContext.request.contextPath}/movies" method="get">
        <input type="hidden" name="action" value="search"/>
        <input class="search-input" type="text" name="movieName" placeholder="Nhập tên phim..."
               value="<%= request.getParameter("movieName") != null ? request.getParameter("movieName") : "" %>"/>
        <button class="search-btn" type="submit">Tìm</button>
    </form>

    <div class="table-title">Các phim đang chiếu</div>

    <div class="table-wrapper">
        <table>
            <thead>
            <tr>
                <th>TT</th>
                <th>Tên phim</th>
                <th>Thể loại</th>
                <th>Độ tuổi (&gt;=)</th>
                <th>Thời lượng (phút)</th>
                <th>Khởi chiếu</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <%
                List<Movie> movieList = (List<Movie>) request.getAttribute("movieList");
                // Các giá trị phân trang có thể được set bởi servlet. Nếu không có, dùng mặc định.
                Integer currentPage = null;
                Integer pageSize = null;
                Long total = null;
                Integer totalPages = null;

                if (request.getAttribute("currentPage") != null) {
                    currentPage = (Integer) request.getAttribute("currentPage");
                } else {
                    try { currentPage = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page")); }
                    catch(Exception ex){ currentPage = 1; }
                }

                if (request.getAttribute("pageSize") != null) {
                    pageSize = (Integer) request.getAttribute("pageSize");
                } else {
                    try { pageSize = Integer.parseInt(request.getParameter("pageSize") == null ? "10" : request.getParameter("pageSize")); }
                    catch(Exception ex){ pageSize = 10; }
                }

                if (request.getAttribute("total") != null) {
                    total = (Long) request.getAttribute("total");
                } else {
                    // fallback: nếu servlet không truyền total, dùng kích thước movieList
                    total = (movieList == null) ? 0L : (long) movieList.size();
                }

                totalPages = (int) ((total + pageSize - 1) / pageSize);
                if (totalPages == 0) totalPages = 1;

                DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

                // Hiển thị dữ liệu movieList (movieList được giả định là đã là page hiện tại)
                if (movieList != null && !movieList.isEmpty()) {
                    int sttStart = (currentPage - 1) * pageSize + 1;
                    int stt = sttStart;
                    for (Movie movie : movieList) {
                        String releaseDateStr = "";
                        if (movie.getReleaseDate() != null) {
                            try {
                                LocalDate date = LocalDate.parse(movie.getReleaseDate().toString(), inputFormatter);
                                releaseDateStr = date.format(outputFormatter);
                            } catch (Exception ex) {
                                releaseDateStr = movie.getReleaseDate().toString();
                            }
                        }
            %>
            <tr>
                <td><%= stt++ %></td>
                <td><%= movie.getTitle() %></td>
                <td><%= movie.getGenre() %></td>
                <td><%= movie.getAgeRating() %></td>
                <td><%= movie.getDuration() %></td>
                <td><%= releaseDateStr %></td>
                <td>
                  <%
                    String ctx = request.getContextPath();
                    String movieName = request.getParameter("movieName") == null ? "" : java.net.URLEncoder.encode(request.getParameter("movieName"), "UTF-8");
                    int cp = (request.getAttribute("currentPage") != null) ? (Integer)request.getAttribute("currentPage") : Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
                    int ps = (request.getAttribute("pageSize") != null) ? (Integer)request.getAttribute("pageSize") : Integer.parseInt(request.getParameter("pageSize") == null ? "10" : request.getParameter("pageSize"));
                  %>
                  <a class="detail-lnk"
                     href="<%= ctx %>/movies?action=movieDetail&movieId=<%= movie.getId() %>&page=<%= cp %>&pageSize=<%= ps %>&movieName=<%= movieName %>">
                    <i class="bi bi-info-circle"></i>
                  </a>
                </td>
            </tr>
            <%
                    }
                } else {
            %>
            <tr>
                <td colspan="7">Không có phim nào phù hợp</td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <!-- Simplified Pagination (only Prev, current page, Next) -->
    <div class="pagination" aria-label="Pagination">
        <div class="pager-left">Tổng số: <strong><%= total %></strong></div>

        <div class="pager-center" style="gap:12px; min-width:200px; justify-content:center;">
            <%
                boolean prevDisabled = currentPage <= 1;
                boolean nextDisabled = currentPage >= totalPages;
                String movieNameParam = request.getParameter("movieName") == null ? "" : request.getParameter("movieName");
            %>

            <!-- Prev -->
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:inline">
                <input type="hidden" name="action" value=""/>
                <input type="hidden" name="movieName" value="<%= movieNameParam %>" />
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= prevDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.max(1, currentPage - 1) %>" <%= prevDisabled ? "disabled" : "" %> >&lt;</button>
            </form>

            <!-- Current page only -->
            <div class="page-number" aria-current="page">
                <%= currentPage %>
            </div>

            <!-- Next -->
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:inline">
                <input type="hidden" name="action" value=""/>
                <input type="hidden" name="movieName" value="<%= movieNameParam %>" />
                <input type="hidden" name="pageSize" value="<%= pageSize %>" />
                <button class="pagination-btn <%= nextDisabled ? "disabled" : "" %>" type="submit" name="page" value="<%= Math.min(totalPages, currentPage + 1) %>" <%= nextDisabled ? "disabled" : "" %> >&gt;</button>
            </form>
        </div>

        <div class="pager-right">
            <form method="get" action="${pageContext.request.contextPath}/movies" style="display:flex; align-items:center; gap:8px;">
                <input type="hidden" name="action" value=""/>
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
</div>
</body>
</html>