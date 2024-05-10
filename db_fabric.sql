
 
CREATE TABLE `customer` (
    `customerCode` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `customerFirstName` VARCHAR(70) NOT NULL,
    `customerLastName` VARCHAR(70) NOT NULL,
    `address` VARCHAR(70) NOT NULL,
    `arrearage` INT(10) NOT NULL DEFAULT 0,
    PRIMARY KEY (`customerCode`)
);

ALTER TABLE `customer` AUTO_INCREMENT=12;


CREATE TABLE `employee` (
    `employeeCode` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `employeeFirstName` VARCHAR(70) NOT NULL,
    `employeeLastName` VARCHAR(70) NOT NULL,
    `genre` VARCHAR(1) NOT NULL CHECK (`genre` IN ('F', 'M', 'B')),
    `address` VARCHAR(70) NOT NULL,
    `customerCode` INT(10) UNSIGNED,
    `FManager` TINYINT(1) NOT NULL CHECK (`FManager` IN (1, 0)),
    `FOfficestaff` TINYINT(1) NOT NULL CHECK (`FOfficestaff` IN (1, 0)),
    `FOperationalstaff` TINYINT(1) NOT NULL CHECK (`FOperationalstaff` IN (1, 0)),
    `FPartnerstaff` TINYINT(1) NOT NULL CHECK (`FPartnerstaff` IN (1, 0)),
    PRIMARY KEY (`employeeCode`),
    CONSTRAINT `fk_customerCode` FOREIGN KEY (`customerCode`) REFERENCES `customer`(`customerCode`)
)AUTO_INCREMENT=53;

CREATE TABLE `supplier` (
	`employeeCode` INT(10) UNSIGNED,
    `supplierCode` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `supplierName` VARCHAR(70) NOT NULL,
    `address` VARCHAR(70) DEFAULT NULL,
    `bankAccount` VARCHAR(22) DEFAULT NULL,
    `taxCode` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`supplierCode`),
    constraint `foreign_employee` foreign KEY (employeeCode) references employee(EmployeeCode)
) auto_increment=16;
CREATE TABLE `category` (
    `categoryCode` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `categoryName` VARCHAR(70) NOT NULL,
    `color` VARCHAR(20) NOT NULL,
    `quantity` INT(10) DEFAULT 0,
    PRIMARY KEY (`categoryCode`)
);

CREATE TABLE `bolt` (
    `categoryCode` INT(10) UNSIGNED NOT NULL,
    `boltCode` INT(10) UNSIGNED NOT NULL,
    `length` FLOAT NOT NULL CHECK (`length` > 0),
    PRIMARY KEY (`boltCode`),
    CONSTRAINT `bolt_fk_category` FOREIGN KEY (`categoryCode`) REFERENCES `category` (`categoryCode`)
) ;

CREATE TABLE `supplier_phonenumber` (
    `supplierCode` INT(10) UNSIGNED NOT NULL,
    `phoneNumber` VARCHAR(11) NOT NULL,
    PRIMARY KEY (`phoneNumber`),
    CONSTRAINT `suplier_phonenumber_fk_supplier` FOREIGN KEY (`supplierCode`) REFERENCES `supplier` (`supplierCode`) ON DELETE CASCADE
) ;

CREATE TABLE `payment_History` (
    `paymentCode` INT(10) UNSIGNED NOT NULL auto_increment,
    `totalprice` INT(100)  NOT NULL default 0,
    `PaymentDate` DATE,
    `CustomerCode` INT(10) UNSIGNED NOT NULL,
    PRIMARY KEY (`paymentCode`),
    CONSTRAINT `payment_History_fk_customer` FOREIGN KEY (`CustomerCode`) REFERENCES `customer` (`customerCode`) ON DELETE CASCADE
)auto_increment=10;


#Cho trigger để khi customer trả thì nó sẽ lưu vào đây


CREATE TABLE `customer_order` (
    `orderCode` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `totalprice` DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT 0,
    `orderstatus` VARCHAR(50) CHECK (`orderstatus` IN ('new', 'ordered', 'partial paid', 'full paid', 'cancelled')),
    `reasoncancel` VARCHAR(50) DEFAULT NULL,
    `r_customerCode` INT(10) UNSIGNED NOT NULL,
    CONSTRAINT `customer_order_fk_customer` FOREIGN KEY (`r_customerCode`) REFERENCES `customer` (`customerCode`),
    PRIMARY KEY (`orderCode`)
) AUTO_INCREMENT=21;


CREATE TABLE `relationprovide_provideinformation` (
	`r_supplierCode` INT(10) unsigned NOT NULL,
    `categoryCode` INT(10) UNSIGNED NOT NULL,
    `purchasePrice` INT(6) UNSIGNED NOT NULL,
    `quantity` INT(10) NOT NULL DEFAULT 0,
    `date` DATE NOT NULL,
    PRIMARY KEY (`categoryCode`),
	CONSTRAINT `relationprovide_provideinformation_fk_supplier` FOREIGN KEY (`r_supplierCode`) REFERENCES `supplier` (`supplierCode`) ON DELETE CASCADE,
	
    CONSTRAINT `relationprovide_provideinformation_fk_category` FOREIGN KEY (`categoryCode`) REFERENCES `category` (`categoryCode`) ON DELETE CASCADE);
CREATE TABLE `customer_phonenumber` (
    `customerCode` INT(10) UNSIGNED NOT NULL,
    `phoneNumber` VARCHAR(11) NOT NULL,
    PRIMARY KEY (`phoneNumber`),
    CONSTRAINT `customer_phonenumber_fk_customer` FOREIGN KEY (`customerCode`) REFERENCES `customer` (`customerCode`) ON DELETE CASCADE
) ;

CREATE TABLE `customer_partialpayment` (
  `customerCode` int(10) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `money` int(10) NOT NULL,
  PRIMARY KEY (`customerCode`, `date`, `money`),
  CONSTRAINT `customer_partialPayment_fk_customer` FOREIGN KEY (`customerCode`) REFERENCES `customer` (`customerCode`) ON DELETE CASCADE
) ;

CREATE TABLE `employee_phonenumber` (
    `employeeCode` INT(10) UNSIGNED NOT NULL,
    `phoneNumber` VARCHAR(11) NOT NULL,
    PRIMARY KEY (`phoneNumber`),
    CONSTRAINT `employee_phonenumber_fk_employee` FOREIGN KEY (`employeeCode`) REFERENCES `employee` (`employeeCode`) ON DELETE CASCADE
);

CREATE TABLE `relationcontain_containbolt` (
  `boltCode` int(10) UNSIGNED NOT NULL,
  `orderCode` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`boltCode`,`orderCode`),
  CONSTRAINT `relationContain_containBolt_fk_bolt` FOREIGN KEY ( `boltCode`) REFERENCES `bolt` ( `boltCode`),
  CONSTRAINT `relationContain_containBolt_fk_order` FOREIGN KEY (`orderCode`) REFERENCES `customer_order` (`orderCode`) ON DELETE CASCADE
) ;



CREATE TABLE `relationprocess_processorder` (
    `orderCode` INT(10) UNSIGNED NOT NULL,
    `employeeCode` INT(10) UNSIGNED,
    `time` TIME DEFAULT NULL,
    `date` DATE DEFAULT NULL,
    PRIMARY KEY (`orderCode`) ,
    KEY `relationProcess_processsOrder_fk_employee` (`employeeCode`),
    CONSTRAINT `relationProcess_processOrder_fk_order` FOREIGN KEY (`orderCode`) REFERENCES `customer_order` (`orderCode`) ON DELETE CASCADE,
    CONSTRAINT `relationProcess_processsOrder_fk_employee` FOREIGN KEY (`employeeCode`) REFERENCES `employee` (`employeeCode`)
);
CREATE TABLE `category_sellingprice` (
    `categoryCode` INT(10) UNSIGNED NOT NULL,
    `price` INT(6) UNSIGNED NOT NULL,
    `date` DATE NOT NULL,
    PRIMARY KEY (`categoryCode`, `price`, `date`),
    CONSTRAINT `category_sellingprice_fk_category` FOREIGN KEY (`categoryCode`) REFERENCES `category` (`categoryCode`) ON DELETE CASCADE
) ;



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- TRIGGER thanh toán một phần ---------------------------------
DELIMITER $$

CREATE TRIGGER `calc_unpaidDebt_delete` AFTER DELETE ON `customer_partialpayment` FOR EACH ROW
BEGIN
    UPDATE customer 
    SET arrearage = arrearage + OLD.money
    WHERE customer.customerCode = OLD.customerCode;

    INSERT INTO payment_History (totalprice, PaymentDate, CustomerCode)
    VALUES (-(OLD.money), OLD.`date`, OLD.customerCode);
END $$
CREATE TRIGGER `calc_unpaidDebt_insert` AFTER INSERT ON `customer_partialpayment` FOR EACH ROW
BEGIN
    UPDATE customer 
    SET arrearage = arrearage - NEW.money
    WHERE customer.customerCode = NEW.customerCode;

    INSERT INTO payment_History (totalprice, PaymentDate, CustomerCode)
    VALUES (NEW.money, NEW.`date`, NEW.customerCode);
END $$

CREATE TRIGGER `calc_unpaidDebt_update` AFTER UPDATE ON `customer_partialpayment` FOR EACH ROW
BEGIN
    IF !(NEW.money <=> OLD.money) THEN
        UPDATE customer 
        SET arrearage = arrearage - (NEW.money - OLD.money)
        WHERE customer.customerCode = NEW.customerCode;

        INSERT INTO payment_History (totalprice, PaymentDate, CustomerCode)
        VALUES ((NEW.money - OLD.money), OLD.`date`, NEW.customerCode);
    END IF;
END $$

DELIMITER ;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

# đây là trigger kiểm tra FOperationalStaff, nếu mà thằng đó là Oper thì nó mới hiện bên relationprocess_processorder

CREATE TABLE PAYMENT_TABLE_LOG (
    PaymentID INT PRIMARY KEY,
    TotalAmount INT,
    StatusReport VARCHAR(255),
    DatePay DATE NOT NULL
);

##################################### Views##########################################################
CREATE TABLE `getallcategories` (
`category` varchar(70)
,`id` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Stand-in view `getallorders`

--
CREATE TABLE `getallorders` (
`orderCode` int(10) unsigned
,`totalPrice` float unsigned
,`customerCode` int(10) unsigned
,`Name` varchar(141)
);

-- --------------------------------------------------------

--
-- Stand-in  view `getalltransaction`
--
CREATE TABLE `getalltransaction` (
`categoryName` varchar(70)
,`Date` date
,`purchasePrice` int(6) unsigned
,`Quantity` int(10)
,`supplierName` varchar(70)
,`supplierCode` int(10) unsigned
);

-- --------------------------------------------------------

--
--
CREATE TABLE `getcustomersname` (
`Name` varchar(141)
);

-- --------------------------------------------------------

--
-- Stand-in  view `getsupplierinfos`
--
CREATE TABLE `getsupplierinfos` (
`supplierCode` int(10) unsigned
,`address` varchar(70)
,`bankAccount` varchar(22)
,`taxCode` varchar(50)
,`phoneNumber` mediumtext
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `getsuppliersname`
--
CREATE TABLE `getsuppliersname` (
`ID` int(10) unsigned
,`Name` varchar(70)
);


DROP TABLE IF EXISTS `getallcategories`;

CREATE  VIEW getallcategories AS
SELECT
    category.categoryName AS category,
    relationprovide_provideinformation.r_supplierCode AS id
FROM
    category
JOIN
    relationprovide_provideinformation ON category.categoryCode = relationprovide_provideinformation.categoryCode;
-- --------------------------------------------------------

--
--
DROP TABLE IF EXISTS `getallorders`;

CREATE  VIEW `getallorders`  AS  select `customer_order`.`orderCode` AS `orderCode`,
`customer_order`.`totalPrice` AS `totalPrice`,`customer`.`customerCode` AS `customerCode`,
concat(`customer`.`customerLastName`,' ',`customer`.`customerFirstName`) AS `Name`
 from (`customer_order` join `customer`) where `customer_order`.`r_customerCode` = `customer`.`customerCode`
 order by `customer_order`.`orderCode` ;

-- --------------------------------------------------------

--
--
DROP TABLE IF EXISTS `getalltransaction`;

CREATE VIEW `getalltransaction`  AS  select `category`.`categoryName` AS `categoryName`,`relationprovide_provideinformation`.`date` AS `Date`,
`relationprovide_provideinformation`.`purchasePrice` AS `purchasePrice`,
`relationprovide_provideinformation`.`quantity` AS `Quantity`,`supplier`.`supplierName` AS `supplierName`,`supplier`.`supplierCode` AS `supplierCode`
 from ((`category` join `relationprovide_provideinformation`) join `supplier`) where `category`.`categoryCode` = `relationprovide_provideinformation`.`categoryCode` 
 and `supplier`.`supplierCode` = `relationprovide_provideinformation`.`r_supplierCode` 
order by `relationprovide_provideinformation`.`date` desc ;

-- --------------------------------------------------------

--
--
DROP TABLE IF EXISTS `getcustomersname`;
CREATE  VIEW `getcustomersname` AS
SELECT DISTINCT
  CONCAT(`customer`.`customerLastName`, ' ', `customer`.`customerFirstName`) AS `Name`,
  `customer`.`customerFirstName`  -- Add the column to the SELECT list
FROM `customer`
ORDER BY `customer`.`customerFirstName`;

-- --------------------------------------------------------

--
-- Structure for view `getsupplierinfos`
--
DROP TABLE IF EXISTS `getsupplierinfos`;

CREATE VIEW `getsupplierinfos`  AS  select `supplier`.`supplierCode` AS `supplierCode`,
`supplier`.`address` AS `address`,`supplier`.`bankAccount` AS `bankAccount`,`supplier`.`taxCode` AS `taxCode`,
group_concat(`supplier_phonenumber`.`phoneNumber` separator ', ') AS `phoneNumber` 
from (`supplier` left join `supplier_phonenumber` on(`supplier`.`supplierCode` = `supplier_phonenumber`.`supplierCode`)) group by `supplier`.`supplierCode` ;

-- --------------------------------------------------------

--
-- Structure for view `getsuppliersname`
--
DROP TABLE IF EXISTS `getsuppliersname`;

CREATE VIEW `getsuppliersname`  AS  select `supplier`.`supplierCode` AS `ID`,
`supplier`.`supplierName` AS `Name` from `supplier` order by `supplier`.`supplierName` ;




################################################# FUNCTION ################################################
DELIMITER $$

CREATE FUNCTION `getNumberOfSuppliers` (`input_supplierName` VARCHAR(70)) RETURNS INT(11) BEGIN
DECLARE totalPurchasePrice INT;
SELECT COUNT(`supplierCode`) INTO totalPurchasePrice FROM supplier WHERE `supplierName` = input_supplierName;
RETURN totalPurchasePrice;
END$$

DELIMITER ;
########################################################## PROCEDURE #####################################################
DELIMITER $$
-- Procedures

############# Supplier ########################
#Lấy Giá của nhà cung cấp
CREATE PROCEDURE `getSellingPrice` (IN `input_supplierId` INT(10))  SELECT categoryCode as code, price, date FROM  category_sellingprice 
  NATURAL JOIN relationprovide_provideinformation
  WHERE relationprovide_provideinformation.r_supplierCode = input_supplierId$$
-- thêm Suplier
CREATE PROCEDURE `add_supplier` 
(IN `supplierName` VARCHAR(70), IN `address` VARCHAR(70), IN `bankAccount` VARCHAR(22), IN `taxCode` VARCHAR(50), OUT `inserted_id` INT(10))  BEGIN
  INSERT INTO supplier (`supplierName`, `address`, `bankAccount`, `taxCode`) VALUES (supplierName, address, bankAccount, taxCode);
  SELECT last_insert_id() INTO inserted_id;
END$$

 -- lấy thông tin supplier 
 CREATE PROCEDURE `getSupplierInfo` (IN `input_supplierId` INT(10))  
 SELECT supplierName as name, taxCode as tax, address, bankAccount as bank  FROM supplier 
 WHERE supplierCode = input_supplierId$$
 
 -- lấy số điện thoại thêm số điện thoại của supplier
 CREATE PROCEDURE `getSupplierPhoneNumber` (IN `input_supplierId` INT(10))  
 SELECT phoneNumber FROM supplier_phonenumber WHERE supplierCode = input_supplierId$$
 
 -- thêm số điện thoại của supplier
 CREATE  PROCEDURE `insertPhones` (IN `supplier` INT(10), IN `phonesArray` LONGTEXT)  BEGIN
    DECLARE _result longtext DEFAULT 'INSERT INTO supplier_phonenumber(supplierCode, phoneNumber) VALUES ';
    DECLARE _counter INT DEFAULT 0;
    SET @start = 'INSERT INTO supplier_phonenumber(supplierCode, phoneNumber) VALUES ';
    WHILE _counter < JSON_LENGTH(phonesArray) DO
        IF _counter != 0 THEN
            SET @start = CONCAT(@start, ', ');
        END IF;
        SET @start = CONCAT(@start,"('", supplier, "',", JSON_EXTRACT(phonesArray, CONCAT('$[',_counter,']')), ')');
        SET _counter = _counter + 1;
    END WHILE;
    PREPARE stmt FROM @start;
    EXECUTE stmt;                                                                
    DEALLOCATE PREPARE stmt;
END$$

-- Lấy loại hàng theo supplier
CREATE  PROCEDURE `getCategoriesBySupplier` (IN `input_supplierId` INT(10))
BEGIN
    SELECT category.categoryCode AS code, category.categoryName AS name, category.color, category.quantity
    FROM category
    JOIN relationprovide_provideinformation ON category.categoryCode = relationprovide_provideinformation.categoryCode
    WHERE relationprovide_provideinformation.r_supplierCode = input_supplierId;
END$$
############# Supplier ########################

################# CUSTOMER, ORDER ####################
-- Lấy số điện thoại khách hàng 
CREATE PROCEDURE `getCustomerPhone` (IN `input_customerCode` INT(10))  SELECT customer_phonenumber.phoneNumber
FROM customer, customer_phonenumber
WHERE customer.customerCode = input_customerCode AND customer.customerCode = customer_phonenumber.customerCode $$

# Add Loại hàng
-- CREATE  PROCEDURE `add_category` (IN `i_categoryName` VARCHAR(70), 
-- IN `i_categoryColor` VARCHAR(20), IN `i_supplierCode` INT(10), IN `i_purchasePrice` INT(6), IN `i_quantity` INT(10), IN `i_sellingPrice` INT(6))  BEGIN
--     DECLARE inserted_category_id INT(10);
--     INSERT INTO category (`categoryName`, `color`,`r_supplierCode`) VALUES(i_categoryName, i_categoryColor, i_supplierCode);
--     SELECT last_insert_id() INTO inserted_category_id;
--     INSERT INTO relationprovide_provideInformation (`categoryCode`, `purchasePrice`, `quantity`) VALUES (inserted_category_id, i_purchasePrice, i_quantity);
--     INSERT INTO category_sellingprice (`categoryCode`, `price`) VALUES (inserted_category_id, i_sellingPrice);
--   END$$

-- CREATE  PROCEDURE `add_order` (IN `i_customerCode` INT(10), IN `i_employeeCode` INT(10), IN `i_boltCode` INT(10))  BEGIN
--     DECLARE inserted_order_id INT(10);
--     INSERT INTO customer_order (`r_customerCode`) VALUES(i_customerCode);
--     SET inserted_order_id = (SELECT last_insert_id());
--     INSERT INTO relationprocess_processorder (`orderCode`, `employeeCode`) VALUES (inserted_order_id, i_employeeCode);
--     INSERT INTO relationcontain_containbolt ( `boltCode`, `orderCode`) VALUES ( i_boltCode, inserted_order_id);
--   END$$

# Lúc xuất ra danh sách order (Category)
CREATE  PROCEDURE `getOrderList` (IN `input_orderCode` INT(10))  SELECT category.categoryCode, category.categoryName, color, bolt.boltCode, length
FROM customer_order, relationcontain_containbolt, bolt, category
WHERE customer_order.orderCode = input_orderCode AND customer_order.orderCode = relationcontain_containbolt.orderCode 
AND relationcontain_containbolt.boltCode = bolt.boltCode AND bolt.categoryCode = category.categoryCode$$

# Xuất ra danh sách order của customer
CREATE PROCEDURE `getOrderByName` (IN `filterName` VARCHAR(256))  
SELECT orderCode, totalPrice, customerCode, CONCAT(customerLastName, " ", customerFirstName) as Name
FROM customer_order, customer 
WHERE customerCode = r_customerCode AND CONCAT(customerLastName, " ", customerFirstName) LIKE CONCAT("%", filterName, "%")$$


# Xuất ra danh sachs trong chi tiết order
CREATE PROCEDURE getOrderInfo (IN input_orderCode INT(10))
 SELECT input_orderCode as OrderID, customer.customerCode, employee.employeeCode,
 CONCAT(customerLastName, " ", customerFirstName) as customerName, customer.address as customerAddress, 
 CONCAT(employeeLastName, " ", employeeFirstName) as employeeName, employee.address as employeeAddress, employee_phonenumber.phoneNumber, 
 relationprocess_processorder.date, relationprocess_processorder.time, totalPrice , customer_order.orderstatus as orderStatus, customer_partialpayment.money as partialPayment,customer_partialpayment.`date` as datePay, customer_order.reasoncancel as reasonCancel, customer.arrearage as arrearage
FROM customer_order
JOIN customer ON customer.customerCode = customer_order.r_customerCode
JOIN relationprocess_processorder ON relationprocess_processorder.orderCode = customer_order.orderCode
JOIN employee ON employee.employeeCode = relationprocess_processorder.employeeCode
JOIN employee_phonenumber ON employee_phonenumber.employeeCode = relationprocess_processorder.employeeCode
LEFT JOIN customer_partialpayment ON customer_partialpayment.customerCode = customer.customerCode
LEFT JOIN customer_partialpayment AS CV ON CV.customerCode = customer_order.r_customerCode
WHERE customer_order.orderCode = input_orderCode$$


DELIMITER $$
############################################################### PROCEDURE##################################33


DELIMITER $$

############### Điều kiện ####################
#check nợ lớn hơn 2000 và sau sáu tháng

CREATE TRIGGER before_insert_relationprocess_processorder
BEFORE INSERT ON `relationprocess_processorder`
FOR EACH ROW
BEGIN
    DECLARE operational_staff TINYINT;
    SELECT `employee`.`FOperationalstaff` INTO operational_staff
    FROM `employee`
    WHERE `employeeCode` = NEW.`employeeCode`;
    IF operational_staff = 1 THEN
        SET NEW.`employeeCode` = NEW.`employeeCode`;
    ELSE
        SET NEW.`employeeCode` = null;
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `Payment_LOG`(
    IN payment_id INT,
    IN date_pay DATE,
    IN total_price INT(100),
    IN customer_code INT
)
BEGIN
    DECLARE total_amount_paid INT(100);
    DECLARE is_alert INT;
    DECLARE is_hard_debt INT;

    SELECT c.Arrearage - total_price
    INTO total_amount_paid
    FROM Customer c
    WHERE c.customerCode = customer_code;

    IF total_amount_paid > 2000 THEN
        SET is_alert = 1;
    ELSE
        SET is_alert = 0;
    END IF;

    IF total_amount_paid > 2000 AND (DATEDIFF(NOW(), date_pay)) > 180 THEN
        SET is_hard_debt = 1;
    ELSE
        SET is_hard_debt = 0;
    END IF;

    INSERT INTO PAYMENT_TABLE_LOG(PaymentID, TotalAmount, StatusReport, DatePay)
    VALUES (payment_id, total_price,
            CASE
                WHEN is_alert = 1 And is_hard_debt = 0  THEN 'Cảnh báo'
                WHEN is_hard_debt = 1 And is_alert = 1 THEN 'Nợ khó đòi'
                ELSE NULL
            END, date_pay);
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_insert_payment_history
AFTER INSERT ON payment_History
FOR EACH ROW
BEGIN
    CALL Payment_LOG(NEW.paymentCode, NEW.PaymentDate, NEW.totalprice, NEW.CustomerCode);
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER before_insert_relationprocess_supplier
BEFORE INSERT ON supplier
FOR EACH ROW
BEGIN
    DECLARE fpartnerstaff TINYINT;
    SELECT `employee`.`FPartnerstaff` INTO fpartnerstaff
    FROM employee
    WHERE employeeCode = NEW.`employeeCode`;
    IF fpartnerstaff = 1 THEN
        SET NEW.`employeeCode` = NEW.`employeeCode`;
    ELSE
        SET NEW.`employeeCode` = null;
    END IF;
END //
DELIMITER ;
 
DELIMITER //
CREATE TRIGGER update_order_status
AFTER INSERT ON customer_partialpayment
FOR EACH ROW
BEGIN
    DECLARE existing_total_price INT;
    -- Get the total price from customer_order
    SELECT totalPrice INTO existing_total_price
    FROM customer_order
    WHERE r_customerCode = NEW.customerCode AND orderstatus != 'cancelled'
    limit 1 
  ;
    -- Update order status based on conditions
    IF NEW.money = existing_total_price THEN
        UPDATE customer_order
        SET orderstatus = 'full paid'
        WHERE r_customerCode = NEW.customerCode AND totalPrice = NEW.money  AND orderstatus != 'cancelled';
    ELSEIF NEW.money < existing_total_price THEN
        UPDATE customer_order
        SET orderstatus = 'partial paid'
        WHERE r_customerCode = NEW.customerCode  AND orderstatus != 'cancelled';
    END IF;
END;
//
DELIMITER ;


# check nhân viên có phải là OfficeStaff không, không thì thằng customer null
ALTER TABLE `employee`
ADD CONSTRAINT chk_customerCode CHECK (
  (`FOfficestaff` = 1 AND `customerCode` IS NOT NULL) OR (`FOfficestaff` = 0 AND `customerCode` IS NULL)
);
# CHECK order cancelled
ALTER TABLE `customer_order` ADD
CONSTRAINT `check_reason_cancel` CHECK (
        (`orderstatus` = 'cancelled' AND `reasoncancel` IS NOT NULL) OR
        (`orderstatus` != 'cancelled' AND `reasoncancel` IS NULL)
    );

############################################### INSERT #####################################################


INSERT INTO `category` (`categoryCode`, `categoryName`, `color`, `quantity`) VALUES
(1, 'Sun Silk', 'hồng cánh sen', 6 ),
(2, 'Long Silk', ' xám', 5),
(3, 'Eric Silk', 'xanh lá cây', 4),
(4, 'Cotton', 'đỏ', 3),
(5, 'Cotton Trung Quốc', 'tím',1),
(6, ' Cotton Ai Cập', 'xanh', 3 ),
(7, 'Leather', 'vàng', 6),
(8, 'Leather Việt Name', 'hồng', 1),
(9, 'Leather Trung Quốc', 'xanh', 2),
(10, 'Silk Trung Quốc', 'trắng', 3),
(11, 'Leather Nhật Bản', 'trắng', 2),
(12, 'Leather Mỹ', 'đen', 1),
(13, 'Silk Nhật', 'đen', 4);

INSERT INTO `customer` (`customerCode`, `customerFirstName`, `customerLastName`, `address`, `arrearage`)
VALUES
 (1, 'Trần ', 'Gia Phú', 'Hồng Bàng, Quận 6', 1100),
 (2, 'Trường', 'Sơn', ' Nguyễn Trãi, Quận 5', 4000),
 (3, 'Vũ ', 'Bình Phước', 'Hòa Bình, Quận 6', 5000),
 (4, 'Nguyễn', 'Tân', ' Đường 3/2, Quận 10', 5000),
 (5, 'Phạm', 'Quân', 'Trần Não, Quận Gò Vấp', 6000);
 
 INSERT INTO `customer_order` (`orderCode`, `totalPrice`, `orderstatus`, `reasoncancel`, `r_customerCode`)
VALUES
(7, 27050, 'new', null, 1),
(8, 5490, 'ordered', null, 2),
(9, 11500, 'cancelled', 'không muốn mua nữa làm gì tao', 4),
(10, 23000, 'partial paid', null, 3),
(21, 48000, 'cancelled', 'tao hủy kệ tao', 1);



INSERT INTO `bolt` (`categoryCode`, `boltCode`, `length`) VALUES
(1, 1, 15),
(1, 2, 50),
(2, 3, 10),
(2, 4, 15),
(3, 5, 10),
(3, 6, 20),
(4, 7, 10),
(4, 8, 20),
(5, 9, 10),
(5, 10, 20),
(6, 11, 10),
(6, 12, 20);

INSERT INTO `relationcontain_containbolt` ( `boltCode`,`orderCode`) VALUES
(1,7),
(12,7),
(7,8),
(3,10),
(11,9),
(8,21),
(10,21),
(9,10),
(9,21);
INSERT INTO `employee` (`employeeCode`,`employeeFirstName`,`employeeLastName`,`genre`,
`address`,`customerCode`,`FManager`,`FOfficestaff`,`FOperationalstaff`,`FPartnerstaff`)
VALUES
(1,"Gia","Phú","M","312/12/2 Hồng Bàng",null,1,0,0,1),
(2,"Vũ","Hồng","F","21/12/2 đường số 4",2,1,1,1,1),
(3,"Hồng Hà","Nhi","B","21/1/2 Hậu Giang",5,0,1,1,1),
(4,"Doraemon","NO","M","21/2 Đặng Văn Bi",null,1,0,0,1);
INSERT INTO `category_sellingprice` (`categoryCode`, `price`, `date`) VALUES
(1, 146, '2023-12-01'),
(1, 193, '2023-12-02'),
(1, 219, '2023-12-05'),
(2, 220, '2023-12-01'),
(2, 330, '2023-12-31'),
(3, 293, '2023-12-01'),
(4, 250, '2023-12-01'),
(5, 300, '2023-12-01'),
(6, 350, '2023-12-01'),
(7, 400, '2023-12-01'),
(8, 450, '2023-12-01'),
(9, 500, '2023-12-01'),
(10, 605, '2023-12-02'),
(11, 600, '2023-12-02'),
(12, 650, '2023-12-02'),
(13, 800, '2023-12-11');

INSERT INTO `supplier` (`employeeCode`,`supplierCode`, `supplierName`, `address`, `bankAccount`, `taxCode`) VALUES
(1,1, 'Silk Supplier', '17 Đường số 2, Quận 7', '12335424131', '0203040506'),
(1,2, 'Cotton Supplier', '330A Bình THuận, Quận Gò Vấp', '22233422424', '0989009809'),
(2,3, 'Leather Supplier', '20/11/B Nha` Bè Quận 10', '0743684285147217', '21321312'),
(3,11, 'Rita Supplier', '17 Lô A, Mỹ Tho, Quận 10', '0000111122223333', '321312131'),
(4,15, 'Silk Supplier', '80/7/A Lạc Long Quân, Quận 10', '0986335711112222', '0134567823');

INSERT INTO `supplier_phonenumber` (`supplierCode`, `phoneNumber`) VALUES
(1, '0121517131'),
(1, '02212302302'),
(2, '0853546345'),
(11, '0922345678'),
(11, '0932345678'),
(11, '0151517479'),
(15, '0933567893');



INSERT INTO `relationprovide_provideinformation` (`r_supplierCode`, `categoryCode`, `purchasePrice`, `quantity`, `date`) VALUES
(1, 1, 100, 1, '2023-12-01'),
(1, 2, 140, 2, '2023-12-01'),
(1, 6, 290, 6, '2023-12-01'),
(2, 7, 340, 3, '2023-12-01'),
(3, 3, 220, 5, '2023-12-01'),
(3, 8, 390, 2, '2023-12-01'),
(11, 5, 240, 4, '2023-12-01'),
(11, 11, 700, 10, '2019-12-11'),
(15, 4, 200, 1, '2023-12-01');




INSERT INTO `customer_phonenumber` (`customerCode`, `phoneNumber`) VALUES
(1, '0933654562'),
(2, '0894562131'),
(2, '0893156156'),
(3, '0321564815'),
(4, '0231231651'),
(5, '0215648948');

INSERT INTO `customer_partialpayment` (`customerCode`, `date`, `money`) VALUES
(1, '2023-12-06', 200),
(1, '2023-12-06', 500),
(2, '2022-02-08', 490),
(3, '2023-11-08', 1000);




INSERT INTO `relationprocess_processorder` (`orderCode`, `employeeCode`,`time`,`date`)
VALUES
(7, null, CURRENT_TIME, CURRENT_DATE),
(8, 2, CURRENT_TIME, CURRENT_DATE),
(9, 3, CURRENT_TIME, CURRENT_DATE),
(10, 2, CURRENT_TIME, CURRENT_DATE),
(21,null, CURRENT_TIME, CURRENT_DATE);

INSERT INTO `employee_phonenumber`(`employeeCode`,`phoneNumber`)
VALUES
(1,01219151713),
(2,0909692013),
(3,0102010293),
(4,0102010113);
