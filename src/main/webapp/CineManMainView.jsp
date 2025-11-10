<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang chủ quản lý CineMan</title>
    <link rel="stylesheet" href="assets/css/cineman_main.css">
</head>
<body>
    <div class="container">
        <h1>Rạp chiếu phim CineMan</h1>

        <form action="management" method="get">
            <input type="hidden" name="action" value="manageShowtimes"/>
            <button class="custom-btn" type="submit">Tìm phim</button>
        </form>

    </div>
</body>
</html>
