
# UI/UX 가이드: 수동 편집용

이 문서는 Order Market App의 UI/UX를 디자이너나 개발자가 **수동으로 수정**하는 것을 돕기 위해 작성되었습니다. AI가 생성한 코드의 특정 디자인 요소를 쉽게 찾고 변경할 수 있도록 안내합니다.

## 📂 주요 UI 파일 경로

- **글로벌 테마 (색상, 폰트, 버튼 스타일 등):**
  - `lib/app/core/theme/app_theme.dart`
- **색상 팔레트:**
  - `lib/app/core/theme/app_colors.dart`
- **화면(View)별 UI 코드:**
  - `lib/app/presentation/views/`
- **화면(View)과 연결된 상태 관리 로직 (Controller):**
  - `lib/app/presentation/controllers/`

---

## 🎨 1. 색상 (Colors)

앱의 주요 색상은 `AppColors` 클래스에 정의되어 있습니다. 색상을 변경하려면 이 파일을 수정하세요.

- **파일 위치:** `lib/app/core/theme/app_colors.dart`
- **주요 색상:**
  - `primary`: 앱의 핵심 색상 (버튼, 강조 표시 등)
  - `surface`: 카드, 앱바 등 표면 색상
  - `background`: 화면 배경색
  - `textPrimary`: 기본 텍스트 색상
  - `textSecondary`: 보조 텍스트 색상
  - `textHint`: 입력 필드 힌트 텍스트 색상
  - `error`: 오류 상태를 나타내는 색상

**수정 방법:**
`app_colors.dart` 파일에서 원하는 `Color` 값을 변경하면 앱 전체에 반영됩니다.

```dart
// lib/app/core/theme/app_colors.dart

class AppColors {
  static const Color primary = Color(0xFF4A90E2); // 이 값을 수정
  // ... 다른 색상들
}
```

---

## 📝 2. 폰트 및 텍스트 스타일 (Typography)

앱의 모든 텍스트 스타일(크기, 굵기, 글꼴)은 `AppTheme`의 `textTheme`에 정의되어 있습니다. `Google Fonts`의 `Inter` 폰트를 사용 중입니다.

- **파일 위치:** `lib/app/core/theme/app_theme.dart`
- **수정 대상:** `lightTheme` 내부의 `textTheme`

**주요 텍스트 스타일:**
- `headlineLarge`: 가장 큰 제목 (e.g., 24px, Bold)
- `headlineMedium`: 중간 제목 (e.g., 20px, SemiBold)
- `bodyLarge`: 본문 텍스트 (e.g., 16px, Regular)
- `bodyMedium`: 기본 본문 텍스트 (e.g., 14px, Regular)
- `labelLarge`: 버튼 내부 텍스트 (e.g., 14px, Medium)

**수정 방법:**
`app_theme.dart`에서 `textTheme`의 각 스타일(`fontSize`, `fontWeight` 등)을 직접 수정합니다.

```dart
// lib/app/core/theme/app_theme.dart

textTheme: GoogleFonts.interTextTheme().copyWith(
  headlineLarge: GoogleFonts.inter(
    fontSize: 26, // 폰트 크기 수정
    fontWeight: FontWeight.w900, // 굵기 수정
    color: AppColors.textPrimary,
  ),
  // ... 다른 텍스트 스타일
),
```

---

## 📏 3. 간격 및 레이아웃 (Spacing)

일관된 간격을 위해 `AppTheme`에 정적 변수로 간격 값을 정의했습니다. 패딩(Padding), 마진(Margin) 등에 이 값을 사용합니다.

- **파일 위치:** `lib/app/core/theme/app_theme.dart`
- **정의된 값:**
  - `AppTheme.small` (8.0)
  - `AppTheme.medium` (16.0)
  - `AppTheme.large` (24.0)
  - `AppTheme.xlarge` (32.0)

**사용 예시:**
`Padding` 위젯이나 `SizedBox`를 사용할 때 이 변수들을 활용하면 일관성을 유지하기 쉽습니다.

```dart
// 예시: lib/app/presentation/views/some_view.dart
Padding(
  padding: const EdgeInsets.all(AppTheme.medium), // 16.0
  child: Text('Hello'),
)
```

---

## 🧩 4. 주요 UI 컴포넌트 (Components)

자주 사용되는 위젯들의 기본 스타일은 `AppTheme`에 정의되어 있습니다.

### 버튼 (ElevatedButton)
- **스타일 위치:** `app_theme.dart` > `elevatedButtonTheme`
- **수정 가능 항목:** 배경색(`backgroundColor`), 텍스트 색상(`foregroundColor`), 모서리 둥글기(`borderRadius`), 패딩(`padding`) 등

### 입력 필드 (TextField / TextFormField)
- **스타일 위치:** `app_theme.dart` > `inputDecorationTheme`
- **수정 가능 항목:** 배경색(`fillColor`), 테두리 스타일(`border`), 포커스 됐을 때 테두리(`focusedBorder`), 힌트 텍스트 스타일(`hintStyle`) 등

### 카드 (Card)
- **스타일 위치:** `app_theme.dart` > `cardTheme`
- **수정 가능 항목:** 배경색(`color`), 그림자(`elevation`), 모서리 둥글기(`shape`) 등

### 앱바 (AppBar)
- **스타일 위치:** `app_theme.dart` > `appBarTheme`
- **수정 가능 항목:** 배경색(`backgroundColor`), 제목 스타일(`titleTextStyle`), 아이콘 색상(`foregroundColor`) 등

---

## 🖼️ 5. 화면별 UI 코드 위치

개별 화면의 UI 코드는 `lib/app/presentation/views/` 디렉토리 아래에 각 기능별로 폴더로 정리되어 있습니다. 예를 들어, 로그인 화면은 `login/login_view.dart` 와 같은 형식으로 찾을 수 있습니다.

- **탐색 경로:** `lib/app/presentation/views/{feature_name}/{feature_name}_view.dart`

**예시:**
- `home_view.dart`: 앱의 메인 화면
- `login_view.dart`: 로그인 UI
- `product_details_view.dart`: 상품 상세 정보 화면

화면의 특정 버튼이나 텍스트를 수정하고 싶다면, 먼저 이 디렉토리에서 관련 파일을 찾으세요. 그런 다음, 해당 파일 내에서 `Theme.of(context).textTheme.headlineLarge` 와 같이 `AppTheme`에 정의된 스타일을 사용하는 코드를 찾아 수정하면 됩니다.


# 🚨 신규가입 및 로그인 후 잘못된 사용자 뷰 진입 관련 문제

## 🧩 현재 발견된 문제점

1. 신규 회원가입 시 역할 분기 오류
   - 회원가입 화면에서 구매자/판매자 선택 후 가입을 완료함.
   - 하지만 판매자로 가입했음에도 불구하고, 가입 직후 이동되는 뷰가 판매자 홈 화면이 아님.
   - 예상치 못한 뷰로 이동하고 있음.

2. 재로그인 시 사용자 역할 반영 오류
   - 판매자로 회원가입한 계정으로 로그인했음에도 불구하고, 구매자 홈 화면이 출력됨.
   - 반대로, 구매자로 가입한 후 로그인했을 때도 판매자 화면이 뜨는 등 역할 기반 분기가 동작하지 않음.
   - 회원가입시 구매자/판매자 를 선택하게 되어있는데 이게 제대로 반영이 안된듯.

3. 위 상황은 가입 직후, 그리고 로그아웃 → 재로그인 시에도 반복적으로 발생함.
   - 이로 인해 사용자 입장에서 시스템 혼란 및 신뢰도 문제 우려됨.

---

## ✅ 지시사항

1. 가입 직후 리디렉션되는 화면이 사용자 역할에 따라 정확하게 분기되도록 수정할 것.
   - 판매자 → 판매자 홈 화면
   - 구매자 → 구매자 홈 화면
   - 불분명한 공통 뷰로 이동되는 것 방지

2. 로그인 이후에도 role 기반 분기가 정확히 동작하는지 확인하고 로직을 개선할 것.
   - user.role 또는 유사한 필드를 통해 사용자 유형을 판별
   - 초기 로딩(Splash 등)에서도 역할 기반 홈 진입이 이뤄지도록 구성

3. 위 사항은 구매자/판매자 모두 동일하게 적용되어야 함.
   - 로직 중 어디서 role 값이 누락되거나 잘못 처리되고 있는지 점검 필요

4. 회원 가입시 판매자 / 구매자 둘 중 하나를 선택하게 되어있는데 선택한 role 에 대한게 회원가입 db 에 정확히 반영되는지 점검 필요.
