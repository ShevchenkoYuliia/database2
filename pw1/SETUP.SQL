use pcmouse;

CREATE TABLE Постачальник (
    Код_постачальника INT PRIMARY KEY,
    Назва NVARCHAR(100) NOT NULL,
    Адреса NVARCHAR(200) NOT NULL,
    Контактний_номер NVARCHAR(20) NOT NULL,
    Електронна_пошта NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Компютерна_Мишка (
    Код_товару INT PRIMARY KEY,
    Назва_моделі NVARCHAR(100) NOT NULL,
    Бренд NVARCHAR(50) NOT NULL,
    Тип NVARCHAR(50) NOT NULL,
    Кількість_кнопок INT NOT NULL,
    Розмір NVARCHAR(20),
    Ціна DECIMAL(10, 2) NOT NULL,
    Кількість_на_складі INT NOT NULL,
    Колір NVARCHAR(20),
    Код_постачальника INT NOT NULL,
    FOREIGN KEY (Код_постачальника) REFERENCES Постачальник(Код_постачальника)
);

CREATE TABLE Клієнт (
    Код_покупця INT PRIMARY KEY,
    Ім_я NVARCHAR(50) NOT NULL,
    Прізвище NVARCHAR(50) NOT NULL,
    Адреса_електронної_пошти NVARCHAR(100) NOT NULL UNIQUE,
    Номер_телефону NVARCHAR(20) NOT NULL UNIQUE,
    Адреса_доставки NVARCHAR(200),
    Номер_бонусного_рахунку NVARCHAR(20) UNIQUE
);

CREATE TABLE Замовлення (
    Код_замовлення INT PRIMARY KEY,
    Код_покупця INT NOT NULL,
    Дата_замовлення DATE NOT NULL,
    Загальна_сума_замовлення DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Код_покупця) REFERENCES Клієнт(Код_покупця)
);

CREATE TABLE Деталі_Замовлення (
    Код_деталей_замовлення INT PRIMARY KEY,
    Код_товару INT NOT NULL,
    Код_замовлення INT NOT NULL,
    Кількість_товару INT NOT NULL,
    Сума_за_позицію DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Код_товару) REFERENCES Компютерна_Мишка(Код_товару),
    FOREIGN KEY (Код_замовлення) REFERENCES Замовлення(Код_замовлення)
);
