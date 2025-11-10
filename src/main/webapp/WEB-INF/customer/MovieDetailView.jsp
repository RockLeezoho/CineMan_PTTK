<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.cineman.model.Movie, java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chi tiết phim</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/movie_detail.css?v=1.0">
</head>
<body>
<div class="container">
    <%
        Movie movie = (Movie) request.getAttribute("movie");
        String releaseDateStr = "";
        if (movie.getReleaseDate() != null) {
            try {
                DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                LocalDate date = LocalDate.parse(movie.getReleaseDate().toString(), inputFormatter);
                releaseDateStr = date.format(outputFormatter);
            } catch (Exception ex) {
                releaseDateStr = movie.getReleaseDate().toString();
            }
        }
        String statusLabel = "";
        if ("now_showing".equals(movie.getStatus())) {
            statusLabel = "Đang chiếu";
        } else if ("upcoming".equals(movie.getStatus())) {
            statusLabel = "Sắp chiếu";
        } else if ("ended".equals(movie.getStatus())) {
            statusLabel = "Dừng chiếu";
        } else {
            statusLabel = movie.getStatus() != null ? movie.getStatus() : "";
        }
    %>

    <div class="movie-title"><%= movie.getTitle() %></div>

    <div class="table-wrapper">
        <table>
            <tr>
                <td class="label">Đạo diễn</td>
                <td><%= movie.getDirector() %></td>
            </tr>
            <tr>
                <td class="label">Diễn viên</td>
                <td><%= movie.getMainCast() %></td>
            </tr>
            <tr>
                <td class="label">Thể loại</td>
                <td><%= movie.getGenre() %></td>
            </tr>
            <tr>
                <td class="label">Khởi chiếu</td>
                <td><%= releaseDateStr %></td>
            </tr>
            <tr>
                <td class="label">Thời lượng</td>
                <td><%= movie.getDuration() %> phút</td>
            </tr>
            <tr>
                <td class="label">Ngôn ngữ</td>
                <td><%= movie.getLanguage() %></td>
            </tr>
            <tr>
                <td class="label">Độ tuổi</td>
                <td><%= movie.getAgeRating() %></td>
            </tr>
            <tr>
                <td class="label">Tóm tắt nội dung</td>
                <td><%= movie.getDescription() %></td>
            </tr>
            <tr>
                <td class="label">Trailer</td>
                <td>
                    <%
                        String trailer = movie.getTrailer();
                        if (trailer != null && trailer.startsWith("http")) {
                    %>
                        <a href="<%= trailer %>" target="_blank"><%= trailer %></a>
                    <%
                        } else {
                            out.print(trailer != null ? trailer : "");
                        }
                    %>
                </td>
            </tr>
            <tr>
                <td class="label">Trạng thái</td>
                <td><%= statusLabel %></td>
            </tr>
        </table>
    </div>

    <div class="back-btn-wrapper">
        <form action="${pageContext.request.contextPath}/movies" method="get" style="margin:0;">
            <input type="hidden" name="action" value="search"/>
            <input type="hidden" name="movieName" value="<%= request.getAttribute("backMovieName") != null ? (String)request.getAttribute("backMovieName") : (request.getParameter("movieName") == null ? "" : request.getParameter("movieName")) %>"/>
            <input type="hidden" name="page" value="<%= request.getAttribute("backPage") != null ? request.getAttribute("backPage") : (request.getParameter("page") == null ? "1" : request.getParameter("page")) %>" />
            <input type="hidden" name="pageSize" value="<%= request.getAttribute("backPageSize") != null ? request.getAttribute("backPageSize") : (request.getParameter("pageSize") == null ? "10" : request.getParameter("pageSize")) %>" />
            <button class="back-btn" type="submit">&lt; Quay lại</button>
        </form>
    </div>
</div>
</body>
</html>
