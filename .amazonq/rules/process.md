# 개선할 사항
1. 구매자 - 홈화면 - 최근 주문 - 판매자 username 만 나와있는데 (판매자) 라고 옆에 명시
2. 구매자 - 홈화면 - 최근 주문 - 클릭하면 주문 내역 볼 수 있도록
3. 구매자 - 홈화면 - 좋은 아침입니다! 문구 삭제, 이름과 상호명 위치 변경. 
4. 구매자 - 홈화면 - 최근 주문 내역 컨테이너 안에 또 <최근 주문> 이 들어가 있어서 중복적으로 보임. 최근 주문 내역 컨테이너 안의 최근 주문은 전체적인 UI 가 묶여 있는거 같은데 이것은 유지하고 제일 바깥에 있는 최근 주문 내역을 없애서 UI 적으로 자연스럽고 부드럽게 보였으면함. 마찬가지로 연결된 판매자도 최근주문 내역 컨테이너 안에 있는 최근 주문 아이콘과 글씨 크기를 사용하여 위에서 아래로 스크롤시 전체적인 UI/UX 가 자연스러워지도록 해야함.


구매자 홈화면에서 UI/UX 변경할것.
1. 연결된 판매자 컨테이너 내에서 판매자의 username 왼쪽으로 (판매자) 아이콘 배치할것. 그리고 연결됨 상태를 알려주는 아이콘은 판매자 아이콘 밑에 배치할것.\
2. 최근 주문 컨테이너에서 모래시계 아이콘 같은것은 삭제하고 1번과 마찬가지로 판매자의 username 왼쪽으로 판매자 아이콘 배치하고 대기중 아이콘 같은것은 판매자 아이콘 아래 배치할것.
3. 아이콘 위치 레이아웃 정렬을 깔끔하게 부탁해
4. 다른 로직 건들이지말고 ui만 바꿔

이해를 제대로 못한거 같네 ? 다시 설명해줄게.
연결된 판매자 컨테이너는
test(판매자username) 판매자(아이콘) 연결됨(아이콘) 이렇게 나란히 배치를해
왼쪽에 세로로 배치된 두개 아이콘은 없애

최근 주문 컨테이너는
test(판매자username) 판매자(아이콘) 대기중(아이콘) 이렇게 나란히 배치를해
왼쪽에 세로로 배치된 두개 아이콘은 없애

# 2025-07-15

# 판매자 로그인했을시 수정해야할 사항
1. 판매자 로그인 - 상품탭 - 상품 추가 버튼을 눌렀을때 - 상품, 단위, 가격이 나오는데 단위는 입력하지 않아도 넘어가도록 해.
2. 주문탭에서 오류 발생. "SellerOrdersController" not found. you need to call "Get.put(SellerOrdersController())" or "Get.layPut((=>SellerOrdersController())"
3. 판매자 홈화면 - 오늘의 주문에 대기중인 상품이 있는데도 불구하고 주문 현황 컨테이너에 반영이 안됨. 신규 주문, 처리 중, 완료가 있는데 이게 주문탭에서 주문 현황 상태를 체크하는것과 일치하는 항목인지도 확인.

# 현재 디자인은 너무 ai 틱 스러워서 촌스러워. toss 스타일로다가 알잘딱깔센으로다가 디자인시스템 반영해줘
1. 주요 비즈니스 로직은 하나도 건들이지 말것
2. UI/UX 디자인과 레이아웃, 글씨폰트, 색등 toss 스타일로 사용자 중심으로 반영할것
3. 우선 판매자 화면만 반영해볼것
4. 로그인, 회원가입 UI/UX 디자인은 마음에 들어. 그 부분은 건들이지 말것 !!! (중요)
   

# 개선할 사항
1. 판매자 화면 - 주문탭 - 주문 수량 입력시 문제발생 - 예를들어 수량 1을 누르고 가만히 있으면 현재상태 커서가 없어져서 다시 수량을 눌러서 입력을 해야함. 1을 눌렀다가 키보드의 <- 버튼을 눌러서 잘못입력했다면 지우고 2를 입력할 수 있어야하는데 그냥 숫자 누르면 바로 포커싱이 바껴버림. 
2. 위 문제가 안드로이드/ios 모두의 문제인지 기기마다 설정을 다시해야하는지 알아보고. 이는 구매자 화면에서도 마찬가지 문제가 발생함.
3. 로그인시 이메일과 비밀번호를 입력하고 로그인 버튼을 누르면 한번 더 눌러야 로그인이 발생하는 문제가 있음. 로그인은 잘돼. 다만 두번을 눌러야함.
4. 판매자 화면에서 연결탭을 누르면 보여지는 화면이 구매자 화면에서 연결탭을 눌렀을때 보여지는 UI 디자인과 같았으면 좋겠어. 디자인만 구매자 화면의 연결 화면과 같게하라는거지 로직을 바꾸라는건 아님.
5. 우선 위 문제부터 step by step 으로 해결하고, 핵심 비즈니스 로직을 바꿔야할때는 내 허락을 맡도록해.

# ✅ Flutter App 개선사항 Task Checklist

## 🔢 주문 수량 입력 UX 문제 (판매자 화면 > 주문 탭) [이 문제는 구매자 화면에서도 동일하게 나타남]
- [ ] 수량 입력 시 커서가 사라지는 문제 재현 및 원인 파악
- [ ] 키보드 입력 중 커서가 유지되도록 수정
- [ ] 숫자 입력 후 백스페이스로 지운 뒤 새로운 숫자를 자연스럽게 입력 가능하도록 개선
- [ ] 입력값이 덮어쓰여지지 않도록 포커스 로직 확인
- [ ] 예를들어, 12를 입력하려면 1을 입력하고 포커싱이 사라져서 다시 포커싱 후 2를 눌러야함

## 📱 입력 UX 문제의 플랫폼 범위 확인
- [ ] 위 UX 문제가 Android에서 발생하는지 확인
- [ ] 동일 문제가 iOS에서도 재현되는지 확인
- [ ] 디바이스 또는 OS 버전에 따라 차이가 있는지 테스트
- [ ] 구매자 화면에서도 동일 문제가 발생하는지 확인

## 🔐 로그인 버튼 2회 클릭 이슈
- [ ] 로그인 버튼을 눌러도 한 번에 동작하지 않는 문제 확인
- [ ] 첫 번째 클릭 시 onPressed 또는 인증 로직이 무시되는 원인 조사
- [ ] 로그인 이벤트가 단일 클릭으로만 실행되도록 수정
- [ ] 로그인 성공 시 UI 반응 및 로딩 처리 확인

## 🎨 판매자 앱 > 연결 탭 UI 통일
- [ ] 구매자 앱의 연결 탭 UI 디자인 참고
- [ ] 판매자 앱의 연결 탭 UI를 동일한 구조와 스타일로 수정
- [ ] 기능 로직은 변경하지 않고 UI만 동일하게 유지
- [ ] 디자인 요소 (색상, 레이아웃, 아이콘 등) 동일하게 적용

## 📌 작업 방식 및 승인 프로세스
- [ ] 위 문제들을 **하나씩 순차적으로(step-by-step)** 처리할 것
- [ ] 핵심 비즈니스 로직을 변경해야 할 경우 **사전 승인 요청 필수**
- [ ] 수정한 핵심 코드는 .md 파일로 남길것



1. 이메일/비밀번호 입력 후 로그인시 두번 눌러야하는 현상 (아래는 로그)
flutter: === 📋 Summary result: {totalAmount: 0, totalOrders: 0, orders: []} ===
flutter: === ✅ Monthly summary loaded: 0 orders, 0 amount ===
flutter: === 🔍 All connections for buyer JUu0QElSqXM5MoQ6gkL3nU9nACz1: 1 ===
flutter: === Connection U1KJeojT00kZHFP0esQ0: ===
flutter:   - Buyer ID: JUu0QElSqXM5MoQ6gkL3nU9nACz1
flutter:   - Seller ID: uzcUcuE12wRZYjnceNKYHgLPjVR2
flutter:   - Buyer Email: luticek@naver.com
flutter:   - Seller Email: test@seller.com
flutter:   - Status: approved
flutter:   - Requested At: Timestamp(seconds=1751098117, nanoseconds=645000000)
flutter: === ✅ Loaded 1 approved connections ===
flutter: === Connection 0: ===
flutter:   - ID: U1KJeojT00kZHFP0esQ0
flutter:   - Buyer ID: JUu0QElSqXM5MoQ6gkL3nU9nACz1
flutter:   - Seller ID: uzcUcuE12wRZYjnceNKYHgLPjVR2
flutter:   - Buyer Name: 풍천
flutter:   - Seller Name: test
flutter:   - Status: ConnectionStatus.approved
flutter:   - Requested At: 2025-06-28 17:08:37.645
flutter: === 🔗 Preloading products for seller: test (uzcUcuE12wRZYjnceNKYHgLPjVR2) ===
flutter: === 🔍 Loading products for seller: uzcUcuE12wRZYjnceNKYHgLPjVR2 ===
flutter: === 🔍 Getting ACTIVE products for seller: uzcUcuE12wRZYjnceNKYHgLPjVR2 ===
flutter: === 📦 Active products snapshot received: 5 docs ===
flutter: === ✅ Active product parsed: 생장어 (isActive: true) ===
flutter: === ✅ Active product parsed: 2 (isActive: true) ===
flutter: === ✅ Active product parsed: 돼지갈비 (isActive: true) ===
flutter: === ✅ Active product parsed: 1 (isActive: true) ===
flutter: === ✅ Active product parsed: 양파 (isActive: true) ===
flutter: === 📋 Final active products list: 5 items ===
flutter: === 📦 Loaded 5 products for seller: uzcUcuE12wRZYjnceNKYHgLPjVR2 ===
flutter: === Product: 돼지갈비 - 0원 (Active: true) ===
flutter: === Product: 생장어 - 0원 (Active: true) ===
flutter: === Product: 양파 - 0원 (Active: true) ===
flutter: === Product: 1 - 0원 (Active: true) ===
flutter: === Product: 2 - 1원 (Active: true) ===

2. 구매자로 로그인시 홈화면에서 '연결된 판매자' 컨테이너에서 주문하기를 누르면 새로운 화면으로 넘어가는데 그러지말고 '주문탭' 으로 이동시키는게 나을거같아.
   - 현재 주문하는 경로가 두군데고 ui 가 달라서 헷갈려. 하나로 통일합시다. 
   - 주문탭에서 주문할 경우 -/+ 기능은 매우 훌륭해 단 간격을 살짝만 더 늘려줬으면 좋겠고 -버튼은 빨간색, +버튼은 파랑색으로 표기했으면해
   - 또한 수량칸을 터치시에 직접 입력도 할 수 있게 해줬으면 좋겠어.

3. 판매자로 로그인시 '연결' 탭에서 보이는 화면에서 '구매자 연결 관리' 는 필요없는 문구야. 해당 문구는 삭제하고 아래 내용들을 위로 올려. 그리고 '대기중인 요청' 아래 박스를 중앙으로 정렬시켜줘.ㅊ
4. 판매자로 로그인시 최근 주문이 없는 경우 아래 박스를 중앙정렬 시켜주고.