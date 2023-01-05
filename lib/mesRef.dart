import 'package:cloud_firestore/cloud_firestore.dart';

class Mes {
  final String id;
  final String message;
  final String address;
  final num amt;
  final num balance;
  final Timestamp date;

  Mes({
    this.id,
    this.message,
    this.address,
    this.amt,
    this.balance,
    this.date,
  });

  factory Mes.fromDocument(DocumentSnapshot doc) {
    return Mes(
      id: doc['id'],
      message: doc['message'],
      address: doc['address'],
      amt: doc['amt'],
      balance: doc['balance'],
      date: doc['date'],
    );
  }
}

class User {
  final String email;
  final num weekly_limit;
  final num daily_limit;
  final num weekly_sum;
  final num daily_sum;
  final Timestamp weekly_date;
  final Timestamp daily_date;

  User({
    this.email,
    this.weekly_limit,
    this.daily_limit,
    this.weekly_sum,
    this.daily_sum,
    this.weekly_date,
    this.daily_date,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      email: doc['email'],
      weekly_limit: doc['weekly_limit'],
      daily_limit: doc['daily_limit'],
      weekly_sum: doc['weekly_sum'],
      daily_sum: doc['daily_sum'],
      weekly_date: doc['weekly_date'],
      daily_date: doc['daily_date'],
    );
  }
}

class Phone {
  final String email;

  Phone({
    this.email,
  });

  factory Phone.fromDocument(DocumentSnapshot doc) {
    return Phone(
      email: doc['email'],
    );
  }
}
