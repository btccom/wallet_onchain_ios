ALTER TABLE 'address' ADD COLUMN 'unconfirmedTXCount' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'received' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'sent' INTEGER;
CREATE INDEX IF NOT EXISTS 'address_query' ON 'address' ('address', 'accountIdx');
CREATE TABLE IF NOT EXISTS 'tx' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'creationDate' DATE,
    'hash' TEXT,
    'value' INTEGER,
    'fee' INTEGER,
    'confirmations' INTEGER,
    'isCoinbase' INTEGER,
    'blockHeight' INTEGER,
    'blockTime' DATE,
    'queryAddresses' TEXT,
    'relatedAddresses' TEXT
);
CREATE INDEX IF NOT EXISTS 'tx_query' ON 'tx' ('hash', 'queryAddress', 'accountIdx');
CREATE TABLE IF NOT EXISTS 'transaction' (
    'hash' TEXT PRIMARY KEY,
    'creationDate' DATE,
    'value' INTEGER,
    'fee' INTEGER,
    'confirmations' INTEGER,
    'inputsValue' INTEGER,
    'outputsValue' INTEGER,
    'inputs' TEXT,
    'outputs' TEXT,
    'isCoinbase' INTEGER,
    'blockHeight' INTEGER,
    'blockTime' DATE,
    'accountIdx' INTEGER
);
CREATE INDEX IF NOT EXISTS 'transaction_query' ON 'transaction' ('accountIdx');