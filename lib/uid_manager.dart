class UidManager {
  // 各类型的自增值
  int _outputUid = 1;
  int _lampUid = 1;
  int _airConUid = 1;
  int _actionGroupUid = 1;
  int _rs485CommandUid = 1;

  // 单例模式
  static final UidManager _instance = UidManager._internal();

  UidManager._internal();

  // 公开单例访问点
  factory UidManager() {
    return _instance;
  }

  // 输出通道
  int generateOutputUid() {
    return _outputUid++;
  }
  void setOutputUid(int uid) {
    _outputUid = uid;
  }

  // 灯
  int generateLampUid() {
    return _lampUid++;
  }
  void setLampUid(int uid) {
    _outputUid = uid;
  }

  // 空调
  int generateAirConUid() {
    return _airConUid++;
  }
  void setAirConUid(int uid) {
    _airConUid = uid;
  }

  // 动作组
  int generateActionGroupUid() {
    return _actionGroupUid++;
  }
  void setActionGroupUid(int uid) {
    _actionGroupUid = uid;
  }

  // 485指令码
  int generateRS485CommandUid() {
    return _rs485CommandUid++;
  }
  void setRS485CommandUid(int uid) {
    _rs485CommandUid = uid;
  }
}