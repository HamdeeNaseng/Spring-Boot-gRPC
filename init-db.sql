-- Create databases for order and payment services
CREATE DATABASE ordersdb;
CREATE DATABASE paymentsdb;

-- Grant privileges to the default user
GRANT ALL PRIVILEGES ON DATABASE ordersdb TO myuser;
GRANT ALL PRIVILEGES ON DATABASE paymentsdb TO myuser;
