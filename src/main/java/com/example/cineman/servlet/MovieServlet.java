package com.example.cineman.servlet;

import com.example.cineman.dao.MovieDAO;
import com.example.cineman.model.Movie;
import com.example.cineman.model.Showtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name="MovieServlet", value="/movies")
public class MovieServlet extends HttpServlet {
    private MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "list"; // đổi default thành list (now showing)

        // pagination params (shared)
        int page = 1;
        int pageSize = 5;
        final int MAX_PAGE_SIZE = 500;

        try {
            String p = req.getParameter("page");
            String ps = req.getParameter("pageSize");
            if (p != null) page = Integer.parseInt(p);
            if (ps != null) pageSize = Integer.parseInt(ps);
        } catch (NumberFormatException ignored) {
            // keep defaults
        }
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 5;
        if (pageSize > MAX_PAGE_SIZE) pageSize = MAX_PAGE_SIZE;

        try {
            switch (action) {
                case "movieDetail":
                    // parse movieId
                    int movieId = Integer.parseInt(req.getParameter("movieId"));
                    // lấy movie
                    req.setAttribute("movie", movieDAO.getMovieDetail(movieId));

                    // Lấy trạng thái phân trang / filter từ URL (nếu có)
                    String pageParam = req.getParameter("page");
                    String pageSizeParam = req.getParameter("pageSize");
                    String movieNameParam = req.getParameter("movieName");

                    // parse an toàn
                    int fromPage = 1;
                    int fromPageSize = 10;
                    try {
                        if (pageParam != null) fromPage = Math.max(1, Integer.parseInt(pageParam));
                    } catch (NumberFormatException ignored) {}
                    try {
                        if (pageSizeParam != null) fromPageSize = Math.max(1, Integer.parseInt(pageSizeParam));
                    } catch (NumberFormatException ignored) {}

                    // truyền các giá trị xuống JSP để hiển thị nút "Quay lại" hoặc build link
                    req.setAttribute("backPage", fromPage);
                    req.setAttribute("backPageSize", fromPageSize);
                    req.setAttribute("backMovieName", movieNameParam == null ? "" : movieNameParam);

                    // hoặc build một backUrl hoàn chỉnh (URL encoded)
                    StringBuilder backUrl = new StringBuilder(req.getContextPath() + "/movies?action=search");
                    // chỉ thêm param nếu tồn tại (giữ URL gọn)
                    if (movieNameParam != null && !movieNameParam.isEmpty()) {
                        backUrl.append("&movieName=").append(java.net.URLEncoder.encode(movieNameParam, "UTF-8"));
                    }
                    backUrl.append("&page=").append(fromPage);
                    backUrl.append("&pageSize=").append(fromPageSize);
                    req.setAttribute("backUrl", backUrl.toString());

                    req.getRequestDispatcher("/WEB-INF/customer/MovieDetailView.jsp").forward(req, resp);
                    break;

                case "addMovie":
                    req.getRequestDispatcher("/WEB-INF/manager/AddMovieView.jsp").forward(req, resp);
                    break;

                case "selectMovie":
                    long totalAvailableMovie = movieDAO.countAvailableMovie(); // nếu chưa có, fallback bên dưới
                    int totalPagesMovie = (totalAvailableMovie == 0) ? 0 : (int) Math.ceil((double) totalAvailableMovie / pageSize);

                    long offsetMovie = (long) (page - 1) * pageSize;
                    if (offsetMovie < 0) offsetMovie = 0L;
                    if (totalPagesMovie > 0 && page > totalPagesMovie) page = totalPagesMovie;

                    List<Movie> movieAvailableList = movieDAO.getAvailableMovieList(offsetMovie, pageSize);

                    System.out.println("Total available movie pages: " + totalPagesMovie);

                    req.setAttribute("movieAvailableList", movieAvailableList);
                    req.setAttribute("totalAvailableMovie", totalAvailableMovie);
                    req.setAttribute("currentPage", page);
                    req.setAttribute("pageSize", pageSize);
                    req.setAttribute("totalPages", Math.max(1, totalPagesMovie));
                    req.getRequestDispatcher("/WEB-INF/manager/SelectMovieView.jsp").forward(req, resp);
                    break;

                case "search":
                    // lấy params
                    String title = req.getParameter("movieName") == null ? "" : req.getParameter("movieName").trim();

                    // Nếu MovieDAO hỗ trợ count + paged search, dùng API đó (recommended)
                    long totalSearch = movieDAO.countSearch(title); // nếu chưa có, fallback bên dưới
                    int totalPagesSearch = (totalSearch == 0) ? 0 : (int) Math.ceil((double) totalSearch / pageSize);
                    long offsetSearch = (long) (page - 1) * pageSize;
                    if (offsetSearch < 0) offsetSearch = 0L;
                    if (totalPagesSearch > 0 && page > totalPagesSearch) page = totalPagesSearch;

                    // lấy page kết quả
                    List<Movie> searchPage;
                    try {
                        searchPage = movieDAO.searchMovieByTitle(title, offsetSearch, pageSize);
                    } catch (UnsupportedOperationException ex) {
                        // Nếu DAO chưa có paging, fallback: lấy toàn bộ rồi subList (kém hiệu năng)
                        List<Movie> all = movieDAO.searchMovieByTitle(title);
                        totalSearch = all.size();
                        totalPagesSearch = (int) Math.max(1, Math.ceil((double) totalSearch / pageSize));
                        int from = (page - 1) * pageSize;
                        int to = Math.min(from + pageSize, all.size());
                        if (from > all.size()) {
                            searchPage = new ArrayList<>();
                        } else {
                            searchPage = new ArrayList<>(all.subList(from, to));
                        }
                    }

                    req.setAttribute("movieList", searchPage);
                    req.setAttribute("total", totalSearch);
                    req.setAttribute("currentPage", page);
                    req.setAttribute("pageSize", pageSize);
                    req.setAttribute("totalPages", Math.max(1, totalPagesSearch));
                    req.setAttribute("pageButtons", buildPageButtons(page, Math.max(1, totalPagesSearch), 7));
                    req.getRequestDispatcher("/WEB-INF/customer/SearchMovieView.jsp").forward(req, resp);
                    break;

                default: // list / now showing with pagination
                    long totalNowShowingMovie = movieDAO.countNowShowingMovie();

                    int totalPages = (totalNowShowingMovie == 0) ? 0 : (int) Math.ceil((double) totalNowShowingMovie / pageSize);
                    long offset = (long) (page - 1) * pageSize;
                    if (offset < 0) offset = 0L;
                    if (totalPages > 0 && page > totalPages) page = totalPages;

                    List<Movie> nowShowingMovieList = movieDAO.getNowShowingMovieList(offset, pageSize);

                    req.setAttribute("movieList", nowShowingMovieList);
                    req.setAttribute("total", totalNowShowingMovie);
                    req.setAttribute("currentPage", page);
                    req.setAttribute("pageSize", pageSize);
                    req.setAttribute("totalPages", Math.max(1, totalPages));
                    req.setAttribute("pageButtons", buildPageButtons(page, Math.max(1, totalPages), 7));
                    req.getRequestDispatcher("/WEB-INF/customer/SearchMovieView.jsp").forward(req, resp);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // Helper: sinh danh sách nút trang (Integer hoặc String "...")
    private List<Object> buildPageButtons(int current, int totalPages, int maxButtons) {
        List<Object> pages = new ArrayList<>();
        if (totalPages <= maxButtons) {
            for (int i = 1; i <= totalPages; i++) pages.add(i);
            return pages;
        }
        int side = (maxButtons - 3) / 2;
        int left = Math.max(2, current - side);
        int right = Math.min(totalPages - 1, current + side);

        pages.add(1);
        if (left > 2) pages.add("...");
        for (int i = left; i <= right; i++) pages.add(i);
        if (right < totalPages - 1) pages.add("...");
        pages.add(totalPages);
        return pages;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // giữ nguyên xử lý của bạn...
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) action = "saveMovie";
        try{
            switch (action) {
                case "chooseMovie":
                    int movieId = Integer.parseInt(req.getParameter("selectedMovieId"));
                    String movieTitle = req.getParameter("selectedMovieTitle");
                    HttpSession session = req.getSession();
                    List<Showtime> tempShowtimes = (List<Showtime>) session.getAttribute("tempShowtimes");
                    if (tempShowtimes != null) {
                        for(Showtime st : tempShowtimes){
                            st.setMovie(new Movie(){{
                                setId(movieId);
                                setTitle(movieTitle);
                            }});
                        }
                    }
                    resp.sendRedirect("showtimes?action=addShowtimes");
                    break;
                case "saveMovie":
                    Movie movie = new Movie();
                    movie.setTitle(req.getParameter("title"));
                    movie.setDescription(req.getParameter("description"));
                    movie.setDirector(req.getParameter("director"));
                    movie.setGenre(req.getParameter("genre"));
                    movie.setLanguage(req.getParameter("language"));
                    movie.setMainCast(req.getParameter("mainCast"));
                    movie.setTrailer(req.getParameter("trailer"));
                    movie.setDuration(Integer.parseInt(req.getParameter("duration")));
                    movie.setAgeRating(Integer.parseInt(req.getParameter("ageRating")));
                    movie.setReleaseDate(java.time.LocalDate.parse(req.getParameter("releaseDate")));
                    movie.setStatus(req.getParameter("status"));
                    boolean success = movieDAO.saveMovie(movie);
                    if (success) {
                        resp.sendRedirect(req.getContextPath() + "/movies?action=selectMovie&message=success");
                        return;
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/movies?action=addMovie&message=fail");
                        return;
                    }
                default:
                    resp.sendRedirect("showtimes?action=addShowtimes");
            }
        }catch (Exception e) {
            throw new ServletException(e);
        }
    }
}