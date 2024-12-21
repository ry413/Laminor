import 'dart:math';

class UidManager {
  // 各类型的自增值
  int _outputUid = 0;

  int _deviceUid = 0;       // 所有Device用同一个uid计数

  int _actionGroup = 0;


  // 单例模式
  static final UidManager _instance = UidManager._internal();

  UidManager._internal();

  // 公开单例访问点
  factory UidManager() {
    return _instance;
  }

  // 输出通道
  int generateOutputUid() {
    return ++_outputUid;
  }
  void setOutputUid(int uid) {
    _outputUid = uid;
  }

  // 设备
  int generateDeviceUid() {
    return ++_deviceUid;
  }
  void updateDeviceUid(int uid) {
    _deviceUid = max(uid, _deviceUid);
  }

  // 动作组uid
  int generateActionGroupUid() {
    return ++_actionGroup;
  }
  void updateActionGroupUid(int uid) {
    _actionGroup = max(uid, _actionGroup);
  }

}
