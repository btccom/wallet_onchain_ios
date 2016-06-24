ALTER TABLE 'address' ADD COLUMN 'unconfirmedTXCount' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'received' INTEGER;
ALTER TABLE 'address' ADD COLUMN 'sent' INTEGER;
CREATE INDEX IF NOT EXISTS 'address_query' ON 'address' ('address', 'accountIdx');
CREATE TABLE IF NOT EXISTS 'tx' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'created_at' DATE,
    'hash' TEXT,
    'balance_diff' INTEGER,
    'block_height' INTEGER,
    'block_time' DATE,
    'queryAddress' TEXT,
    'relatedAddresses' TEXT
);
CREATE INDEX IF NOT EXISTS 'tx_query' ON 'tx' ('hash', 'queryAddress');
CREATE TABLE IF NOT EXISTS 'transaction' (
    'rid' INTEGER PRIMARY KEY AUTOINCREMENT,
    'created_at' DATE,
    'hash' TEXT,
    'fee' INTEGER,
    'inputs_value' INTEGER,
    'inputs_count' INTEGER,
    'inputs' TEXT,
    'outputs_value' INTEGER,
    'outputs_count' INTEGER,
    'outputs' TEXT,
    'is_coinbase' INTEGER,
    'block_height' INTEGER,
    'block_time' DATE,
    'size' INTEGER,
    'version' INTEGER,
    'accountIdx' INTEGER
);
CREATE INDEX IF NOT EXISTS 'transaction_query' ON 'transaction' ('hash', 'accountIdx');