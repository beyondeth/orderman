# 코드 변경사항 요약

## 1. 로그인 버튼 두 번 눌러야 하는 현상 해결

### 문제 원인
- 로그인 버튼을 클릭했을 때 `isLoading` 상태가 변경되기 전에 사용자가 다시 버튼을 클릭할 수 있어 로그인 메서드가 두 번 호출되는 문제

### 해결 방법
1. 디바운스 로직 추가 (LoginController)
```dart
// 디바운스 타이머
Timer? _loginDebounce;

// Email login with debounce
void loginWithEmail() {
  // 이미 로딩 중이면 중복 호출 방지
  if (isLoading.value) return;
  
  // 폼 검증
  if (!formKey.currentState!.validate()) return;
  
  // 디바운스 처리
  _loginDebounce?.cancel();
  _loginDebounce = Timer(const Duration(milliseconds: 300), () {
    _performLogin();
  });
}
```

2. 버튼 클릭 시 즉시 시각적 피드백 제공 (LoginView)
```dart
ElevatedButton(
  onPressed: controller.isLoading.value ? null : () {
    // 버튼 클릭 시 즉시 시각적 피드백 제공
    FocusScope.of(Get.context!).unfocus(); // 키보드 닫기
    controller.loginWithEmail();
  },
  style: ElevatedButton.styleFrom(
    disabledBackgroundColor: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.6),
    disabledForegroundColor: Colors.white70,
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: controller.isLoading.value
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : const Text('로그인', style: TextStyle(fontSize: 16)),
)
```

## 2. 주문 수량 입력 UX 문제 해결

### 문제 원인
- 수량 입력 TextField에서 매번 상태가 변경될 때마다 새로운 `TextEditingController`가 생성되어 커서 위치가 초기화되는 문제
- 이로 인해 사용자가 숫자를 입력하는 도중에 커서가 사라지거나 처음으로 돌아가는 문제 발생

### 해결 방법
1. 공통 위젯 생성 (QuantityInputField)
```dart
class _QuantityInputFieldState extends State<QuantityInputField> {
  late TextEditingController _controller;
  int _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.initialValue;
    _controller = TextEditingController(
      text: widget.initialValue > 0 ? widget.initialValue.toString() : '',
    );
  }

  @override
  void didUpdateWidget(QuantityInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 값이 변경되었고, 현재 컨트롤러의 값과 다른 경우에만 업데이트
    if (widget.initialValue != _lastValue) {
      final currentPosition = _controller.selection.start;
      final textLength = _controller.text.length;
      
      _lastValue = widget.initialValue;
      _controller.text = widget.initialValue > 0 ? widget.initialValue.toString() : '';
      
      // 커서 위치 유지 로직
      if (currentPosition >= 0 && _controller.text.isNotEmpty) {
        final newPosition = currentPosition > _controller.text.length 
            ? _controller.text.length 
            : currentPosition;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: newPosition),
        );
      }
    }
  }
}
```

2. 수량 조절 버튼 개선 (QuantityControlButtons)
```dart
class _QuantityControlButtonsState extends State<QuantityControlButtons> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _decreaseQuantity(),
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.red,
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
        _buildQuantityDisplay(),
        IconButton(
          onPressed: () => _increaseQuantity(),
          icon: const Icon(Icons.add_circle_outline),
          color: Colors.blue,
          iconSize: 24,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityDisplay() {
    if (_isEditing || !widget.allowDirectInput) {
      return GestureDetector(
        onTap: () {
          if (widget.allowDirectInput && !_isEditing) {
            setState(() {
              _isEditing = true;
            });
          }
        },
        child: Container(
          width: 50,
          alignment: Alignment.center,
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  onSubmitted: (value) {
                    final newQuantity = int.tryParse(value) ?? 0;
                    widget.onChanged(widget.productId, newQuantity);
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  onTapOutside: (_) {
                    final newQuantity = int.tryParse(_controller.text) ?? 0;
                    widget.onChanged(widget.productId, newQuantity);
                    setState(() {
                      _isEditing = false;
                    });
                  },
                )
              : Text(
                  widget.quantity.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (widget.allowDirectInput) {
            setState(() {
              _isEditing = true;
            });
          }
        },
        child: Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            widget.quantity.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }
}
```

## 3. 구매자 홈화면 주문하기 버튼 기능 개선

### 문제 원인
- 구매자 홈화면에서 '연결된 판매자' 컨테이너의 주문하기 버튼을 눌렀을 때 새로운 화면으로 넘어가서 UI가 달라 사용자 혼란 발생

### 해결 방법
- 주문하기 버튼 클릭 시 주문 탭으로 이동하도록 수정 (SellerConnectController)
```dart
// 주문 화면으로 이동 (주문 탭으로 이동하도록 수정)
void goToOrder(ConnectionModel connection) {
  try {
    // MainController를 통해 주문 탭으로 이동
    final mainController = Get.find<MainController>();
    
    // 선택한 판매자 정보를 MainController에 설정
    mainController.setActiveConnection(connection);
    
    // 주문 탭으로 이동
    mainController.changeTab(1);
    
    print('=== 주문 탭으로 이동: ${connection.sellerName} ===');
  } catch (e) {
    print('=== 주문 탭 이동 오류: $e ===');
    
    // 폴백: 기존 방식으로 주문 화면으로 이동
    Get.toNamed(
      AppRoutes.orderCreate,
      arguments: {
        'connection': connection,
        'sellerId': connection.sellerId,
      },
    );
  }
}
```

## 4. BuyerHomeController에 selectProduct 메서드 추가

### 문제 원인
- `BuyerHomeController`에 `selectProduct` 메서드가 정의되어 있지 않아 오류 발생

### 해결 방법
- `BuyerHomeController`에 `selectProduct` 메서드 추가
```dart
// 특정 수량으로 직접 설정
void selectProduct(String productId, int quantity) {
  if (quantity > 0) {
    selectedProducts[productId] = true;
    productQuantities[productId] = quantity;
  } else {
    selectedProducts[productId] = false;
    productQuantities.remove(productId);
  }
}
```

## 5. 판매자 앱 UI 개선

### 문제 원인
- 판매자 앱의 연결 탭에서 '구매자 연결 관리' 문구가 불필요하고 레이아웃이 비효율적
- 판매자 앱 홈 화면에서 최근 주문이 없는 경우 박스가 중앙 정렬되지 않음

### 해결 방법
1. 판매자 앱 연결 탭 UI 개선
```dart
// 헤더 정보 - 간소화된 버전
Widget _buildHeader(BuildContext context) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            color: Theme.of(context).primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '구매자 연결 요청',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '구매자들의 연결 요청을 승인하거나 거절할 수 있습니다.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

2. 판매자 앱 홈 화면 빈 주문 상태 중앙 정렬
```dart
/// 빈 주문 상태
Widget _buildEmptyOrdersState() {
  return Center(
    child: TossWidgets.surfaceCard(
      padding: const EdgeInsets.all(TossDesignSystem.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(TossDesignSystem.radius16),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 32,
              color: TossDesignSystem.gray400,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing16),
          Text(
            '오늘 들어온 주문이 없어요',
            style: TossDesignSystem.body1.copyWith(
              color: TossDesignSystem.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing8),
          Text(
            '새로운 주문이 들어오면 알려드릴게요',
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
```
