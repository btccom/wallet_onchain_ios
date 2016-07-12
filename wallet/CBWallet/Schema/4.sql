DROP INDEX IF EXISTS 'tx_query';
DROP TABLE IF EXISTS 'txmap';
DROP INDEX IF EXISTS 'transaction_query';
DROP TABLE IF EXISTS 'tx';
CREATE TABLE IF NOT EXISTS 'tx' (
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
    'version' INTEGER
);
CREATE INDEX IF NOT EXISTS 'transaction_query' ON 'tx' ('hash', 'inputs', 'outputs');