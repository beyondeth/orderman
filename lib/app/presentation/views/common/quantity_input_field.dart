import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/toss_design_system.dart';

/// 수량 입력 필드 위젯
/// 
/// 커서 위치를 유지하면서 수량을 입력할 수 있는 커스텀 위젯
class QuantityInputField extends StatefulWidget {
  final String productId;
  final int initialValue;
  final bool enabled;
  final Function(String, int) onChanged;
  final bool useTossDesign;

  const QuantityInputField({
    super.key,
    required this.productId,
    required this.initialValue,
    required this.enabled,
    required this.onChanged,
    this.useTossDesign = false,
  });

  @override
  State<QuantityInputField> createState() => _QuantityInputFieldState();
}

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useTossDesign) {
      return TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: widget.enabled ? '0' : '-',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
            borderSide: const BorderSide(color: TossDesignSystem.gray300),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.spacing8,
            vertical: TossDesignSystem.spacing8,
          ),
          filled: !widget.enabled,
          fillColor: !widget.enabled 
              ? TossDesignSystem.gray100
              : null,
        ),
        onChanged: (value) {
          final newQuantity = int.tryParse(value) ?? 0;
          _lastValue = newQuantity;
          widget.onChanged(widget.productId, newQuantity);
        },
      );
    } else {
      return TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: widget.enabled ? '0' : '-',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          filled: !widget.enabled,
          fillColor: !widget.enabled 
              ? Get.theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : null,
        ),
        onChanged: (value) {
          final newQuantity = int.tryParse(value) ?? 0;
          _lastValue = newQuantity;
          widget.onChanged(widget.productId, newQuantity);
        },
      );
    }
  }
}

/// 수량 조절 버튼 위젯
/// 
/// +/- 버튼으로 수량을 조절할 수 있는 커스텀 위젯
class QuantityControlButtons extends StatefulWidget {
  final String productId;
  final int quantity;
  final Function(String, int) onChanged;
  final bool useTossDesign;
  final bool allowDirectInput;

  const QuantityControlButtons({
    super.key,
    required this.productId,
    required this.quantity,
    required this.onChanged,
    this.useTossDesign = false,
    this.allowDirectInput = true,
  });

  @override
  State<QuantityControlButtons> createState() => _QuantityControlButtonsState();
}

class _QuantityControlButtonsState extends State<QuantityControlButtons> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(QuantityControlButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity && !_isEditing) {
      _controller.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useTossDesign) {
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
    } else {
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

  void _increaseQuantity() {
    widget.onChanged(widget.productId, widget.quantity + 1);
  }

  void _decreaseQuantity() {
    if (widget.quantity > 1) {
      widget.onChanged(widget.productId, widget.quantity - 1);
    } else {
      // 수량이 1 이하면 0으로 설정 (선택 해제 처리는 호출자에서)
      widget.onChanged(widget.productId, 0);
    }
  }
}
