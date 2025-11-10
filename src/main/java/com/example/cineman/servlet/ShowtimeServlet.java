package com.example.cineman.servlet;

import com.example.cineman.dao.MovieDAO;
import com.example.cineman.dao.ShowtimeDAO;
import com.example.cineman.model.Movie;
import com.example.cineman.model.Room;
import com.example.cineman.model.Showtime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name="ShowtimeServlet", value="/showtimes")
public class ShowtimeServlet extends HttpServlet{
    private ShowtimeDAO showtimeDAO = new ShowtimeDAO();
    private MovieDAO movieDAO = new MovieDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null){
            action = "manageShowtimes";
        }
        try{
            switch (action) {
                case "addShowtimes":
                    req.getRequestDispatcher("/WEB-INF/manager/AddShowtimesView.jsp").forward(req, resp);
                    break;
                case "selectRoom":
                    String dateStr = req.getParameter("date");
                    String timeStr = req.getParameter("time");

                    if (dateStr == null || timeStr == null) {
                        resp.sendRedirect("showtimes?action=addShowtimes");
                        return;
                    }

                    LocalDate date = LocalDate.parse(dateStr);
                    LocalTime time = LocalTime.parse(timeStr);
                    List<Room> availableRoomList = showtimeDAO.getAvailableRoomList(date, time);

                    List<Showtime> tempShowtimes = getTempShowtimeList(req);
                    if(tempShowtimes != null){
                        for(Showtime st : tempShowtimes){
                            if(st.getShowDate().equals(date) && st.getTimeSlot().equals(time)){
                                for(Room r : st.getRooms()){
                                    availableRoomList.removeIf(room -> room.getId() == r.getId());
                                }
                                break;
                            }
                        }
                    }

                    req.setAttribute("date", date);
                    req.setAttribute("time", time);
                    req.setAttribute("availableRoomList", availableRoomList);
                    req.getRequestDispatcher("/WEB-INF/manager/SelectRoomView.jsp").forward(req, resp);
                    break;
                case "selectMovie":
                    List<Movie> availableMovieList = movieDAO.getAvailableMovieList();
                    req.setAttribute("availableMovieList", availableMovieList);
                    req.getRequestDispatcher("/WEB-INF/manager/SelectMovieView.jsp").forward(req, resp);
                    break;
                case "deleteTempShowtime":
                    HttpSession session = req.getSession();
                    List<Showtime> tempList = getTempShowtimeList(req);
                    System.out.println("Delete tempShowtime");
                    String indexStr = req.getParameter("index");
                    if (indexStr != null) {
                        int index = Integer.parseInt(indexStr);
                        if (index >= 0 && index < tempList.size()) {
                            tempList.remove(index);
                        }
                    }

                    session.setAttribute("tempShowtimes", tempList);
                    resp.sendRedirect("showtimes?action=addShowtimes");
                    break;
                default:
                    req.getSession().removeAttribute("tempShowtimes");

                    LocalDate today = LocalDate.now();
                    req.setAttribute("showtimeList", showtimeDAO.getAvailableShowtimeList(today));
                    req.getRequestDispatcher("/WEB-INF/manager/ManageShowtimesView.jsp").forward(req, resp);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            switch (action) {
                case "chooseRooms":
                    String tempDate = req.getParameter("showDate");
                    String tempTime = req.getParameter("timeSlot");
                    String roomIdListStr = req.getParameter("roomIdList"); // "1,2,3"
                    System.out.println(roomIdListStr);
                    String[] roomIdArr = roomIdListStr != null && !roomIdListStr.isEmpty() ? roomIdListStr.split(",") : new String[0];

                    List<Showtime> tempShowtimes = getTempShowtimeList(req);
                    if (tempShowtimes != null) {
                        for (Showtime st : tempShowtimes) {
                            if (st.getShowDate().toString().equals(tempDate) && st.getTimeSlot().toString().equals(tempTime)) {
                                for (String roomId : roomIdArr) {
                                    int id = Integer.parseInt(roomId);


                                    Room selectedRoom = new Room();
                                    selectedRoom.setId(id);
                                    selectedRoom.setRoomNumber(id);
                                    boolean exists = false;


                                    for (Room r : st.getRooms()) {
                                        if (r.getId() == id) {
                                            exists = true;
                                            break;
                                        }
                                    }
                                    if (!exists) st.getRooms().add(selectedRoom);
                                }
                            }
                        }
                    }
                    req.getSession().setAttribute("tempShowtimes", tempShowtimes);

                    req.getRequestDispatcher("/WEB-INF/manager/AddShowtimesView.jsp").forward(req, resp);
                    break;

                case "confirmTime":
                    HttpSession session1 = req.getSession();
                    List<Showtime> tempList1 = getTempShowtimeList(req);

                    String dateStr = req.getParameter("date");
                    String timeStr = req.getParameter("time");
                    if (dateStr == null || timeStr == null) {
                        resp.sendRedirect("showtimes?action=addShowtimes");
                        return;
                    }

                    LocalDate date = LocalDate.parse(dateStr);
                    LocalTime time = LocalTime.parse(timeStr);
                    Showtime st = new Showtime();
                    for(Showtime existingSt : tempList1){
                        if(existingSt.getShowDate().equals(date) && existingSt.getTimeSlot().equals(time)){
                            resp.sendRedirect("showtimes?action=addShowtimes");
                            return;
                        }
                    }
                    st.setShowDate(date);
                    st.setTimeSlot(time);
                    tempList1.add(st);

                    session1.setAttribute("tempShowtimes", tempList1);
                    resp.sendRedirect("showtimes?action=addShowtimes");
                    break;

                case "saveShowtimes":
                    HttpSession session2 = req.getSession();
                    @SuppressWarnings("unchecked")
                    List<Showtime> tempList2 = (List<Showtime>) session2.getAttribute("tempShowtimes");

                    boolean success = false;
                    if (tempList2 != null && !tempList2.isEmpty()) {
                        success = showtimeDAO.saveShowtime(tempList2);
                    }

                    session2.removeAttribute("tempShowtimes");
                    if(success){
                        resp.sendRedirect("showtimes?action=manageShowtimes&success=true");
                    } else {
                        resp.sendRedirect("showtimes?action=addShowtimes&success=false");
                    }
                    break;
                default:
                    resp.sendRedirect("showtimes?action=manageShowtimes");
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }


    //Danh sach lich chieu tam thoi trong session
    @SuppressWarnings("unchecked") //Tat canh bao ve viec ep kieu
    public static List<Showtime> getTempShowtimeList(HttpServletRequest req) {
        HttpSession session = req.getSession(); // lay session hien tai (moi Manager A co session rieng)

        List<Showtime> tempList = (List<Showtime>) session.getAttribute("tempShowtimes");
        if (tempList == null) {
            tempList = new ArrayList<>();
            session.setAttribute("tempShowtimes", tempList);
        }
        return tempList;
    }
}
