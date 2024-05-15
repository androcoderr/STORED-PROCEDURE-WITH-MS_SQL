--WITH STORED PROCEDURE--
--EXAMPLE 1 INSERT PATIENT 
CREATE PROCEDURE InsertPatient
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Age INT,
    @Gender NVARCHAR(10),
    @PhoneNumber NVARCHAR(20)
AS
BEGIN
    INSERT INTO Patients (FirstName, LastName, Age, Gender, PhoneNumber)
    VALUES (@FirstName, @LastName, @Age, @Gender, @PhoneNumber)
END

EXEC InsertPatient 'Ali', 'Can', 22, 'Male', '999-456-7890'

----------------------------------------------------------------
--EXAMPLE 2 (GET PATIENT INFO )
CREATE PROCEDURE GET_PATIENT_INFO 
@PatientID INT
AS 
BEGIN 
  SELECT PatientID, FirstName, LastName, Age, Gender, PhoneNumber
  FROM [dbo].[Patients]
  WHERE [PatientID]=@PatientID
END

EXEC GET_PATIENT_INFO 1
----------------------------------------------------------
--EXAMPLE 3 CALCULATE AGE
CREATE PROCEDURE CALCULATE_AGE 
@BIRTHDATE DATE
AS
BEGIN
  DECLARE @CURRENT_DATE DATE
  SET @CURRENT_DATE = GETDATE()

  SELECT DATEDIFF(YEAR, @BIRTHDATE, @CURRENT_DATE) AS Age 
END


EXEC CALCULATE_AGE '2002-04-16'
----------------------------------------------
--EXAMPLE 4 CLCULATE TOTAL COST
CREATE PROCEDURE CALCULATE_TOTAL_COST
@PATIENT_ID INT,
@START_DATE DATE,
@END_DATE DATE,
@TOTAL_COST DECIMAL(10,2) OUTPUT
AS 
BEGIN 
 SET  @TOTAL_COST=(SELECT SUM(Cost) FROM [dbo].[Appointments]
 WHERE [PatientID]=@PATIENT_ID AND
 AppointmentDate BETWEEN @START_DATE AND @END_DATE
 )
END

DECLARE @TOTAL DECIMAL(10,2)

EXEC CALCULATE_TOTAL_COST 1,'2024-01-01','2024-12-31',@TOTAL OUTPUT
SELECT @TOTAL AS [TOTAL COST]

---------------------------------------------------------
--EXAMPLE 5 UPDATE APPOINTMENT STATUS
CREATE PROCEDURE UPDATE_APPOINTMEN_STATUS
@APPOINTMENT_ID INT,
@NEW_STATUS VARCHAR(20)
AS 
BEGIN 
  UPDATE Appointments
  SET [Status]=@NEW_STATUS
  WHERE [AppointmentID]=@APPOINTMENT_ID
END

EXEC UPDATE_APPOINTMEN_STATUS 1,'CANCELLED'
-------------------------------------------------
--EXAMPLE 6 GET APPOINTMENT COUNT
CREATE PROCEDURE GET_APPOINTMENT_COUNT
@PATIENT_ID INT,
@START_DATE DATE,
@END_DATE DATE,
@COUNT INT OUTPUT
AS 
BEGIN
SET @COUNT=
(
SELECT COUNT(*) FROM [dbo].[Appointments]
WHERE [PatientID]=@PATIENT_ID AND
AppointmentDate BETWEEN @START_DATE AND @END_DATE
)
END

DECLARE @APPOINTMNET_COUNT INT 
EXEC GET_APPOINTMENT_COUNT 1,'2024-01-01','2024-12-31', @APPOINTMNET_COUNT OUTPUT
SELECT @APPOINTMNET_COUNT AS [APPOINTMENT COUNT]
-----------------------------------------------------------------------
--EXAMPLE 7 GENERATE APPOINTMENT REPORT
CREATE PROCEDURE GENERATE_APPOINTMENT_REPORT
@START_DATE DATE,
@END_DATE DATE
AS
BEGIN
 SELECT [FirstName],[LastName],[AppointmentDate],[Status]
 FROM [dbo].[Patients] P
 INNER JOIN [dbo].[Appointments] A ON P.PatientID =A.PatientID
 WHERE [AppointmentDate] BETWEEN @START_DATE AND @END_DATE 
 ORDER BY [FirstName],[LastName],[AppointmentDate]
END

EXEC GENERATE_APPOINTMENT_REPORT '2024-01-01','2024-12-31'
----------------------------------------------------------------
--EXAMPLE 8 UPDATE APPOINTMENT STATUS IF PAST DUE
CREATE PROCEDURE UPDATE_APPOPINTMENT_STATUS_PAST_DUE
@APPOINTMENT_ID INT
AS 
BEGIN 
DECLARE @CURRENT_DATE DATE =GETDATE();
DECLARE @APPOINTMENT_DATE DATE;

SET @APPOINTMENT_DATE =(
SELECT [AppointmentDate] FROM [dbo].[Appointments]
WHERE [AppointmentID]=@APPOINTMENT_ID 
)
	IF  @APPOINTMENT_DATE<@CURRENT_DATE
		BEGIN
		UPDATE [dbo].[Appointments]
		SET [Status]='PAST DUE'
		WHERE [AppointmentID]=@APPOINTMENT_ID
		END
	ELSE
	BEGIN
		UPDATE [dbo].[Appointments]
		SET [Status]='SCHEDULED'
		WHERE [AppointmentID]=@APPOINTMENT_ID
	END
END

EXEC UPDATE_APPOPINTMENT_STATUS_PAST_DUE 1
--------------------------------------------------------
--EXAMPLE 9 CHECK TOTAL COST 
CREATE PROCEDURE CHECK_TOTAL_COST_THERES_HOLD
@PATIENT_ID  INT,
@Exceed BIT OUTPUT
AS
BEGIN 
	DECLARE @THERES_HOLD DECIMAL(10,2)=500.00
	DECLARE @TOTAL_COST DECIMAL(10,2)
	SET  @TOTAL_COST=
	(
	SELECT SUM([Cost]) FROM [dbo].[Appointments]
	WHERE [PatientID]=@PATIENT_ID 
	)
	IF  @TOTAL_COST>@THERES_HOLD
		BEGIN
		SET @Exceed =1
		END
	ELSE
		BEGIN
		SET @Exceed =0
		END

END

DECLARE @RESULT BIT
EXEC CHECK_TOTAL_COST_THERES_HOLD 1, @RESULT OUTPUT

IF @RESULT=1
	 BEGIN
	 SELECT  @RESULT AS EXCEED
	 END
ELSE
	BEGIN
	SELECT  @RESULT AS  [NOT EXCEED]
	END
--------------------------------------------------

