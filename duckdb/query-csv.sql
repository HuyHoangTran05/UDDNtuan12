-- Configure DuckDB to read from MinIO via S3-compatible API
SET s3_region='us-east-1';
SET s3_endpoint='localhost:30900';
SET s3_url_style='path';
SET s3_use_ssl=false;
SET s3_access_key_id='minioadmin';
SET s3_secret_access_key='minioadmin123!';

-- Read the CSV from the bucket
CREATE OR REPLACE VIEW airtravel AS SELECT * FROM read_csv('s3://datasets/airtravel.csv', AUTO_DETECT=TRUE);

-- Example queries
SELECT COUNT(*) AS rows FROM airtravel;
SELECT * FROM airtravel LIMIT 5;