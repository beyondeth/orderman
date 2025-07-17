import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/toss_design_system.dart';

class TossCalendarWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime? startDate, DateTime? endDate) onDateRangeSelected;
  final bool isRangeSelection;

  const TossCalendarWidget({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
    this.isRangeSelection = true,
  });

  @override
  State<TossCalendarWidget> createState() => _TossCalendarWidgetState();
}

class _TossCalendarWidgetState extends State<TossCalendarWidget> {
  late DateTime _focusedDay;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedStartDate = widget.initialStartDate;
    _selectedEndDate = widget.initialEndDate;
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TossDesignSystem.surface,
        borderRadius: BorderRadius.circular(TossDesignSystem.radius20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          _buildHeader(),

          // 캘린더
          _buildCalendar(),

          // 선택된 날짜 표시 및 액션 버튼
          _buildFooter(),
        ],
      ),
    );
  }

  /// 헤더 (제목과 닫기 버튼)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TossDesignSystem.gray200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.isRangeSelection ? '기간 선택' : '날짜 선택',
            style: TossDesignSystem.heading4,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: TossDesignSystem.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더 위젯
  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      child: Column(
        children: [
          // 커스텀 월/년 헤더
          _buildCustomHeader(),

          const SizedBox(height: TossDesignSystem.spacing16),

          // 커스텀 요일 헤더
          _buildDaysOfWeekHeader(),

          const SizedBox(height: TossDesignSystem.spacing8),

          // 캘린더 본체
          TableCalendar<dynamic>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,

            // 요일 시작을 월요일로 설정
            startingDayOfWeek: StartingDayOfWeek.monday,

            // 선택 모드
            rangeSelectionMode:
                widget.isRangeSelection
                    ? RangeSelectionMode.toggledOn
                    : RangeSelectionMode.toggledOff,

            // 선택된 날짜들
            selectedDayPredicate: (day) {
              if (widget.isRangeSelection) {
                return false; // 범위 선택 모드에서는 개별 선택 비활성화
              }
              return isSameDay(_selectedStartDate, day);
            },

            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,

            // 이벤트 콜백
            onDaySelected:
                widget.isRangeSelection
                    ? null
                    : (selectedDay, focusedDay) {
                      setState(() {
                        _selectedStartDate = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      widget.onDateRangeSelected(selectedDay, null);
                    },

            onRangeSelected:
                widget.isRangeSelection
                    ? (start, end, focusedDay) {
                      setState(() {
                        _rangeStart = start;
                        _rangeEnd = end;
                        _focusedDay = focusedDay;
                      });
                      widget.onDateRangeSelected(start, end);
                    }
                    : null,

            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },

            // 토스 스타일 커스터마이징
            calendarStyle: CalendarStyle(
              // 기본 스타일
              outsideDaysVisible: false,
              weekendTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.textPrimary,
              ),
              holidayTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.error,
              ),

              // 선택된 날짜 스타일
              selectedDecoration: const BoxDecoration(
                color: TossDesignSystem.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TossDesignSystem.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),

              // 오늘 날짜 스타일
              todayDecoration: BoxDecoration(
                color: TossDesignSystem.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: TossDesignSystem.primary, width: 1),
              ),
              todayTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.primary,
                fontWeight: FontWeight.w600,
              ),

              // 범위 선택 스타일
              rangeStartDecoration: const BoxDecoration(
                color: TossDesignSystem.primary,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: TossDesignSystem.primary,
                shape: BoxShape.circle,
              ),
              rangeHighlightColor: TossDesignSystem.primary.withOpacity(0.1),
              withinRangeDecoration: BoxDecoration(
                color: TossDesignSystem.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              withinRangeTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.primary,
                fontWeight: FontWeight.w500,
              ),

              // 기본 날짜 스타일
              defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
              defaultTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.textPrimary,
              ),

              // 비활성 날짜 스타일
              disabledTextStyle: TossDesignSystem.body2.copyWith(
                color: TossDesignSystem.textTertiary,
              ),

              // 마커 스타일
              markersMaxCount: 1,
              markerDecoration: const BoxDecoration(
                color: TossDesignSystem.secondary,
                shape: BoxShape.circle,
              ),

              // 셀 패딩
              cellPadding: const EdgeInsets.all(6),
              cellMargin: const EdgeInsets.all(4),
            ),

            // 헤더 스타일 (월/년 표시 - 숨김 처리)
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 0,
                height: 0,
                color: Colors.transparent,
              ),
              headerPadding: EdgeInsets.zero,
              headerMargin: EdgeInsets.zero,
            ),

            // 요일 헤더 스타일 (daysOfWeekBuilder로 처리하므로 숨김)
            daysOfWeekVisible: false,
          ),
        ],
      ),
    );
  }

  /// 커스텀 월/년 헤더 위젯 (한글화)
  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TossDesignSystem.spacing4,
        vertical: TossDesignSystem.spacing8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 이전 달 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month - 1,
                  1,
                );
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: TossDesignSystem.textSecondary,
                size: 20,
              ),
            ),
          ),

          // 월/년 표시 (한글)
          Text(
            _getKoreanMonthYear(_focusedDay),
            style: TossDesignSystem.heading4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // 다음 달 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedDay = DateTime(
                  _focusedDay.year,
                  _focusedDay.month + 1,
                  1,
                );
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TossDesignSystem.gray100,
                borderRadius: BorderRadius.circular(TossDesignSystem.radius8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: TossDesignSystem.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 한글 월/년 형식으로 변환
  String _getKoreanMonthYear(DateTime date) {
    const months = [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];

    return '${date.year}년 ${months[date.month - 1]}';
  }

  /// 한글 요일 헤더 위젯
  Widget _buildDaysOfWeekHeader() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: TossDesignSystem.spacing8),
      child: Row(
        children:
            weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  /// 푸터 (선택된 날짜 표시 및 버튼)
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(TossDesignSystem.spacing20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: TossDesignSystem.gray200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 선택된 날짜 표시
          if (widget.isRangeSelection) ...[
            _buildSelectedRangeDisplay(),
          ] else ...[
            _buildSelectedDateDisplay(),
          ],

          const SizedBox(height: TossDesignSystem.spacing16),

          // 액션 버튼들
          Row(
            children: [
              // 초기화 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetSelection,
                  style: TossDesignSystem.outlineButton,
                  child: Text(
                    '초기화',
                    style: TossDesignSystem.button.copyWith(
                      color: TossDesignSystem.textPrimary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: TossDesignSystem.spacing12),

              // 확인 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: _hasValidSelection() ? _confirmSelection : null,
                  style: TossDesignSystem.primaryButton,
                  child: Text(
                    '확인',
                    style: TossDesignSystem.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 선택된 범위 표시
  Widget _buildSelectedRangeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '시작일',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      _rangeStart != null
                          ? DateFormat('yyyy.MM.dd').format(_rangeStart!)
                          : '선택해주세요',
                      style: TossDesignSystem.body1.copyWith(
                        color:
                            _rangeStart != null
                                ? TossDesignSystem.textPrimary
                                : TossDesignSystem.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 20,
                height: 1,
                color: TossDesignSystem.gray300,
                margin: const EdgeInsets.symmetric(
                  horizontal: TossDesignSystem.spacing12,
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '종료일',
                      style: TossDesignSystem.caption.copyWith(
                        color: TossDesignSystem.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TossDesignSystem.spacing4),
                    Text(
                      _rangeEnd != null
                          ? DateFormat('yyyy.MM.dd').format(_rangeEnd!)
                          : '선택해주세요',
                      style: TossDesignSystem.body1.copyWith(
                        color:
                            _rangeEnd != null
                                ? TossDesignSystem.textPrimary
                                : TossDesignSystem.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 선택된 단일 날짜 표시
  Widget _buildSelectedDateDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TossDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: TossDesignSystem.gray50,
        borderRadius: BorderRadius.circular(TossDesignSystem.radius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선택된 날짜',
            style: TossDesignSystem.caption.copyWith(
              color: TossDesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: TossDesignSystem.spacing4),
          Text(
            _selectedStartDate != null
                ? DateFormat('yyyy년 MM월 dd일').format(_selectedStartDate!)
                : '날짜를 선택해주세요',
            style: TossDesignSystem.body1.copyWith(
              color:
                  _selectedStartDate != null
                      ? TossDesignSystem.textPrimary
                      : TossDesignSystem.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 선택 초기화
  void _resetSelection() {
    setState(() {
      if (widget.isRangeSelection) {
        _rangeStart = null;
        _rangeEnd = null;
      } else {
        _selectedStartDate = null;
      }
    });
    widget.onDateRangeSelected(null, null);
  }

  /// 유효한 선택이 있는지 확인
  bool _hasValidSelection() {
    if (widget.isRangeSelection) {
      return _rangeStart != null && _rangeEnd != null;
    } else {
      return _selectedStartDate != null;
    }
  }

  /// 선택 확인
  void _confirmSelection() {
    if (widget.isRangeSelection) {
      widget.onDateRangeSelected(_rangeStart, _rangeEnd);
    } else {
      widget.onDateRangeSelected(_selectedStartDate, null);
    }
    Navigator.of(context).pop();
  }
}
