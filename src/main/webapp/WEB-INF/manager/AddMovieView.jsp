<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.example.cineman.model.Movie" %>
<%
    Movie movie = (Movie) request.getAttribute("movie"); // Nếu sửa thì truyền movie vào, nếu thêm mới thì để null
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
%>
<html>
<head>
    <title>Thêm phim mới</title>
    <link rel="stylesheet" href="assets/css/add_movie.css"/>
</head>
<body>
<div class="container-movie">
    <div class="movie-header">Thêm phim mới</div>
    <form class="form-movie" method="post" action="movies">
        <input type="hidden" name="action" value="saveMovie"/>
        <div class="form-row">
            <label for="title">Tên phim</label>
            <input type="text" id="title" name="title" required value="<%= movie != null ? movie.getTitle() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="director">Đạo diễn</label>
            <input type="text" id="director" name="director" required value="<%= movie != null ? movie.getDirector() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="mainCast">Diễn viên chính</label>
            <input type="text" id="mainCast" name="mainCast" required value="<%= movie != null ? movie.getMainCast() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="genre">Thể loại</label>
            <input type="text" id="genre" name="genre" required value="<%= movie != null ? movie.getGenre() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="releaseDate">Ngày phát hành</label>
            <input type="date" id="releaseDate" name="releaseDate" required
                value="<%= movie != null && movie.getReleaseDate() != null ? movie.getReleaseDate().format(dateFormatter) : "" %>"/>
        </div>
        <div class="form-row">
            <label for="duration">Thời lượng (phút)</label>
            <input type="number" id="duration" name="duration" required min="1" value="<%= movie != null ? movie.getDuration() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="language">Ngôn ngữ</label>
            <input type="text" id="language" name="language" required value="<%= movie != null ? movie.getLanguage() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="ageRating">Độ tuổi</label>
            <input type="number" id="ageRating" name="ageRating" min="0" required value="<%= movie != null ? movie.getAgeRating() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="trailer">Trailer</label>
            <input type="text" id="trailer" name="trailer" value="<%= movie != null ? movie.getTrailer() : "" %>"/>
        </div>
        <div class="form-row">
            <label for="status">Trạng thái</label>
            <select id="status" name="status" required>
                <option value="">-- Chọn trạng thái --</option>
                <option value="now_showing" <%= (movie != null && "now_showing".equals(movie.getStatus())) ? "selected" : "" %>>Đang chiếu</option>
                <option value="upcoming" <%= (movie != null && "upcoming".equals(movie.getStatus())) ? "selected" : "" %>>Sắp chiếu</option>
                <option value="ended" <%= (movie != null && "ended".equals(movie.getStatus())) ? "selected" : "" %>>Dừng chiếu</option>
            </select>
        </div>
        <div class="btn-row">
            <button type="submit" class="btn-save-movie">Lưu</button>
            <button type="button" class="btn-cancel-movie" onclick="window.location.href='movies?action=selectMovie'">Hủy</button>
        </div>
    </form>
</div>
</body>
</html>