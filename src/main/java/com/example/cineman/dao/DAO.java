package com.example.cineman.dao;

import io.github.cdimascio.dotenv.Dotenv;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DAO {
    public static Connection con;

    public DAO() {
        if (con == null) {
            String dbUrl = Dotenv.load().get("JDBC_URL");
            String dbUser = Dotenv.load().get("JDBC_USER");
            String dbPass = Dotenv.load().get("JDBC_PASS");
            try {
                Class.forName("org.postgresql.Driver");
                con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            } catch (ClassNotFoundException | SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
