
CREATE DATABASE MapAppDb;
GO

USE MapAppDb;
GO

-- Tạo bảng lưu trữ tuyến đường yêu thích
CREATE TABLE FavoriteRoutes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    StartLocation NVARCHAR(250) NOT NULL,
    EndLocation NVARCHAR(250) NOT NULL,
    StartLat FLOAT NOT NULL,
    StartLng FLOAT NOT NULL,
    EndLat FLOAT NOT NULL,
    EndLng FLOAT NOT NULL,
    TravelMode NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);