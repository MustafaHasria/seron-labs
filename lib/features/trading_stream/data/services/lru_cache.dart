import 'dart:collection';

/// Least Recently Used (LRU) Cache implementation.
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache;

  LRUCache({required this.maxSize})
      : _cache = LinkedHashMap<K, V>();

  /// Get value by key, updating access order.
  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }
    // Move to end (most recently used)
    final value = _cache.remove(key);
    _cache[key] = value!;
    return value;
  }

  /// Put value by key, updating access order.
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing: remove and re-add to end
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used (first entry)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Check if key exists without updating access order.
  bool containsKey(K key) => _cache.containsKey(key);

  /// Clear all entries.
  void clear() => _cache.clear();

  /// Get current size.
  int get length => _cache.length;
}

