SELECT * FROM dbo.Instructors

ALTER TABLE KdzFitness.Instructors CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
--представления

--Список клиентов и их абонементов
CREATE VIEW View_ClientsAndSubscriptions AS
SELECT Clients.ClientID, Clients.FirstName, Clients.LastName, Subscription.SubscriptionID, Subscription.SubscriptionStartDate, Subscription.SubscriptionEndDate
FROM Clients
JOIN ClientSubscription ON Clients.ClientID = ClientSubscription.ClientID
JOIN Subscription ON ClientSubscription.SubscriptionID = Subscription.SubscriptionID;

--Список программ и их инструкторов

CREATE VIEW View_ProgramsAndInstructors AS
SELECT Programs.ProgramID, Programs.Name, Instructors.FirstName, Instructors.LastName
FROM Programs
JOIN ProgramInstructor ON Programs.ProgramID = ProgramInstructor.ProgramId
JOIN Instructors ON ProgramInstructor.InsructorID = Instructors.InstructorID;

--Список клиентов и их отзывов

CREATE VIEW View_ClientsAndReviews AS
SELECT Clients.ClientID, Clients.FirstName, Clients.LastName, Reviews.ReviewText, Reviews.RatingOufOfFive
FROM Clients
JOIN Reviews ON Clients.ClientID = Reviews.ClientID;


--функции


--получение среднего рейтинга программы

CREATE FUNCTION GetAverageProgramRating(@ProgramID INT)
RETURNS DECIMAL(3, 2) AS
BEGIN
    DECLARE @AverageRating DECIMAL(3, 2);
    SELECT @AverageRating = AVG(RatingOufOfFive) FROM Reviews WHERE ProgramID = @ProgramID;
    RETURN @AverageRating;
END;

--получение общей суммы платежей клиента

CREATE FUNCTION GetTotalClientPayments(@ClientID INT)
RETURNS DECIMAL(10, 2) AS
BEGIN
    DECLARE @TotalPayments DECIMAL(10, 2);
    SELECT @TotalPayments = SUM(Amount) FROM Payments WHERE ClientID = @ClientID;
    RETURN @TotalPayments;
END;

-- получение количества активных абонементов

CREATE FUNCTION GetActiveSubscriptions()
RETURNS INT AS
BEGIN
    DECLARE @ActiveSubscriptions INT;
    SELECT @ActiveSubscriptions = COUNT(*) FROM Subscription WHERE SubscriptionEndDate >= GETDATE();
    RETURN @ActiveSubscriptions;
END;


--процедуры

--добавление нового клиента

CREATE PROCEDURE InsertNewClient 
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(255),
    @DateOfBith DATE,
    @Email NVARCHAR(100),
    @PhoneNumber NVARCHAR(255)
AS
BEGIN
    INSERT INTO Clients (FirstName, LastName, DateOfBith, Email, PhoneNumber)
    VALUES (@FirstName, @LastName, @DateOfBith, @Email, @PhoneNumber);
END;

--добавление новый программы

CREATE PROCEDURE InsertNewProgram 
    @Name NVARCHAR(100),
    @Level NVARCHAR(50),
    @IsForChildren BIT,
    @ProgramDescription NVARCHAR(255)
AS
BEGIN
    INSERT INTO Programs (Name, Level, IsForChildren, ProgramDescription)
    VALUES (@Name, @Level, @IsForChildren, @ProgramDescription);
END;

--добавление нового инструктора

CREATE PROCEDURE InsertNewInstructor 
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(255),
    @Experience INT,
    @FieldOfWork NVARCHAR(255)
AS
BEGIN
    INSERT INTO Instructors (FirstName, LastName, Experience, FieldOfWork)
    VALUES (@FirstName, @LastName, @Experience, @FieldOfWork);
END;

--удаление клиента

CREATE PROCEDURE DeleteClient 
    @ClientID INT
AS
BEGIN
    DELETE FROM Clients WHERE ClientID = @ClientID;
END;


-- общая сумма оплаты по всем абонементам для каждого клиента

CREATE PROCEDURE GetTotalPaymentPerClient
AS
BEGIN
    CREATE TABLE #TotalPaymentPerClient (
        ClientID INT,
        TotalPayment DECIMAL(10, 2)
    );

    DECLARE @current_client_id INT;
    DECLARE client_cursor CURSOR FOR SELECT DISTINCT ClientID FROM Clients;

    OPEN client_cursor;
    FETCH NEXT FROM client_cursor INTO @current_client_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @total_payment DECIMAL(10, 2);
        SELECT @total_payment = SUM(Amount) FROM Payments WHERE ClientID = @current_client_id;

        INSERT INTO #TotalPaymentPerClient VALUES (@current_client_id, @total_payment);

        FETCH NEXT FROM client_cursor INTO @current_client_id;
    END;

    CLOSE client_cursor;
    DEALLOCATE client_cursor;

    SELECT * FROM #TotalPaymentPerClient;

    DROP TABLE #TotalPaymentPerClient;
END;

--триггеры


--проверка возвраста клиента

CREATE TRIGGER CheckClientAge
ON Clients
AFTER INSERT
AS
BEGIN
    DECLARE @dateOfBirth DATE;
    SELECT @dateOfBirth = DateOfBith FROM inserted;

    IF (YEAR(GETDATE()) - YEAR(@dateOfBirth)) < 18
    BEGIN
        THROW 51000, 'Клиент должен быть старше 18 лет', 1;
    END
END;



--применение скидки к платежу

CREATE TRIGGER ApplyDiscountOnPayment
ON Payments
AFTER INSERT
AS
BEGIN
    DECLARE @ClientID INT, @PaymentID INT, @Amount DECIMAL(10, 2), @DiscountAmount DECIMAL(10, 2);

    -- Получаем информацию о платеже
    SELECT @PaymentID = PaymentID, @ClientID = ClientID, @Amount = Amount FROM inserted;

    -- Проверяем, есть ли для этого клиента действующая скидка
    IF EXISTS (SELECT 1 FROM Discounts WHERE SubscriptionID IN (SELECT SubscriptionID FROM ClientSubscription WHERE ClientID = @ClientID) AND DiscountDuration >= GETDATE())
    BEGIN
        -- Получаем сумму скидки
        SELECT @DiscountAmount = DiscountAmount FROM Discounts WHERE SubscriptionID IN (SELECT SubscriptionID FROM ClientSubscription WHERE ClientID = @ClientID) AND DiscountDuration >= GETDATE();

        -- Применяем скидку к платежу
        UPDATE Payments SET Amount = @Amount - @DiscountAmount WHERE PaymentID = @PaymentID;
    END
END;

--применение скидки 

CREATE TRIGGER ApplyDiscount
BEFORE INSERT ON Subscription
FOR EACH ROW
BEGIN
    DECLARE discount_amount DECIMAL(10, 2);
    SELECT DiscountAmount INTO discount_amount FROM Discounts WHERE SubscriptionID = NEW.SubscriptionID;
    IF discount_amount IS NOT NULL THEN
        SET NEW.TotalDue = NEW.TotalDue - discount_amount;
    END IF;
END;


--обновление статуса оплаты абонемента после внесения платежа

CREATE TRIGGER UpdateSubscriptionPaymentStatus
ON Payments
AFTER INSERT
AS
BEGIN
    DECLARE @subscriptionId INT;

    SELECT @subscriptionId = SubscriptionID FROM inserted;

    UPDATE Subscription
    SET IsPaid = 1
    WHERE SubscriptionID = @subscriptionId;
END;


-- проверка доступности инструктора при назначении программы

CREATE TRIGGER CheckInstructorAvailability
BEFORE INSERT ON ProgramInstructor
FOR EACH ROW
BEGIN
    DECLARE instructor_count INT;
    SELECT COUNT(*) INTO instructor_count FROM ProgramInstructor WHERE InsructorID = NEW.InsructorID;
    IF instructor_count >= 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Инструктор уже назначен на 5 программ. Выберите другого инструктора.';
    END IF;
END;





--пример работыт


-- 1 сценарий
INSERT INTO Clients ( FirstName, LastName, DateOfBith, Email, PhoneNumber)
VALUES ( 'Иван', 'Иванов', '2006-01-01', 'ivanov@example.com', '+7 900 123 45 67');

--клиенту больще 18

INSERT INTO Clients ( FirstName, LastName, DateOfBith, Email, PhoneNumber)
VALUES ( 'Иван', 'Иванов', '2004-01-01', 'ivanov@example.com', '+7 900 123 45 67');

--2 сценарий

EXEC GetTotalPaymentPerClient;

--3 сценарий

INSERT INTO Discounts (SubscriptionID, DiscountDescrition, DiscountAmount, DiscountDuration)
VALUES (2, 'Скидка 10% на годовой абонемент', 1200, '2023-12-31');

SELECT * FROM Discounts

UPDATE Subscription
SET TotalDue = TotalDue - (SELECT DiscountAmount FROM Discounts WHERE SubscriptionID = 1)
WHERE SubscriptionID = 1;

SELECT * FROM Discounts

--добавление платежа

INSERT INTO Payments ( ClientID, Amount, PaymentDate)
VALUES (1, 12000, '2023-01-01');

SELECT * FROM Payments