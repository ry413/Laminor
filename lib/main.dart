import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/pages/air_config_page.dart';
import 'package:flutter_web_1/pages/board_input_page.dart';
import 'package:flutter_web_1/pages/board_output_page.dart';
import 'package:flutter_web_1/pages/curtain_config_page.dart';
import 'package:flutter_web_1/pages/lamp_config_page.dart';
import 'package:flutter_web_1/pages/panel_config_page.dart';
import 'package:flutter_web_1/pages/rs485_config_page.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:provider/provider.dart';
import 'web_export_stub.dart' if (dart.library.html) 'web_export.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BoardConfigNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => AirConNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => PanelConfigNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => LampNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => RS485ConfigNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => CurtainNotifier(),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laminor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 逻辑索引
  static const int indexHomePage = 100;
  static const int indexBoardOutputPage = 0;
  static const int indexAirConPage = 1;
  static const int indexPanelPage = 2;
  static const int indexCurtainPage = 5;
  static const int indexActionGroupPage = 6;
  static const int indexLampPage = 7;
  static const int indexBoardInputPage = 8;
  static const int indexRS485Page = 9;

  var _selectedIndex = indexHomePage;

  bool showBoardOutputList = true;
  bool showBoardInputList = true;
  bool showLampList = true;
  bool showACList = true;
  bool showPanelList = true;
  bool showCurtainList = true;
  bool showRS485List = true;

  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();
    final lampNotifier = context.watch<LampNotifier>();
    final airConNotifier = context.watch<AirConNotifier>();
    final curtainNotifier = context.watch<CurtainNotifier>();
    final rs485Notifier = context.watch<RS485ConfigNotifier>();
    final panelNotifier = context.watch<PanelConfigNotifier>();

    List<Widget> navigationItems = [
      // 主页
      InkWell(
        canRequestFocus: false,
        onTap: () {
          setState(() {
            _selectedIndex = indexHomePage;
          });
        },
        child: Container(
          color: _selectedIndex == indexHomePage ? Colors.blue : null,
          child: Row(
            children: [
              SizedBox(width: 12, height: 40),
              Icon(Icons.home),
              SizedBox(width: 6),
              Text('主页',
                  style: TextStyle(
                      color: _selectedIndex == indexHomePage
                          ? Colors.white
                          : Colors.black)),
            ],
          ),
        ),
      ),

      sideBarItem(indexBoardOutputPage, '板子配置', Icons.developer_board,
          showBoardOutputList, () {
        showBoardOutputList = !showBoardOutputList;
      }),
      ...buildItemList(
          showBoardOutputList, boardNotifier.allOutputs, indexBoardOutputPage),

      Divider(height: 3),

      sideBarItem(indexLampPage, '灯配置', Icons.light, showLampList, () {
        showLampList = !showLampList;
      }),
      ...buildItemList(showLampList, lampNotifier.allLamps, indexLampPage),

      sideBarItem(indexAirConPage, '空调配置', Icons.ac_unit_rounded, showACList,
          () {
        showACList = !showACList;
      }),
      ...buildItemList(showACList, airConNotifier.allAirCons, indexAirConPage),

      sideBarItem(
          indexCurtainPage, '窗帘配置', Icons.curtains_closed, showCurtainList, () {
        showCurtainList = !showCurtainList;
      }),
      ...buildItemList(
          showCurtainList, curtainNotifier.allCurtains, indexCurtainPage),

      sideBarItem(
          indexRS485Page, '485配置', Icons.electrical_services, showRS485List,
          () {
        showRS485List = !showRS485List;
      }),
      ...buildItemList(
          showRS485List, rs485Notifier.allCommands, indexRS485Page),

      Divider(height: 3),

      sideBarItem(
          indexPanelPage, '面板配置', Icons.border_all_rounded, showPanelList, () {
        showPanelList = !showPanelList;
      }),
      ...buildItemList(showPanelList, panelNotifier.allPanel, indexPanelPage),

      sideBarItem(indexBoardInputPage, "输入配置", Icons.developer_board,
          showBoardInputList, () {
        showBoardInputList = !showBoardInputList;
      }),
      // 不管, 这里逻辑不一样
      if (showBoardInputList)
        ...boardNotifier.allBoard.asMap().entries.map((entry) {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.only(left: 60.0),
              child: Row(
                children: [
                  Text('板子 ${entry.value.id}'),
                ],
              ),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = indexBoardInputPage;
              });
            },
          );
        }),

      Divider(height: 3),
      // 生成json的按钮
      InkWell(
        canRequestFocus: false,
        onTap: () {
          generateAndDownloadJson();
        },
        child: Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.sim_card_download),
            SizedBox(width: 6),
            Text('生成json'),
            SizedBox(width: 40, height: 40),
          ],
        ),
      ),
      // 发送
      if (!kIsWeb)
        InkWell(
          canRequestFocus: false,
          onTap: () {
            generateAndSendJson();
          },
          child: Row(
            children: [
              SizedBox(width: 12),
              Icon(Icons.send_and_archive),
              SizedBox(width: 6),
              Text('发送Json'),
              SizedBox(width: 40, height: 40),
            ],
          ),
        ),
      // 上传json
      InkWell(
        canRequestFocus: false,
        onTap: () {
          uploadAndParseJsonDesktop(context);
        },
        child: Row(
          children: [
            SizedBox(width: 12),
            Icon(Icons.upload),
            SizedBox(width: 6),
            Text('上传json'),
            SizedBox(width: 40, height: 40),
          ],
        ),
      ),
    ];

    return Scaffold(
        body: Row(
      children: [
        SafeArea(
          child: Material(
            color: Color.fromRGBO(225, 226, 227, 1),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              constraints: BoxConstraints(
                maxWidth: 300,
                minWidth: 150,
              ),
              child: ListView(
                children: navigationItems,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: _buildPageContent(),
          ),
        )
      ],
    ));
  }

  // 构建左侧的边栏项
  InkWell sideBarItem(int index, String name, IconData icon, bool openDrawer,
      Function onPressed) {
    return InkWell(
      canRequestFocus: false,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: _selectedIndex == index ? Colors.blue : null,
        child: Row(
          children: [
            SizedBox(width: 12),
            Icon(icon),
            SizedBox(width: 6),
            Text(name,
                style: TextStyle(
                    color:
                        _selectedIndex == index ? Colors.white : Colors.black)),
            Spacer(),
            ExcludeFocus(
              child: IconButton(
                  icon: Icon(openDrawer
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_left),
                  onPressed: () {
                    setState(() {
                      onPressed();
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }

  // 构建侧边栏之下的展开抽屉
  List<Widget> buildItemList(bool openDrawer, dynamic data, int pageIndex) {
    if (!openDrawer) return [];

    Map items = {};
    if (data is Map) {
      items = data;
    } else if (data is List) {
      items = data.asMap();
    }

    return items.entries.map((entry) {
      return InkWell(
        canRequestFocus: false,
        child: Padding(
          padding: EdgeInsets.only(left: 60.0),
          child: Row(
            children: [
              Flexible(
                  child:
                      Text(entry.value.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = pageIndex;
          });
        },
      );
    }).toList();
  }

  // 决定显示哪个页面
  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case indexHomePage:
        return Placeholder();
      case indexBoardOutputPage:
        return BoardOutputPage();
      case indexAirConPage:
        return ACConfigPage();
      case indexPanelPage:
        return PanelConfigPage();
      case indexActionGroupPage:
      // return ActionConfigPage();
      case indexLampPage:
        return LampConfigPage();
      case indexBoardInputPage:
        return BoardInputPage();
      case indexRS485Page:
        return RS485ConfigPage();
      case indexCurtainPage:
        return CurtainConfigPage();
      default:
        return Placeholder();
    }
  }

  Map<String, dynamic> generateJson() {
    final boardConfigNotifier =
        Provider.of<BoardConfigNotifier>(context, listen: false);
    final lampConfigNotifier =
        Provider.of<LampNotifier>(context, listen: false);
    final acConfigNotifier =
        Provider.of<AirConNotifier>(context, listen: false);
    final curtainConfigNotifier =
        Provider.of<CurtainNotifier>(context, listen: false);
    final rs485CommandNotifier =
        Provider.of<RS485ConfigNotifier>(context, listen: false);
    final panelConfigNotifier =
        Provider.of<PanelConfigNotifier>(context, listen: false);

    // 清空可能残留的所有设备的关联按钮
    for (var device in DeviceManager().allDevices.values) {
      device.clearAssociatedButtons();
    }

    Map<String, dynamic> fullConfig = {
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
      '485指令码列表': rs485CommandNotifier.allCommands.values
          .map((command) => command.toJson())
          .toList(),
    };
    return fullConfig;
  }

  // 生成并下载json文件
  Future<void> generateAndDownloadJson() async {
    String jsonStr = jsonEncode(generateJson());

    if (kIsWeb) {
      // 使用 web_export.dart 中的导出函数处理 Web 平台
      downloadJsonForWeb(jsonStr, "rcu_config.json");
    } else {
      String? selectedPath;

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        selectedPath = await FilePicker.platform.getDirectoryPath();
        if (selectedPath == null) {
          return;
        }
      }
      if (selectedPath != null) {
        String path = '$selectedPath/rcu_config.json';
        File file = File(path);
        await file.writeAsString(jsonStr);
      }
    }
  }

  Future<void> generateAndSendJson() async {
    String jsonStr = jsonEncode(generateJson());
    sendJsonOverTcp(jsonStr, '192.168.2.3', 8080);
  }

  // 将 JSON 字符串通过 TCP 发送
  Future<void> sendJsonOverTcp(
      String jsonStr, String ipAddress, int port) async {
    try {
      // 连接到指定的 TCP 服务器
      Socket socket = await Socket.connect(ipAddress, port);
      print('已连接到 $ipAddress:$port');

      // 将 JSON 字符串转换为字节，并发送
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

  Future<void> uploadAndParseJsonDesktop(BuildContext context) async {
    // 使用 FilePicker 打开文件选择对话框
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // 限制只选择 JSON 文件
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      try {
        final jsonString = await File(filePath).readAsString();
        final Map<String, dynamic> jsonData = jsonDecode(jsonString);

        DeviceManager().clear();

        // 解析 JSON 数据并更新对应的配置
        final boardConfigNotifier =
            Provider.of<BoardConfigNotifier>(context, listen: false);
        final newBoards = (jsonData['板子列表'] as List)
            .map((item) => BoardConfig.fromJson(item))
            .toList();
        boardConfigNotifier.deserializationUpdate(newBoards);

        final lampConfigNotifier =
            Provider.of<LampNotifier>(context, listen: false);
        final newLamps = (jsonData['灯列表'] as List)
            .map((item) => Lamp.fromJson(item))
            .toList();
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

        final rs485CommandNotifier =
            Provider.of<RS485ConfigNotifier>(context, listen: false);
        final newCommands = (jsonData['485指令码列表'] as List)
            .map((item) => RS485Command.fromJson(item))
            .toList();
        rs485CommandNotifier.deserializationUpdate(newCommands);

        final panelConfigNotifier =
            Provider.of<PanelConfigNotifier>(context, listen: false);
        final newPanels = (jsonData['面板列表'] as List)
            .map((item) => Panel.fromJson(item))
            .toList();
        panelConfigNotifier.deserializationUpdate(newPanels);

        // 提示用户上传成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("JSON 文件上传并解析成功")),
        );
      } catch (e) {
        // 提示解析错误
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("解析 JSON 文件失败: $e")),
        );
      }
    } else {
      // 用户取消选择文件
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("未选择任何文件")),
      );
    }
  }
}
