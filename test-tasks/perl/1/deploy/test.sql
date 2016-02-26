DROP TABLE phones;
CREATE TABLE phones (
    id INTEGER PRIMARY KEY,
    phone INTEGER UNIQUE
);

DROP TABLE persons;
CREATE TABLE persons (
    id INTEGER PRIMARY KEY,
    phone_id INTEGER REFERENCES phones,
    name TEXT,
    address TEXT,
    note TEXT,
    ctime DATETIME DEFAULT CURRENT_TIMESTAMP
);
