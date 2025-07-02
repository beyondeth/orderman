#!/bin/bash

# 🚀 Flutter iOS 빌드 최적화 스크립트

echo "🔧 iOS 빌드 최적화 시작..."

# 1. Xcode 캐시 정리
echo "📦 Xcode 캐시 정리 중..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

# 2. CocoaPods 캐시 정리
echo "🍫 CocoaPods 캐시 정리 중..."
pod cache clean --all

# 3. Flutter 캐시 정리
echo "🐦 Flutter 캐시 정리 중..."
flutter clean

# 4. 의존성 재설치
echo "📥 의존성 재설치 중..."
flutter pub get
cd ios && pod install --repo-update

# 5. 빌드 최적화 환경변수 설정
export FLUTTER_BUILD_MODE=debug
export XCODE_XCCONFIG_FILE="Flutter/Debug.xcconfig"

echo "✅ 빌드 최적화 완료!"
echo "이제 'flutter run'으로 앱을 실행하세요."
