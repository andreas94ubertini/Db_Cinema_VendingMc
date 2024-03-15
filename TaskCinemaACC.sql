use acc_Task_Cinema;
SELECT * FROM Movie;

INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
VALUES
    (4, 1, 'A1', '2023-01-01 17:30:00', 1);

INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate)
VALUES
    (1, 1, 1, 'Great movie!', 5, '2023-01-02 10:00:00'),
    (2, 2, 2, 'Enjoyed it!', 4, '2023-02-10 10:30:00'),
    (3, 3, 1, 'Not my favorite.', 2, '2023-03-12 09:15:00');


CREATE VIEW FilmsInProgrammation AS
SELECT Title, DurationMinutes,ReleaseDate, Showtime.ShowDateTime as 'Ora Spettacolo' FROM Movie
JOIN Showtime ON Movie.MovieID = Showtime.MovieID

CREATE VIEW AvailableSeatsForShow AS
SELECT Theater.Capacity as totali, (Theater.Capacity - COUNT(Ticket.TicketID)) as postiDIS FROM Theater
JOIN Showtime ON Theater.TheaterID = Showtime.TheaterID
JOIN Movie ON Showtime.MovieID = Movie.MovieID
JOIN Ticket ON Showtime.ShowtimeID = Ticket.ShowtimeID
GROUP BY Theater.TheaterID, Theater.Capacity;


CREATE VIEW TotalEarningsPerMovie AS
SELECT Title AS Titolo, SUM(Price) AS 'Totale Generato' FROM Movie
JOIN Showtime ON Movie.MovieID = Showtime.MovieID
JOIN Ticket ON Showtime.ShowtimeID = Ticket.ShowtimeID
GROUP BY Title

CREATE VIEW RecentReviews AS
SELECT TOP 10 Title, Review.Rating, ReviewText,ReviewDate FROM Review
JOIN Movie ON Review.MovieID = Movie.MovieID
ORDER BY ReviewDate DESC 



--Creare una stored procedure PurchaseTicket che permetta di acquistare un biglietto per uno
--spettacolo, specificando l'ID dello spettacolo, il numero del posto e l'ID del cliente. La procedura
--dovrebbe verificare la disponibilità del posto e registrare l'acquisto.
DROP PROCEDURE IF EXISTS PurchaseTicket
CREATE PROCEDURE PurchaseTicket 
@idSpett INT,
@numPost VARCHAR(10),
@idCli INT
AS
BEGIN


BEGIN TRY
DECLARE @idTicket INT;
SELECT @idTicket = Ticket.TicketID FROM Ticket

		
			SELECT *
			FROM Ticket
			WHERE ShowtimeID = @idSpett
			AND SeatNumber = @numPost
			IF @@ROWCOUNT = 0
				BEGIN
				 INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
				 VALUES
				 (@idTicket+1, @idSpett, @numPost, CURRENT_TIMESTAMP, @idCli);
				 END
			ELSE
				BEGIN
					PRINT 'Posto Occupato';
				END
		
END TRY
	BEGIN CATCH
		
		
		PRINT 'Errore riscontrato' + ERROR_MESSAGE();
	END CATCH


END;

 SELECT * FROM Ticket
 


EXEC PurchaseTicket
@idSpett = 1,
@numPost = 'A8',
@idCli = 1

--Implementare una stored procedure UpdateMovieSchedule che permetta di aggiornare gli orari
--degli spettacoli per un determinato film. Questo include la possibilità di aggiungere o rimuovere
--spettacoli dall'agenda.
-- ----------------------------------------------------------------------------
--Sviluppare una stored procedure InsertNewMovie che consenta di inserire un nuovo film nel
--sistema, richiedendo tutti i dettagli pertinenti come titolo, regista, data di uscita, durata e
--classificazione
DROP PROCEDURE IF EXISTS InsertNewMovie
CREATE PROCEDURE InsertNewMovie
    @Title VARCHAR(255),
    @Director VARCHAR(100),
    @ReleaseDate DATE,
    @DurationMinutes INT,
    @Rating VARCHAR(5)
AS
BEGIN
DECLARE @MovieID INT;

    SELECT @MovieID = (Movie.MovieID) + 1 FROM Movie;

    INSERT INTO Movie (MovieID,Title, Director, ReleaseDate, DurationMinutes, Rating)
    VALUES (@MovieID,@Title, @Director, @ReleaseDate, @DurationMinutes, @Rating);
    PRINT 'Film inserito con successo.';
END;

--Creare una stored procedure SubmitReview che consenta ai clienti di lasciare una recensione per
--un film, comprensiva di valutazione, testo e data. Questa procedura dovrebbe verificare che il
--cliente abbia effettivamente acquistato un biglietto per il film in questione prima di permettere la
--pubblicazione della recensione

DROP PROCEDURE IF EXISTS SubmitReview
CREATE PROCEDURE SubmitReview
    @MovieID INT,
    @CustomerID INT,
    @ReviewText TEXT,
    @Rating INT
AS
BEGIN
DECLARE @reviewID INT;

    SELECT @reviewID = (Review.ReviewID) + 1 FROM Review;
    IF EXISTS (
        SELECT 1
        FROM Ticket T
        JOIN Showtime S ON T.ShowtimeID = S.ShowtimeID
        WHERE T.CustomerID = @CustomerID
          AND S.MovieID = @MovieID
    )
    BEGIN
        -- Inserisci la recensione
        INSERT INTO Review ( ReviewID,MovieID, CustomerID, ReviewText, Rating, ReviewDate)
        VALUES (@reviewID,@MovieID, @CustomerID, @ReviewText, @Rating, GETDATE());
        PRINT 'Recensione pubblicata con successo.';
    END
    ELSE
    BEGIN
        PRINT 'Spiacente, devi acquistare un biglietto per questo film prima di poter lasciare una recensione.';
    END
END;

EXEC SubmitReview
    @MovieID = 1,
    @CustomerID = 2,
    @ReviewText = 'Molto Bello',
    @Rating = 5;