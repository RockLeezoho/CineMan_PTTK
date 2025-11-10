package com.example.cineman.dao;

import com.example.cineman.model.SystemUser;

import java.sql.*;
import java.time.LocalDate;
import java.util.Optional;

public class UserDAO extends DAO {

    public Optional<SystemUser> findByUsernameOrEmail(String identity) throws SQLException {
        String FIND_BY_USERNAME_SQL =
                "SELECT id, fullName, username, password, dateOfBirth, phoneNumber, email, gender, role " +
                        "FROM tblSystemUser WHERE username = ? OR email = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(FIND_BY_USERNAME_SQL)) {

            ps.setString(1, identity.trim());
            ps.setString(2, identity.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SystemUser u = mapRowToUser(rs);
                    return Optional.of(u);
                } else {
                    return Optional.empty();
                }
            }
        }
    }

    public boolean existsByUsername(String username) throws SQLException {
        String EXISTS_BY_USERNAME_SQL =
                "SELECT 1 FROM tblSystemUser WHERE username = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(EXISTS_BY_USERNAME_SQL)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existsByEmail(String email) throws SQLException {
        String EXISTS_BY_EMAIL_SQL =
                "SELECT 1 FROM tblSystemUser WHERE email = ? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(EXISTS_BY_EMAIL_SQL)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }


    public int insertUser(SystemUser user) throws SQLException {
        String INSERT_USER_SQL =
                "INSERT INTO tblSystemUser (fullName, username, password, dateOfBirth, phoneNumber, email, gender, role) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(INSERT_USER_SQL, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getUsername());
            ps.setString(3, user.getPasswordHash()); // already hashed before calling DAO
            // dateOfBirth -> java.sql.Date
            LocalDate dob = user.getDateOfBirth();
            if (dob != null) {
                ps.setDate(4, Date.valueOf(dob));
            } else {
                ps.setNull(4, Types.DATE);
            }
            ps.setString(5, user.getPhoneNumber());
            ps.setString(6, user.getEmail());
            ps.setString(7, user.getGender());
            ps.setString(8, user.getRole());

            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Inserting user failed, no rows affected.");
            }

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    // Generated key may be long depending on DB; cast to int if safe
                    return keys.getInt(1);
                } else {
                    throw new SQLException("Inserting user failed, no ID obtained.");
                }
            }
        }
    }

    private SystemUser mapRowToUser(ResultSet rs) throws SQLException {
        SystemUser u = new SystemUser();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("fullName"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password")); // note: hashed password
        Date sqlDob = rs.getDate("dateOfBirth");
        if (sqlDob != null) {
            u.setDateOfBirth(sqlDob.toLocalDate());
        }
        u.setPhoneNumber(rs.getString("phoneNumber"));
        u.setEmail(rs.getString("email"));
        u.setGender(rs.getString("gender"));
        u.setRole(rs.getString("role"));
        return u;
    }

}