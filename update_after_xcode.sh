#!/bin/bash

echo "🔄 Xcode 16.2 업데이트 후 설정 작업 시작..."

# 1. Xcode 버전 확인
echo "📱 현재 Xcode 버전:"
xcodebuild -version

# 2. Flutter doctor 실행
echo "🔍 Flutter 환경 확인:"
flutter doctor -v

# 3. iOS 프로젝트 정리
echo "🧹 iOS 프로젝트 정리 중..."
cd ios
rm -rf Pods Podfile.lock
cd ..

# 4. Flutter 프로젝트 정리
echo "🧹 Flutter 프로젝트 정리 중..."
flutter clean

# 5. 의존성 재설치
echo "📦 의존성 재설치 중..."
flutter pub get

# 6. CocoaPods 재설치
echo "🍎 CocoaPods 재설치 중..."
cd ios
pod install --repo-update
cd ..

# 7. 기기 연결 확인
echo "📱 연결된 기기 확인:"
flutter devices

echo "✅ 설정 작업 완료! 이제 'flutter run -d [기기ID]'로 앱을 실행할 수 있습니다."
