-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Oct 11, 2016 at 03:57 PM
-- Server version: 10.1.13-MariaDB
-- PHP Version: 5.6.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `library_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_due_list` ()  NO SQL
SELECT I.issue_id, M.email, B.isbn, B.title
FROM book_issue_log I INNER JOIN member M on I.member = M.username INNER JOIN book B ON I.book_isbn = B.isbn
WHERE DATEDIFF(CURRENT_DATE, I.due_date) >= 0 AND DATEDIFF(CURRENT_DATE, I.due_date) % 5 = 0 AND (I.last_reminded IS NULL OR DATEDIFF(I.last_reminded, CURRENT_DATE) <> 0)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `book`
--

CREATE TABLE `book` (
  `isbn` char(13) NOT NULL,
  `title` varchar(80) NOT NULL,
  `author` varchar(80) NOT NULL,
  `category` varchar(80) NOT NULL,
  `price` int(4) UNSIGNED NOT NULL,
  `copies` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `book`
--

INSERT INTO `book` (`isbn`, `title`, `author`, `category`, `price`, `copies`) VALUES
('0000545010225', 'Harry Potter and the Deathly Hallows', 'J. K. Rowling', 'Fiction', 550, 30),
('0000553103547', 'A Game of Thrones', 'George R. R. Martin', 'Fiction', 500, 10),
('0000553106635', 'A Storm of Swords', 'George R. R. Martin', 'Fiction', 550, 15),
('0000553108034', 'A Clash of Kings', 'George R. R. Martin', 'Fiction', 500, 10),
('0000553801503', 'A Feast for Crows', 'George R. R. Martin', 'Fiction', 600, 20),
('0000747532699', 'Harry Potter and the Philosopher''s Stone', 'J. K. Rowling', 'Fiction', 300, 12),
('0000747538492', 'Harry Potter and the Chamber of Secrets', 'J. K. Rowling', 'Fiction', 300, 10),
('0000747542155', 'Harry Potter and the Prisoner of Azkaban', 'J. K. Rowling', 'Fiction', 350, 16),
('0000747546240', 'Harry Potter and the Goblet of Fire', 'J. K. Rowling', 'Fiction', 400, 15),
('0000747551006', 'Harry Potter and the Order of the Phoenix', 'J. K. Rowling', 'Fiction', 400, 20),
('0000747581088', 'Harry Potter and the Half-Blood Prince', 'J. K. Rowling', 'Fiction', 500, 25),
('9780066620992', 'Good to Great', 'Jim Collins', 'Non-fiction', 300, 10),
('9780241257555', 'The Pigeon Tunnel', 'John le CarrÃ©', 'Non-fiction', 200, 25),
('9780439023511', 'Mockingjay', 'Suzanne Collins', 'Fiction', 500, 20),
('9780439023528', 'The Hunger Games', 'Suzanne Collins', 'Fiction', 400, 10),
('9780545227247', 'Catching Fire', 'Suzanne Collins', 'Fiction', 400, 14),
('9780553801477', 'A Dance with Dragons', 'George R. R. Martin', 'Fiction', 600, 30),
('9780967752808', 'Sandbox Wisdom', 'Tom Asacker', 'Non-fiction', 250, 5),
('9781501141515', 'Born to Run', 'Bruce Springsteen', 'Non-fiction', 250, 20),
('9788183331630', 'Let Us C', 'Yashavant Kanetkar', 'Education', 200, 22),
('9789350776667', 'Computer Graphics and Virtual Reality', 'Sanjesh S. Pawale', 'Education', 100, 30),
('9789350776773', 'Microcontroller and Embedded Systems', 'Harish G. Narula', 'Education', 80, 15),
('9789350777077', 'Advanced Database Management Systems', 'Mahesh Mali', 'Education', 60, 29),
('9789350777121', 'Operating Systems', 'Rajesh Kadu', 'Education', 50, 24),
('9789351194545', 'Open Source Technologies', 'Dayanand Ambawade', 'Education', 100, 20),
('9789381626719', 'Stay Hungry Stay Foolish', 'Rashmi Bansal', 'Non-fiction', 100, 5);

-- --------------------------------------------------------

--
-- Table structure for table `book_issue_log`
--

CREATE TABLE `book_issue_log` (
  `issue_id` int(11) NOT NULL,
  `member` varchar(20) NOT NULL,
  `book_isbn` varchar(13) NOT NULL,
  `due_date` date NOT NULL,
  `last_reminded` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `book_issue_log`
--

INSERT INTO `book_issue_log` (`issue_id`, `member`, `book_isbn`, `due_date`, `last_reminded`) VALUES
(1, 'seph32', '9789350777077', '2016-10-17', NULL),
(2, 'seph32', '9780545227247', '2016-10-17', NULL);

--
-- Triggers `book_issue_log`
--
DELIMITER $$
CREATE TRIGGER `issue_book` BEFORE INSERT ON `book_issue_log` FOR EACH ROW BEGIN
	SET NEW.due_date = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    UPDATE member SET balance = balance - (SELECT price FROM book WHERE isbn = NEW.book_isbn) WHERE username = NEW.member;
    UPDATE book SET copies = copies - 1 WHERE isbn = NEW.book_isbn;
    DELETE FROM pending_book_requests WHERE member = NEW.member AND book_isbn = NEW.book_isbn;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `return_book` BEFORE DELETE ON `book_issue_log` FOR EACH ROW BEGIN
    UPDATE member SET balance = balance + (SELECT price FROM book WHERE isbn = OLD.book_isbn) WHERE username = OLD.member;
    UPDATE book SET copies = copies + 1 WHERE isbn = OLD.book_isbn;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `librarian`
--

CREATE TABLE `librarian` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `librarian`
--

INSERT INTO `librarian` (`id`, `username`, `password`) VALUES
(1, 'genesis', '93c768d0152f72bc8d5e782c0b585acc35fb0442');

-- --------------------------------------------------------