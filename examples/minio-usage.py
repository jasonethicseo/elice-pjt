#!/usr/bin/env python3
"""
MinIO 사용 예제
AWS S3와 호환되는 MinIO 객체 스토리지 사용법
"""

import boto3
from botocore.client import Config
from botocore.exceptions import ClientError
import os
import json

# MinIO 설정
MINIO_ENDPOINT = os.getenv('MINIO_ENDPOINT', 'http://localhost:9000')
MINIO_ACCESS_KEY = os.getenv('MINIO_ACCESS_KEY', 'minioadmin')
MINIO_SECRET_KEY = os.getenv('MINIO_SECRET_KEY', 'minioadmin123')
MINIO_REGION = os.getenv('MINIO_REGION', 'us-east-1')

class MinIOClient:
    def __init__(self, endpoint, access_key, secret_key, region='us-east-1'):
        """MinIO 클라이언트 초기화"""
        self.s3_client = boto3.client(
            's3',
            endpoint_url=endpoint,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            config=Config(signature_version='s3v4'),
            region_name=region
        )
    
    def create_bucket(self, bucket_name):
        """버킷 생성"""
        try:
            self.s3_client.create_bucket(Bucket=bucket_name)
            print(f"✅ 버킷 '{bucket_name}' 생성됨")
        except ClientError as e:
            if e.response['Error']['Code'] == 'BucketAlreadyExists':
                print(f"⚠️  버킷 '{bucket_name}'이 이미 존재함")
            else:
                print(f"❌ 버킷 생성 실패: {e}")
    
    def list_buckets(self):
        """모든 버킷 목록 조회"""
        try:
            response = self.s3_client.list_buckets()
            print("📂 사용 가능한 버킷:")
            for bucket in response['Buckets']:
                print(f"  - {bucket['Name']} (생성일: {bucket['CreationDate']})")
        except ClientError as e:
            print(f"❌ 버킷 목록 조회 실패: {e}")
    
    def upload_file(self, file_path, bucket_name, object_name=None):
        """파일 업로드"""
        if object_name is None:
            object_name = os.path.basename(file_path)
        
        try:
            self.s3_client.upload_file(file_path, bucket_name, object_name)
            print(f"⬆️  파일 '{file_path}' -> '{bucket_name}/{object_name}' 업로드 완료")
        except ClientError as e:
            print(f"❌ 파일 업로드 실패: {e}")
    
    def download_file(self, bucket_name, object_name, file_path):
        """파일 다운로드"""
        try:
            self.s3_client.download_file(bucket_name, object_name, file_path)
            print(f"⬇️  파일 '{bucket_name}/{object_name}' -> '{file_path}' 다운로드 완료")
        except ClientError as e:
            print(f"❌ 파일 다운로드 실패: {e}")
    
    def list_objects(self, bucket_name, prefix=''):
        """객체 목록 조회"""
        try:
            response = self.s3_client.list_objects_v2(
                Bucket=bucket_name,
                Prefix=prefix
            )
            
            if 'Contents' in response:
                print(f"📁 버킷 '{bucket_name}'의 객체:")
                for obj in response['Contents']:
                    print(f"  - {obj['Key']} (크기: {obj['Size']} bytes)")
            else:
                print(f"📭 버킷 '{bucket_name}'이 비어있음")
        except ClientError as e:
            print(f"❌ 객체 목록 조회 실패: {e}")
    
    def delete_object(self, bucket_name, object_name):
        """객체 삭제"""
        try:
            self.s3_client.delete_object(Bucket=bucket_name, Key=object_name)
            print(f"🗑️  객체 '{bucket_name}/{object_name}' 삭제 완료")
        except ClientError as e:
            print(f"❌ 객체 삭제 실패: {e}")
    
    def set_bucket_policy(self, bucket_name, policy):
        """버킷 정책 설정"""
        try:
            self.s3_client.put_bucket_policy(
                Bucket=bucket_name,
                Policy=json.dumps(policy)
            )
            print(f"🔒 버킷 '{bucket_name}' 정책 설정 완료")
        except ClientError as e:
            print(f"❌ 버킷 정책 설정 실패: {e}")

def main():
    """메인 함수 - MinIO 사용 예제"""
    print("🔧 MinIO 클라이언트 초기화...")
    minio = MinIOClient(MINIO_ENDPOINT, MINIO_ACCESS_KEY, MINIO_SECRET_KEY)
    
    # 1. 버킷 생성
    print("\n1️⃣ 버킷 생성")
    test_buckets = ['test-uploads', 'user-profiles', 'product-images']
    for bucket in test_buckets:
        minio.create_bucket(bucket)
    
    # 2. 버킷 목록 조회
    print("\n2️⃣ 버킷 목록 조회")
    minio.list_buckets()
    
    # 3. 테스트 파일 생성 및 업로드
    print("\n3️⃣ 파일 업로드")
    test_file = '/tmp/test_file.txt'
    with open(test_file, 'w') as f:
        f.write('Hello MinIO! This is a test file.')
    
    minio.upload_file(test_file, 'test-uploads', 'hello.txt')
    
    # 4. 객체 목록 조회
    print("\n4️⃣ 객체 목록 조회")
    minio.list_objects('test-uploads')
    
    # 5. 파일 다운로드
    print("\n5️⃣ 파일 다운로드")
    download_path = '/tmp/downloaded_file.txt'
    minio.download_file('test-uploads', 'hello.txt', download_path)
    
    # 6. 공개 읽기 정책 설정 (선택사항)
    print("\n6️⃣ 버킷 정책 설정")
    public_read_policy = {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::test-uploads/*"
            }
        ]
    }
    minio.set_bucket_policy('test-uploads', public_read_policy)
    
    # 7. 정리
    print("\n7️⃣ 정리")
    minio.delete_object('test-uploads', 'hello.txt')
    
    # 임시 파일 삭제
    os.remove(test_file)
    if os.path.exists(download_path):
        os.remove(download_path)
    
    print("\n✅ MinIO 사용 예제 완료!")

if __name__ == "__main__":
    # 환경 변수 확인
    print("🔍 환경 설정 확인:")
    print(f"  MINIO_ENDPOINT: {MINIO_ENDPOINT}")
    print(f"  MINIO_ACCESS_KEY: {MINIO_ACCESS_KEY}")
    print(f"  MINIO_SECRET_KEY: {'*' * len(MINIO_SECRET_KEY)}")
    print(f"  MINIO_REGION: {MINIO_REGION}")
    
    main()