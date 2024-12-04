import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/uid_manager.dart';


enum DeviceType {
  lamp,
  airCon,
  curtain,
  // rs485, // 操作485
}

mixin DeviceNotifierMixin on ChangeNotifier {
  void removeDevice(int uid) {
    DeviceManager().removeDevice(uid);
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void deserializationUpdate(List<IDeviceBase> newDevices) {
    DeviceManager().addDevices(newDevices);

    int maxUid = newDevices.fold(0, (prev, device) => max(prev, device.uid));
    UidManager().updateDeviceUid(maxUid);
    notifyListeners();
  }
}