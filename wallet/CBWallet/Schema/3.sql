ALTER TABLE 'address' ADD COLUMN 'unconfirmedTXCount' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'received' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'sent' INTEGER;
CREATE INDEX IF NOT EXISTS 'address_query' ON 'address' ('address', 'accountIdx');
CREATE TABLE IF NOT EXISTS 'tx' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE,
    'hash' TEXT,
    'value' INTEGER,
    'blockHeight' INTEGER,
    'blockTime' DATE,
    'queryAddress' TEXT,
    'relatedAddresses' TEXT
);
CREATE INDEX IF NOT EXISTS 'tx_query' ON 'tx' ('hash', 'queryAddress');
CREATE TABLE IF NOT EXISTS 'transaction' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE,
    'hash' TEXT,
    'fee' INTEGER,
    'inputsValue' INTEGER,
    'inputsCount' INTEGER,
    'inputs' TEXT,
    'outputsValue' INTEGER,
    'outputsCount' INTEGER,
    'outputs' TEXT,
    'isCoinbase' INTEGER,
    'blockHeight' INTEGER,
    'blockTime' DATE,
    'size' INTEGER,
    'version' INTEGER,
    'accountIdx' INTEGER
);
CREATE INDEX IF NOT EXISTS 'transaction_query' ON 'transaction' ('hash', 'accountIdx');