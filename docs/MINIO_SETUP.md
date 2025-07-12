# MinIO Object Storage 설정 가이드

## 개요

MinIO는 S3 호환 API를 제공하는 오픈소스 객체 스토리지 시스템입니다. 이 가이드는 Kubernetes 클러스터에서 MinIO를 설정하고 사용하는 방법을 설명합니다.

## MinIO vs S3 비교

| 특성 | AWS S3 | MinIO |
|------|--------|-------|
| **비용** | 사용량 기반 과금 | 무료 (인프라 비용만) |
| **API 호환성** | S3 Native | S3 Compatible |
| **배포 환경** | 클라우드 전용 | 온프레미스/하이브리드 |
| **관리** | 완전 관리형 | 자체 관리 |
| **보안** | AWS IAM 통합 | 자체 정책 관리 |

## 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    EKS Cluster                             │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   MinIO Pod 1   │  │   MinIO Pod 2   │  │   MinIO Pod N   │ │
│  │   (StatefulSet) │  │   (StatefulSet) │  │   (StatefulSet) │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │      EBS 1      │  │      EBS 2      │  │      EBS N      │ │
│  │   (10Gi-100Gi)  │  │   (10Gi-100Gi)  │  │   (10Gi-100Gi)  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                    Services                                │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │   API Service   │  │ Console Service │                   │
│  │   (Port 9000)   │  │   (Port 9001)   │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

## 환경별 설정

### 1. Development 환경
```hcl
# environments/dev/core-infra/main.tf
module "minio" {
  source = "../../../modules/minio"
  
  stage           = "dev"
  servicename     = "microservices"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.service_subnet_ids
  eks_cluster_name = module.eks.cluster_name
  
  # 개발용 설정
  minio_root_user     = "minioadmin"
  minio_root_password = "minioadmin123"
  minio_storage_size  = "10Gi"
  minio_replicas      = 1
  
  # 기본 버킷 생성
  default_buckets = ["uploads", "backups", "logs", "user-profiles"]
}
```

### 2. Staging 환경
```hcl
# environments/staging/core-infra/main.tf
module "minio" {
  source = "../../../modules/minio"
  
  stage           = "staging"
  servicename     = "microservices"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.service_subnet_ids
  eks_cluster_name = module.eks.cluster_name
  
  # 스테이징용 설정
  minio_root_user     = "minioadmin"
  minio_root_password = "staging-secure-password"
  minio_storage_size  = "50Gi"
  minio_replicas      = 2
  
  # 도메인별 버킷
  default_buckets = [
    "user-profiles", "user-avatars",
    "product-images", "product-docs",
    "order-receipts", "order-exports"
  ]
}
```

### 3. Production 환경
```hcl
# environments/production/core-infra/main.tf
module "minio" {
  source = "../../../modules/minio"
  
  stage           = "production"
  servicename     = "microservices"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.service_subnet_ids
  eks_cluster_name = module.eks.cluster_name
  
  # 프로덕션용 설정
  minio_root_user     = "minioadmin"
  minio_root_password = "production-ultra-secure-password"
  minio_storage_size  = "100Gi"
  minio_replicas      = 4  # 분산 모드
  
  # 리소스 제한
  minio_cpu_request    = "500m"
  minio_memory_request = "1Gi"
  minio_cpu_limit      = "1000m"
  minio_memory_limit   = "2Gi"
  
  # 도메인별 버킷
  default_buckets = [
    "user-profiles", "user-avatars", "user-documents",
    "product-images", "product-docs", "product-videos",
    "order-receipts", "order-exports", "order-attachments"
  ]
}
```

## 애플리케이션에서 MinIO 사용

### 1. Python (boto3)
```python
import boto3
from botocore.client import Config

# MinIO 클라이언트 설정
s3_client = boto3.client(
    's3',
    endpoint_url='http://minio-api.microservices-minio-dev.svc.cluster.local:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123',
    config=Config(signature_version='s3v4'),
    region_name='us-east-1'
)

# 파일 업로드
s3_client.upload_file('local_file.txt', 'uploads', 'remote_file.txt')

# 파일 다운로드
s3_client.download_file('uploads', 'remote_file.txt', 'downloaded_file.txt')
```

### 2. Node.js (AWS SDK)
```javascript
const AWS = require('aws-sdk');

// MinIO 클라이언트 설정
const s3 = new AWS.S3({
    endpoint: 'http://minio-api.microservices-minio-dev.svc.cluster.local:9000',
    accessKeyId: 'minioadmin',
    secretAccessKey: 'minioadmin123',
    s3ForcePathStyle: true, // MinIO는 path-style 필요
    signatureVersion: 'v4'
});

// 파일 업로드
const uploadParams = {
    Bucket: 'uploads',
    Key: 'file.txt',
    Body: fileBuffer
};

s3.upload(uploadParams, (err, data) => {
    if (err) console.log(err);
    else console.log('Upload Success', data.Location);
});
```

### 3. Java (Spring Boot)
```java
@Configuration
public class MinIOConfig {
    
    @Bean
    public AmazonS3 amazonS3() {
        return AmazonS3ClientBuilder.standard()
            .withEndpointConfiguration(
                new AwsClientBuilder.EndpointConfiguration(
                    "http://minio-api.microservices-minio-dev.svc.cluster.local:9000",
                    "us-east-1"
                )
            )
            .withCredentials(new AWSStaticCredentialsProvider(
                new BasicAWSCredentials("minioadmin", "minioadmin123")
            ))
            .withPathStyleAccessEnabled(true)
            .build();
    }
}
```

## 마이크로서비스별 사용 패턴

### 1. User Service - 프로필 이미지 관리
```yaml
# helm-charts/user-service/values.yaml
minio:
  enabled: true
  endpoint: "http://minio-api.microservices-minio-dev.svc.cluster.local:9000"
  buckets:
    - user-profiles
    - user-avatars
  accessKey: "minioadmin"
  secretKey: "minioadmin123"
```

### 2. Product Service - 상품 이미지 관리
```yaml
# helm-charts/product-service/values.yaml
minio:
  enabled: true
  endpoint: "http://minio-api.microservices-minio-dev.svc.cluster.local:9000"
  buckets:
    - product-images
    - product-docs
    - product-videos
  accessKey: "minioadmin"
  secretKey: "minioadmin123"
```

### 3. Order Service - 주문 문서 관리
```yaml
# helm-charts/order-service/values.yaml
minio:
  enabled: true
  endpoint: "http://minio-api.microservices-minio-dev.svc.cluster.local:9000"
  buckets:
    - order-receipts
    - order-exports
  accessKey: "minioadmin"
  secretKey: "minioadmin123"
```

## 보안 설정

### 1. IAM 정책 (MinIO 내부)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::user-profiles/*",
        "arn:aws:s3:::product-images/*"
      ]
    }
  ]
}
```

### 2. Kubernetes Secret 관리
```yaml
# 각 마이크로서비스에서 사용할 시크릿
apiVersion: v1
kind: Secret
metadata:
  name: minio-credentials
type: Opaque
stringData:
  endpoint: "http://minio-api.microservices-minio-dev.svc.cluster.local:9000"
  accessKey: "service-specific-key"
  secretKey: "service-specific-secret"
```

## 모니터링 및 백업

### 1. 프로메테우스 메트릭 수집
```yaml
# MinIO는 기본적으로 /minio/v2/metrics/cluster 엔드포인트 제공
apiVersion: v1
kind: Service
metadata:
  name: minio-metrics
  labels:
    app: minio
spec:
  ports:
  - port: 9000
    name: metrics
  selector:
    app: minio
```

### 2. 백업 전략
```bash
# mc (MinIO Client) 를 사용한 백업
mc mirror minio/production-bucket s3/backup-bucket

# 정기적인 백업을 위한 CronJob
apiVersion: batch/v1
kind: CronJob
metadata:
  name: minio-backup
spec:
  schedule: "0 2 * * *"  # 매일 2시
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: minio/mc:latest
            command: ["mc", "mirror", "minio/data", "s3/backup"]
```

## 문제 해결

### 1. 연결 문제
```bash
# MinIO 서비스 상태 확인
kubectl get svc -n microservices-minio-dev

# Pod 상태 확인
kubectl get pods -n microservices-minio-dev

# 로그 확인
kubectl logs -n microservices-minio-dev minio-0
```

### 2. 성능 튜닝
```yaml
# MinIO 성능 최적화 설정
env:
- name: MINIO_API_REQUESTS_MAX
  value: "1000"
- name: MINIO_API_REQUESTS_DEADLINE
  value: "10s"
```

## 마이그레이션 가이드

### AWS S3에서 MinIO로 마이그레이션
```bash
# 1. S3 데이터를 MinIO로 복사
mc cp --recursive s3/aws-bucket minio/minio-bucket

# 2. 애플리케이션 설정 변경
# endpoint URL만 변경하면 됨 (S3 API 호환)

# 3. 점진적 마이그레이션
# - 새로운 데이터는 MinIO에 저장
# - 기존 데이터는 점진적으로 이동
```

이 설정을 통해 S3 호환 객체 스토리지를 자체 관리하면서도 AWS S3의 모든 기능을 사용할 수 있습니다.