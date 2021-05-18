/***********************************************************************************************/
/*         SET UP DATABASE                                                                     */
/***********************************************************************************************/

-- Set Context to Master
        USE MASTER;

-- If the InstructionalTechnologyServices database exists, delete it.  
        IF EXISTS (SELECT * FROM Master.dbo.sysdatabases WHERE NAME = 
        'InstructionalTechnologyServices')
        DROP DATABASE InstructionalTechnologyServices;

--Create the InstructionalTechnologyServices Database           
        CREATE DATABASE InstructionalTechnologyServices;
        GO                  
        USE InstructionalTechnologyServices;

/***********************************************************************************************/
/*         CREATE TABLES                                                                       */
/***********************************************************************************************/

------------------------------------------------------------------------------------------------
---- EMPLOYEES ---------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblEmployees (RedID, FirstName, LastName, SupervisorID, CallSign, EmploymentStatus, Team)
fk SupervisorID references tblEmployees

PURPOSE:
Lists each employee at ITS SDSU that will handle the tools and consumables.

NOTES:
Employment Status: Either "Employed" or "Unemployed".
*/

CREATE TABLE tblEmployees (
        RedID                   INT PRIMARY KEY,
        FirstName               VARCHAR(50),
        LastName                VARCHAR(50),
        SupervisorID            INT REFERENCES tblEmployees,
        CallSign                INT,
        EmploymentStatus        VARCHAR(50),
        Team                    VARCHAR(50)
);

------------------------------------------------------------------------------------------------
---- VENDORS -----------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblVendors (VendorID, VendorName, VendorPhone, VendorAddress)

PURPOSE:
Lists each vendor that ITS SDSU orders from.

NOTES: None
*/

CREATE TABLE tblVendors (
        VendorID        INT PRIMARY KEY,
        VendorName      VARCHAR(50),
        VendorPhone     VARCHAR(24),
        VendorAddress   VARCHAR(256),
);

------------------------------------------------------------------------------------------------
---- CONSUMABLE INVENTORY ----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblConsumableInventory (ConsumableID, ConsumableName, ConsumableDescription, 
ConsumableQuantity)

PURPOSE:
Lists the current inventory of each consumable item at ITS SDSU.
        
NOTES: None
*/

CREATE TABLE tblConsumableInventory (
        ConsumableID            INT PRIMARY KEY,
        ConsumableName          VARCHAR(50),  
        ConsumableDescription   VARCHAR(256),
        ConsumableQuantity      INT
);

------------------------------------------------------------------------------------------------
---- CONSUMBALE LOGS ---------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblConsumableLogs (RedID, ConsumableID,TakenDateTime, NumTaken, NumReturned)
                fk RedID references tblEmployees
                fk ConsumableID references tblConsumableInventory
                Not null NumTaken

PURPOSE:
        Lists the logs of consumable items that are checked out and returned.

NOTES:
Any number can be checked out and returned. Zero returned is valid.
Must come after Employees and ConsumableInventory.
*/

CREATE TABLE tblConsumableLogs (
        RedID           INT FOREIGN KEY REFERENCES tblEmployees(RedID),
        ConsumableID    INT FOREIGN KEY REFERENCES tblConsumableInventory(ConsumableID),
        TakenDateTime   DATETIME,
        NumTaken        INT NOT NULL,
        NumReturned     INT,
        CONSTRAINT ConsumableLogsPK PRIMARY KEY (RedID, ConsumableID)
);

------------------------------------------------------------------------------------------------
---- TOOLS -------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblTools (ToolID, ToolName, ToolDescription, VendorID)
                fk VendorID references tblVendors
                Not null VendorID


PURPOSE:
        Lists each tool at ITS SDSU.


NOTES: None
*/

CREATE TABLE tblTools (
        ToolID          INT  PRIMARY KEY,
        ToolName        VARCHAR(128),  
        ToolDescription VARCHAR(256),
        VendorID        INT NOT NULL FOREIGN KEY REFERENCES tblVendors(VendorID)
);

------------------------------------------------------------------------------------------------
---- SHIPPING MANIFESTS ------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblShippingManifest (ManifestID, OrderNumber, ShippingDate, VendorID)
        fk VendorID references Vendors
        Not null VendorID

PURPOSE:
        Lists each shipping manifest from a vendor.

NOTES: None
*/

CREATE TABLE tblShippingManifest (       
        ManifestID      INT PRIMARY KEY, 
        OrderNumber     VARCHAR(50),
        ShippingDate    DATE,
        VendorID        INT NOT NULL REFERENCES tblVendors
);

------------------------------------------------------------------------------------------------
---- MANIFEST ITEMS ----------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblManifestItems (ConsumableID, VendorID, ItemDescription, ManifestQuantity, ManifestID)
        fk ConsumableID references tblConsumableInventory
        fk VendorID references tblVendors
        fk ManifestID references tblShippingManifest
        Not null ManifestID

PURPOSE:
Lists the consumable items that are received and listed from each shipping manifest.

NOTES:
Must come after ConsumableInventory, Vendors, and ShippingManifest.
*/

CREATE TABLE tblManifestItems (
        ConsumableID            INT FOREIGN KEY REFERENCES tblConsumableInventory(ConsumableID),
        VendorID                INT FOREIGN KEY REFERENCES tblVendors(VendorID),
        ItemDescription         VARCHAR (250),
        ManifestQuantity        INT,
        ManifestID              INT NOT NULL FOREIGN KEY REFERENCES tblShippingManifest(ManifestID),
        CONSTRAINT ManifestItemsPK PRIMARY KEY (ConsumableID, VendorID)
);

------------------------------------------------------------------------------------------------
---- TOOL LOGS ---------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* SCHEMA:
tblToolLogs (RedID, ToolID, CheckOutDateTime, CheckInDateTime, ServiceTicketID)
        fk RedID references tblEmployees
        fk ToolID references tblTools

PURPOSE:
        Lists the logs of tools that are checked out and returned.

NOTES:
        Must come after Tools and Employees.
*/

CREATE TABLE tblToolLogs (
        RedID                   INT FOREIGN KEY REFERENCES tblEmployees, 
        ToolID                  INT FOREIGN KEY REFERENCES tblTools,
        CheckOutDateTime        DATETIME,
        CheckInDateTime         DATETIME,
        ServiceTicketID         INT,
        CONSTRAINT tbkToolLogsPK PRIMARY KEY (RedID, ToolID, CheckOutDateTime)
);

/***********************************************************************************************/
/*         FILL TABLES                                                                         */
/***********************************************************************************************/

------------------------------------------------------------------------------------------------
---- VENDORS -----------------------------------------------------------------------------------
---- (VendorID, VendorName, PhoneNumber, Address) ----------------------------------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblVendors VALUES
    (001, 'Grainger', '1-800-GRAINGER', '8001 Raytheon Road, San Diego, CA 92111'),
    (002, 'Extron', '1-714-491-1500', '1025 East Ball Road, Anaheim, CA 92805'),
    (003, 'Milwaukee', '1-800-SAWDUST', '13135 West Lisbon Road, Brookfield, WI 53005-2550'),
    (004, 'B&H Photo', '1-212-239-7503:7745', '420 9th Avenue, New York, NY 10001'),
    (005, 'Adorama Camera', '1-212-741-0063', '42 West 18th Street, New York, NY 10011'),
    (006, 'Matterport', '1-888-993-8990', '352 East Java Drive, Sunnyvale, CA 94089'),
    (007,'Fastenal','1-800-Fastenal','1120 Bay Blvd, Chula Vista, CA 91911');

-- Check tblVendors
SELECT * FROM tblVendors;

------------------------------------------------------------------------------------------------
---- TOOLS -------------------------------------------------------------------------------------
---- (ToolID, ToolName, ToolDescription, VendorID) ---------------------------------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblTools VALUES
    (501, 'Drill', 'Cordless Red Craftsman', 001),
    (502, 'Drill', 'Cordless Red Craftsman', 001),
    (503, 'Drill','Cordless Red Craftsman',001),
    (504,'Drill','Cordless Red Craftsman',001),
    (505, 'Drill','Yellow DeWalt',002),
    (506,'Drill','Yellow DeWalt',002),
    (507,'Drill','Yellow DeWalt',002),
    (508,'Hammer','Wood handle Claw', 002),
    (509,'Hammer','Orange Handle Claw',003),
    (510,'Hammer','Black Handle Claw',003),
    (511, 'Hammer', 'Black Handle Ball Pein',003),
    (512, 'Hammer' , 'Black Handle Ball Pein' , 003),
    (513, 'Hammer' , 'Wood Handle Ball Pein' , 003),
    (514, 'Wrench','Adjustable', 003),
    (515, 'Wrench','Adjustable',004),
    (516,'Wrench','1/4',004),
    (517,'Wrench','5/8',004),
    (518,'Screwdriver','Phillips Black Handle',004),
    (519,'Screwdriver','Slotted Black Handle',005),
    (520,'Screwdriver','Phillips Red Handle',005),
    (521,'Screwdriver','Slotted Red Handle',005);

-- Check tblTools
SELECT * FROM tblTools;

------------------------------------------------------------------------------------------------
---- EMPLOYEES ---------------------------------------------------------------------------------
---- (RedID, FirstName, LastName, SupervisorID, CallSign, EmploymentStatus, Team) --------------
------------------------------------------------------------------------------------------------

INSERT INTO tblEmployees VALUES
    -- Professor Briggs
    (000000035, 'Robert', 'Briggs', NULL, 31, 'Employed', NULL),
    -- Team Sun-Tzu
    (000000006, 'Nick', 'Weikel', 000000035, 6, 'Employed', 'Sun Tzu'),
    (000000005, 'Michael', 'Tobin', 000000006, 5, 'Employed', 'Sun Tzu'),
    (000000001, 'Elizabeth', 'Fabio', 000000005, 1, 'Employed', 'Sun Tzu'),
    (000000002, 'Thai', 'Nguyen', 000000005, 2, 'Employed', 'Sun Tzu'),
    (000000003, 'Amy', 'Petris', 000000005, 3, 'Employed', 'Sun Tzu'),
    (000000004, 'Harmit', 'Chima', 000000005, 4, 'Employed', 'Sun Tzu'),
    -- Team Da-Vinci
    (000000007, 'Alexander', 'Nestler', 000000007, NULL, 'Unemployed', 'Da Vinci'),
    (000000008, 'Tanner', 'Franklin', 000000035, 8, 'Employed', 'Da Vinci'),
    (000000009, 'Danny', 'Garica', 000000007, 9, 'Unemployed', 'Da Vinci'),
    (000000010, 'Yihua', 'Gan', 000000007, 10, 'Employed', 'Da Vinci'),
    (000000011, 'Chris', 'Pappas', 000000007, 11, 'Employed', 'Da Vinci'),
    (000000012, 'Yiwen', 'Mo', 000000007, 7, 'Employed', 'Da Vinci'),
    -- Team Einstein
    (000000013, 'Emily', 'Lam', 000000017, NULL, 'Unemployed', 'Einstein'),
    (000000014, 'Rahul', 'Ambati', 000000017, 12, 'Employed', 'Einstein'),
    (000000015, 'Melissa', 'Yakuta', 000000017, 13, 'Employed', 'Einstein'),
    (000000016, 'Will', 'McGrath', 000000017, 14, 'Employed', 'Einstein'),
    (000000017, 'Eric', 'Walters', 000000035, 15, 'Employed', 'Einstein'),
    (000000018, 'Jue', 'Li', 000000017, 16, 'Employed', 'Einstein'),
    -- Team Galileo
    (000000019, 'Kelvin', 'Murillo', 000000035, NULL, 'Unemployed', 'Galileo'),
    (000000020, 'Michael', 'Yglesias', 000000019, 17, 'Employed', 'Galileo'),
    (000000021, 'Shad', 'Fernandez', 000000019, 18, 'Employed', 'Galileo'),
    (000000022, 'Louis', 'Calderon', 000000019, 19, 'Employed', 'Galileo'),
    (000000023, 'Jakob', 'Roulier', 000000019, NULL, 'Unemployed', 'Galileo'),
    (000000024, 'Rome', 'Lucero', 000000019, 20, 'Employed', 'Galileo'),
    -- Team Plato
    (000000025, 'Tatiana', 'Chavez', 000000029, 21, 'Employed', 'Plato'),
    (000000026, 'Mu-Ting', 'Huang', 000000029, 22, 'Employed', 'Plato'), 
    (000000027, 'Jordan', 'Cook', 000000029, 23, 'Employed', 'Plato'),
    (000000028, 'Marcos', 'Gonzalez', 000000029, 24, 'Employed', 'Plato'),
    (000000029, 'Gabe', 'Longbrake', 000000035, 25, 'Employed', 'Plato'),
    -- Team Voltaire
    (000000030, 'Cullen', 'Muir', 000000031, 26, 'Employed', 'Voltaire'),
    (000000031, 'Andrew', 'Forsythe', 000000035, 27, 'Employed', 'Voltaire'),
    (000000032, 'Timothy', 'Levandowski', 000000031, 28, 'Employed', 'Voltaire'),
    (000000033, 'Huong', 'Pham', 000000031, 29, 'Employed', 'Voltaire'),
    (000000034, 'Mohammad', 'Yousaf', 000000031, 30, 'Employed', 'Voltaire');

-- Check tblEmployees
SELECT * FROM tblEmployees;

------------------------------------------------------------------------------------------------
---- TOOL LOGS ---------------------------------------------------------------------------------
---- (RedID, ToolID, CheckOutDateTime, CheckInDateTime, ServiceTicketID) -----------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblToolLogs VALUES
    (25, 508, '2021-03-08 18:51', '2021-03-09 14:51', 1),
    (30, 517, '2021-03-09 16:09', '2021-03-11 08:26', 2),
    (32, 515, '2021-03-11 07:07', '2021-03-11 16:43', 3),
    (25, 511, '2021-03-11 19:24', '2021-03-17 09:07', 4),
    (9, 507, '2021-03-13 06:47', '2021-03-13 18:01', 5),
    (13, 518, '2021-03-13 12:35', '2021-03-14 21:35', 6),
    (27, 507, '2021-03-13 22:17', '2021-03-14 22:17', 7),
    (11, 505, '2021-03-14 00:08', '2021-03-14 18:44', 8),
    (29, 518, '2021-03-15 05:10', '2021-03-17 08:10', 9),
    (32, 504, '2021-03-15 12:29', '2021-03-16 20:29', 10),
    (10, 518, '2021-03-18 03:21', '2021-03-18 11:10', 11),
    (5, 502, '2021-03-19 16:38', '2021-03-21 14:27', 12),
    (19, 513, '2021-03-20 23:39', '2021-03-22 12:07', 13),
    (18, 514, '2021-03-21 13:12', '2021-03-22 00:16', 14),
    (26, 517, '2021-03-21 17:09', '2021-03-22 11:56', 15),
    (35, 507, '2021-03-22 17:56', '2021-03-24 14:20', 16),
    (17, 503, '2021-03-22 21:03', '2021-03-24 06:50', 17),
    (21, 516, '2021-03-23 01:29', '2021-03-25 01:29', 18),
    (16, 517, '2021-03-25 19:57', '2021-03-27 19:57', 19),
    (7, 520, '2021-03-26 09:33', '2021-03-26 19:50', 20),
    (24, 520, '2021-03-27 11:48', '2021-03-28 10:40', 21),
    (26, 520, '2021-03-29 03:32', '2021-03-29 16:32', 22),
    (20, 504, '2021-03-31 03:25', '2021-04-01 13:25', 23),
    (27, 512, '2021-04-01 02:16', '2021-04-01 18:26', 24),
    (18, 511, '2021-04-05 05:03', '2021-04-06 01:48', 25),
    (6, 515, '2021-04-06 08:58', '2021-04-10 04:38', 26),
    (34, 514, '2021-04-06 16:22', '2021-04-08 00:22', 27),
    (12, 509, '2021-04-06 18:53', '2021-04-07 18:53', 28),
    (1, 519, '2021-04-06 20:19', '2021-04-08 03:10', 29),
    (9, 516, '2021-04-08 05:53', '2021-04-10 21:03', 30),
    (2, 518, '2021-04-08 19:10', '2021-04-14 05:50', 31),
    (24, 502, '2021-04-08 22:00', '2021-04-09 14:00', 32),
    (19, 513, '2021-04-09 22:17', '2021-04-11 22:17', 33),
    (7, 517, '2021-04-11 11:53', '2021-04-11 20:43', 34),
    (21, 505, '2021-04-13 12:32', '2021-04-14 03:37', 35),
    (8, 508, '2021-04-13 22:00', '2021-04-17 10:00', 36),
    (21, 516, '2021-04-14 21:05', NULL, 37),
    (28, 502, '2021-04-17 21:18', NULL, 38),
    (28, 504, '2021-04-20 21:18', '2021-04-24 00:30', 39),
    (19, 518, '2021-04-21 03:39', NULL, 40),
    (34, 520, '2021-04-21 08:43', '2021-04-22 16:43', 41),
    (31, 507, '2021-04-21 15:24', '2021-04-22 21:48', 42),
    (35, 520, '2021-04-23 20:46', NULL, 43),
    (18, 505, '2021-04-24 05:42', NULL, 44),
    (27, 507, '2021-04-26 14:11', NULL, 45),
    (26, 504, '2021-04-26 16:50', NULL, 46),
    (12, 513, '2021-04-26 19:06', NULL, 47),
    (11, 512, '2021-04-28 13:08', NULL, 48),
    (29, 517, '2021-04-22 09:22', NULL, 49),
    (9, 508, '2021-04-29 13:35', NULL, 50);

-- Check tblToolLogs
SELECT * FROM tblToolLogs;

------------------------------------------------------------------------------------------------
---- SHIPPING MANIFESTS ------------------------------------------------------------------------
---- (ManifestID, OrderNumber, ShippingDate, VendorID) -----------------------------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblShippingManifest VALUES
    (1,'E23645','2020-11-25',2), --Ordered (2) Yellow DeWalt
    (2,'M2451','2020-11-30',3), --Ordered (1) Black Handle Claw Hammer, (2) Black Handle Ball Pein Hammer, (1) Wood Handle Ball Pein Hammer, (1) Adjustable Wrench
    (3,'G9891','2020-12-02',1), --Ordered (2) Cordless Red Craftsman Drill
    (4,'AC782124','2020-12-12',5), --Ordered (1) Slotted Black Handle Screwdriver, (1) Phillips Red Handle Screwdriver, (1) Slotted Red Handle Screwdriver
    (5,'BH105','2020-12-25',4), --Ordered (1) Adjustable Wrench, (1) 1/4 in Wrench, (1) 1/8 in Wrench
    (6,'G9921','2020-12-29',1), --Ordered (2) Cordless Red Craftsman Drill
    (7,'E23703','2021-01-05',2), --Ordered (1) Yellow DeWalt, (1) Wood Handle Claw
    (8,'M2523','2021-01-07',3), --Ordered (1) Orange Handle Claw Hammer
    (9,'BH183','2021-01-10',4), --Ordered (1) Phillips Black Handle Screwdriver
    (10,'G9925' ,'2021-01-15' ,1), --Ordered (2) PaperTowels and (2) Bleach
    (11,'MP254','2021-01-18' ,6), --Ordered (100) Shop Towels
    (12,'BH205','2021-01-24' ,4), --Ordered (75) AA Batteries and (50) AAA Batteries
    (13,'E24756','2021-01-27',2), --Ordered (300) Glue Sticks
    (14,'G10014' ,'2021-02-15' ,1), --Ordered (20) Hand Sanitizer
    (15,'BH315' ,'2021-03-01' ,4); --Ordered (10) Electronic Wipes

-- Check tblShippingManifest
SELECT * FROM tblShippingManifest;

------------------------------------------------------------------------------------------------
---- CONSUMABLE INVENTORY ----------------------------------------------------------------------
---- (ConsumableID, ConsumableName, ConsumableDescription, ConsumableQuantity) -----------------
------------------------------------------------------------------------------------------------

INSERT INTO tblConsumableInventory VALUES
    (201, 'Paper Towels', 'Brawny, single rolls', 4),
    (202, 'Sponge', 'Non-Scratch Scrub Sponge', 10),
    (203, 'Tissue','Kleenex, square box',5),
    (204,'Velcro','Rolls, each roll is 5 ft',6),
    (205, 'Electronic Wipes','Wipes checked out for IT',32),
    (206,'Disinfecting Wipes','For surfaces',22),
    (207,'Shop Towels','Reusable',210),
    (208,'Hand Sanitizer','Large bottles for classrooms',29),
    (209,'Goo Gone','Used for residue clean up',4),
    (210,'Spray Paint','Color:Black',8),
    (211, 'AA Batteries', 'Packs of 20',105),
    (212, 'AAA Batteries' , 'Pack of 50' , 56),
    (213, 'Blue Pens' , 'Single pens, Fine tip' , 92),
    (214, 'Paper','paper ream (500 sheets)', 65),
    (215, 'Soap','500 ml bottles',14),
    (216,'Printer ink','Single cartridges',66),
    (217,'Light bulbs','A60 bulb, Color:White',22),
    (218,'Staples','complete boxes',59),
    (219,'Bleach','500 ml bottles',156),
    (220,'Computer disks','Single, Non-reusable',97),
    (221,'Glue sticks','Single, Elmer''s',333);

-- Check tblConsumableInventory
SELECT * FROM tblConsumableInventory;

------------------------------------------------------------------------------------------------
---- MANIFEST ITEMS ----------------------------------------------------------------------------
---- (ConsumableID, VendorID, ItemDescription, ManifestQuantity, ManifestID) -------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblManifestItems VALUES
    (201, 001, 'Paper Towels', 2, 10),
    (219, 001, 'Bleach', 2, 10),
    (207, 006, 'Shop Towels', 100, 11),
    (211, 004, 'AA Batteries', 75, 12),
    (212, 004, 'AAA Batteries', 50, 12),
    (221, 002, 'Glue sticks', 300, 13),
    (208, 001, 'Hand Sanitizer', 20, 14),
    (205, 004, 'Electronic Wipes', 10, 15);

-- Check tblManifestItems
SELECT * FROM tblManifestItems;

------------------------------------------------------------------------------------------------
---- CONSUMBALE LOGS ---------------------------------------------------------------------------
---- (RedID,ConsumableID,TakenDateTime,NumTaken,NumReturned) -----------------------------------
------------------------------------------------------------------------------------------------

INSERT INTO tblConsumableLogs VALUES
    (000000006, 220, '2020-01-08 18:00', 15, 2),
    (000000001, 203, '2020-01-09 09:51', 1, NULL),
    (000000007, 207, '2020-01-09 10:15', 10, 5),
    (000000023, 210, '2020-01-09 12:30', 1, 1),
    (000000005, 219, '2020-01-12 13:00', 2, NULL),
    (000000025, 212, '2020-01-13 18:51', 1, NULL),
    (000000024, 221, '2020-01-20 18:51', 15, 10),
    (000000031, 220, '2020-02-10 18:51', 5, NULL),
    (000000034, 218, '2020-02-10 18:51', 1, NULL),
    (000000032, 209, '2020-02-11 18:51', 1, 1),
    (000000029, 213, '2020-02-11 18:51', 20, 1),
    (000000031, 208, '2020-02-11 18:51', 2, NULL),
    (000000005, 211, '2020-02-20 18:51', 1, NULL),
    (000000001, 212, '2020-02-20 18:51', 1, 1),
    (000000019, 204, '2020-02-20 18:51', 1, 1),
    (000000004, 207, '2020-02-20 18:51', 2, NULL),
    (000000026, 213, '2020-04-10 18:51', 2, NULL),
    (000000035, 210, '2020-04-10 18:51', 1, NULL),
    (000000002, 219, '2020-04-10 18:51', 1, 1),
    (000000010, 216, '2020-05-14 18:51', 2, NULL),
    (000000022, 205, '2020-06-05 18:51', 2, 1),
    (000000019, 203, '2020-06-06 18:51', 2, NULL),
    (000000003, 215, '2020-06-07 18:51', 2, NULL),
    (000000004, 217, '2020-08-05 18:51', 5, NULL),
    (000000014, 207, '2020-08-05 18:51', 1, 1),
    (000000002, 214, '2020-08-25 18:51', 5, NULL),
    (000000018, 219, '2020-08-25 18:51', 1, 1);

-- Check tblConsumableLogs
SELECT * FROM tblConsumableLogs;

/***********************************************************************************************/
/*         Create Indexes                                                                      */
/***********************************************************************************************/
/* INSTRUCTIONS:
    - Three (3) Indexes related to improve the performance of specific queries 
    - Must not index any primary keys; they are already indexed automatically by the system. 
*/

/* NAME: ndx_tblEmployees_FirstName
   COLUMN: FirstName
   PURPOSE: To speed up queries regarding the first name of the employee. It will be faster to query 
            who checked out a particular tool or consumable.
*/
CREATE INDEX ndx_tblEmployees_FirstName ON tblEmployees(FirstName);

/* NAME: ndx_tblEmployees_LastName
   COLUMN: LastName
   PURPOSE: To speed up queries regarding the last name of the employee. It will be faster to query 
            who checked out a particular tool or consumable.
*/
CREATE INDEX ndx_tblEmployees_LastName ON tblEmployees(LastName);

/* NAME: ndx_tblTools_ToolName
   COLUMN: ToolName
   PURPOSE: To speed up queries regarding tool names. It will be faster to query which tool was 
            checked out or is available.
*/
CREATE INDEX ndx_tblTools_ToolName ON tblTools(ToolName);

/* NAME: ndx_tblVendors_VendorName
   COLUMN: VendorName
   PURPOSE: To speed up queries regarding vendor names. It will be faster to query which tool or 
            consumable was ordered from a particular vendor.
*/
CREATE INDEX ndx_tblVendors_VendorName ON tblVendors(VendorName);

/* NAME: ndx_tblConsumableInventory_ConsumableName
   COLUMN: ConsumableName
   PURPOSE: To speed up queries regarding the names of consumable items. It will be faster to query 
            which consumable was used.
*/
CREATE INDEX ndx_tblConsumableInventory_ConsumableName ON tblConsumableInventory(ConsumableName);

/***********************************************************************************************/
/*         Queries                                                                             */
/***********************************************************************************************/
/* INSTRUCTIONS:
    - 10 Retrieval Queries (1-2 for each table)
    - At least 2 need to be subqueries (e.g. nested queries)
    NOTE:
    - Variables intended to be replaced are flanked by ‘$’ and include their type, such as $Variablename_Type$
    - Variables not flanked by ‘$’ should be left as they are
*/

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 1: Which employees have checked out a 5/8 wrench and when did they check it in?
    SHOW: FirstName, LastName, CheckOutDateTime, CheckInDateTime
    ORGANIZE: CheckOutDateTime descending, showing the the most recent check out time first.
    BUSINESS REQUIREMENT: BR(d) and BR(e)
------------------------------------------------------------------------------------------------ */

SELECT FirstName, LastName, CheckOutDateTime, CheckInDateTime
FROM tblToolLogs tl
JOIN tblTools t
    ON tl.ToolID = t.ToolID
JOIN tblEmployees e
    ON e.RedID = tl.RedID
WHERE t.ToolName = 'Wrench' AND t.ToolDescription = '5/8'
ORDER BY CheckOutDateTime DESC;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 2: Who is the supervisor of the employees that have checked out a 5/8 wrench?
    SHOW: FirstName, LastName, Supervisor First Name, Supervisor Last Name
    ORGANIZE: N/A
    BUSINESS REQUIREMENT: BR(d) and BR(e)
------------------------------------------------------------------------------------------------ */

SELECT e.FirstName, e.LastName,
(SELECT s.FirstName FROM tblEmployees s WHERE s.RedID = e.SupervisorID) [SupervisorFirstName],
(SELECT s.LastName FROM tblEmployees s WHERE s.RedID = e.SupervisorID) [SupervisorLastName]
FROM tblEmployees e
JOIN tblToolLogs tl
    ON tl.RedID = e.RedID
JOIN tblTools t
    ON t.ToolID = tl.ToolID
WHERE t.ToolName = 'Wrench' AND t.ToolDescription = '5/8';

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 3: What tools are ordered from Milwaukee?
    SHOW: ToolName, ToolDescription
    ORGANIZE: ToolName ascending and ToolDescription ascending
    BUSINESS REQUIREMENT: BR(a)
------------------------------------------------------------------------------------------------ */

SELECT ToolName, ToolDescription
FROM tblTools t
JOIN tblVendors v
    ON v.VendorID = t.VendorID
WHERE v.VendorName = 'Milwaukee'
ORDER BY ToolName, ToolDescription;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 4: What vendor supplied order mumber E23645?
    SHOW: VendorName
    ORGANIZE: N/A
    BUSINESS REQUIREMENT: BR(c)
------------------------------------------------------------------------------------------------ */

SELECT VendorName
FROM tblVendors v
JOIN tblShippingManifest sm
    ON sm.VendorID = v.VendorID
WHERE sm.OrderNumber = 'E23645';

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 5: What items were received from order number E24756?
    SHOW: ConsumableID, ConsumableName, ManifestQuantity
    ORGANIZE: ConsumableName ascending
    BUSINESS REQUIREMENT: BR(c)
------------------------------------------------------------------------------------------------ */

SELECT mi.ConsumableID, ci.ConsumableName, mi.ManifestQuantity
FROM tblConsumableInventory ci
JOIN tblManifestItems mi
    ON mi.ConsumableID = ci.ConsumableID
JOIN tblShippingManifest sm
    ON sm.ManifestID = mi.ManifestID
WHERE OrderNumber = 'E24756'
ORDER BY ConsumableName;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 6: Are there any vendors we haven't ordered from in a year? 
    SHOW: VendorName, YearsSinceLastOrder
    ORGANIZE: YearsSinceLastOrder, DESC
    BUSINESS REQUIREMENT: BR(b)
------------------------------------------------------------------------------------------------ */

SELECT VendorName, DATEDIFF(YEAR, MAX (ShippingDate), GETDATE()) AS YearsSinceLastOrder
FROM tblShippingManifest  sm
JOIN tblVendors v 
    ON v.VendorID = sm.VendorID
GROUP BY VendorName, ShippingDate
HAVING DATEDIFF(YEAR, MAX (ShippingDate), GETDATE()) >= 1
ORDER BY YearsSinceLastOrder DESC;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 7: Are there any vendors we haven't ordered from yet?
    SHOW: VendorName, NumberofOrders
    ORGANIZE: N/A
    BUSINESS REQUIREMENT: BR(b)
------------------------------------------------------------------------------------------------ */

SELECT v.VendorName, COUNT(sm.ManifestID) AS NumberofOrders
FROM tblShippingManifest  sm
FULL JOIN tblVendors v 
    ON v.VendorID = sm.VendorID
WHERE ManifestID IS NULL
GROUP BY VendorName;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 8: Who did we order from the most? When determining this we can request a 
        discount when bulk ordering.
    SHOW: VendorName, NumberofOrders
    ORGANIZE: NumberofOrders descending
    BUSINESS REQUIREMENT: BR(b)
------------------------------------------------------------------------------------------------ */

SELECT VendorName, COUNT(ManifestID) AS NumberofOrders
FROM tblShippingManifest  sm
JOIN tblVendors v 
    ON v.VendorID = sm.VendorID
GROUP BY VendorName
ORDER BY NumberofOrders DESC;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 9: What consumable items are less than 10 in quantity?
    SHOW: ConsumableName, ConsumableQuantity
    ORGANIZE: N/A
    BUSINESS REQUIREMENT: BR(d) and BR(e)
------------------------------------------------------------------------------------------------ */

SELECT ConsumableName, ConsumableQuantity
FROM tblConsumableInventory 
WHERE ConsumableQuantity < 10;

/* -----------------------------------------------------------------------------------------------
    BUSINESS QUESTION 10: What consumables are ordered from Grainger?
    SHOW: ConsumableName, ConsumableDescription
    ORGANIZE: ConsumableName ascending
    BUSINESS REQUIREMENT: BR(a)
------------------------------------------------------------------------------------------------ */

SELECT ConsumableName, ConsumableDescription
FROM tblConsumableInventory ci
JOIN tblManifestItems mi
    ON mi.ConsumableID = ci.ConsumableID
JOIN tblVendors v
    ON v.VendorID = mi.VendorID
WHERE v.VendorName = 'Grainger'
ORDER BY ConsumableName;

/* ------------------------------------------------------------------------------------------------
    BUSINESS QUESTION 11: What are the most used tools?
    SHOW: ToolID, ToolName, ToolDescription
    ORGANIZE: N/A
    BUSINESS REQUIREMENT: BR(d) and BR(e)
------------------------------------------------------------------------------------------------ */

SELECT DISTINCT t.ToolID, t.ToolName, t.ToolDescription
FROM tblToolLogs tl
LEFT JOIN tblTools t
    ON t.ToolID = tl.ToolID
WHERE t.ToolID IN (
	SELECT ToolID
	FROM (
		SELECT TOP 25 PERCENT COUNT(tl2.CheckOutDateTime) AS NumOfCheckouts, tl2.ToolID
		FROM tblToolLogs tl2
		GROUP BY tl2.ToolID
		) [TopTools]
);

/***********************************************************************************************/
/*         UPDATE TABLES                                                                       */
/***********************************************************************************************/
-- Needed for updating rows easily.
-- Add information explaining this section & add to the query dictionary.
-- Add comment block regarding adding information.
-- Variables intended to be replaced are flanked by ‘$’, such as $Variablename_Type$
-- Variables not flanked by ‘$’ should be left as is


------------------------------------------------------------------------------------------------
---- PART 1: CONSUMABLES -----------------------------------------------------------------------
------------------------------------------------------------------------------------------------
---- Checkout a consumable ----
-- To input a new consumable checkout log, replace the template values below with the appropriate data
-- NumReturned should remain NULL at checkout
-- Automatically updates the inventory quantity for the consumable checked out
INSERT INTO tblConsumableLogs VALUES
($RedID_INT$, $ConsumableID_INT$, GETDATE() , $NumTaken_INT$, NULL)
UPDATE tblConsumableInventory 
SET ConsumableQuantity = ConsumableQuantity - tblConsumableLogs.NumTaken
FROM tblConsumableInventory
JOIN tblConsumableLogs
    ON tblConsumableLogs.ConsumableID = tblConsumableInventory.ConsumableID;


---- Return a consumable ---- 
-- To input a returned consumable, replace the template values below with the appropriate data
-- Automatically updates the inventory quantity for the consumable checked out
UPDATE tblConsumableLogs
SET NumReturned = $NumReturned_INT$
WHERE RedID = $RedID_INT$ AND ConsumableID = $Consumable_ID$
UPDATE tblConsumableInventory 
SET ConsumableQuantity = ConsumableQuantity + tblConsumableLogs.NumReturned
FROM tblConsumableInventory
JOIN tblConsumableLogs
    ON tblConsumableLogs.ConsumableID = tblConsumableInventory.ConsumableID;


---- New consumable ----
-- To insert a new consumable (NOT more of an existing consumable), replace the template values below with the appropriate data
INSERT INTO tblConsumableInventory VALUES
($ConsumableID_INT$, $ConsumableName_VARCHAR$, $ConsumableDescription_VARCHAR$, $ConsumableQuantity_INT$)



------------------------------------------------------------------------------------------------
---- PART2: TOOLS ------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
---- Check out a tool ----
-- To input a new tool checkout log, replace the template values below with the appropriate data
-- Leave the GETDATE() and NULL values as they are
INSERT INTO tblToolLogs VALUES
($RedID_INT$, $ToolID_INT$, GETDATE() , NULL, $ServiceTicketID_INT$)


---- Return a tool ----
-- To return a tool, replace the template values below with the appropriate data
UPDATE tblToolLogs
SET CheckinDateTime = GETDATE()
WHERE RedID = $RedID_INT$ 
    AND ToolID = $ToolID_INT$
    AND ServiceTicketID = $ServiceTicketID_INT$


---- Add a new tool ----
-- Add a new tool, this includes additional tools of existing type
-- Duplicate tools should have different Tool ID’s
INSERT INTO tblTools VALUES
($ToolID_INT$, $ToolName_VARCHAR$, $ToolDescr_VARCHAR$, $VendorID_INT$)



------------------------------------------------------------------------------------------------
---- PART3: EMPLOYEES --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
---- New employee ----
-- To input a new employee, replace the template values with the appropriate information for the employee
-- Employment Status is either "Employed" or "Unemployed"
INSERT INTO tblEmployees VALUES
($RedID_INT$, $FirstName_VARCHAR$, $LastName_VARCHAR$, $SupervisorID_INT$, $CallSign_INT$, $EmploymentStatus_VARCHAR$, $Team_VARCHAR$)


---- Change employment status ----
-- Employment Status is either "Employed" or "Unemployed"
UPDATE tblEmployees
SET EmploymentStatus = $Status$
WHERE RedID = $ID_NUM$



------------------------------------------------------------------------------------------------
---- PART 4: MANIFEST --------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
---- New Shipping Manifest ----
-- To input a new shipping manifest, replace the template values with the appropriate information 
-- Manifest ID in both lines must match.
INSERT INTO tblShippingManifest VALUES
($ManifestID_INT$, $OrderNumber_VARCHAR$, $ShippingDate_DATE$, $VendorID_INT$)
INSERT INTO tblManifestItems VALUES
($ConsumableID_INT$, $VendorID_INT$, $ItemDescription_VARCHAR$, $ManifestQuantity_INT$, $ManifestID_INT$)



------------------------------------------------------------------------------------------------
---- PART 5: VENDORS ---------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
---- New Vendor ----
-- To add a new vendor, replace the template values with the appropriate information for the vendor
INSERT INTO tblVendors VALUES
($VendorID_INT$, $VendorName_VARCHAR$, $PhoneNumber_VARCHAR$, $Address_VARCHAR$)