<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Trang chủ quản lý CineMan</title>
    <link rel="stylesheet" href="assets/css/manager_main.css">
</head>
<body>
    <div class="container">
        <h1>Trang chủ quản lý</h1>

        <form action="management" method="get">
            <input type="hidden" name="action" value="manageShowtimes"/>
            <button class="custom-btn" type="submit">Quản lý lịch chiếu</button>
        </form>

    </div>
</body>
</html>
