// 继承于IDeviceAction的类, 如灯, 窗帘什么的, 会被面板控制的设备
// 表示这些设备关联于哪个面板的哪个按钮
class AssociatedButton {
  int panelId;
  int buttonId;

  AssociatedButton({required this.panelId, required this.buttonId});
}

// 有操作的设备的基类
abstract class IDeviceBase {
  String name;
  final int uid;
  List<AssociatedButton>
      _associatedButtons; // 这个属性在常时是不应该被使用的, 仅仅在最终的toJson时才能用它

  IDeviceBase({
    required this.uid,
    required this.name,
  }) : _associatedButtons = [];

  List<String> get operations => [];

  // 只应该在最终生成json那一步被[Panel.toJson]调用
  // 也就是说必须调用这个之后, 才调用所有IDeviceBase的派生类.toJson
  // 不参与fromJson
  void clearAssociatedButtons() {
    _associatedButtons.clear();
  }

  void addAssociatedButton(AssociatedButton button) {
    _associatedButtons.add(button);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uid': uid,
      'associatedButtons': _associatedButtons
          .map((e) => {'panelId': e.panelId, 'buttonId': e.buttonId})
          .toList(),
    };
  }
}
