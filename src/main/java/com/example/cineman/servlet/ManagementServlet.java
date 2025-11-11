package com.example.cineman.servlet;

import com.example.cineman.dao.MovieDAO;
import com.example.cineman.dao.ShowtimeDAO;
import com.example.cineman.model.Movie;
import com.example.cineman.model.Showtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ManagementServlet", value = "/management")
public class ManagementServlet extends HttpServlet {
    private MovieDAO movieDAO = new MovieDAO();
    private ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        // pagination params
        int page = 1;
        int pageSize = 10;
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
        if (pageSize < 1) pageSize = 10;
        if (pageSize > MAX_PAGE_SIZE) pageSize = MAX_PAGE_SIZE;
        try {
            if ("searchMovie".equals(action)) {

                long totalMovie = movieDAO.countNowShowingMovie();
                int totalPages = (totalMovie == 0) ? 0 : (int) Math.ceil((double) totalMovie / pageSize);
                long offset = (long) (page - 1) * pageSize;
                if (offset < 0) offset = 0L;
                List<Movie> movieList = movieDAO.getNowShowingMovieList(offset, pageSize);

                req.setAttribute("currentPage", page);
                req.setAttribute("pageSize", pageSize);
                req.setAttribute("totalPages", totalPages);
                req.setAttribute("movieList", movieList);
                req.getRequestDispatcher("/WEB-INF/customer/SearchMovieView.jsp").forward(req, resp);

            } else if ("manageShowtimes".equals(action)) {
                // optional: allow client to pass a date filter, default = today
                LocalDate dateFilter = LocalDate.now();
                String dateParam = req.getParameter("date"); // format yyyy-MM-dd
                if (dateParam != null && !dateParam.isEmpty()) {
                    try {
                        dateFilter = LocalDate.parse(dateParam);
                    } catch (Exception ignored) {}
                }

                long totalRecords = showtimeDAO.countAvailableShowtime(dateFilter);
                int totalPages = (totalRecords == 0) ? 0 : (int) Math.ceil((double) totalRecords / pageSize);
                if (totalPages > 0 && page > totalPages) page = totalPages;

                long offset = (long) (page - 1) * pageSize;
                if (offset < 0) offset = 0L;

                List<Showtime> showtimeList = showtimeDAO.getAvailableShowtimeList(dateFilter, offset, pageSize);

                System.out.println("Total showtime pages: " + totalPages);
                System.out.println("Total showtimes: " + showtimeList.size());

                // set attributes for JSP
                req.setAttribute("showtimeList", showtimeList);
                req.setAttribute("currentPage", page);
                req.setAttribute("pageSize", pageSize);
                req.setAttribute("totalRecords", totalRecords);
                req.setAttribute("totalPages", totalPages);

                req.getRequestDispatcher("/WEB-INF/manager/ManageShowtimesView.jsp").forward(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

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
}