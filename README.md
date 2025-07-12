# Microservices Platform on AWS EKS

이 프로젝트는 AWS EKS 기반의 마이크로서비스 플랫폼 POC(Proof of Concept)입니다. 도메인 주도 설계(DDD) 원칙에 따라 각 비즈니스 도메인별로 인프라를 분리하여 관리합니다.

## 아키텍처 개요

```
├── Core Infrastructure (공유)
│   ├── VPC & Networking
│   ├── EKS Cluster
│   ├── OpenVPN
│   └── Shared S3 & CloudFront
├── Domain: Order
│   ├── PostgreSQL Database
│   ├── ECR Repositories
│   ├── Kubernetes Namespace
│   └── S3 Bucket (문서)
├── Domain: Product
│   ├── PostgreSQL Database
│   ├── ECR Repositories
│   ├── Kubernetes Namespace
│   └── S3 Bucket (이미지)
└── Domain: User
    ├── PostgreSQL Database
    ├── ECR Repositories
    ├── Kubernetes Namespace
    └── S3 Bucket (프로필)
```

## 디렉토리 구조

```
terraform-aws/
├── .github/workflows/        # CI/CD 파이프라인
├── environments/dev/         # 개발 환경
│   ├── core-infra/          # 공유 인프라
│   ├── domain-order/        # 주문 도메인
│   ├── domain-product/      # 상품 도메인
│   └── domain-user/         # 사용자 도메인
├── modules/                 # 재사용 가능한 모듈
│   ├── microservice-base/   # 마이크로서비스 기본 리소스
│   ├── vpc/                # 네트워크
│   ├── eks/                # EKS 클러스터
│   ├── aurora/             # PostgreSQL
│   └── ...
└── k8s-manifests/          # Kubernetes 매니페스트
    ├── argocd-apps/        # ArgoCD 애플리케이션
    └── argocd-install.yaml # ArgoCD 설치
```

## 구축 순서

### 1. 사전 준비

1. AWS CLI 설정 및 권한 확인
2. Terraform 설치 (v1.5.0+)
3. kubectl 설치
4. S3 backend bucket 생성 (이미 존재: `jasonseo-dev-terraform-state`)

### 2. Core Infrastructure 배포

```bash
cd environments/dev/core-infra
terraform init
terraform plan
terraform apply
```

이 단계에서 다음이 생성됩니다:
- VPC, 서브넷, 라우팅 테이블
- EKS 클러스터 및 노드 그룹
- OpenVPN 인스턴스
- 공유 S3 버킷 및 CloudFront

### 3. Domain Infrastructure 배포

각 도메인별로 병렬 배포 가능:

```bash
# Order Domain
cd environments/dev/domain-order
terraform init
terraform plan
terraform apply

# Product Domain
cd environments/dev/domain-product
terraform init
terraform plan
terraform apply

# User Domain
cd environments/dev/domain-user
terraform init
terraform plan
terraform apply
```

### 4. ArgoCD 설치

```bash
# EKS 클러스터 접근 설정
aws eks update-kubeconfig --region ca-central-1 --name aws-eks-cluster-dev-microservices

# ArgoCD 설치
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 커스텀 설정 적용
kubectl apply -f k8s-manifests/argocd-install.yaml

# ArgoCD 앱 등록
kubectl apply -f k8s-manifests/argocd-apps/app-of-apps.yaml
```

### 5. ArgoCD 접근

```bash
# 초기 admin 패스워드 확인
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 포트 포워딩으로 접근
kubectl port-forward svc/argocd-server -n argocd 8080:443

# 브라우저에서 https://localhost:8080 접근
```

## CI/CD 파이프라인

GitHub Actions를 통한 자동화된 배포:

1. **Pull Request**: 모든 변경사항에 대해 `terraform plan` 실행
2. **Main 브랜치 머지**: 자동으로 `terraform apply` 실행
3. **변경 감지**: 변경된 도메인만 선별적으로 배포

### GitHub Secrets 설정

다음 secrets를 GitHub 리포지토리에 설정해야 합니다:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

## 각 도메인별 리소스

### Order Domain
- **Database**: `orderdb` (PostgreSQL)
- **Services**: api, worker, scheduler
- **S3**: 주문 문서 저장 (7년 보관)
- **Namespace**: `order`

### Product Domain
- **Database**: `productdb` (PostgreSQL)
- **Services**: api, search, recommendation, inventory
- **S3**: 상품 이미지 저장 (CDN 연동)
- **Namespace**: `product`

### User Domain
- **Database**: `userdb` (PostgreSQL)
- **Services**: api, auth, profile, notification
- **S3**: 사용자 프로필 저장 (14일 백업)
- **Namespace**: `user`

## 리소스 관리

### 네트워크 정책
각 도메인별로 Kubernetes Network Policy가 적용되어 네임스페이스 간 통신을 제어합니다.

### 리소스 쿼터
도메인별로 CPU, 메모리, Pod 수 등에 대한 리소스 쿼터가 설정됩니다.

### 보안
- 모든 데이터베이스는 프라이빗 서브넷에 배치
- VPN을 통한 관리 접근
- ECR 이미지 스캐닝 활성화
- 네트워크 정책으로 마이크로서비스 간 통신 제어

## 확장 계획

이 POC는 다음과 같이 확장 가능합니다:

1. **새 도메인 추가**: `domain-payment`, `domain-notification` 등
2. **환경 추가**: `staging`, `prod` 환경
3. **모니터링 스택**: Prometheus, Grafana, Jaeger 추가
4. **서비스 메시**: Istio 도입
5. **보안 강화**: Pod Security Standards, OPA Gatekeeper

## 문제 해결

### Terraform 상태 충돌
```bash
terraform force-unlock LOCK_ID
```

### EKS 접근 권한 오류
```bash
aws sts get-caller-identity
aws eks update-kubeconfig --region ca-central-1 --name aws-eks-cluster-dev-microservices
```

### ArgoCD 동기화 오류
```bash
kubectl get applications -n argocd
kubectl describe application order-service -n argocd
```

## 비용 최적화

- 개발 환경에서는 `t3.medium` 인스턴스 사용
- Aurora Serverless 고려 (현재는 Provisioned)
- S3 Lifecycle 정책으로 비용 절감
- 필요시 Spot 인스턴스 활용

---

**이 POC는 20시간 내 구축을 목표로 설계되었으며, 프로덕션 환경으로 확장 시 추가 보안 및 모니터링 구성이 필요합니다.**