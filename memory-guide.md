
# Flutter 성능 및 메모리 최적화 가이드

이 문서는 Flutter 앱의 성능 저하 및 메모리 누수 문제를 진단하고 해결하기 위한 체계적인 가이드입니다. **Flutter DevTools**를 활용하여 데이터를 기반으로 문제를 분석하고, 단계별로 최적화를 진행합니다.

## 🎯 최종 목표

- 메모리 누수를 찾아 제거하고, 앱의 안정성을 높입니다.
- 불필요한 CPU/GPU 사용을 줄여 앱의 반응성을 개선합니다.
- 부드러운 60fps(또는 그 이상) 렌더링을 유지하여 사용자 경험을 극대화합니다.

---

## 🚀 최적화 프로세스 (단계별 협업 방식)

아래 단계를 순서대로 진행합니다. 각 단계마다 제가 점검 목록과 필요한 데이터 요청을 드리면, 당신은 코드 스니펫이나 DevTools 스크린샷/데이터를 제공해주세요. 데이터를 기반으로 함께 문제를 분석하고 해결책을 찾습니다.

### **Phase 1: 기준선 설정 및 문제 영역 식별**

**목표:** 현재 앱의 성능 기준선을 측정하고, 가장 먼저 개선이 필요한 영역을 식별합니다.

1.  **Flutter DevTools 연결 및 기본 프로파일링:**
    - 앱을 `profile` 모드로 실행합니다. (`flutter run --profile`)
    - DevTools를 열고 **Memory** 탭과 **Performance** 탭을 확인합니다.
2.  **메모리 사용량 관찰:**
    - 앱을 평소처럼 사용하면서 메모리 사용량 그래프의 변화를 관찰합니다.
    - 특정 화면에 진입하거나 특정 기능을 사용할 때 메모리가 급증하는지 확인합니다.
3.  **UI 성능(Jank) 확인:**
    - Performance 탭에서 `Frame Time` 그래프를 확인합니다.
    - 그래프가 빨간색으로 표시되는 부분(Jank)이 자주 발생하는지, 어떤 상황에서 발생하는지 기록합니다.

> **📋 당신의 액션 아이템:**
> 1. 앱을 `profile` 모드로 실행하고 DevTools에 연결해주세요.
> 2. 앱의 여러 화면을 이동하면서 **Memory 탭의 사용량 그래프 스크린샷**을 찍어 공유해주세요.
> 3. Jank가 발생한다면, **Performance 탭의 Frame Time 그래프 스크린샷**을 공유해주세요.

---

### **Phase 2: 메모리 누수 심층 분석**

**목표:** DevTools의 메모리 분석 도구를 사용하여 구체적인 누수 지점을 찾습니다.

1.  **Heap Snapshot 비교 분석:**
    - **(A)** 특정 화면에 들어가기 전, Memory 탭에서 `Take Snapshot`을 눌러 힙 스냅샷을 찍습니다.
    - **(B)** 해당 화면에 들어갔다가 다시 나옵니다. (e.g., 상품 상세 페이지 진입 후 뒤로 가기)
    - **(C)** `GC` 버튼을 눌러 가비지 컬렉션을 수동으로 실행합니다.
    - **(D)** 다시 `Take Snapshot`을 눌러 두 번째 스냅샷을 찍습니다.
    - **(E)** `Diff` 기능을 사용하여 두 스냅샷의 차이를 분석합니다. 화면에서 벗어났음에도 불구하고 해제되지 않은 객체(특히 Controller, Widget, State 등)가 있는지 확인합니다.
2.  **Listener 및 Controller 누수 확인:**
    - `StreamSubscription`, `AnimationController`, `TextEditingController` 등 `dispose`가 필요한 객체들이 `StatefulWidget`의 `dispose` 메서드에서 올바르게 해제되고 있는지 코드 리뷰를 진행합니다.
    - GetX 사용 시: `GetxController`의 `onClose()` 메서드에서 리소스를 정리하는지 확인합니다.

> **📋 당신의 액션 아이템:**
> 1. 메모리 누수가 의심되는 화면을 대상으로 **Heap Snapshot Diff 분석 결과**를 공유해주세요. (특히 해제되지 않은 클래스 목록)
> 2. 해당 화면의 `StatefulWidget` 코드(특히 `initState`와 `dispose` 부분)와 `GetxController` 코드를 공유해주세요.

---

### **Phase 3: 비동기 처리 및 상태 관리 최적화**

**목표:** 불필요한 비동기 작업과 위젯 리빌드를 줄여 CPU 사용량을 최적화합니다.

1.  **CPU Profiler 사용:**
    - Performance 탭에서 `CPU Profiler`를 사용하여 어떤 메서드가 CPU 시간을 많이 소모하는지 분석합니다. (특히 `build` 메서드)
2.  **과도한 `setState` / `update` 호출 분석:**
    - `Performance Overlay`를 활성화하여 어떤 위젯이 불필요하게 자주 리빌드되는지 시각적으로 확인합니다.
    - GetX 사용 시: `Obx` 또는 `GetBuilder`가 감싸는 위젯의 범위를 최소화하여 불필요한 리빌드를 방지하고 있는지 확인합니다.
3.  **비동기 작업 관리:**
    - `Future`, `Stream`, `Timer` 등이 화면 이탈 후에도 계속 실행되고 있는지 확인합니다. `StreamSubscription`은 반드시 `cancel()` 처리가 필요합니다.

> **📋 당신의 액션 아이템:**
> 1. CPU 사용량이 높은 화면의 **CPU Profiler 분석 결과 (Flame Chart)**를 공유해주세요.
> 2. 불필요한 리빌드가 의심되는 위젯의 코드와 `GetxController`의 관련 로직을 공유해주세요.

---

### **Phase 4: 렌더링 및 위젯 구조 최적화**

**목표:** 위젯 트리를 최적화하고 렌더링 비용을 줄여 부드러운 UI를 구현합니다.

1.  **위젯 리빌드 최소화:**
    - `const` 키워드를 최대한 활용하여 불필요한 위젯 생성을 방지합니다.
    - 상태가 변경되는 부분만 최소한의 위젯으로 감싸 리빌드 범위를 줄입니다. (e.g., `Obx`의 범위를 최소화)
2.  **비용이 큰 위젯 사용 최적화:**
    - `Opacity`, `ClipRRect`, `ShaderMask` 등 렌더링 비용이 비싼 위젯의 사용을 최소화하거나, `RepaintBoundary`를 사용하여 렌더링 영역을 격리합니다.
3.  **이미지 최적화:**
    - 표시될 크기보다 과도하게 큰 이미지를 사용하고 있지 않은지 확인합니다.
    - `cacheWidth`와 `cacheHeight` 속성을 사용하여 이미지 캐시 크기를 조절합니다.

> **📋 당신의 액션 아이템:**
> 1. `Performance Overlay`에서 리빌드가 자주 일어나는 위젯의 코드를 공유해주세요.
> 2. 렌더링이 느리다고 느껴지는 화면의 위젯 트리 구조를 설명해주시거나 관련 코드를 공유해주세요.

---

## 📚 추천 패턴 및 주의사항

- **리소스 해제:** `StatefulWidget`의 `dispose` 메서드, `GetxController`의 `onClose` 메서드를 적극적으로 활용하여 컨트롤러, 리스너, 구독 등을 반드시 해제하세요.
- **상태 관리:** 상태 변경이 UI의 특정 부분에만 영향을 미치도록 상태 관리 로직을 설계하세요. (e.g., GetX에서 ID를 사용한 `update()` 호출)
- **지연 로딩(Lazy Loading):** `ListView.builder` 등을 사용하여 화면에 보이지 않는 위젯은 생성하지 않도록 합니다.
