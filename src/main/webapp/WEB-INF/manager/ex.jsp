<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, com.example.cineman.model.Movie, java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Tìm thông tin phim</title>
    <link rel="stylesheet" href="assets/css/search_movie.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
</head>
<body>
<div class="container">
    <h2>Tìm thông tin phim</h2>

    <!-- Thanh tìm kiếm -->
    <form class="search-box" action="movies" method="get">
        <input type="hidden" name="action" value="search"/>
        <input class="search-input" type="text" name="movieName" placeholder="Nhập tên phim"
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
                DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                if (movieList != null && !movieList.isEmpty()) {
                    int stt = 1;
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
                    <a class="detail-lnk" href="movies?action=movieDetail&movieId=<%= movie.getId() %>">
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

    <!-- Pagination -->
    <div class="pagination">
        <button class="pagination-btn" type="button" disabled>&lt;</button>
        <span class="page-number">1</span>
        <button class="pagination-btn" type="button" disabled>&gt;</button>
    </div>
</div>
</body>
</html>
