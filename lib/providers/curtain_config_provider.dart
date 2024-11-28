import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

part 'curtain_config_provider.g.dart';

@JsonSerializable()
class Curtain {
  final int uid;
  String name;
  int channelOpenUid;
  int channelCloseUid;
  int runDuration;

  Curtain({
    required this.uid,
    required this.name,
    required this.channelOpenUid,
    required this.channelCloseUid,
    required this.runDuration
  });

  static List<String> get operations {
    return ["开", "关"];
  }

  factory Curtain.fromJson(Map<String, dynamic> json) => _$CurtainFromJson(json);
  Map<String, dynamic> toJson() => _$CurtainToJson(this);
}

class CurtainNotifier extends ChangeNotifier {
  Map<int, Curtain> _allCurtains = {};
  Map<int, Curtain> get allCurtains => _allCurtains;

  void addCurtain(BuildContext context) {
    final allOutputs =
        Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
    if (allOutputs.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('请先配置输出')));
      return;
    }

    final curtain = Curtain(
      uid: UidManager().generateCurtainUid(),
      name: '未命名 窗帘',
      channelOpenUid: allOutputs.keys.first,
      channelCloseUid: allOutputs.keys.first,
      runDuration: 20,
    );

    _allCurtains[curtain.uid] = curtain;
    notifyListeners();
  }

  void removeCurtain(int key) {
    _allCurtains.remove(key);
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  void updateCurtainMap(Map<int, Curtain> newCurtains) {
    _allCurtains = newCurtains;
    notifyListeners();
  }

  void deserializationUpdate(List<Curtain> newCurtains) {
    _allCurtains.clear();
    int newCurtainUidMax = newCurtains.fold(0, (prev, curtain) => max(prev, curtain.uid));

    UidManager().setCurtainUid(newCurtainUidMax + 1);

    for (var curtain in newCurtains) {
      _allCurtains[curtain.uid] = curtain;
    }
    notifyListeners();
  }
}
