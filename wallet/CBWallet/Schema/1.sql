CREATE TABLE IF NOT EXISTS 'account' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE DEFAULT CURRENT_DATE,
    'modificationDate' DATE DEFAULT CURRENT_DATE,
    'idx' INTEGER NOT NULL UNIQUE,
    'label' TEXT,
    'customDefaultEnabled' INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS 'address' (
	'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE DEFAULT CURRENT_DATE,
    'modificationDate' DATE DEFAULT CURRENT_DATE,
	'idx' INTEGER,
    'address' TEXT UNIQUE,
	'label' TEXT,
    'archived' INTEGER,
    'dirty' INTEGER,
    'balance' INTEGER,
    'txCount' INTEGER,
    'accountRid' INTEGER,
    'accountIdx' INTEGER
);
CREATE TABLE IF NOT EXISTS 'recipient' (
	'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
	'address' TEXT UNIQUE,
	'label' TEXT
);