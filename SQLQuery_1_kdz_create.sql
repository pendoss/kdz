CREATE DATABASE KdzFitness;

CREATE TABLE "ProgramInstructor"("ProgramId" INT NOT NULL,"InsructorID" INT NOT NULL, PRIMARY KEY ("ProgramId", "InsructorID"));
-- Удалить существующие ограничения PRIMARY KEY
ALTER TABLE "ProgramInstructor" DROP CONSTRAINT "programinstructor_programid_primary";
ALTER TABLE "ProgramInstructor" DROP CONSTRAINT "programinstructor_insructorid_primary";

-- Добавить новое ограничение PRIMARY KEY
ALTER TABLE "ProgramInstructor" ADD CONSTRAINT "programinstructor_programid_insructorid_primary" PRIMARY KEY ("ProgramId", "InsructorID");

CREATE TABLE "Reviews"(
    "ClientID" INT NOT NULL,
    "ReviewText" BIGINT NOT NULL,
    "RatingOufOfFive" INT NOT NULL
);
ALTER TABLE
    "Reviews" ADD CONSTRAINT "reviews_clientid_primary" PRIMARY KEY("ClientID");
CREATE TABLE "Instructors"(
    "InstructorID" INT NOT NULL,
    "FirstName" NVARCHAR(100) NOT NULL,
    "LastName" NVARCHAR(100) NOT NULL,
    "Experience" INT NOT NULL,
    "FieldOfWork" NVARCHAR(100) NOT NULL
);

DROP Table Instructors

ALTER TABLE
    "Instructors" ADD CONSTRAINT "instructors_instructorid_primary" PRIMARY KEY("InstructorID");
CREATE TABLE "Programs"(
    "ProgramID" INT NOT NULL,
    "Name" NVARCHAR(100) NOT NULL,
    "Level" NVARCHAR(50) NOT NULL,
    "IsForChildren" BIT NOT NULL,
    "ProgramDescription" NVARCHAR(255) NOT NULL,
    "StartTime" TIME NOT NULL,
    "Duration" TIME NOT NULL,
    "Date" DATE NOT NULL
);
ALTER TABLE
    "Programs" ADD CONSTRAINT "programs_programid_primary" PRIMARY KEY("ProgramID");
DROP TABLE ClientInstructor
CREATE TABLE "ClientInstructor"(
    "CientID" INT NOT NULL,
    "InstructorID" INT NOT NULL, 
    PRIMARY KEY("CientID", "InstructorID")
);
-- ALTER TABLE
--     "ClientInstructor" ADD CONSTRAINT "clientinstructor_cientid_primary" PRIMARY KEY("CientID");
-- ALTER TABLE
--     "ClientInstructor" ADD CONSTRAINT "clientinstructor_instructorid_primary" PRIMARY KEY("InstructorID");
CREATE TABLE "Pricing"(
    "SubscriptionID" INT NOT NULL,
    "ProgramID" INT NOT NULL,
    PRIMARY KEY("SubscriptionID", "ProgramID")
);
-- ALTER TABLE
--     "Pricing" ADD CONSTRAINT "pricing_subscriptionid_primary" PRIMARY KEY("SubscriptionID");
-- ALTER TABLE
--     "Pricing" ADD CONSTRAINT "pricing_programid_primary" PRIMARY KEY("ProgramID");
CREATE TABLE "Payments"(
    "PaymentID" INT NOT NULL,
    "ClientID" INT NOT NULL,
    "Amount" DECIMAL(10, 2) NOT NULL,
    "PaymentDate" DATETIME NOT NULL,
    PRIMARY KEY ("PaymentID")
);
-- ALTER TABLE
--     "Payments" ADD CONSTRAINT "payments_paymentid_primary" PRIMARY KEY("PaymentID");
CREATE TABLE "Clients"(
    "ClientID" INT NOT NULL,
    "FirstName" NVARCHAR(100) NOT NULL,
    "LastName" NVARCHAR(255) NOT NULL,
    "DateOfBith" DATE NOT NULL,
    "Email" NVARCHAR(100) NOT NULL,
    "PhoneNumber" NVARCHAR(255) NOT NULL,
    PRIMARY KEY("ClientID")
);
-- ALTER TABLE
--     "Clients" ADD CONSTRAINT "clients_clientid_primary" PRIMARY KEY("ClientID");
CREATE TABLE "Discounts"(
    "SubscriptionID" INT NOT NULL,
    "DiscountDescrition" NVARCHAR(255) NOT NULL,
    "DiscountAmount" DECIMAL(10, 2) NOT NULL,
    "DiscountDuration" DATE NOT NULL,
    PRIMARY KEY("SubscriptionID")
);
-- ALTER TABLE
--     "Discounts" ADD CONSTRAINT "discounts_subscriptionid_primary" PRIMARY KEY("SubscriptionID");
CREATE TABLE "Subscription"(
    "SubscriptionID" INT NOT NULL,
    "SubscriptionStartDate" DATE NOT NULL,
    "SubscriptionEndDate" DATE NOT NULL,
    "IsPaid" BIT NOT NULL,
    "SubscriptionTypeID" INT NOT NULL,
    "TotalDue" INT NOT NULL,
    PRIMARY KEY("SubscriptionID")
);
-- ALTER TABLE
--     "Subscription" ADD CONSTRAINT "subscription_subscriptionid_primary" PRIMARY KEY("SubscriptionID");
ALTER TABLE
    "ClientInstructor" ADD CONSTRAINT "clientinstructor_instructorid_foreign" FOREIGN KEY("InstructorID") REFERENCES "Instructors"("InstructorID");
ALTER TABLE
    "ProgramInstructor" ADD CONSTRAINT "programinstructor_insructorid_foreign" FOREIGN KEY("InsructorID") REFERENCES "Instructors"("InstructorID");
ALTER TABLE
    "Pricing" ADD CONSTRAINT "pricing_subscriptionid_foreign" FOREIGN KEY("SubscriptionID") REFERENCES "Subscription"("SubscriptionID");
ALTER TABLE
    "ProgramInstructor" ADD CONSTRAINT "programinstructor_programid_foreign" FOREIGN KEY("ProgramId") REFERENCES "Programs"("ProgramID");
ALTER TABLE
    "ClientInstructor" ADD CONSTRAINT "clientinstructor_cientid_foreign" FOREIGN KEY("CientID") REFERENCES "Clients"("ClientID");
ALTER TABLE
    "Programs" ADD CONSTRAINT "programs_programid_foreign" FOREIGN KEY("ProgramID") REFERENCES "Pricing"("ProgramID");
ALTER TABLE
    "Payments" ADD CONSTRAINT "payments_clientid_foreign" FOREIGN KEY("ClientID") REFERENCES "Clients"("ClientID");
ALTER TABLE
    "Reviews" ADD CONSTRAINT "reviews_clientid_foreign" FOREIGN KEY("ClientID") REFERENCES "Clients"("ClientID");
ALTER TABLE
    "Discounts" ADD CONSTRAINT "discounts_subscriptionid_foreign" FOREIGN KEY("SubscriptionID") REFERENCES "Subscription"("SubscriptionID");


-- Создаем таблицу "SubscriptionType" для типов абонементов
CREATE TABLE "SubscriptionType"("SubscriptionTypeID" INT, "Description" NVARCHAR(255), PRIMARY KEY("SubscriptionTypeID"));
ALTER TABLE "SubscriptionType" ADD CONSTRAINT "subscriptiontype_subscriptiontypeid_primary" PRIMARY KEY("SubscriptionTypeID");

-- Добавляем "SubscriptionTypeID" в таблицу "Subscription"
ALTER TABLE "Subscription" ADD "SubscriptionTypeID" INT;
ALTER TABLE "Subscription" ADD CONSTRAINT "subscription_subscriptiontypeid_foreign" FOREIGN KEY("SubscriptionTypeID") REFERENCES "SubscriptionType"("SubscriptionTypeID");

-- Удаляем таблицу "ClientInstructor"
DROP TABLE "ClientInstructor";

-- Добавляем "SubscriptionID" в таблицу "Payments"
ALTER TABLE "Payments" ADD "SubscriptionID" INT;
ALTER TABLE "Payments" ADD CONSTRAINT "payments_subscriptionid_foreign" FOREIGN KEY("SubscriptionID") REFERENCES "Subscription"("SubscriptionID");

-- Изменяем таблицу "Reviews", добавляем "ProgramID" и "SubscriptionID"
ALTER TABLE "Reviews" ADD "ProgramID" INT, "SubscriptionID" INT;
ALTER TABLE "Reviews" ADD CONSTRAINT "reviews_programid_foreign" FOREIGN KEY("ProgramID") REFERENCES "Programs"("ProgramID");
ALTER TABLE "Reviews" ADD CONSTRAINT "reviews_subscriptionid_foreign" FOREIGN KEY("SubscriptionID") REFERENCES "Subscription"("SubscriptionID");

-- Удаляем "StartTime", "Duration" и "Date" из таблицы "Programs"
ALTER TABLE "Programs" DROP COLUMN "StartTime", COLUMN "Duration", COLUMN "Date";

-- Добавляем составной ключ в таблицу "Discounts"
ALTER TABLE "Discounts" ADD CONSTRAINT "discounts_subscriptionid_discountamount_primary" PRIMARY KEY("SubscriptionID", "DiscountAmount");
DROP TABLE ClientSubscription
CREATE TABLE "ClientSubscription"("ClientID" INT NOT NULL, "SubscriptionID" INT NOT NULL, PRIMARY KEY("ClientID", "SubscriptionID"));
-- ALTER TABLE "ClientSubscription" ADD CONSTRAINT "clientsubscription_clientid_primary" PRIMARY KEY("ClientID");
-- ALTER TABLE "ClientSubscription" ADD CONSTRAINT "clientsubscription_subscriptionid_primary" PRIMARY KEY("SubscriptionID");
ALTER TABLE "ClientSubscription" ADD CONSTRAINT "clientsubscription_clientid_foreign" FOREIGN KEY("ClientID") REFERENCES "Clients"("ClientID");
ALTER TABLE "ClientSubscription" ADD CONSTRAINT "clientsubscription_subscriptionid_foreign" FOREIGN KEY("SubscriptionID") REFERENCES "Subscription"("SubscriptionID");



-- Заполняем таблицу Instructors
USE KdzFitness
INSERT INTO Instructors (InstructorID, FirstName, LastName, Experience, FieldOfWork)
VALUES (1, 'Иван', 'Иванов', 10, 'Фитнес'),
       (2, 'Петр', 'Петров', 5, 'Йога');
SELECT * FROM Instructors
-- Заполняем таблицу Programs
INSERT INTO Programs (ProgramID, Name, Level, IsForChildren, ProgramDescription)
VALUES (1, 'Программа 1', 'Начальный', 0, 'Описание программы 1'),
       (2, 'Программа 2', 'Продвинутый', 1, 'Описание программы 2');
SELECT * FROM Programs
-- Заполняем таблицу Clients
INSERT INTO Clients (ClientID, FirstName, LastName, DateOfBith, Email, PhoneNumber)
VALUES (1, 'Алексей', 'Алексеев', '1980-01-01', 'aleksey@example.com', '1234567890'),
       (2, 'Мария', 'Мариева', '1990-01-01', 'maria@example.com', '0987654321');
SELECT * FROM Clients
-- Заполняем таблицу SubscriptionType
INSERT INTO SubscriptionType (SubscriptionTypeID, Description)
VALUES (1, 'Тип абонемента 1'),
       (2, 'Тип абонемента 2');
SELECT * FROM SubscriptionType
-- Заполняем таблицу Subscription
INSERT INTO Subscription (SubscriptionID, SubscriptionStartDate, SubscriptionEndDate, IsPaid, SubscriptionTypeID, TotalDue)
VALUES (1, '2023-01-01', '2023-12-31', 1, 1, 1000),
       (2, '2023-01-01', '2023-06-30', 0, 2, 500);
SELECT * FROM Subscription
-- Заполняем таблицу ProgramInstructor
INSERT INTO ProgramInstructor (ProgramId, InsructorID)
VALUES (1, 1),
       (2, 2);
SELECT * FROM ProgramInstructor
-- Заполняем таблицу Reviews
INSERT INTO Reviews (ClientID, ReviewText, RatingOufOfFive, ProgramID ,SubscriptionID)
VALUES (1, 'Отличная программа!', 5, 1, 1),
       (2, 'Неплохо, но есть куда стремиться.', 3, null, 2);
SELECT * FROM Reviews
-- DELETE FROM Reviews
-- Заполняем таблицу ClientSubscription
INSERT INTO ClientSubscription (ClientID, SubscriptionID)
VALUES (1, 1),
       (2, 2);
SELECT * FROM ClientSubscription
-- Заполняем таблицу Pricing
INSERT INTO Pricing (SubscriptionID, ProgramID)
VALUES (1, 1),
       (2, 2);
SELECT * FROM Pricing
-- Заполняем таблицу Payments
INSERT INTO Payments (PaymentID, ClientID, Amount, PaymentDate, SubscriptionID)
VALUES (1, 1, 1000, '2023-01-01', 1),
       (2, 2, 500, '2023-01-01', 2);
SELECT * FROM Payments
-- Заполняем таблицу Discounts
INSERT INTO Discounts (SubscriptionID, DiscountDescrition, DiscountAmount, DiscountDuration)
VALUES (1, 'Скидка для новых клиентов', 100, '2023-01-01'),
       (2, 'Скидка для постоянных клиентов', 50, '2023-01-01');
SELECT * FROM Discounts