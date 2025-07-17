[![hits](https://myhits.vercel.app/api/hit/https%3A%2F%2Fgithub.com%2Fjasonethicseo%2Felice-pjt?color=blue&label=hits&size=small)](https://myhits.vercel.app)

# Microservices Platform on AWS EKS

> **완전한 MSA 환경**: Kubernetes 기반의 마이크로서비스 플랫폼  
> **Multi-Environment**: Development, Staging, Production 환경 지원  
> **S3 호환 스토리지**: MinIO를 통한 비용 효율적인 객체 스토리지  

이 프로젝트는 AWS EKS를 기반으로 한 마이크로서비스 플랫폼입니다. 도메인 주도 설계(DDD) 원칙에 따라 각 비즈니스 도메인별로 인프라를 분리하여 관리하며, 11개의 마이크로서비스를 지원합니다.

## 🏗️ 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                          AWS EKS Cluster                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  User Domain    │  │ Product Domain  │  │  Order Domain   │  │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │
│  │ │ api         │ │  │ │ api         │ │  │ │ api         │ │  │
│  │ │ auth        │ │  │ │ search      │ │  │ │ worker      │ │  │
│  │ │ profile     │ │  │ │ recommend   │ │  │ │ scheduler   │ │  │
│  │ │ notification│ │  │ │ inventory   │ │  │ └─────────────┘ │  │
│  │ └─────────────┘ │  │ └─────────────┘ │  │                 │  │
│  │     Aurora      │  │     Aurora      │  │     Aurora      │  │
│  │   PostgreSQL    │  │   PostgreSQL    │  │   PostgreSQL    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│                    Shared Infrastructure                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   MinIO S3      │  │   AWS S3 +      │  │   OpenVPN       │  │
│  │ Object Storage  │  │   CloudFront    │  │   VPN Access    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 🌐 Multi-Environment Architecture

| 환경 | VPC CIDR | 노드 크기 | MinIO 스토리지 | 외부 접근 |
|------|----------|-----------|----------------|-----------|
| **Development** | `10.0.0.0/16` | t3.medium × 3 | 10Gi × 1 | ✅ LoadBalancer |
| **Staging** | `10.10.0.0/16` | t3.small × 2 | 50Gi × 2 | ❌ Internal Only |
| **Production** | `10.20.0.0/16` | t3.large × 5 | 100Gi × 4 | ❌ Internal Only |

## 📁 프로젝트 구조

```
elice-pjt/ (Public Repository)
├── 📂 .github/workflows/           # CI/CD Pipelines with Private Module Access
│   ├── msa_core_infra_plan.yml     # Core 인프라 계획
│   ├── msa_core_infra_apply_destroy.yml # Core 인프라 배포/삭제
│   ├── msa_domain_modules_plan.yml  # 도메인 모듈 계획
│   ├── msa_domain_modules_apply_destroy.yml # 도메인 모듈 배포/삭제
│   ├── environment_promotion.yml    # 환경 승격 워크플로우
│   ├── multi_env_core_infra_plan.yml # 다중 환경 계획
│   └── helm_chart_publish.yml       # Helm 차트 배포
├── 📂 environments/                 # Multi-Environment Infrastructure
│   ├── 📂 dev/                     # 개발 환경
│   │   ├── 📂 core-infra/          # 공유 인프라
│   │   ├── 📂 domain-user/         # 사용자 도메인 
│   │   ├── 📂 domain-product/      # 상품 도메인
│   │   ├── 📂 domain-order/        # 주문 도메인
│   │   └── 📂 private-cloud/       # OpenStack 프라이빗 클라우드
│   ├── 📂 staging/                 # 스테이징 환경
│   │   ├── 📂 core-infra/
│   │   ├── 📂 domain-user/
│   │   ├── 📂 domain-product/
│   │   └── 📂 domain-order/
│   └── 📂 production/              # 프로덕션 환경
│       ├── 📂 core-infra/
│       ├── 📂 domain-user/
│       ├── 📂 domain-product/
│       └── 📂 domain-order/
├── 📂 modules/                     # 🔒 Private Modules (Runtime Only)
│   │                               # ⚠️  Available only in CI/CD environment
│   │                               # ❌ Not included in public repository
│   ├── 📂 vpc/                     # 네트워크 구성
│   ├── 📂 eks/                     # EKS 클러스터
│   ├── 📂 aurora/                  # PostgreSQL 데이터베이스
│   ├── 📂 microservice-base/       # 마이크로서비스 기본 리소스
│   ├── 📂 s3/                      # S3 버킷
│   ├── 📂 cloudfront/              # CDN
│   ├── 📂 openvpn/                 # VPN 서버
│   ├── 📂 ecr/                     # Container Registry
│   └── 📂 minio/                   # S3 호환 객체 스토리지 (Public)
├── 📂 modules/openstack-*/         # OpenStack Private Cloud Modules
│   ├── 📂 openstack-network/       # 프라이빗 클라우드 네트워킹
│   ├── 📂 openstack-compute/       # 가상머신 및 컴퓨팅
│   └── 📂 openstack-storage/       # 블록/객체 스토리지
├── 📂 helm-charts/                 # Kubernetes Deployments (11 Services)
│   ├── 📂 base-chart/              # 공통 Helm 차트
│   ├── 📂 user-api-service/        # User API Gateway
│   ├── 📂 user-auth-service/       # 인증 및 JWT 관리
│   ├── 📂 user-profile-service/    # 프로필 관리
│   ├── 📂 user-notification-service/ # 멀티채널 알림
│   ├── 📂 product-api-service/     # Product API Gateway
│   ├── 📂 product-search-service/  # Elasticsearch 검색
│   ├── 📂 product-recommendation-service/ # ML 추천 엔진
│   ├── 📂 product-inventory-service/ # 실시간 재고 관리
│   ├── 📂 order-api-service/       # 주문 처리 API
│   ├── 📂 order-worker-service/    # 백그라운드 작업 처리
│   └── 📂 order-scheduler-service/ # 크론 스케줄링
├── 📂 docs/                        # Documentation
│   ├── MINIO_SETUP.md              # MinIO 설정 가이드
│   └── PRIVATE_CLOUD_ARCHITECTURE.md # 프라이빗 클라우드 가이드
├── 📂 examples/                    # Usage Examples
│   ├── minio-usage.py              # MinIO Python 예제
│   └── minio-microservice-config.yaml # Kubernetes 설정 예제
└── README.md                       # This file

📋 Private Module Repository (elice-pjt-modules)
└── 📂 modules/                     # 🔒 Private Enterprise Modules
    ├── 📂 vpc/                     # Advanced networking configuration
    ├── 📂 eks/                     # Production-grade EKS setup
    ├── 📂 aurora/                  # Enterprise PostgreSQL configuration
    ├── 📂 microservice-base/       # Advanced microservice infrastructure
    ├── 📂 s3/                      # Enterprise S3 configuration
    ├── 📂 cloudfront/              # Production CDN setup
    ├── 📂 openvpn/                 # Secure VPN configuration
    └── 📂 ecr/                     # Container registry management
```

## 🚀 Quick Start

### 1. 사전 준비

```bash
# 필수 도구 설치 확인
terraform --version  # v1.8.0+
aws --version        # v2.0+
kubectl version      # v1.28+
helm version         # v3.14+

# AWS 자격 증명 설정
aws configure
aws sts get-caller-identity
```

### 2. 백엔드 준비 (자동화됨)

Terraform 백엔드는 CI/CD 파이프라인에서 자동으로 생성됩니다:

| 환경 | S3 버킷 | DynamoDB 테이블 |
|------|---------|-----------------|
| **Dev** | `jasonseo-dev-terraform-state` | `jasonseo-dev-terraform-lock` |
| **Staging** | `jasonseo-staging-terraform-state` | `jasonseo-staging-terraform-lock` |
| **Production** | `jasonseo-prod-terraform-state` | `jasonseo-prod-terraform-lock` |

### 3. 🏗️ 인프라 배포

#### Option A: 수동 배포 (개발용)

```bash
# 1. Core Infrastructure 배포
cd environments/dev/core-infra
terraform init
terraform plan
terraform apply

# 2. Domain Infrastructure 배포 (병렬 가능)
cd ../domain-user && terraform init && terraform apply
cd ../domain-product && terraform init && terraform apply  
cd ../domain-order && terraform init && terraform apply
```

#### Option B: CI/CD 배포 (권장)

```bash
# GitHub Actions를 통한 자동 배포
git push origin main  # 자동으로 plan 및 apply 실행
```

## 🔒 보안 아키텍처 - Private Module System

### **Two-Repository Architecture**

이 프로젝트는 **보안과 투명성**을 모두 달성하기 위한 구조를 사용합니다:

```yaml
Repository Structure:
  Public Repository (elice-pjt):
    - 아키텍처 및 구조 공개
    - 환경 설정 및 배포 스크립트
    - OpenStack 프라이빗 클라우드 모듈
    - MinIO 객체 스토리지 구현
    
  Private Repository (elice-pjt-modules):
    - 프로젝트 핵심 모듈
    - 프로덕션 보안 설정
    - 고급 네트워킹 구성
    - 상용 환경 최적화 코드
```

### **Runtime Module Access**

```yaml
# CI/CD 실행 시 (GitHub Actions)
Security Flow:
  1. Public repo checkout        # 메인 코드 가져오기
  2. Private modules checkout    # PAT로 인증 후 모듈 가져오기
     with: 
       token: PRIVATE_MODULES_TOKEN
  3. Module setup               # modules/ 폴더에 배치
  4. Terraform execution        # ../../../modules/ 참조 동작
  
# 로컬 Clone 시
Local Access:
  ❌ modules/ 폴더 없음
  ❌ terraform init 실패
  ❌ 인프라 배포 불가
  ✅ 아키텍처 학습 가능
```

### **보안 장점**

- **👥 Public Transparency**: 아키텍처와 접근 방식 완전 공개
- **🔐 IP Protection**: 핵심 비즈니스 로직과 보안 설정 보호  
- **🚀 CI/CD Integration**: 인증된 환경에서만 자동 배포
- **🛡️ Access Control**: PAT 기반 세밀한 권한 관리
- **📊 Audit Trail**: 모든 인프라 변경 사항 추적 가능

### **Setup Instructions**

CI/CD에서 private modules에 접근하려면 다음 설정이 필요합니다:

#### 1. Personal Access Token 생성
```bash
GitHub → Settings → Developer settings → Personal access tokens
- repo (Full control of private repositories) ✅
- workflow (Update GitHub Action workflows) ✅
```

#### 2. Repository Secrets 설정  
```bash
elice-pjt Repository → Settings → Secrets and variables → Actions
- Name: PRIVATE_MODULES_TOKEN
- Secret: [위에서 생성한 PAT]
```

#### 3. Workflow 동작 확인
```bash
git push origin main
→ GitHub Actions에서 private modules 자동 체크아웃
→ Terraform 정상 실행 ✅
```

### 4. 🔐 클러스터 접근 설정

```bash
# EKS 클러스터 연결
aws eks update-kubeconfig --region ca-central-1 --name aws-eks-cluster-dev-microservices

# 클러스터 상태 확인
kubectl get nodes
kubectl get namespaces
```

### 5. 📦 MinIO 객체 스토리지 접근

```bash
# MinIO 콘솔 접근 (개발 환경)
kubectl port-forward -n microservices-minio-dev svc/minio-console 9001:9001

# 브라우저에서 http://localhost:9001 접속
# 사용자명: minioadmin
# 비밀번호: minioadmin123
```

## 🏢 도메인별 마이크로서비스

### 👤 User Domain (4개 서비스)
```yaml
Services:
  - user-api-service: User API Gateway (라우팅, 인증, 속도 제한)
  - user-auth-service: JWT/OAuth 인증 (Google, GitHub 통합)
  - user-profile-service: 프로필 관리 (MinIO 파일 업로드)
  - user-notification-service: 멀티채널 알림 (Email, SMS, Push, WebSocket)

Database: userdb (Aurora PostgreSQL)
Storage:
  - user-profiles: 프로필 이미지
  - user-avatars: 아바타 이미지
  - user-documents: 사용자 문서

Resources:
  - CPU: 2-4 cores, Memory: 2-4Gi per service
  - HPA: 2-15 replicas (서비스별 차등)
  - 특별 기능: BCrypt 암호화, 속도 제한, 다국어 템플릿
```

### 🛍️ Product Domain (4개 서비스)
```yaml
Services:
  - product-api-service: Product API Gateway (Elasticsearch 통합, 캐싱)
  - product-search-service: 검색 엔진 (퍼지 매칭, 자동완성, 패싯)
  - product-recommendation-service: ML 추천 (협업 필터링, 모델 저장)
  - product-inventory-service: 실시간 재고 (예약, 자동 보충, 멀티 창고)

Database: productdb (Aurora PostgreSQL)
Storage:
  - product-images: 상품 이미지 (CDN 연동)
  - product-docs: 상품 문서
  - product-videos: 상품 동영상
  - ml-models: 추천 모델 저장 (PVC)

Resources:
  - CPU: 2-4 cores, Memory: 2-4Gi per service  
  - HPA: 3-15 replicas (서비스별 차등)
  - 특별 기능: Elasticsearch 통합, ML 모델 저장, 실시간 브로드캐스팅
```

### 📦 Order Domain (3개 서비스)
```yaml
Services:
  - order-api-service: 주문 처리 API (Stripe/PayPal 결제, 워크플로우)
  - order-worker-service: 백그라운드 작업 (Redis 큐, 우선순위, 데드레터)
  - order-scheduler-service: 크론 스케줄링 (리더 선출, 주문 정리, 재고 동기화)

Database: orderdb (Aurora PostgreSQL)
Storage:
  - order-receipts: 주문 영수증
  - order-exports: 주문 내역 내보내기
  - order-attachments: 주문 첨부파일

Resources:
  - CPU: 2-4 cores, Memory: 2-4Gi per service
  - HPA: 2-20 replicas (API 서비스), 1 replica (스케줄러)
  - 특별 기능: 결제 시스템 통합, Redis 큐, 리더 선출, 정시 작업
```

## 💰 비용 효율적인 객체 스토리지

### MinIO vs AWS S3 비교

| 특성 | AWS S3 | MinIO | 절감율 |
|------|--------|-------|--------|
| **월 비용 (Dev)** | ~$15 | ~$5 | **67%** |
| **월 비용 (Staging)** | ~$75 | ~$25 | **67%** |
| **월 비용 (Production)** | ~$300 | ~$80 | **73%** |
| **API 호환성** | 100% Native | 99% Compatible | - |
| **데이터 주권** | AWS 관리 | 완전 자체 관리 | - |

### MinIO 사용법

```python
# Python에서 MinIO 사용 (S3 API 호환)
import boto3
from botocore.client import Config

s3_client = boto3.client(
    's3',
    endpoint_url='http://minio-api.microservices-minio-dev.svc.cluster.local:9000',
    aws_access_key_id='minioadmin',
    aws_secret_access_key='minioadmin123',
    config=Config(signature_version='s3v4')
)

# 기존 S3 코드와 동일하게 사용 가능
s3_client.upload_file('local_file.txt', 'user-profiles', 'user123.txt')
```

## 🔄 환경 승격 워크플로우

### 자동화된 환경 승격

```bash
# GitHub Actions를 통한 환경 승격
# dev → staging → production

# 1. Staging으로 승격
gh workflow run environment_promotion.yml \
  -f source_environment=dev \
  -f target_environment=staging \
  -f promote_domains=all \
  -f confirm_promotion=PROMOTE

# 2. Production으로 승격
gh workflow run environment_promotion.yml \
  -f source_environment=staging \
  -f target_environment=production \
  -f promote_domains=user,product \
  -f confirm_promotion=PROMOTE
```

### 환경별 차이점

| 설정 | Dev | Staging | Production |
|------|-----|---------|------------|
| **인스턴스 타입** | t3.medium | t3.small | t3.large |
| **노드 수** | 2-5 | 1-3 | 3-10 |
| **MinIO 복제본** | 1 | 2 | 4 |
| **외부 접근** | ✅ | ❌ | ❌ |
| **백업 정책** | 7일 | 30일 | 90일 |

## 🛡️ 보안 및 네트워킹

### 네트워크 보안
```yaml
Security Features:
  - Private EKS Cluster: ✅
  - VPN Access Only: ✅ (OpenVPN)
  - Network Policies: ✅ (Namespace 간 격리)
  - Security Groups: ✅ (최소 권한)
  
Database Security:
  - Private Subnets: ✅
  - Encryption at Rest: ✅
  - Secrets Manager: ✅
  - Aurora Backup: ✅ (7-90일)

Container Security:
  - ECR Image Scanning: ✅
  - Pod Security Standards: ✅
  - Resource Quotas: ✅
  - Non-root Containers: ✅
```

### 모니터링 및 로깅
```yaml
Observability:
  - CloudWatch Logs: ✅ (EKS)
  - Aurora Monitoring: ✅
  - MinIO Metrics: ✅ (Prometheus)
  - Application Logs: ✅ (FluentBit)

Backup & Recovery:
  - Database Backups: ✅ (자동)
  - Volume Snapshots: ✅ (EBS)
  - Cross-AZ Redundancy: ✅
  - Disaster Recovery: 📋 (계획됨)
```

## 🔧 운영 및 관리

### 일반적인 운영 명령어

```bash
# 클러스터 상태 확인
kubectl get nodes -o wide
kubectl top nodes

# 도메인별 리소스 확인
kubectl get all -n microservices-user-dev
kubectl get all -n microservices-product-dev
kubectl get all -n microservices-order-dev

# MinIO 상태 확인
kubectl get pods -n microservices-minio-dev
kubectl logs -n microservices-minio-dev deployment/minio

# 데이터베이스 연결 확인
kubectl get secrets -n microservices-user-dev
kubectl describe secret user-db-credentials -n microservices-user-dev
```

### 트러블슈팅

```bash
# Terraform 상태 문제
terraform force-unlock <LOCK_ID>
terraform refresh

# EKS 접근 권한 문제
aws eks update-kubeconfig --region ca-central-1 --name <cluster-name>
kubectl config current-context

# MinIO 연결 문제  
kubectl port-forward -n microservices-minio-dev svc/minio-api 9000:9000
curl http://localhost:9000/minio/health/live

# Pod 문제 진단
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
```

## 📈 확장 및 개선 계획

### Phase 2: 모니터링 스택
- [ ] Prometheus + Grafana 구축
- [ ] Jaeger 분산 추적
- [ ] ELK 스택 로깅
- [ ] Alerting 시스템

### Phase 3: 서비스 메시
- [ ] Istio 도입
- [ ] 트래픽 관리
- [ ] 보안 정책
- [ ] 카나리 배포

### Phase 4: 고급 기능
- [ ] GitOps (ArgoCD)
- [ ] 정책 엔진 (OPA)
- [ ] 비밀 관리 (Vault)
- [ ] 비용 최적화 (Spot instances)
