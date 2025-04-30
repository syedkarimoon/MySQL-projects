CREATE DATABASE StudentManagementSystem;
USE StudentManagementSystem;

CREATE TABLE Students (
    StudentID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    Email VARCHAR(255) UNIQUE,
    PhoneNumber VARCHAR(20),
    Address VARCHAR(255)
);

CREATE TABLE Courses (
    CourseID INT PRIMARY KEY AUTO_INCREMENT,
    CourseName VARCHAR(255) NOT NULL,
    Credits INT
);

CREATE TABLE Enrollments (
    EnrollmentID INT PRIMARY KEY AUTO_INCREMENT,
    StudentID INT,
    CourseID INT,
    EnrollmentDate DATE,
    Grade VARCHAR(5),  -- e.g., A, B, C, etc.
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE Teachers (
    TeacherID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    PhoneNumber VARCHAR(20)
);

CREATE TABLE Subjects (coursescourses
    SubjectID INT PRIMARY KEY AUTO_INCREMENT,
    SubjectName VARCHAR(255) NOT NULL
);

CREATE TABLE Teacher_Subject (
    Teacher_SubjectID INT PRIMARY KEY AUTO_INCREMENT,
    TeacherID INT,
    SubjectID INT,
    FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID),
    FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
);
/* sample data insertion*/
INSERT INTO Students (FirstName, LastName, DateOfBirth, Email, PhoneNumber, Address)
VALUES
('Alice', 'Smith', '2002-03-15', 'alice.smith@example.com', '123-456-7890', '123 Main St'),
('Bob', 'Johnson', '2001-09-22', 'bob.johnson@example.com', '987-654-3210', '456 Oak Ave'),
('Charlie', 'Lee', '2003-01-10', 'charlie.lee@example.com', '555-123-4567', '789 Pine Ln');

INSERT INTO Courses (CourseName, Credits) 
VALUES
('Introduction to Programming', 3),
('Data Structures and Algorithms', 4),
('Database Management', 3);

INSERT INTO Enrollments (StudentID, CourseID, EnrollmentDate, Grade) 
VALUES
(1, 1, '2023-08-20', 'A'),
(2, 1, '2023-08-20', 'B'),
(1, 2, '2023-08-20', 'C');

INSERT INTO Teachers (FirstName, LastName, Email, PhoneNumber) 
VALUES
('Eva', 'Brown', 'eva.brown@example.com', '111-222-3333'),
('Frank', 'Miller', 'frank.miller@example.com', '444-555-6666');

INSERT INTO Subjects (SubjectName) VALUES
('Computer Science'),
('Mathematics');

INSERT INTO Teacher_Subject (TeacherID, SubjectID) 
VALUES
(1, 1),
(2, 2);

/*get all students*/
SELECT * FROM Students;

/*Get students enrolled in a specific course*/
SELECT s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName = 'Introduction to Programming';

/*Get courses a student is enrolled in*/
SELECT c.CourseName
FROM Courses c
JOIN Enrollments e ON c.CourseID = e.CourseID
JOIN Students s ON e.StudentID = s.StudentID
WHERE s.FirstName = 'Alice';

/*Get the average grade for a course:*/
SELECT AVG(CASE WHEN Grade = 'A' THEN 4 WHEN Grade = 'B' THEN 3 WHEN Grade = 'C' THEN 2 WHEN Grade = 'D' THEN 1 ELSE 0 END) AS AverageGrade
FROM Enrollments e
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName = 'Introduction to Programming';

/*Find the teacher who teaches a specific subject:*/
SELECT t.FirstName, t.LastName
FROM Teachers t
JOIN Teacher_Subject ts ON t.TeacherID = ts.TeacherID
JOIN Subjects s ON ts.SubjectID = s.SubjectID
WHERE s.SubjectName = 'Computer Science';

/*Get the total number of students enrolled in each course:*/
SELECT c.CourseName, COUNT(e.StudentID) AS NumberOfStudents
FROM Courses c
LEFT JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY c.CourseName;

/*Find students with a grade higher than 'C' in a specific course:*/
SELECT s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName = 'Introduction to Programming' AND e.Grade IN ('A', 'B');

/*views*/
 /*View: StudentEnrollmentDetails:
This view combines information from the Students, Courses, and Enrollments tables to provide a comprehensive view of student enrollments */
CREATE VIEW StudentEnrollmentDetails AS
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    c.CourseID,
    c.CourseName,
    c.Credits,
    e.EnrollmentDate,
    e.Grade
FROM
    Students s
JOIN
    Enrollments e ON s.StudentID = e.StudentID
JOIN
    Courses c ON e.CourseID = c.CourseID;    
    
    /*Query using the view:*/
    SELECT * FROM StudentEnrollmentDetails WHERE FirstName = 'Alice';  
    -- Get Alice's enrollment details

/*View: CourseStudentCount:
This view calculates the number of students enrolled in each course*/
CREATE VIEW CourseStudentCount AS
SELECT
    c.CourseID,
    c.CourseName,
    COUNT(e.StudentID) AS StudentCount
FROM
    Courses c
LEFT JOIN
    Enrollments e ON c.CourseID = e.CourseID
GROUP BY
    c.CourseID, c.CourseName;
    /*Query using the view:*/
    SELECT * FROM CourseStudentCount ORDER BY StudentCount DESC; 
    -- Get courses and student counts, sorted by count

/*View: TeacherSubjectDetails
This view combines information about teachers and the subjects they teach*/
CREATE VIEW TeacherSubjectDetails AS
SELECT
    t.TeacherID,
    t.FirstName,
    t.LastName,
    s.SubjectID,
    s.SubjectName
FROM
    Teachers t
JOIN
    Teacher_Subject ts ON t.TeacherID = ts.TeacherID
JOIN
    Subjects s ON ts.SubjectID = s.SubjectID;
    
    /*Query using the view:*/
    SELECT SubjectName FROM TeacherSubjectDetails WHERE LastName = 'Brown'; 
    -- Get subjects taught by teacher Brown
    
/*View: StudentGrades
This view provides a summarized view of student grades, potentially including calculated averages*/
CREATE VIEW StudentGrades AS
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    AVG(CASE
        WHEN e.Grade = 'A' THEN 4
        WHEN e.Grade = 'B' THEN 3
        WHEN e.Grade = 'C' THEN 2
        WHEN e.Grade = 'D' THEN 1
        ELSE 0  -- Handle other grades or NULLs appropriately
    END) AS AverageGrade
FROM
    Students s
LEFT JOIN
    Enrollments e ON s.StudentID = e.StudentID
GROUP BY
    s.StudentID, s.FirstName, s.LastName;
    
    /*View: StudentCourseGrades
This view shows individual student grades for each course*/
CREATE VIEW StudentCourseGrades AS
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    c.CourseName,
    e.Gradebank_transactions
FROM
    Students s
JOIN
    Enrollments e ON s.StudentID = e.StudentID
JOIN
    Courses c ON e.CourseID = c.CourseID;
    /*Query using the view:*/
    SELECT * FROM StudentCourseGrades 
    WHERE FirstName = 'Bob' AND CourseName = 'Data Structures and Algorithms'; 
    -- Get Bob's grade in a specific course
