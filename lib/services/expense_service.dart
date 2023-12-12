import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/earning.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');
  final CollectionReference _earningsCollection =
      FirebaseFirestore.instance.collection('earnings');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> addExpense(Expense expense) async {
    String? userId = getUserId();
    if (userId != null) {
      await _expensesCollection.add({
        'userId': userId,
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date,
        'category': expense.category,
        'latitude': expense.latitude,
        'longitude': expense.longitude,
        'dueDate': expense.dueDate,
      });
    }
  }

  Future<void> addEarning(Earning earning) async {
    String? userId = getUserId();
    if (userId != null) {
      await _earningsCollection.add({
        'userId': userId,
        'title': earning.title,
        'amount': earning.amount,
        'date': earning.date,
        'category': earning.category,
        'latitude': earning.latitude,
        'longitude': earning.longitude,
      });
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    String? userId = getUserId();
    if (userId != null) {
      await _expensesCollection.doc(expenseId).delete();
    }
  }

  Future<void> deleteEarning(String earningId) async {
    String? userId = getUserId();
    if (userId != null) {
      await _earningsCollection.doc(earningId).delete();
    }
  }

  Stream<List<Expense>> getExpenses() {
    String? userId = getUserId();
    if (userId != null) {
      return _expensesCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Expense(
            id: doc.id,
            title: data['title'],
            amount: data['amount'],
            date: data['date'].toDate(),
            category: data['category'],
            latitude: data['latitude'],
            longitude: data['longitude'],
          );
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
  }

  Stream<List<Earning>> getEarnings() {
    String? userId = getUserId();
    if (userId != null) {
      return _earningsCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Earning(
            id: doc.id,
            title: data['title'],
            amount: data['amount'],
            date: data['date'].toDate(),
            category: data['category'],
            latitude: data['latitude'],
            longitude: data['longitude'],
          );
        }).toList();
      });
    } else {
      return Stream.value([]);
    }
  }
}
