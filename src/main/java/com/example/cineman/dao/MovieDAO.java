package com.example.cineman.dao;

import com.example.cineman.model.Movie;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class MovieDAO extends DAO{

    public long countNowShowingMovie() throws SQLException {
        String sql = "SELECT COUNT(*) FROM tblmovie WHERE status = 'now_showing'";
        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0L;
    }

    public List<Movie> getNowShowingMovieList(long offset, int limit) throws SQLException{
        List<Movie> movieList = new ArrayList<>();
        String sql = "SELECT * FROM tblmovie WHERE status = 'now_showing' ORDER BY id DESC LIMIT ? OFFSET ?";

        try (PreparedStatement ps = con.prepareStatement(sql)){
            ps.setInt(1, limit);
            ps.setLong(2, offset);
            try(ResultSet rs = ps.executeQuery()){
                while (rs.next()) {
                    Movie movie = mapMovieFromResultSet(rs);
                    movieList.add(movie);
                }
            }
        }
        return movieList;
    }

    public Movie getMovieDetail(int movieId) throws SQLException {
        Movie movie = null;
        String sql = "SELECT * FROM tblmovie WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    movie = mapMovieFromResultSet(rs);
                }
            }
        }
        return movie;
    }

    public long countAvailableMovie() throws SQLException {

        String sql = "SELECT COUNT(*) FROM tblmovie WHERE status IN ('now_showing', 'upcoming')";
        try (PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();) {
                if (rs.next()) return rs.getLong(1);
        }
        return 0L;
    }

    public List<Movie> getAvailableMovieList(long offset, int limit) throws SQLException {
        List<Movie> movieList = new ArrayList<>();
        String sql = "SELECT * FROM tblmovie WHERE status IN ('now_showing', 'upcoming') "
                + "ORDER BY id DESC "
                + "LIMIT ? OFFSET ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setLong(2, offset);
            try(ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Movie movie = mapMovieFromResultSet(rs);
                    movieList.add(movie);
                }
            }
        }
        return movieList;
    }

    /**
     * Full search (không phân trang) - giữ lại để tương thích.
     */
    public List<Movie> searchMovieByTitle(String title) throws SQLException {
        List<Movie> movieList = new ArrayList<>();
        String sql = "SELECT * FROM tblmovie WHERE LOWER(title) LIKE ? ORDER BY id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String q = "%" + (title == null ? "" : title.toLowerCase()) + "%";
            ps.setString(1, q);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Movie movie = mapMovieFromResultSet(rs);
                    movieList.add(movie);
                }
            }
        }
        return movieList;
    }

    /**
     * Count matching movies for a search title (dùng để tính total pages).
     * If title is null or empty, counts all rows.
     */
    public long countSearch(String title) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tblmovie WHERE LOWER(title) LIKE ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String q = "%" + (title == null ? "" : title.toLowerCase()) + "%";
            ps.setString(1, q);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        return 0L;
    }

    /**
     * Paged search: return a page of movies matching title using LIMIT/OFFSET.
     */
    public List<Movie> searchMovieByTitle(String title, long offset, int limit) throws SQLException {
        List<Movie> movieList = new ArrayList<>();
        String sql = "SELECT * FROM tblmovie WHERE LOWER(title) LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            String q = "%" + (title == null ? "" : title.toLowerCase()) + "%";
            ps.setString(1, q);
            ps.setInt(2, limit);
            ps.setLong(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Movie movie = mapMovieFromResultSet(rs);
                    movieList.add(movie);
                }
            }
        }
        return movieList;
    }

    public boolean saveMovie(Movie newMovie) throws SQLException {
        String sql = "INSERT INTO tblmovie (title, description, director, genre, releasedate, duration, language, maincast, agerating, trailer, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newMovie.getTitle());
            ps.setString(2, newMovie.getDescription());
            ps.setString(3, newMovie.getDirector());
            ps.setString(4, newMovie.getGenre());
            ps.setDate(5, java.sql.Date.valueOf(newMovie.getReleaseDate()));
            ps.setInt(6, newMovie.getDuration());
            ps.setString(7, newMovie.getLanguage());
            ps.setString(8, newMovie.getMainCast());
            ps.setInt(9, newMovie.getAgeRating());
            ps.setString(10, newMovie.getTrailer());
            ps.setString(11, newMovie.getStatus());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        }
    }

    /**
     * Helper: map ResultSet -> Movie and handle null releaseDate safely.
     */
    private Movie mapMovieFromResultSet(ResultSet rs) throws SQLException {
        Movie movie = new Movie();
        movie.setId(rs.getInt("id"));
        movie.setTitle(rs.getString("title"));
        movie.setDescription(rs.getString("description"));
        movie.setDirector(rs.getString("director"));
        movie.setGenre(rs.getString("genre"));

        Date sqlDate = rs.getDate("releasedate");
        if (sqlDate != null) {
            movie.setReleaseDate(sqlDate.toLocalDate());
        } else {
            movie.setReleaseDate(null);
        }

        movie.setDuration(rs.getInt("duration"));
        movie.setLanguage(rs.getString("language"));
        movie.setMainCast(rs.getString("maincast"));
        movie.setAgeRating(rs.getInt("agerating"));
        movie.setTrailer(rs.getString("trailer"));
        movie.setStatus(rs.getString("status"));
        return movie;
    }
}