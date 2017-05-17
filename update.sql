CREATE TABLE AutoToken (
	ID INT NOT NULL AUTO_INCREMENT,
	Token VARCHAR(64),
	StartDate DATETIME,
	LastChange DATETIME,
	EndDate DATETIME,
	AutoAppID INT(11),
	AutoAppDataID INT(11),
	AutoSchengenAppDataID INT(11),
	Insurance VARCHAR(256),
	Step INT (2) DEFAULT 0,
	LastError VARCHAR(256),
	Finished INT(2) DEFAULT 0,
	Draft INT (2) DEFAULT 0,
	CreatedApp INT(8),
	PRIMARY KEY (ID),
	INDEX Token (Token) 
);

CREATE TABLE AutoAppointments (
	ID INT(8) UNSIGNED NOT NULL AUTO_INCREMENT,
	PersonalDataPermission TINYINT(1),
	MobilPermission TINYINT(1),
	PersonForAgreements INT(11),
	AppDate DATE NOT NULL,
	TimeslotID INT(10) UNSIGNED NOT NULL,
	RDate DATETIME NOT NULL,
	CenterID INT(3) UNSIGNED NOT NULL,
	Login VARCHAR(25) NOT NULL,
	EMail VARCHAR(50) NOT NULL,
	Phone VARCHAR(15) NOT NULL,
	Mobile VARCHAR(15) NOT NULL,
	Notes TEXT NOT NULL,
	Address TEXT NOT NULL,
	NCount INT(3) UNSIGNED NOT NULL,
	Status TINYINT(1) UNSIGNED NOT NULL,
	SMS TINYINT(1) UNSIGNED NOT NULL,
	FName VARCHAR(50) NOT NULL COLLATE 'cp1251_general_ci',
	LName VARCHAR(50) NOT NULL COLLATE 'cp1251_general_ci',
	MName VARCHAR(50) NOT NULL COLLATE 'cp1251_general_ci',
	PassNum VARCHAR(20) NOT NULL,
	PassDate DATE NOT NULL,
	PassWhom VARCHAR(255) NOT NULL,
	SessionID VARCHAR(10) NOT NULL,
	SDate DATE NOT NULL,
	FDate DATE NOT NULL,
	Duration INT(3) UNSIGNED NOT NULL,
	Urgent TINYINT(1) UNSIGNED NOT NULL,
	VType INT(3) UNSIGNED NOT NULL,
	TFName VARCHAR(50) NOT NULL,
	TLName VARCHAR(50) NOT NULL,
	TBDate DATE NOT NULL,
	PolicyType TINYINT(1) UNSIGNED NOT NULL COMMENT '1-group,0-personal',
	PacketID INT(10) UNSIGNED NOT NULL,
	Shipping TINYINT(1) UNSIGNED NOT NULL,
	ShAddress TEXT NOT NULL,
	dwhom TINYINT(1) UNSIGNED NOT NULL,
	CompanyID INT(11) NULL DEFAULT NULL,
	Draft INT(1) NULL DEFAULT '0' COMMENT 'for agency',
	Itinerario VARCHAR(45) NULL DEFAULT NULL,
	Vettore VARCHAR(45) NULL DEFAULT NULL,
	Frontiera VARCHAR(45) NULL DEFAULT NULL,
	Cost INT(11) NULL DEFAULT NULL,
	BankID VARCHAR(45) NULL DEFAULT NULL,
	PrintSrv INT(11) NULL DEFAULT '0',
	OfficeToReceive INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (ID)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

CREATE TABLE AutoAppData (
	ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
	AppID INT(8) UNSIGNED NOT NULL DEFAULT '0',
	Finished INT(2) DEFAULT 0,
	FName VARCHAR(50) NOT NULL,
	LName VARCHAR(50) NOT NULL,
	RFName VARCHAR(50) NOT NULL,
	RMName VARCHAR(50) NOT NULL COLLATE 'cp1251_general_ci',
	RLName VARCHAR(50) NOT NULL,
	PassNum VARCHAR(20) NOT NULL,
	RPassNum VARCHAR(20) NOT NULL,
	RPWhen DATE NOT NULL,
	RPWhere VARCHAR(255) NOT NULL,
	BirthDate DATE NOT NULL,
	Status TINYINT(1) UNSIGNED NOT NULL,
	isChild TINYINT(1) UNSIGNED NOT NULL,
	PolicyType TINYINT(1) UNSIGNED NOT NULL COMMENT '1-to create,2-created,3-error',
	PolicyNum VARCHAR(10) NOT NULL,
	PolicyErr VARCHAR(255) NOT NULL,
	InsurerID INT(10) UNSIGNED NOT NULL DEFAULT '0',
	DListID INT(10) UNSIGNED NOT NULL,
	NRes TINYINT(1) UNSIGNED NOT NULL,
	AMobile VARCHAR(20) NOT NULL,
	ASAddr TEXT NOT NULL,
	PolicyID VARCHAR(36) NOT NULL,
	PrevLNames VARCHAR(50) NOT NULL,
	BrhPlace VARCHAR(26) NOT NULL,
	BrhCountry VARCHAR(26) NOT NULL,
	Citizenship VARCHAR(30) NOT NULL,
	PrevCitizenship VARCHAR(30) NOT NULL,
	Gender TINYINT(1) UNSIGNED NOT NULL,
	Family TINYINT(1) UNSIGNED NOT NULL,
	FullAddress VARCHAR(255) NOT NULL,
	AppPhone VARCHAR(25) NOT NULL,
	KinderData VARCHAR(255) NOT NULL,
	DocType TINYINT(1) UNSIGNED NOT NULL,
	PassDate DATE NOT NULL,
	DocTypeOther VARCHAR(16) NOT NULL,
	PassTill DATE NOT NULL,
	PassWhom VARCHAR(14) NOT NULL,
	CountryLive TINYINT(1) UNSIGNED NOT NULL,
	VidNo VARCHAR(30) NOT NULL,
	VidTill DATE NOT NULL,
	ProfActivity VARCHAR(255) NOT NULL,
	WorkOrg TEXT NOT NULL,
	
	VisaPurpose1 TINYINT(1),
	VisaPurpose2 TINYINT(1),
	VisaPurpose3 TINYINT(1),
	VisaPurpose4 TINYINT(1),
	VisaPurpose5 TINYINT(1),
	VisaPurpose6 TINYINT(1),
	VisaPurpose7 TINYINT(1),
	VisaPurpose8 TINYINT(1),
	VisaPurpose9 TINYINT(1),
	VisaPurpose10 TINYINT(1),
	VisaPurpose11 TINYINT(1),
	VisaPurpose12 TINYINT(1),
	VisaPurpose13 TINYINT(1),
	VisaPurpose14 TINYINT(1),
	VisaPurpose15 TINYINT(1),
	VisaPurpose16 TINYINT(1),
	VisaPurpose17 TINYINT(1),
	
	VisaOther VARCHAR(20) NOT NULL,
	Countries VARCHAR(50) NOT NULL,
	FirstCountry VARCHAR(20) NOT NULL,
	VisaNum TINYINT(1) UNSIGNED NOT NULL,
	AppSDate DATE NOT NULL,
	AppFDate DATE NOT NULL,
	CalcDuration VARCHAR(50) NOT NULL,
	PrevVisa TINYINT(1) UNSIGNED NOT NULL,
	PrevVisaFD DATE NOT NULL,
	PrevVisaED DATE NOT NULL,
	Fingers TINYINT(1) UNSIGNED NOT NULL,
	FingersDate DATE NOT NULL,
	Permesso VARCHAR(255) NOT NULL,
	PermessoFD DATE NOT NULL,
	PermessoED DATE NOT NULL,
	Hotels VARCHAR(255) NOT NULL,
	HotelAdresses VARCHAR(255) NOT NULL,
	HotelPhone VARCHAR(50) NOT NULL,
	ACompanyName VARCHAR(100) NOT NULL,
	ACompanyAddress VARCHAR(100) NOT NULL,
	ACompanyPhone VARCHAR(50) NOT NULL,
	ACompanyFax VARCHAR(50) NOT NULL,
	ACopmanyPerson VARCHAR(255) NOT NULL,
	MezziWhom TINYINT(1) UNSIGNED NOT NULL,
	MezziWhomOther VARCHAR(100) NOT NULL,
	
	Mezzi1 TINYINT(1),
	Mezzi2 TINYINT(1),
	Mezzi3 TINYINT(1),
	Mezzi4 TINYINT(1),
	Mezzi5 TINYINT(1),
	Mezzi6 TINYINT(1),
	Mezzi7 TINYINT(1),
	
	MezziOtherSrc VARCHAR(30) NOT NULL,
	FamRel TINYINT(1) UNSIGNED NOT NULL,
	EuLName VARCHAR(50) NOT NULL,
	EuFName VARCHAR(50) NOT NULL,
	EuBDate DATE NOT NULL,
	EuCitizen VARCHAR(50) NOT NULL,
	EuPassNum VARCHAR(50) NOT NULL,
	IDNumber VARCHAR(50) NOT NULL,
	AnkDate DATETIME NOT NULL,
	AnketaC VARCHAR(50) NOT NULL,
	FamilyOther VARCHAR(25) NOT NULL,
	CountryRes VARCHAR(50) NOT NULL,
	City VARCHAR(50) NOT NULL,
	Nulla VARCHAR(25) NOT NULL,
	NullaCity VARCHAR(30) NOT NULL,
	FirstCity VARCHAR(50) NULL DEFAULT NULL,
	SchengenAppDataID INT(11) NULL DEFAULT NULL,
	AppDateBM DATE NULL DEFAULT NULL,
	TimeslotBMID INT(11) NULL DEFAULT NULL,
	ConcilFree ENUM('0','1') NULL DEFAULT '0',
	Short TINYINT(1) UNSIGNED NULL DEFAULT '0',
	AnketaSrv TINYINT(1) UNSIGNED NULL DEFAULT '0',
	PhotoSrv TINYINT(1) UNSIGNED NULL DEFAULT '0',
	PRIMARY KEY (ID),
	INDEX AppID (AppID)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB;

CREATE TABLE AutoSchengenAppData (
	ID INT(11) NOT NULL AUTO_INCREMENT,
	HostDataType ENUM('S','P','H') NULL DEFAULT NULL,
	HostDataName VARCHAR(25) NULL DEFAULT NULL,
	HostDataDenomination VARCHAR(50) NULL DEFAULT NULL,
	HostDataDateOfBirth DATE NULL DEFAULT NULL,
	HostDataAddress VARCHAR(50) NULL DEFAULT NULL,
	HostDataPostalCode VARCHAR(10) NULL DEFAULT NULL,
	HostDataCity VARCHAR(50) NULL DEFAULT NULL,
	HostDataProvince INT(3) NULL DEFAULT NULL,
	HostDataPhoneNumber VARCHAR(30) NULL DEFAULT NULL,
	HostDataEmail VARCHAR(100) NULL DEFAULT NULL,
	HostDataFax VARCHAR(30) NULL DEFAULT NULL,
	VisaDataType VARCHAR(45) NULL DEFAULT NULL,
	VisaDataNumberEntries VARCHAR(10) NULL DEFAULT NULL,
	VisaDataBeginningTravel VARCHAR(45) NULL DEFAULT NULL,
	VisaDataBorderFirstEntry VARCHAR(45) NULL DEFAULT NULL,
	VisaDataBorderEntryCity VARCHAR(45) NULL DEFAULT NULL,
	VisaDataCityDestination VARCHAR(45) NULL DEFAULT NULL,
	VisaDataPurposeTravel VARCHAR(45) NULL DEFAULT NULL,
	VisaDataDuration VARCHAR(45) NULL DEFAULT NULL,
	VisaDataEndTravel VARCHAR(45) NULL DEFAULT NULL,
	VisaDataIBorderEntry VARCHAR(45) NULL DEFAULT NULL,
	VisaDataMainDestination VARCHAR(45) NULL DEFAULT NULL,
	PRIMARY KEY (ID)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM;