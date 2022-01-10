-- Role: test_user
-- DROP ROLE IF EXISTS test_user;

CREATE ROLE test_user WITH
  LOGIN
  SUPERUSER
  INHERIT
  CREATEDB
  CREATEROLE
  NOREPLICATION
  ENCRYPTED PASSWORD 'SCRAM-SHA-256$4096:gNugjC2HPcpaaHec6DAxRQ==$/i7xi4uQKtOoA8I/XMehP06cqHMIYOUPMj8vYqfDwc0=:4iJlfatj+h0Ar99ZE3GArCwnqQAY39MtPyvP6jaMMnY=';

-- Database: test_database

-- DROP DATABASE IF EXISTS test_database;

CREATE DATABASE test_database
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Ukraine.1251'
    LC_CTYPE = 'Russian_Ukraine.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

GRANT ALL ON DATABASE test_database TO postgres;

GRANT TEMPORARY, CONNECT ON DATABASE test_database TO PUBLIC;

GRANT ALL ON DATABASE test_database TO test_user;