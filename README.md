# MinIO Data Lake on Kubernetes (3 replicas) + DuckDB CSV Query

## Prerequisites
- A working Kubernetes cluster and `kubectl` configured
- On Windows: PowerShell 5.1
- (Optional) DuckDB CLI installed

## Deploy MinIO (Distributed, 3 replicas)

```powershell
# Apply manifests
kubectl apply -f .\k8s\minio-distributed.yaml

# Wait for pods to be ready
kubectl -n minio get pods
kubectl -n minio rollout status statefulset/minio

# Check services
kubectl -n minio get svc
```

- MinIO API: `http://<node-ip>:30900` (NodePort)
- MinIO Console: `http://<node-ip>:30901` (login: `minioadmin` / `minioadmin123!`)

> If you use local cluster like kind/minikube, use their node IP or `localhost` port-forwarding as needed.

## Upload CSV to MinIO

```powershell
# Run upload script (downloads a sample CSV and uploads to bucket 'datasets')
PowerShell -ExecutionPolicy Bypass -File .\scripts\upload-csv.ps1 -Bucket datasets -MinioEndpoint "http://localhost:30900"
```

This creates bucket `datasets` and uploads `airtravel.csv`. Public URL: `http://localhost:30900/datasets/airtravel.csv`.

## Query with DuckDB

Option A: Use DuckDB CLI with S3 settings (MinIO-compatible):
```powershell
# Launch duckdb and run SQL
# If `duckdb` is not in PATH, download from https://duckdb.org
duckdb -c "\nSET s3_region='us-east-1'; SET s3_endpoint='localhost:30900'; SET s3_url_style='path'; SET s3_use_ssl=false; SET s3_access_key_id='minioadmin'; SET s3_secret_access_key='minioadmin123!'; SELECT * FROM read_csv('s3://datasets/airtravel.csv', AUTO_DETECT=TRUE) LIMIT 5;"
```

Option B: Use prepared SQL file:
```powershell
duckdb -init .\duckdb\query-csv.sql
```

## Notes
- Credentials are stored in a Kubernetes Secret; change them before production use.
- The Job `minio-init-bucket` initializes the `datasets` bucket and opens it for anonymous download (handy for simple demos). Remove or tighten policies for production.
- For TLS and external access, front MinIO with an Ingress + TLS.
- Storage class and PVC sizes can be adjusted in the StatefulSet.
