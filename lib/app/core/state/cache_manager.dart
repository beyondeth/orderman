import 'dart:async';

/// 타입 안전한 메모리 캐시 매니저
class CacheManager {
  static final Map<String, _CacheEntry> _cache = {};
  static Timer? _cleanupTimer;

  /// 캐시에서 값 가져오기
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    // 만료 확인
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    // 타입 안전성 확인
    if (entry.value is! T) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value as T;
  }

  /// 캐시에 값 저장
  void set<T>(String key, T value, {Duration? ttl}) {
    final expiresAt = ttl != null 
        ? DateTime.now().add(ttl)
        : null;
    
    _cache[key] = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    
    _startCleanupTimer();
  }

  /// 특정 키 제거
  void remove(String key) {
    _cache.remove(key);
  }

  /// 모든 캐시 클리어
  void clearAll() {
    _cache.clear();
  }

  /// 만료된 캐시 클리어
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// 특정 패턴의 키들 제거
  void removeByPattern(String pattern) {
    final regex = RegExp(pattern);
    _cache.removeWhere((key, entry) => regex.hasMatch(key));
  }

  /// 캐시 크기 반환
  int get size => _cache.length;

  /// 캐시가 비어있는지 확인
  bool get isEmpty => _cache.isEmpty;

  /// 캐시에 키가 존재하는지 확인 (만료되지 않은 경우만)
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// 캐시 통계 정보
  CacheStats get stats {
    final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;
    
    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }
    
    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
    );
  }

  /// 정리 타이머 시작
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => clearExpired(),
    );
  }

  /// 정리 타이머 중지
  static void stopCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}

/// 캐시 엔트리 클래스
class _CacheEntry {
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const _CacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration get age => DateTime.now().difference(createdAt);
}

/// 캐시 통계 정보
class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;

  const CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  double get hitRate {
    if (totalEntries == 0) return 0.0;
    return validEntries / totalEntries;
  }

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
  }
}

/// 캐시 키 생성 헬퍼
class CacheKeys {
  static const String _separator = '_';
  
  static String user(String userId) => 'user$_separator$userId';
  static String connections(String userId) => 'connections$_separator$userId';
  static String orders(String userId) => 'orders$_separator$userId';
  static String products(String sellerId) => 'products$_separator$sellerId';
  static String sellerProducts(String sellerId, String buyerId) => 
      'seller_products$_separator${sellerId}$_separator$buyerId';
  
  // 패턴 매칭용
  static String userPattern(String userId) => 'user$_separator$userId.*';
  static String connectionsPattern(String userId) => 'connections$_separator$userId.*';
  static String ordersPattern(String userId) => 'orders$_separator$userId.*';
  static String productsPattern(String sellerId) => 'products$_separator$sellerId.*';
}

/// 캐시 전략 열거형
enum CacheStrategy {
  /// 캐시 우선 - 캐시에 있으면 캐시 사용, 없으면 네트워크
  cacheFirst,
  /// 네트워크 우선 - 네트워크 시도 후 실패하면 캐시 사용
  networkFirst,
  /// 캐시만 사용 - 캐시에 없으면 null 반환
  cacheOnly,
  /// 네트워크만 사용 - 캐시 무시하고 항상 네트워크
  networkOnly,
}

/// 캐시 전략을 적용한 데이터 로더
class CachedDataLoader {
  final CacheManager _cacheManager;
  
  CachedDataLoader(this._cacheManager);
  
  /// 캐시 전략에 따른 데이터 로드
  Future<T?> load<T>({
    required String cacheKey,
    required Future<T> Function() networkLoader,
    CacheStrategy strategy = CacheStrategy.cacheFirst,
    Duration? cacheTtl,
  }) async {
    switch (strategy) {
      case CacheStrategy.cacheFirst:
        final cached = _cacheManager.get<T>(cacheKey);
        if (cached != null) return cached;
        
        try {
          final networkData = await networkLoader();
          _cacheManager.set(cacheKey, networkData, ttl: cacheTtl);
          return networkData;
        } catch (e) {
          return null;
        }
        
      case CacheStrategy.networkFirst:
        try {
          final networkData = await networkLoader();
          _cacheManager.set(cacheKey, networkData, ttl: cacheTtl);
          return networkData;
        } catch (e) {
          return _cacheManager.get<T>(cacheKey);
        }
        
      case CacheStrategy.cacheOnly:
        return _cacheManager.get<T>(cacheKey);
        
      case CacheStrategy.networkOnly:
        try {
          final networkData = await networkLoader();
          _cacheManager.set(cacheKey, networkData, ttl: cacheTtl);
          return networkData;
        } catch (e) {
          return null;
        }
    }
  }
}
