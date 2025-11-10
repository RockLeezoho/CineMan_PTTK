CREATE DATABASE cinema_db;
\c cinema_db;

CREATE TABLE tblSystemUser (
    id SERIAL PRIMARY KEY,
    fullName VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    role VARCHAR(100) NOT NULL
);

CREATE TABLE tblStaff (
    user_id INT NOT NULL PRIMARY KEY REFERENCES tblSystemUser(id),
    position VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL
);

CREATE TABLE tblCustomer (
    user_id INT NOT NULL PRIMARY KEY REFERENCES tblSystemUser(id),
    cardType VARCHAR(100) NOT NULL,
    registrationDate DATE NOT NULL,
    points INT NOT NULL
);

CREATE TABLE tblManager (
    staff_id INT NOT NULL PRIMARY KEY REFERENCES tblStaff(user_id),
    hireDate DATE NOT NULL
);

CREATE TABLE tblSalesStaff (
    staff_id INT NOT NULL PRIMARY KEY REFERENCES tblStaff(user_id),
    staffType VARCHAR(100) NOT NULL
);

CREATE TABLE tblMovie (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(255) NOT NULL,
    director VARCHAR(100) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    releaseDate DATE NOT NULL,
    duration INT NOT NULL,
    language VARCHAR(20) NOT NULL,
    mainCast VARCHAR(255) NOT NULL,
    ageRating INT NOT NULL,
    trailer VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE tblShowtime (
    id SERIAL PRIMARY KEY,
    showDate DATE NOT NULL,
    timeSlot TIME NOT NULL,
    basePrice NUMERIC(10,2) NOT NULL,
    tblMovieid INT NOT NULL REFERENCES tblMovie(id)
);

CREATE TABLE tblRoom (
    id SERIAL PRIMARY KEY,
    roomNumber INT NOT NULL,
    description VARCHAR(255)
);


CREATE TABLE tblShowtimeRoom (
    tblRoomid INT NOT NULL REFERENCES tblRoom(id),
    tblShowtimeid INT NOT NULL REFERENCES tblShowtime(id)
);


CREATE TABLE tblSeat (
    id SERIAL PRIMARY KEY,
    seatRow VARCHAR(10) NOT NULL,
    seatColumn VARCHAR(10) NOT NULL,
    seatType VARCHAR(100) NOT NULL,
    dynamicPrice NUMERIC(10,2) NOT NULL,
    tblRoomid INT NOT NULL REFERENCES tblRoom(id)
);

CREATE TABLE tblShowSeat (
    id SERIAL PRIMARY KEY,
    isReserved BOOLEAN NOT NULL DEFAULT FALSE,
    tblSeatid INT NOT NULL REFERENCES tblSeat(id),
    tblShowtimeid INT NOT NULL REFERENCES tblShowtime(id)
);

CREATE TABLE tblInvoice (
    id SERIAL PRIMARY KEY,
    createdDate DATE NOT NULL,
    totalAmount NUMERIC(12,2) NOT NULL,
    tblSalesStaffid INT REFERENCES tblSalesStaff(staff_id),
    tblCustomerid INT REFERENCES tblCustomer(user_id)
);

CREATE TABLE tblTicket (
    id SERIAL PRIMARY KEY,
    ticketPrice NUMERIC(12,2) NOT NULL,
    tblShowSeatid INT REFERENCES tblShowSeat(id),
    tblInvoiceid INT REFERENCES tblInvoice(id)
);
