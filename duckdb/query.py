import argparse
import duckdb

parser = argparse.ArgumentParser()
parser.add_argument('--endpoint', required=True, help='MinIO endpoint host:port, e.g., 192.168.49.2:30900')
parser.add_argument('--bucket', default='datasets')
parser.add_argument('--object', default='airtravel.csv')
parser.add_argument('--access_key', default='minioadmin')
parser.add_argument('--secret_key', default='minioadmin123!')
args = parser.parse_args()

con = duckdb.connect(database=':memory:')
con.execute("PRAGMA threads=2")
con.execute("INSTALL httpfs; LOAD httpfs;")
con.execute("SET s3_region='us-east-1';")
con.execute(f"SET s3_endpoint='{args.endpoint}';")
con.execute("SET s3_url_style='path';")
con.execute("SET s3_use_ssl=false;")
con.execute(f"SET s3_access_key_id='{args.access_key}';")
con.execute(f"SET s3_secret_access_key='{args.secret_key}';")

url = f"s3://{args.bucket}/{args.object}"
print(f"Querying {url} via {args.endpoint}...\n")
res = con.execute(f"SELECT COUNT(*) AS rows FROM read_csv_auto('{url}')").fetchall()
print(f"Rows: {res[0][0]}")
print("\nSample:")
sample = con.execute(f"SELECT * FROM read_csv_auto('{url}') LIMIT 5").fetchdf()
print(sample.to_string(index=False))
