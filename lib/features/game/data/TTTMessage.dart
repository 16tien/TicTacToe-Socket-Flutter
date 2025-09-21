import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';


class TTTMessage {
  final String type;
  final Map<String, dynamic> data;

  TTTMessage({required this.type, required this.data});

  factory TTTMessage.fromJson(Map<String, dynamic> json) {
    return TTTMessage(
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'data': data,
  };

  void operator [](String other) {}
}
