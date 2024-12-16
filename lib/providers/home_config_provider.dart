import 'package:flutter/material.dart';

class HomePageNotifier extends ChangeNotifier {
  String _configVersion = '';
  String _hotelName = '';
  String _roomName = '';

  // Getters
  String get configVersion => _configVersion;
  String get hotelName => _hotelName;
  String get roomName => _roomName;

  // Setters (通知监听器更新)
  set configVersion(String value) {
    if (_configVersion != value) {
      _configVersion = value;
      notifyListeners();
    }
  }

  set hotelName(String value) {
    if (_hotelName != value) {
      _hotelName = value;
      notifyListeners();
    }
  }

  set roomName(String value) {
    if (_roomName != value) {
      _roomName = value;
      notifyListeners();
    }
  }

  // 从 JSON 加载数据
  void fromJson(Map<String, dynamic> json) {
    configVersion = json['config_version'] ?? '';
    hotelName = json['hotel_name'] ?? '';
    roomName = json['room_name'] ?? '';
  }

  // 转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {
      'config_version': configVersion,
      'hotel_name': hotelName,
      'room_name': roomName,
    };
  }
}