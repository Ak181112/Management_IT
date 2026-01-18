import 'dart:convert';
import 'package:http/http.dart' as http;

class Transaction {
  final DateTime date;
  final double amount;
  final String type; // 'buy' or 'sell'
  final String description;
  final String product; // product name or details

  Transaction({
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    required this.product,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      product: json['product'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amount': amount,
    'type': type,
    'description': description,
    'product': product,
  };
}

class Member {
  final String id;
  final String name;
  final String contact; // phone number
  final String email;
  final DateTime? dob;
  final DateTime? joinedDate;
  final double totalBought;
  final double totalSold;
  final List<Transaction> transactions;

  Member({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.dob,
    required this.joinedDate,
    required this.totalBought,
    required this.totalSold,
    required this.transactions,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String? ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'] as String)
          : null,
      totalBought: (json['totalBought'] as num).toDouble(),
      totalSold: (json['totalSold'] as num).toDouble(),
      transactions: (json['transactions'] as List<dynamic>? ?? [])
          .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contact': contact,
    'email': email,
    'dob': dob?.toIso8601String(),
    'joinedDate': joinedDate?.toIso8601String(),
    'totalBought': totalBought,
    'totalSold': totalSold,
    'transactions': transactions.map((t) => t.toJson()).toList(),
  };
}

class MemberService {
  static final List<Member> _members = [];
  static const String _baseUrl = 'http://localhost:3000/api/members';

  static Future<void> init() async {
    await fetchMembers();
  }

  static Future<void> fetchMembers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        _members.clear();
        for (final m in list) {
          _members.add(Member.fromJson(m as Map<String, dynamic>));
        }
      }
    } catch (e) {
      print('Error fetching members: $e');
    }
  }

  static List<Member> getMembers() => List.from(_members);

  static Member create({
    String? id,
    required String name,
    required String contact,
    String email = '',
    DateTime? dob,
    DateTime? joinedDate,
    double totalBought = 0.0,
    double totalSold = 0.0,
  }) {
    return Member(
      id: id ?? '', // ID handled by backend if empty
      name: name,
      contact: contact,
      email: email,
      dob: dob,
      joinedDate: joinedDate,
      totalBought: totalBought,
      totalSold: totalSold,
      transactions: [],
    );
  }

  static Future<void> addMember(Member member) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(member.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchMembers();
      }
    } catch (e) {
      print('Error adding member: $e');
    }
  }

  static Future<void> updateMember(String id, Member updated) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updated.toJson()),
      );
      if (response.statusCode == 200) {
        final idx = _members.indexWhere((m) => m.id == id);
        if (idx >= 0) _members[idx] = updated;
      }
    } catch (e) {
      print('Error updating member: $e');
    }
  }

  static Future<void> deleteMember(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        _members.removeWhere((m) => m.id == id);
      }
    } catch (e) {
      print('Error deleting member: $e');
    }
  }

  static Future<void> addTransaction(
    String memberId, {
    required double amount,
    required String type, // 'buy' or 'sell'
    required String description,
    String product = '',
  }) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx >= 0) {
      final member = _members[idx];
      final transaction = Transaction(
        date: DateTime.now(),
        amount: amount,
        type: type,
        description: description,
        product: product,
      );
      final updatedMember = Member(
        id: member.id,
        name: member.name,
        contact: member.contact,
        email: member.email,
        dob: member.dob,
        joinedDate: member.joinedDate,
        totalBought: type == 'buy'
            ? member.totalBought + amount
            : member.totalBought,
        totalSold: type == 'sell'
            ? member.totalSold + amount
            : member.totalSold,
        transactions: [...member.transactions, transaction],
      );

      await updateMember(memberId, updatedMember);
    }
  }
}
