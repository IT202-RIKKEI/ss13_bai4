
USE RikkeiClinicDB;

-- TẠO BẢNG APPOINTMENTS
CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending'
);

-- DỮ LIỆU MẪU
INSERT INTO Appointments
(appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES
(101, 1, 201, '2026-06-10 08:00:00', 'Pending'),
(102, 2, 201, '2026-06-10 09:00:00', 'Cancelled'),
(103, 3, 202, '2026-06-10 08:00:00', 'Pending');


-- TRIGGER INSERT
DELIMITER //
CREATE TRIGGER PreventDoctorDoubleBooking_Insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    DECLARE total_conflict INT;
    SELECT COUNT(*)
    INTO total_conflict
    FROM Appointments
    WHERE doctor_id = NEW.doctor_id
    AND appointment_date = NEW.appointment_date
    AND status <> 'Cancelled';
    IF total_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi: Bac si da co lich hen vao khung gio nay';
    END IF;
END //
DELIMITER ;


-- TRIGGER UPDATE
DELIMITER //
CREATE TRIGGER PreventDoctorDoubleBooking_Update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    DECLARE total_conflict INT;
    SELECT COUNT(*)
    INTO total_conflict
    FROM Appointments
    WHERE doctor_id = NEW.doctor_id
    AND appointment_date = NEW.appointment_date
    AND status <> 'Cancelled'
    AND appointment_id <> NEW.appointment_id;
    IF total_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi: Bac si da co lich hen vao khung gio nay';
    END IF;
END //
DELIMITER ;

-- TEST 1
INSERT INTO Appointments
VALUES
(104, 4, 201, '2026-06-10 10:00:00', 'Pending');


-- TEST 2
INSERT INTO Appointments
VALUES
(105, 5, 201, '2026-06-10 08:00:00', 'Pending');


-- TEST 3
INSERT INTO Appointments
VALUES
(106, 6, 201, '2026-06-10 09:00:00', 'Pending');

-- UPDATE TRẠNG THÁI CHÍNH NÓ
UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 101;