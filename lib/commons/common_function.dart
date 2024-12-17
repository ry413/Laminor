import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:flutter_web_1/providers/home_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/other_device_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:provider/provider.dart';

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

mixin UsageCountMixin {
  // 这个不参与序列化
  @JsonKey(includeFromJson: false, includeToJson: false)
  int usageCount = 0;

  bool get inUse => usageCount > 0;

  void addUsage() {
    usageCount++;
  }

  void removeUsage() {
    if (usageCount > 0) {
      usageCount--;
    }
  }
}

Future<void> parseJsonString(String jsonString, BuildContext context) async {
  try {
    // 解析 JSON 字符串
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    DeviceManager().clear();

    // 解析 JSON 数据并更新对应的配置

    final homeConfigNotifier =
        Provider.of<HomePageNotifier>(context, listen: false);
    homeConfigNotifier.fromJson(jsonData['一般配置']);

    final boardConfigNotifier =
        Provider.of<BoardConfigNotifier>(context, listen: false);
    // 这里不会反序列化inputs, 而是到设备们反序列化完了才到它
    final newBoards = (jsonData['板子列表'] as List)
        .map((item) => BoardConfig.fromJson(item))
        .toList();
    boardConfigNotifier.deserializationUpdate(newBoards);

    final lampConfigNotifier =
        Provider.of<LampNotifier>(context, listen: false);
    final newLamps =
        (jsonData['灯列表'] as List).map((item) => Lamp.fromJson(item)).toList();
    lampConfigNotifier.deserializationUpdate(newLamps);

    final acConfigNotifier =
        Provider.of<AirConNotifier>(context, listen: false);
    acConfigNotifier.fromJson(jsonData['空调通用配置']);
    final newAirCons = (jsonData['空调列表'] as List)
        .map((item) => AirCon.fromJson(item))
        .toList();
    acConfigNotifier.deserializationUpdate(newAirCons);

    final curtainConfigNotifier =
        Provider.of<CurtainNotifier>(context, listen: false);
    final newCurtains = (jsonData['窗帘列表'] as List)
        .map((item) => Curtain.fromJson(item))
        .toList();
    curtainConfigNotifier.deserializationUpdate(newCurtains);

    final otherDeviceNotifier =
        Provider.of<OtherDeviceNotifier>(context, listen: false);
    final newOtherDevice = (jsonData['其他设备列表'] as List)
        .map((item) => OtherDevice.fromJson(item))
        .toList();
    otherDeviceNotifier.deserializationUpdate(newOtherDevice);

    final rs485CommandNotifier =
        Provider.of<RS485ConfigNotifier>(context, listen: false);
    final newCommands = (jsonData['485指令码列表'] as List)
        .map((item) => RS485Command.fromJson(item))
        .toList();
    rs485CommandNotifier.deserializationUpdate(newCommands);

    // 到这里再解析inputs
    final boardListJson = (jsonData['板子列表'] as List);
    for (int i = 0; i < newBoards.length; i++) {
      final boardJson = boardListJson[i] as Map<String, dynamic>;
      newBoards[i].loadInputsFromJson(boardJson['inputs'] as List<dynamic>);
    }

    final panelConfigNotifier =
        Provider.of<PanelConfigNotifier>(context, listen: false);
    final newPanels =
        (jsonData['面板列表'] as List).map((item) => Panel.fromJson(item)).toList();
    panelConfigNotifier.deserializationUpdate(newPanels);

    // 提示用户解析成功
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("JSON 数据解析成功"),
        duration: Duration(seconds: 1),
      ),
    );
  } catch (e) {
    // 提示解析错误
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("解析 JSON 数据失败: $e"),
      duration: Duration(seconds: 1),
    ));
  }
}

// 把json发送到指定地址
Future<void> generateAndSendJson(String ipAddress, int port, BuildContext context) async {
  String jsonStr = jsonEncode(generateJson(context));
  try {
    // 连接到指定的 TCP 服务器
    Socket socket = await Socket.connect(ipAddress, port);
    print('已连接到 $ipAddress:$port');

    // 发送数据
    socket.write(jsonStr);

    // 监听服务器的响应（可选）
    socket.listen(
      (data) {
        String response = utf8.decode(data);
        print('来自服务器的响应: $response');
      },
      onError: (error) {
        print('连接中发生错误: $error');
        socket.destroy();
      },
      onDone: () {
        print('服务器已关闭连接');
        socket.destroy();
      },
    );

    await Future.delayed(Duration(seconds: 2));
    socket.close();
  } catch (e) {
    print('无法连接到服务器: $e');
  }
}

// 生成终极json
Map<String, dynamic> generateJson(BuildContext context) {
  final homeConfigNotifier =
      Provider.of<HomePageNotifier>(context, listen: false);
  final boardConfigNotifier =
      Provider.of<BoardConfigNotifier>(context, listen: false);
  final lampConfigNotifier = Provider.of<LampNotifier>(context, listen: false);
  final acConfigNotifier = Provider.of<AirConNotifier>(context, listen: false);
  final curtainConfigNotifier =
      Provider.of<CurtainNotifier>(context, listen: false);
  final rs485CommandNotifier =
      Provider.of<RS485ConfigNotifier>(context, listen: false);
  final panelConfigNotifier =
      Provider.of<PanelConfigNotifier>(context, listen: false);
  final otherDeviceNotifier =
      Provider.of<OtherDeviceNotifier>(context, listen: false);

  // 清空可能残留的所有设备的关联按钮
  for (var device in DeviceManager().allDevices.values) {
    device.clearAssociatedButtons();
  }

  Map<String, dynamic> fullConfig = {
    '一般配置': homeConfigNotifier.toJson(),
    '板子列表':
        boardConfigNotifier.allBoard.map((board) => board.toJson()).toList(),
    // 必须先序列化面板, 然后再到各种设备
    '面板列表':
        panelConfigNotifier.allPanel.map((panel) => panel.toJson()).toList(),

    '灯列表': lampConfigNotifier.allLamps.map((lamp) => lamp.toJson()).toList(),
    '空调通用配置': acConfigNotifier.toJson(),
    '空调列表': acConfigNotifier.allAirCons.values
        .map((acConfig) => acConfig.toJson())
        .toList(),
    '窗帘列表': curtainConfigNotifier.allCurtains
        .map((curtain) => curtain.toJson())
        .toList(),
    '其他设备列表': otherDeviceNotifier.allOtherDevices
        .map((device) => device.toJson())
        .toList(),
    '485指令码列表': rs485CommandNotifier.allCommands
        .map((command) => command.toJson())
        .toList(),
  };
  return fullConfig;
}
