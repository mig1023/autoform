/* ALTER TABLE `vcs`.`PriceRate` 
ADD COLUMN `AnketaPrice` FLOAT(15,2) NOT NULL DEFAULT 0.00 AFTER `TranslatePr`,
ADD COLUMN `PrintPrice` FLOAT(15,2) NOT NULL DEFAULT 0.00 AFTER `AnketaPrice`,
ADD COLUMN `PhotoPrice` FLOAT(15,2) NOT NULL DEFAULT 0.00 AFTER `PrintPrice`;

ALTER TABLE `vcs`.`DocPack` 
ADD COLUMN `AnketaSrv` INT(3) NOT NULL DEFAULT 0 COMMENT 'Услуга по заполнению анкеты (кол-во комплектов)' AFTER `XeroxPage`,
ADD COLUMN `PrintSrv` INT(3) NOT NULL DEFAULT 0 COMMENT 'Печать документов (кол-во листов)' AFTER `AnketaSrv`,
ADD COLUMN `PhotoSrv` INT(3) NOT NULL DEFAULT 0 COMMENT 'Фотографирование (кол-во фото)' AFTER `PrintSrv`;

ALTER TABLE `vcs`.`Branches` 
ADD COLUMN `isAnketa` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'флаг наличия допуслуги \"Заполнение анкеты\"' AFTER `shengen`,
ADD COLUMN `isPrinting` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'флаг наличия допуслуги \"Распечатка документов\"' AFTER `isAnketa`,
ADD COLUMN `isPhoto` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'флаг наличия допуслуги \"фотографирование\"' AFTER `isPrinting`;
*/

/* Changes from 2014-10-23 */
/*
CREATE TABLE `SchengenAppData` (
    `ID` INT(11) NOT NULL AUTO_INCREMENT,
    `HostDataType` ENUM('S','P','H') NOT NULL COMMENT 'P - person, S - company, H - hotel',
    `HostDataName` VARCHAR(25) NULL DEFAULT NULL COMMENT 'invitante-nome',
    `HostDataDenomination` VARCHAR(50) NULL DEFAULT NULL COMMENT 'invitante-denominazione / last_name',
    `HostDataDateOfBirth` DATE NULL DEFAULT NULL COMMENT 'invitante-dataNascita',
    `HostDataAddress` VARCHAR(50) NULL DEFAULT NULL COMMENT 'invitante-indirizzo',
    `HostDataPostalCode` VARCHAR(10) NULL DEFAULT NULL COMMENT 'invitante-cap',
    `HostDataCity` VARCHAR(50) NULL DEFAULT NULL COMMENT 'invitante-citta',
    `HostDataProvince` INT(3) NULL DEFAULT NULL COMMENT 'invitante-provincia',
    `HostDataPhoneNumber` VARCHAR(30) NULL DEFAULT NULL COMMENT 'invitante-telefono',
    `HostDataEmail` VARCHAR(100) NULL DEFAULT NULL COMMENT 'invitante-email',
    `HostDataFax` VARCHAR(30) NULL DEFAULT NULL COMMENT 'invitante-fax',
    `VisaDataType` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataNumberEntries` VARCHAR(10) NULL DEFAULT NULL,
    `VisaDataBeginningTravel` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataBorderFirstEntry` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataBorderEntryCity` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataCityDestination` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataPurposeTravel` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataDuration` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataEndTravel` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataIBorderEntry` VARCHAR(45) NULL DEFAULT NULL,
    `VisaDataMainDestination` VARCHAR(45) NULL DEFAULT NULL,
    PRIMARY KEY (`ID`)
)
COMMENT='a part of AppData corresponding to schengen site form'
COLLATE='utf8_general_ci'
ENGINE=MyISAM
AUTO_INCREMENT=12;



ALTER TABLE `AppData`
    ADD COLUMN `SchengenAppDataID` INT(11) NULL DEFAULT NULL AFTER `AppID`;

CREATE TABLE `SchengenProvinces` (
    `ID` INT(11) NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(100) NOT NULL,
    `Code` CHAR(2) NOT NULL,
    PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
AUTO_INCREMENT=104;
*/

/* Changes from 2014-10-28 */
/*
CREATE TABLE `SchengenItalianBrd` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(95) NOT NULL,
  `SCHID` INT NOT NULL,
  PRIMARY KEY (`ID`));*/

/* Changes from 2014-11-10 */
/*
ALTER TABLE `DailySum`
	ADD COLUMN `PaymentType` TINYINT(1) UNSIGNED NOT NULL AFTER `isJur`; */  

    
/* Changes from 2014-11-12 */     
ALTER TABLE `Users`
	ADD COLUMN `CompanyID` INT(5) UNSIGNED NULL AFTER `PersNo`;        
         
/* 2014-11-14 */        
/*
ALTER TABLE `vcs`.`Branches` ADD COLUMN `genbank` INT(3) NOT NULL DEFAULT 0 AFTER `ConsNDS`;
ALTER TABLE `vcs`.`DocPackList` ADD COLUMN `CBankID` VARCHAR(12) NOT NULL AFTER `PackInfoID`; */

CREATE TABLE `DocRequest` (
	  `ID` int(11) NOT NULL AUTO_INCREMENT,
	  `PackListID` int(11) NOT NULL,
	  `VisaDataType` varchar(45) DEFAULT NULL,
	  `VisaDataNumberEntries` varchar(45) DEFAULT NULL,
	  `VisaDataBeginningTravel` varchar(45) DEFAULT NULL,
	  `VisaDataBorderFirstEntry` varchar(45) DEFAULT NULL,
	  `VisaDataBorderEntryCity` varchar(45) DEFAULT NULL,
	  `VisaDataCityDestination` varchar(45) DEFAULT NULL,
	  `VisaDataPurposeTravel` varchar(45) DEFAULT NULL,
	  `VisaDataDuration` varchar(45) DEFAULT NULL,
	  `VisaDataEndTravel` varchar(45) DEFAULT NULL,
	  `VisaDataIBorderEntry` varchar(45) DEFAULT NULL,
	  `VisaDataMainDestination` varchar(45) DEFAULT NULL,
	  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

/* 2015-01-16 */
INSERT INTO `vcs`.`Menu` (`ID`, `Title`, `URL`, `Parent`, `Order`, `inVisible`) VALUES (71, 'menuLocalisation', '/settings/localisation.htm', 4, 340, 0);
INSERT INTO `vcs`.`RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (2, 71, 1);


/* 2015-04-10 */
ALTER TABLE `vcs`.`PriceRate` 
ADD COLUMN `IntShipping` FLOAT(15,2) NOT NULL DEFAULT 0.00 AFTER `Shipping`;


ALTER TABLE `vcs`.`Appointments` 
ADD COLUMN `Itinerario` VARCHAR(45) NULL AFTER `Draft`,
ADD COLUMN `Vettore` VARCHAR(45) NULL AFTER `Itinerario`,
ADD COLUMN `Frontiera` VARCHAR(45) NULL AFTER `Vettore`;


/* 2015-04-24 */
ALTER TABLE `Users`
	ADD COLUMN `PassChanged` DATE NOT NULL AFTER `StatusDate`;
    
ALTER TABLE `Users`
	ADD COLUMN `CookieID` VARCHAR(50) NULL DEFAULT NULL AFTER `CompanyID`;


/* 2015-04-27 */
/*
CREATE TABLE `AccessActionRoles` (
	`AccessActionID` INT(11) NOT NULL,
	`RoleID` INT(11) NOT NULL,
	`Rights` ENUM('read','write','full') NULL DEFAULT NULL,
	PRIMARY KEY (`AccessActionID`, `RoleID`)
)
COMMENT='Связывает таблицы AccessAction и Roles (may-to-many)'
COLLATE='utf8_general_ci'
ENGINE=InnoDB;



CREATE TABLE `AccessActions` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`Name` VARCHAR(50) NOT NULL DEFAULT '0',
	`Description` TEXT NULL,
	PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;    */
    
/* 2015-05-06, 2015-05-07 */
/*
CREATE TABLE `DocStatus` (
	`ID` INT NOT NULL,
	`Name` VARCHAR(30) NOT NULL,
	`Position` INT NOT NULL,
	PRIMARY KEY (`ID`)
)
COMMENT='Статусы документов'
COLLATE='utf8_general_ci'
ENGINE=InnoDB; */

/*
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (1, 'wait_for_payment', 10);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (2, 'payed', 20);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (3, 'in_consulate', 30);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (4, 'doc_ready', 40);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (5, 'delivering', 50);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (6, 'complete', 60);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (7, 'deleted', 70);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (8, 'returned_to_consulate', 80);
INSERT INTO `DocStatus` (`ID`, `Name`, `Position`) VALUES (9, 'received', 35); 


INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (1, 'view_status', 'Allows view \'received\' status of document for privileged users');

INSERT INTO `AccessActionRoles` (`AccessActionID`, `RoleID`, `Rights`) VALUES (1, 1, 'full');
INSERT INTO `AccessActionRoles` (`AccessActionID`, `RoleID`, `Rights`) VALUES (1, 2, 'full');
INSERT INTO `AccessActionRoles` (`AccessActionID`, `RoleID`, `Rights`) VALUES (1, 5, 'write');
INSERT INTO `AccessActionRoles` (`AccessActionID`, `RoleID`, `Rights`) VALUES (1, 6, 'write');
*/

/* Alows to manipulate some/all types of visa on create contract page */
/*
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (5, 72, 1);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (6, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (7, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (8, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (9, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (10, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (11, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (12, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (13, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (14, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (15, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (16, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (17, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (18, 72, 0);
INSERT INTO `RoleRights` (`RoleID`, `MenuID`, `Rights`) VALUES (19, 72, 1); 
INSERT INTO `vcs`.`Roles` (`RoleID`, `RoleName`, `Priority`) VALUES (19, 'AdminOfVisaType', 4);*/
/* -- */


ALTER TABLE `vcs`.`Appointments` 
    ADD COLUMN `Cost` INT NULL AFTER `Frontiera`,
    ADD COLUMN `BankID` VARCHAR(45) NULL AFTER `Cost`;



/* 2015-06-19  The changess  are needed on all the servers */
ALTER TABLE `Branches`
	ADD COLUMN `isVIP` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `isPhoto`;
    
ALTER TABLE `PriceRate`
	ADD COLUMN `VIPPrice` FLOAT(15,2) NOT NULL DEFAULT '0.00' AFTER `PhotoPrice`;
    
ALTER TABLE `DocPack`
	ADD COLUMN `VIPSrv` INT(3) NOT NULL DEFAULT '0' AFTER `PhotoSrv`;    

/* End */ 

ALTER TABLE `vcs`.`Timeslots` ADD COLUMN `Agency` TINYINT(1) NULL DEFAULT 0 AFTER `isDeleted`;

/* 2015-06-26  Weekend - integer like '67' - Saturday, Sunday. 1234567 - Monday - Sunday is a weekend for current branch */
ALTER TABLE `Branches`
	ADD COLUMN `Weekend` INT(7) UNSIGNED NOT NULL DEFAULT '67' COMMENT '12345567 - all days in week' AFTER `isVIP`;
/* End */ 

CREATE TABLE `DocPackVideo` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PackListID` int(11) NOT NULL,
  `FName` varchar(45) NOT NULL,
  `Login` varchar(45) NOT NULL,
  `VDate` datetime NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

/* 2015-07-29 */ 
ALTER TABLE `vcs`.`Companies` 
ADD COLUMN `NoteDetailsRU` VARCHAR(255) NULL AFTER `RCenter`,
ADD COLUMN `NoteDetailsEN` VARCHAR(255) NULL AFTER `NoteDetailsRU`,
ADD COLUMN `NoteChief` VARCHAR(100) NULL AFTER `NoteDetailsEN`;


/* 2015-08-17 - adding VIP service for juridicals*/
ALTER TABLE `JurSum`
	ADD COLUMN `VIPSrv` FLOAT(15,2) UNSIGNED NOT NULL AFTER `Xerox`;



/*  2015-08-20 */
CREATE TABLE `Services` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`Name` VARCHAR(45) NOT NULL,
    `TplPrefix` VARCHAR(200) NOT NULL,
	`CalculationType` VARCHAR(200) NOT NULL COMMENT '0 - Цена указывается при создании договора, 1 - Цена берется из прайса, в договоре указывается кол-во',
	PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=4;

  
  
  
CREATE TABLE `ServicesBranches` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`ServiceID` INT(11) NOT NULL,
	`BranchID` INT(11) NOT NULL,
	PRIMARY KEY (`ID`)
)
COMMENT='Сводная таблица many-to-many'
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=7
;
  
  
CREATE TABLE `ServiceFields` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`ServiceID` INT(11) NOT NULL,
	`FName` VARCHAR(45) NOT NULL,
	`FType` ENUM('INT','FLOAT','VARCHAR','DATE') NOT NULL COMMENT 'Должно соответствовать постфиксу таблиц ServiceFieldValues*',
	`ValueType` ENUM('0','1','2') NOT NULL DEFAULT '0' COMMENT 'Тип значения, указывающий на то, что поле участвует в рассчете суммы в договоре. 0 - default(не участвует), 1 - (стоимость), 2 - (количество)',
	`Required` ENUM('0','1') NOT NULL DEFAULT '0',
	PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=10
; 
  

CREATE TABLE `ServiceFieldValuesDATE` (
	`DocPackServiceID` INT(11) NOT NULL,
	`ServiceFieldID` INT(11) NOT NULL,
	`Value` DATE NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
;

CREATE TABLE `ServiceFieldValuesFLOAT` (
	`DocPackServiceID` INT(11) NOT NULL,
	`ServiceFieldID` INT(11) NOT NULL,
	`Value` FLOAT NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
;

CREATE TABLE `ServiceFieldValuesINT` (
	`DocPackServiceID` INT(11) NOT NULL,
	`ServiceFieldID` INT(11) NOT NULL,
	`Value` INT(11) NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
;
 
CREATE TABLE `ServiceFieldValuesVARCHAR` (
	`DocPackServiceID` INT(11) NOT NULL,
	`ServiceFieldID` INT(11) NOT NULL,
	`Value` VARCHAR(100) NULL DEFAULT NULL
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
;

CREATE TABLE `DocPackService` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`PackID` INT(11) NOT NULL,
	`ServiceID` INT(11) NOT NULL,
	PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=20
;


CREATE TABLE `ServicesPriceRates` (
	`ID` INT(11) NOT NULL AUTO_INCREMENT,
	`ServiceID` INT(11) NOT NULL,
	`PriceRateID` INT(11) NOT NULL,
	`Price` FLOAT NOT NULL DEFAULT '0',
	PRIMARY KEY (`ID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2
;

/* 2015-08-26 */
CREATE TABLE `CompanyBranch` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `CompanyID` int(11) NOT NULL,
  `BranchID` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* 2015-09-17*/
ALTER TABLE `Branches`
	ADD COLUMN `isShippingFree` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0' AFTER `Weekend`;


/* 2015-10-27 */
ALTER TABLE AppData ADD COLUMN Short INT AFTER ConcilFree;

/* 2015-11-06 */
CREATE TABLE Announced (ID INT AUTO_INCREMENT, AnDate VARCHAR(10), Message TEXT, Type INT, PRIMARY KEY(ID));
CREATE TABLE AnnounUsers (ID INT AUTO_INCREMENT, AnnounceID INT, Login VARCHAR(50), Data VARCHAR(10), PRIMARY KEY(ID));

INSERT INTO Menu (`Title`, `URL`, `Parent`, `Order`, `inVisible`) VALUES ('menuAddNews', '/personal/add_news.htm', 1, 3, 0);
INSERT INTO Menu (`Title`, `URL`, `Parent`, `Order`, `inVisible`) VALUES ('menuNewsList', '/personal/news.htm', 1, 4, 0);

/* 2015-11-09 */

ALTER TABLE Branches ADD COLUMN SenderID INT AFTER BAddr;
ALTER TABLE DHL_Prices ADD COLUMN SenderID INT AFTER RateID;
ALTER TABLE `vcs`.`DHL_Prices` 
ADD COLUMN `ID` INT NOT NULL AUTO_INCREMENT,
DROP PRIMARY KEY,
ADD PRIMARY KEY (`ID`);

UPDATE DHL_Prices SET SenderID = 1;


CREATE TABLE `vcs`.`DHL_Senders` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `City` VARCHAR(45) NOT NULL,
  `PCode` VARCHAR(45) NOT NULL,
  `CompanyName` VARCHAR(45) NOT NULL,
  `CompanyAddress` VARCHAR(45) NOT NULL,
  `PersonName` VARCHAR(45) NOT NULL,
  `PhoneNumber` VARCHAR(45) NOT NULL,
  `PhoneExtension` VARCHAR(45) NOT NULL,
  `FaxNumber` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`));

/* 2015-12-24 */
INSERT INTO AccessActions VALUES (2, 'data protection', 'Access to the personal data');

/* 2016-01-14 */
ALTER TABLE `DocPack`
	ADD COLUMN `ConcilPaymentDate` DATE NOT NULL AFTER `isNewDHL`;
    
/* 2016-01-18 */
ALTER TABLE `PriceRate`
	ADD COLUMN `ConcilCurrency` VARCHAR(3) NOT NULL DEFAULT 'RUR' AFTER `Currency`;

/* 2016-01-22 */
/* Fixes after merge */
ALTER TABLE `Appointments`
	ADD COLUMN `DHL_IndexID` INT(6) UNSIGNED NULL AFTER `ShAddress`;
ALTER TABLE `Appointments`
	ADD COLUMN `PrintSrv` INT(11) NULL DEFAULT '0' AFTER `BankID`;

ALTER TABLE `AppData`
	ADD COLUMN `AnketaSrv` TINYINT(1) UNSIGNED NULL DEFAULT '0' AFTER `ConcilFree`,
	ADD COLUMN `PhotoSrv` TINYINT(1) UNSIGNED NULL DEFAULT '0' AFTER `AnketaSrv`,
	ADD COLUMN `InvPerson` VARCHAR(256) NULL DEFAULT NULL AFTER `PhotoSrv`,
	ADD COLUMN `Permi` VARCHAR(22) NULL DEFAULT NULL AFTER `InvPerson`,
	ADD COLUMN `PassType` VARCHAR(42) NULL DEFAULT NULL AFTER `Permi`,
	ADD COLUMN `AllPrevVisa` VARCHAR(256) NULL DEFAULT NULL AFTER `PassType`;

/* 2016-02-01 */
ALTER TABLE `DailySum`
	ALTER `Price` DROP DEFAULT;
ALTER TABLE `DailySum`
	CHANGE COLUMN `Price` `Price` FLOAT(15,2) UNSIGNED NULL AFTER `Qnt`;
    
/* 2016-02-08 */
CREATE TABLE `TimeSlotOverrides` (
	`ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	`TimeDataID` INT(5) NOT NULL,
	`Date` DATE NOT NULL,
	`NewVisaCount` INT(5) UNSIGNED NOT NULL,
	`NewUrgentVisaCount` INT(5) UNSIGNED NOT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE INDEX `TimeData-Date` (`TimeDataID`, `Date`)
)

/* 2016-02-09 */
INSERT INTO `Menu` (`Title`, `URL`, `Parent`, `Order`, `inVisible`) VALUES ('menuTimeShowOverrides', '/settings/overrides.htm', 4, 350, 0);

/* VMSK-37, 2016-02-16 */
INSERT INTO AccessActions VALUES (3, 'E-mail in report', 'Show an e-mail in visa fee report');

/* 2016-02-19 */
insert into AccessActions values (4, 'moving an applicant', 'Access to move applicants to other appointments');

/* VMSK-75 */
ALTER TABLE `CompDov` ADD COLUMN `ExpDovDate` DATE AFTER `isDeleted`;

/* 2016-03-23 */
ALTER TABLE `Branches` ADD COLUMN `Timezone` INT(2) NOT NULL AFTER `BName`;

/* 2016-03-25 */
INSERT INTO `vcs`.`AccessActions` (`Name`, `Description`) VALUES ('appForToday', 'Позволяет записывать на любой слот текущего дня, вне зависимости от других ограничений');

/* VMSK-95 */
insert into AccessActions values (5, 'Перенос даты ноты', 'Доступность переноса даты и времени для нот');

/* VMSK-110 */
insert into AccessActions values (7, 'shortcutmenu_menu1', 'Новая запись на подачу');
insert into AccessActions values (8, 'shortcutmenu_menu2', 'Список приглашений');
insert into AccessActions values (9, 'shortcutmenu_menu3', 'Список договоров физ. лиц');
insert into AccessActions values (10, 'shortcutmenu_menu4', 'Список договоров юр. лиц');
insert into AccessActions values (11, 'shortcutmenu_menu5', 'Статус документов');
insert into AccessActions values (12, 'shortcutmenu_menu6', 'История документов');
insert into AccessActions values (13, 'shortcutmenu_menu7', 'Организации');
insert into AccessActions values (14, 'shortcutmenu_menu8', 'Оплата договоров физ. лиц');
insert into AccessActions values (15, 'shortcutmenu_menu9', 'Оплата договоров юр. лиц');
insert into AccessActions values (16, 'start_report', 'Отчёт с датой вылета на главной странице');

/* 2016-04-27 */
INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (17, 'docs_branch_ops', 'Отправлять документы в головной офис и принимать из головного офиса');
INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (18, 'docs_HQ_branch_ops', 'Принимать документы из филиалов и отправлять в филиалы');
INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (19, 'docs_send_to_consulate', 'Отправлять документы в консульство');
INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (20, 'docs_receive_from_consulate_HQ', 'Принимать документы из консульства для центрального офиса');
INSERT INTO `AccessActions` (`ID`, `Name`, `Description`) VALUES (21, 'docs_receive_from_consulate_branch', 'Принимать документы из консульства для филиалов');

/* 2016-06-08 */
/* already applied */
CREATE TABLE `DocHistory_daily` (
	`DocID` INT(10) UNSIGNED NOT NULL,
	`PassNum` VARCHAR(15) NOT NULL,
	`Login` VARCHAR(25) NOT NULL,
	`HDate` DATETIME NOT NULL,
	`StatusID` INT(2) UNSIGNED NOT NULL,
	`BankID` VARCHAR(12) NULL DEFAULT NULL,
	`ActTime` INT(5) UNSIGNED NOT NULL,
	`AddInfo` VARCHAR(50) NOT NULL,
	`ODuration` INT(10) UNSIGNED NOT NULL,
	INDEX `DocID` (`DocID`),
	INDEX `PassNum` (`PassNum`),
	INDEX `BankID` (`BankID`),
	INDEX `HDate` (`HDate`),
	INDEX `StatusID` (`StatusID`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
ROW_FORMAT=COMPACT;

CREATE TRIGGER `DocHistory_daily_copying` AFTER INSERT ON `DocHistory` 
FOR EACH ROW 
INSERT INTO DocHistory_daily (DocID, PassNum, Login, HDate, StatusID, BankID, ActTime, AddInfo, ODuration) VALUES (NEW.DocID, NEW.PassNum, NEW.Login, NEW.HDate, NEW.StatusID, NEW.BankID, NEW.ActTime, NEW.AddInfo, NEW.ODuration)

/* VMSK-145 */
ALTER TABLE `Branches`
	ADD COLUMN `DefaultPaymentMethod` INT(1) NOT NULL DEFAULT '1' AFTER `isPrepayedAppointment`;

/* VMSK-167 */
ALTER TABLE `AppData`
	ADD COLUMN `ACompanyAddress` VARCHAR(100) NOT NULL AFTER `ACompanyName`;

ALTER TABLE `AppData`
	ADD COLUMN `ACompanyFax` VARCHAR(50) NOT NULL AFTER `ACompanyPhone`;
    
ALTER TABLE `PriceList`
	CHANGE COLUMN `ID` `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST;

ALTER TABLE `PriceRate`
	CHANGE COLUMN `ID` `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT FIRST;
    
ALTER TABLE `PriceList`
	ALTER `RateID` DROP DEFAULT;
ALTER TABLE `PriceList`
	CHANGE COLUMN `RateID` `RateID` INT UNSIGNED NOT NULL AFTER `ID`;

/* VMSK-158 */
ALTER TABLE `DocPack`
	ADD COLUMN `OfficeToReceive` INT NULL AFTER `ConcilPaymentDate`;

ALTER TABLE `DocRequest`
	CHANGE COLUMN `VisaDataBorderEntryCity` `VisaDataBorderEntryCity` VARCHAR(50) NULL DEFAULT NULL AFTER `VisaDataBorderFirstEntry`;
	
CREATE TABLE DraftAppointments (
	ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	Token VARCHAR(128),
	GUID INT,
	Draft INT,
	RequestData TEXT, 
	PRIMARY KEY (`ID`)
)

CREATE TABLE EmailToken (
	ID INT NOT NULL AUTO_INCREMENT,
	Token VARCHAR(128),
	Email VARCHAR(256),
	CenterID INT,
	VisaType INT,
	NCount INT,
	StartDate DATETIME,
	Finished INT,
	AppID INT,
	PRIMARY KEY (ID) 
);

ALTER TABLE DraftAppointments 
	CHANGE COLUMN GUID GUID VARCHAR(128);

ALTER TABLE Branches
	ADD COLUMN JAddr MEDIUMTEXT AFTER BAddr,
	ADD COLUMN AddrEqualled INT DEFAULT 1 AFTER JAddr;
	
ALTER TABLE DocHistory
	ADD COLUMN FPStatus INT(2) DEFAULT 0 AFTER ODuration;

ALTER TABLE `Appointments`
	ADD COLUMN `OfficeToReceive` INT NULL AFTER `PrintSrv`;

INSERT INTO `vcs`.`AccessActions` (`ID`, `Name`, `Description`) VALUES ('22', 'note_new_jurid', 'Доступность изменения агентства на странице ноты');

CREATE TABLE AutoformToken (
	ID INT NOT NULL AUTO_INCREMENT,
	Token VARCHAR(64),
	AppID INT(11),
	AppDataID INT(11),
	Step INT (2) DEFAULT 0,
	LastError VARCHAR(256),
	Finished INT(2) DEFAULT 0,
	Draft INT (2) DEFAULT 0,
	PRIMARY KEY (ID) );