-- =============================================================================
-- PennyPal — Database Schema Definition (.sql)
-- TechWiz 7 — The World Tech Championship (Aptech)
-- Theme: NextGen BudgetBee
-- Category: Multi-Platform App Computing
-- Software Requirements Specification (SRS) Version 1.0 — Database Entity Script
-- =============================================================================

-- Drop tables in reverse foreign key order if they exist
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS SupportQueries;
DROP TABLE IF EXISTS Reports;
DROP TABLE IF EXISTS SavingsGoals;
DROP TABLE IF EXISTS Budgets;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS LearningContent;
DROP TABLE IF EXISTS UserProfiles;
DROP TABLE IF EXISTS Users;

-- =============================================================================
-- 1. Users Entity (SRS Page 13)
-- Core authentication and identity table for students and administrators
-- =============================================================================
CREATE TABLE Users (
    UserId VARCHAR(64) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    MobileNumber VARCHAR(25) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL DEFAULT 'student' CHECK (Role IN ('student', 'admin')),
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LastLogin TIMESTAMP NULL
);

-- =============================================================================
-- 2. UserProfiles Entity (SRS Page 13)
-- Student preferences, personalization, and profile metadata
-- =============================================================================
CREATE TABLE UserProfiles (
    ProfileId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL UNIQUE,
    StudentStatus VARCHAR(50) DEFAULT 'Enrolled',
    CurrencyPreference VARCHAR(10) DEFAULT 'PKR',
    NotificationPreference BOOLEAN DEFAULT TRUE,
    ProfileImage VARCHAR(500) NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- =============================================================================
-- 3. Categories Entity (SRS Page 13)
-- Standard and student-defined expense and income categories
-- =============================================================================
CREATE TABLE Categories (
    CategoryId VARCHAR(64) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL,
    CategoryType VARCHAR(20) NOT NULL CHECK (CategoryType IN ('expense', 'income')),
    Icon VARCHAR(50) NOT NULL,
    IsDefault BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedBy VARCHAR(64) NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserId) ON DELETE SET NULL
);

-- =============================================================================
-- 4. Transactions Entity (SRS Page 13)
-- Itemized records of student daily expenses and income entries
-- =============================================================================
CREATE TABLE Transactions (
    TransactionId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    Type VARCHAR(20) NOT NULL CHECK (Type IN ('expense', 'income')),
    Amount DECIMAL(12, 2) NOT NULL CHECK (Amount > 0),
    CategoryId VARCHAR(64) NULL,
    Description VARCHAR(255) NULL,
    Date TIMESTAMP NOT NULL,
    PaymentMode VARCHAR(30) NOT NULL DEFAULT 'Cash' CHECK (PaymentMode IN ('Cash', 'Card', 'Bank Transfer', 'Mobile Wallet')),
    ReceiptImageUrl VARCHAR(500) NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId) ON DELETE SET NULL
);

-- =============================================================================
-- 5. Budgets Entity (SRS Page 13)
-- Monthly spending limits and category alert thresholds
-- =============================================================================
CREATE TABLE Budgets (
    BudgetId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    Month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    CategoryId VARCHAR(64) NULL,
    LimitAmount DECIMAL(12, 2) NOT NULL CHECK (LimitAmount > 0),
    AlertThreshold DECIMAL(3, 2) NOT NULL DEFAULT 0.80, -- Warning at 80%
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId) ON DELETE SET NULL
);

-- =============================================================================
-- 6. SavingsGoals Entity (SRS Page 13)
-- Student financial targets, progress tracking, and milestones
-- =============================================================================
CREATE TABLE SavingsGoals (
    GoalId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    GoalName VARCHAR(100) NOT NULL,
    TargetAmount DECIMAL(12, 2) NOT NULL CHECK (TargetAmount > 0),
    CurrentAmount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (CurrentAmount >= 0),
    TargetDate DATE NOT NULL,
    MonthlyContribution DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    Status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (Status IN ('active', 'completed', 'archived')),
    CompletedAt TIMESTAMP NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- =============================================================================
-- 7. Reports Entity (SRS Page 13)
-- Generated monthly summaries, trend analysis, and export metadata
-- =============================================================================
CREATE TABLE Reports (
    ReportId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    ReportType VARCHAR(50) NOT NULL,
    DateRange VARCHAR(100) NOT NULL,
    GeneratedOn TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FileUrl VARCHAR(500) NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- =============================================================================
-- 8. LearningContent Entity (SRS Page 13)
-- Financial literacy modules, educational topics, and tips managed by Admin
-- =============================================================================
CREATE TABLE LearningContent (
    ContentId VARCHAR(64) PRIMARY KEY,
    Title VARCHAR(150) NOT NULL,
    Topic VARCHAR(50) NOT NULL,
    Body TEXT NOT NULL,
    DifficultyLevel VARCHAR(20) NOT NULL DEFAULT 'Beginner' CHECK (DifficultyLevel IN ('Beginner', 'Intermediate', 'Advanced')),
    ImageUrl VARCHAR(500) NULL,
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

-- =============================================================================
-- 9. Notifications Entity (SRS Page 13)
-- Real-time spending alerts, threshold notifications, and savings updates
-- =============================================================================
CREATE TABLE Notifications (
    NotificationId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    Title VARCHAR(150) NOT NULL,
    Message TEXT NOT NULL,
    Type VARCHAR(50) NOT NULL,
    ReadStatus BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- =============================================================================
-- 10. SupportQueries Entity (SRS Page 13)
-- Student contact queries and administrative responses
-- =============================================================================
CREATE TABLE SupportQueries (
    QueryId VARCHAR(64) PRIMARY KEY,
    UserId VARCHAR(64) NOT NULL,
    Subject VARCHAR(150) NOT NULL,
    Message TEXT NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (Status IN ('open', 'answered', 'closed')),
    AdminResponse TEXT NULL,
    SubmittedOn TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- =============================================================================
-- Performance Optimization Indexes
-- =============================================================================
CREATE INDEX idx_transactions_user_date ON Transactions(UserId, Date);
CREATE INDEX idx_budgets_user_month ON Budgets(UserId, Month);
CREATE INDEX idx_savings_user_status ON SavingsGoals(UserId, Status);
CREATE INDEX idx_notifications_user_read ON Notifications(UserId, ReadStatus);
CREATE INDEX idx_support_user_status ON SupportQueries(UserId, Status);

-- =============================================================================
-- Seed Data: Mandatory Default Categories (SRS Page 9)
-- =============================================================================
INSERT INTO Categories (CategoryId, CategoryName, CategoryType, Icon, IsDefault) VALUES
('cat_food', 'Food', 'expense', 'restaurant_outlined', TRUE),
('cat_transport', 'Transport', 'expense', 'directions_bus_outlined', TRUE),
('cat_education', 'Education', 'expense', 'menu_book_outlined', TRUE),
('cat_shopping', 'Shopping', 'expense', 'shopping_bag_outlined', TRUE),
('cat_entertainment', 'Entertainment', 'expense', 'movie_outlined', TRUE),
('cat_bills', 'Bills', 'expense', 'receipt_long_outlined', TRUE),
('cat_savings', 'Savings', 'expense', 'savings_outlined', TRUE),
('cat_misc', 'Miscellaneous', 'expense', 'category_outlined', TRUE),
('cat_inc_allowance', 'Allowance', 'income', 'payments_outlined', TRUE),
('cat_inc_scholarship', 'Scholarship', 'income', 'school_outlined', TRUE),
('cat_inc_salary', 'Salary', 'income', 'work_outlined', TRUE),
('cat_inc_freelance', 'Freelance', 'income', 'computer_outlined', TRUE);

-- =============================================================================
-- Seed Data: Preconfigured Administrator and Demo Accounts (SRS Page 8, 15)
-- =============================================================================
INSERT INTO Users (UserId, FullName, Email, MobileNumber, PasswordHash, Role) VALUES
('usr_admin_01', 'PennyPal Admin', 'admin@pennypal.app', '+92 300 0000000', 'Admin@1234', 'admin'),
('usr_student_01', 'Alex Khan', 'alex@student.edu', '+92 300 1234567', 'PennyPal1', 'student');

INSERT INTO UserProfiles (ProfileId, UserId, StudentStatus, CurrencyPreference, NotificationPreference) VALUES
('prof_admin_01', 'usr_admin_01', 'Administrator', 'PKR', TRUE),
('prof_student_01', 'usr_student_01', 'Full-time Student', 'PKR', TRUE);

-- =============================================================================
-- Seed Data: Educational Learning Modules (SRS Page 10)
-- =============================================================================
INSERT INTO LearningContent (ContentId, Title, Topic, Body, DifficultyLevel, IsActive) VALUES
('les_budget_01', 'What is a Budget?', 'Budgeting', 'A budget is a plan that shows what money comes in, what goes out, and what is left over. It answers one question before the month begins: where should my money go?', 'Beginner', TRUE),
('les_budget_02', 'The 50/30/20 Guide', 'Budgeting', 'A popular starting point for splitting your money three ways: 50% for needs, 30% for wants, and 20% for savings and financial goals.', 'Beginner', TRUE),
('les_saving_01', 'Building an Emergency Fund', 'Saving', 'Aim to keep 1 to 2 months of basic expenses safe in a separate fund. When an unexpected expense arrives, you do not need to borrow.', 'Beginner', TRUE),
('les_needs_01', 'Needs vs Wants', 'Needs vs wants', 'A need is something required for health, safety, or core education. A want is something that makes life more pleasant. Learning the line between them protects your future.', 'Beginner', TRUE);
