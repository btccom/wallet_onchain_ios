CREATE TABLE IF NOT EXISTS 'account' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE DEFAULT CURRENT_DATE,
    'modificationDate' DATE DEFAULT CURRENT_DATE,
    'idx' INTEGER NOT NULL UNIQUE,
    'label' TEXT,
    'customDefaultEnabled' INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS 'address' (
	'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE DEFAULT CURRENT_DATE,
    'modificationDate' DATE DEFAULT CURRENT_DATE,
	'idx' INTEGER,
    'address' TEXT UNIQUE,
	'label' TEXT,
    'dirty' INTEGER,
    'balance' INTEGER,
    'txCount' INTEGER,
    'accountId' INTEGER,
    'accountIdx' INTEGER
);
CREATE TABLE IF NOT EXISTS 'recipient' (
	'id' INTEGER PRIMARY KEY AUTOINCREMENT,
	'address' TEXT UNIQUE,
	'label' TEXT
);