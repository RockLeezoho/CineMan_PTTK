package com.example.cineman.dao;

import com.example.cineman.model.Movie;
import com.example.cineman.model.Room;
import com.example.cineman.model.Showtime;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

public class ShowtimeDAO extends DAO {
    private MovieDAO movieDAO  = new MovieDAO();

    public long getAvailableShowtimeCount(LocalDate currentDate) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tblshowtime s WHERE s.showdate >= ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(currentDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        }
        return 0L;
    }

    public List<Showtime> getAvailableShowtimeList(LocalDate currentDate, long offset, int limit) throws SQLException {
        List<Showtime> showtimeList = new ArrayList<>();
        String sql =
                "SELECT s.id, s.showdate, s.timeslot, s.baseprice, s.tblmovieid, m.title AS movie_title " +
                        "FROM tblshowtime s " +
                        "LEFT JOIN tblmovie m ON s.tblmovieid = m.id " +
                        "WHERE s.showdate >= ? " +
                        "ORDER BY s.showdate, s.timeslot " +
                        "LIMIT ? OFFSET ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(currentDate));
            ps.setInt(2, limit);
            ps.setLong(3, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Showtime showtime = mapShowtimeMinimalFromResultSet(rs);
                    showtimeList.add(showtime);
                }
            }
        }

        // Batch load rooms for all showtimes in this page to avoid N+1 queries
        if (!showtimeList.isEmpty()) {
            loadRoomsForShowtimes(showtimeList);
        }

        return showtimeList;
    }

    public List<Showtime> getAvailableShowtimeList(LocalDate currentDate) throws SQLException {
        List<Showtime> showtimeList = new ArrayList<>();
        String sql =
                "SELECT s.id, s.showdate, s.timeslot, s.baseprice, s.tblmovieid, m.title AS movie_title " +
                        "FROM tblshowtime s " +
                        "LEFT JOIN tblmovie m ON s.tblmovieid = m.id " +
                        "WHERE s.showdate >= ? " +
                        "ORDER BY s.showdate, s.timeslot";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(currentDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Showtime showtime = mapShowtimeMinimalFromResultSet(rs);
                    showtimeList.add(showtime);
                }
            }
        }

        if (!showtimeList.isEmpty()) {
            loadRoomsForShowtimes(showtimeList);
        }

        return showtimeList;
    }

    private Showtime mapShowtimeMinimalFromResultSet(ResultSet rs) throws SQLException {
        Showtime showtime = new Showtime();
        showtime.setId(rs.getInt("id"));

        Date sqlDate = rs.getDate("showdate");
        Time sqlTime = rs.getTime("timeslot");
        if (sqlDate != null && sqlTime != null) {
            showtime.setShowDate(sqlDate.toLocalDate());
            showtime.setTimeSlot(sqlTime.toLocalTime());
        } else {
            throw new SQLException("Error retrieving showdate or timeslot from database.");
        }

        BigDecimal bd = rs.getBigDecimal("baseprice");
        if (bd != null) {
            showtime.setBasePrice(bd.floatValue());
        }

        Movie movie = new Movie();
        movie.setId(rs.getInt("tblmovieid"));
        // movie_title lấy từ alias trong query (có thể null nếu không có movie)
        String movieTitle = rs.getString("movie_title");
        if (movieTitle != null) movie.setTitle(movieTitle);
        else {
            // fallback: nếu cần chi tiết hơn, bạn có thể gọi movieDAO.getMovieDetail(movie.getId())
            movie.setTitle(null);
        }
        showtime.setMovie(movie);

        return showtime;
    }

    private void loadRoomsForShowtimes(List<Showtime> showtimes) throws SQLException {
        if (showtimes == null || showtimes.isEmpty()) return;

        // Tạo danh sách id để dùng trong IN (...)
        List<Integer> ids = showtimes.stream().map(Showtime::getId).collect(Collectors.toList());

        // Build placeholder (?, ?, ?, ...) với số lượng ids
        String placeholders = ids.stream().map(id -> "?").collect(Collectors.joining(","));
        String sql =
                "SELECT sr.tblshowtimeid, r.id AS room_id, r.roomnumber, r.description " +
                        "FROM tblshowtimeroom sr " +
                        "JOIN tblroom r ON r.id = sr.tblroomid " +
                        "WHERE sr.tblshowtimeid IN (" + placeholders + ") " +
                        "ORDER BY sr.tblshowtimeid, r.roomnumber";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;
            for (Integer id : ids) {
                ps.setInt(idx++, id);
            }
            try (ResultSet rs = ps.executeQuery()) {
                Map<Integer, List<Room>> map = new HashMap<>();
                while (rs.next()) {
                    int showtimeId = rs.getInt("tblshowtimeid");
                    Room room = new Room();
                    room.setId(rs.getInt("room_id"));
                    room.setRoomNumber(rs.getInt("roomnumber"));
                    room.setDescription(rs.getString("description"));
                    map.computeIfAbsent(showtimeId, k -> new ArrayList<>()).add(room);
                }
                // assign rooms back to showtime objects
                for (Showtime s : showtimes) {
                    List<Room> rlist = map.get(s.getId());
                    if (rlist != null) s.setRooms(rlist);
                    else s.setRooms(new ArrayList<>()); // empty list if none
                }
            }
        }
    }

    public List<Room> getRoomListByShowtimeId(int showtimeId) throws SQLException {
        List<Room> roomList = new ArrayList<>();
        String sql = "SELECT r.* FROM tblroom r " +
                "JOIN tblshowtimeroom sr ON r.id = sr.tblroomid " +
                "WHERE sr.tblshowtimeid = ?;";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, showtimeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room room = new Room();
                    room.setId(rs.getInt("id"));
                    room.setRoomNumber(rs.getInt("roomnumber"));
                    room.setDescription(rs.getString("description"));
                    roomList.add(room);
                }
            }
        }
        return roomList;
    }

    public List<Room> getAvailableRoomList(LocalDate showDate, LocalTime timeSlot) throws SQLException {
        List<Room> roomList = new ArrayList<>();

        String sql = "SELECT * FROM tblroom WHERE id NOT IN (" +
                "SELECT tblroomid FROM tblshowtimeroom WHERE tblshowtimeid IN (" +
                "SELECT id FROM tblshowtime WHERE showdate = ? AND timeslot = ?))";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(showDate));
            ps.setTime(2, Time.valueOf(timeSlot));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room room = new Room();
                    room.setId(rs.getInt("id"));
                    room.setRoomNumber(rs.getInt("roomnumber"));
                    room.setDescription(rs.getString("description"));
                    roomList.add(room);
                }
            }
        }
        return roomList;
    }

    public boolean saveShowtime(List<Showtime> showtimeList) throws SQLException {
        String insertShowtimeSQL = "INSERT INTO tblshowtime (showdate, timeslot, baseprice, tblmovieid) VALUES (?, ?, ?, ?)";
        String insertShowtimeRoomSQL = "INSERT INTO tblshowtimeroom (tblshowtimeid, tblroomid) VALUES (?, ?)";

        try(PreparedStatement psShowtime = con.prepareStatement(insertShowtimeSQL, PreparedStatement.RETURN_GENERATED_KEYS);
            PreparedStatement psShowtimeRoom = con.prepareStatement(insertShowtimeRoomSQL)) {

            for (Showtime showtime : showtimeList) {
                psShowtime.setObject(1, showtime.getShowDate());
                psShowtime.setObject(2, showtime.getTimeSlot());
                psShowtime.setBigDecimal(3, BigDecimal.valueOf(50000));
                psShowtime.setInt(4, showtime.getMovie().getId());

                int affectedRows = psShowtime.executeUpdate();
                if (affectedRows == 0) {
                    throw new SQLException("Creating showtime failed, no rows affected.");
                }

                try (ResultSet generatedKeys = psShowtime.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int showtimeId = generatedKeys.getInt(1); //Lay Id vua tao ra khi insert showtime moi

                        for (Room room : showtime.getRooms()) {
                            psShowtimeRoom.setInt(1, showtimeId);
                            psShowtimeRoom.setInt(2, room.getId());
                            psShowtimeRoom.executeUpdate();
                        }
                    } else {
                        throw new SQLException("Creating showtime failed, no ID obtained.");
                    }
                }
            }
            return true;
        }
    }
}