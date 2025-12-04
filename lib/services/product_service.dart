import 'dart:math';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Product {
  String id;
  String name;
  String description;
  double price; // selling price (LKR)
  double cost; // buying price (LKR)
  List<String> images; // local file paths
  double soldPerMonth; // kg sold per month
  double boughtPerMonth; // kg bought per month
  double currentStock; // available stock in kg
  DateTime createdAt; // when product was added

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    List<String>? images,
    this.soldPerMonth = 0.0,
    this.boughtPerMonth = 0.0,
    this.currentStock = 0.0,
    DateTime? createdAt,
  }) : images = images ?? [],
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'cost': cost,
    'images': images,
    'soldPerMonth': soldPerMonth,
    'boughtPerMonth': boughtPerMonth,
    'currentStock': currentStock,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> m) => Product(
    id: m['id'] as String,
    name: m['name'] as String,
    description: m['description'] as String,
    price: (m['price'] as num).toDouble(),
    cost: (m['cost'] as num).toDouble(),
    images: (m['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    soldPerMonth: (m['soldPerMonth'] as num?)?.toDouble() ?? 0.0,
    boughtPerMonth: (m['boughtPerMonth'] as num?)?.toDouble() ?? 0.0,
    currentStock: (m['currentStock'] as num?)?.toDouble() ?? 0.0,
    createdAt: m['createdAt'] != null
        ? DateTime.parse(m['createdAt'] as String)
        : DateTime.now(),
  );
}

class ProductService {
  static final List<Product> _products = [];
  static const String _storageKey = 'products_v1';

  // Initialize from local storage. Call once on app/page start.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        _products.clear();
        for (final e in list) {
          try {
            _products.add(Product.fromJson(e as Map<String, dynamic>));
          } catch (_) {
            // ignore malformed entries
          }
        }
      }
    } catch (_) {
      // ignore storage errors
    }
  }

  static Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_products.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // ignore save errors
    }
  }

  static List<Product> getProducts() => List.unmodifiable(_products);

  static void addProduct(Product p) {
    _products.insert(0, p);
    _saveToStorage();
  }

  static void updateProduct(String id, Product updated) {
    final idx = _products.indexWhere((e) => e.id == id);
    if (idx != -1) _products[idx] = updated;
    _saveToStorage();
  }

  static void deleteProduct(String id) {
    _products.removeWhere((e) => e.id == id);
    _saveToStorage();
  }

  // Totals in LKR
  static double totalSelling() {
    final months = monthlyIncome();
    return months.fold(0.0, (a, b) => a + b);
  }

  static double totalBuying() {
    final months = monthlyOutcome();
    return months.fold(0.0, (a, b) => a + b);
  }

  // Monthly breakdown (12 months). Income = selling revenue per month; outcome = buying cost per month.
  // Returns a list of 12 values representing the last 12 calendar months (oldest->newest)
  static List<double> monthlyIncome() {
    final months = List<double>.filled(12, 0.0);
    if (_products.isEmpty) return months;

    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      // compute month start for (now - (11 - i)) so index 11 is current month
      final monthOffset = i - 11;
      final monthDate = DateTime(now.year, now.month + monthOffset, 1);
      for (final p in _products) {
        // include product only if it existed at this month
        if (!p.createdAt.isAfter(
          DateTime(monthDate.year, monthDate.month + 1, 0),
        )) {
          months[i] += p.price * p.soldPerMonth;
        }
      }
    }
    return months;
  }

  static List<double> monthlyOutcome() {
    final months = List<double>.filled(12, 0.0);
    if (_products.isEmpty) return months;

    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final monthOffset = i - 11;
      final monthDate = DateTime(now.year, now.month + monthOffset, 1);
      for (final p in _products) {
        if (!p.createdAt.isAfter(
          DateTime(monthDate.year, monthDate.month + 1, 0),
        )) {
          months[i] += p.cost * p.boughtPerMonth;
        }
      }
    }
    return months;
  }

  // Get available stock summary by product name
  static Map<String, double> getStockByProduct() {
    final stock = <String, double>{};
    for (final p in _products) {
      stock[p.name] = p.currentStock;
    }
    return stock;
  }

  // Helpful factory for creating product with an id
  static Product create({
    required String name,
    required String description,
    required double price,
    required double cost,
    List<String>? images,
    double soldPerMonth = 0.0,
    double boughtPerMonth = 0.0,
    double currentStock = 0.0,
    DateTime? createdAt,
  }) {
    final id =
        DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(999).toString();
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      cost: cost,
      images: images,
      soldPerMonth: soldPerMonth,
      boughtPerMonth: boughtPerMonth,
      currentStock: currentStock,
      createdAt: createdAt,
    );
  }
}
