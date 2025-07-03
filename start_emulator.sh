#!/bin/bash

# Google DNS를 사용하여 에뮬레이터 시작
echo "🚀 Google DNS로 에뮬레이터 시작 중..."

# 기존 에뮬레이터 프로세스 종료
pkill -f "qemu-system-aarch64.*orderman" 2>/dev/null

# 잠시 대기
sleep 2

# Google DNS로 에뮬레이터 시작
cd /Users/sihyungpark/Library/Android/sdk/emulator
./emulator -avd orderman -dns-server 8.8.8.8,8.8.4.4 -no-snapshot-load &

echo "✅ 에뮬레이터가 Google DNS(8.8.8.8, 8.8.4.4)로 시작되었습니다."
echo "📱 에뮬레이터 부팅 완료까지 약 30초 정도 기다려주세요."
