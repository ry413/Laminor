import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/pages/air_config_page.dart';
import 'package:flutter_web_1/pages/board_input_page.dart';
import 'package:flutter_web_1/pages/board_output_page.dart';
import 'package:flutter_web_1/pages/curtain_config_page.dart';
import 'package:flutter_web_1/pages/home_config_page.dart';
import 'package:flutter_web_1/pages/lamp_config_page.dart';
import 'package:flutter_web_1/pages/other_device_config_page.dart';
import 'package:flutter_web_1/pages/panel_config_page.dart';
import 'package:flutter_web_1/pages/rs485_config_page.dart';
import 'package:flutter_web_1/pages/voice_config_page.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:flutter_web_1/providers/home_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/other_device_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:flutter_web_1/providers/voice_config_provider.dart';
import 'package:provider/provider.dart';
import 'web_export_stub.dart' if (dart.library.html) 'web_export.dart';

String ipAddress = '192.168.2.40';
int port = 8080;

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 确保初始化
  SemanticsBinding.instance.ensureSemantics(); // 强制启用语义
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomePageNotifier(),
        ),
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
        ),
        ChangeNotifierProvider(
          create: (context) => OtherDeviceNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => VoiceConfigNotifier(),
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
      home: Semantics(
          container: true, excludeSemantics: true, child: MyHomePage()),
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
  static const int indexLampPage = 7;
  static const int indexBoardInputPage = 8;
  static const int indexRS485Page = 9;
  static const int indexOtherDevicePage = 10;
  static const int indexVoiceCommandPage = 11;

  var _selectedIndex = indexHomePage;

  bool showBoardOutputList = true;
  bool showBoardInputList = true;
  bool showLampList = true;
  bool showACList = true;
  bool showPanelList = true;
  bool showCurtainList = true;
  bool showRS485List = true;
  bool showOtherDeviceList = true;
  bool showVoiceCommandList = true;

  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();
    final lampNotifier = context.watch<LampNotifier>();
    final airConNotifier = context.watch<AirConNotifier>();
    final curtainNotifier = context.watch<CurtainNotifier>();
    final rs485Notifier = context.watch<RS485ConfigNotifier>();
    final panelNotifier = context.watch<PanelConfigNotifier>();
    final otherDeviceNotifier = context.watch<OtherDeviceNotifier>();
    final voiceCommandNotifier = context.watch<VoiceConfigNotifier>();

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

      // 板子
      sideBarItem(indexBoardOutputPage, '板子配置', Icons.developer_board,
          showBoardOutputList, () {
        showBoardOutputList = !showBoardOutputList;
      }),
      ...buildItemList(
          showBoardOutputList, boardNotifier.allOutputs, indexBoardOutputPage),

      Divider(height: 3),
      // 灯
      sideBarItem(indexLampPage, '灯配置', Icons.light, showLampList, () {
        showLampList = !showLampList;
      }),
      ...buildItemList(showLampList, lampNotifier.allLamps, indexLampPage),

      // 窗帘
      sideBarItem(
          indexCurtainPage, '窗帘配置', Icons.curtains_closed, showCurtainList, () {
        showCurtainList = !showCurtainList;
      }),
      ...buildItemList(
          showCurtainList, curtainNotifier.allCurtains, indexCurtainPage),

      // 空调
      sideBarItem(indexAirConPage, '空调配置', Icons.ac_unit_rounded, showACList,
          () {
        showACList = !showACList;
      }),

      ...buildItemList(showACList, airConNotifier.allAirCons, indexAirConPage),
      // 485
      sideBarItem(
          indexRS485Page, '485配置', Icons.electrical_services, showRS485List,
          () {
        showRS485List = !showRS485List;
      }),
      ...buildItemList(
          showRS485List, rs485Notifier.allCommands, indexRS485Page),

      // 别的设备
      sideBarItem(indexOtherDevicePage, '其他配置', Icons.devices_other,
          showOtherDeviceList, () {
        showOtherDeviceList = !showOtherDeviceList;
      }),
      ...buildItemList(showOtherDeviceList, otherDeviceNotifier.allOtherDevices,
          indexOtherDevicePage),

      Divider(height: 3),

      // 面板
      sideBarItem(
          indexPanelPage, '面板配置', Icons.border_all_rounded, showPanelList, () {
        showPanelList = !showPanelList;
      }),
      ...buildItemList(showPanelList, panelNotifier.allPanel, indexPanelPage),

      // 干接点输入
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

      // 语音指令
      sideBarItem(indexVoiceCommandPage, '语音指令', Icons.keyboard_voice,
          showVoiceCommandList, () {
        showVoiceCommandList = !showVoiceCommandList;
      }),
      ...buildItemList(showVoiceCommandList,
          voiceCommandNotifier.allVoiceCommands, indexVoiceCommandPage),

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
            Icon(Icons.download),
            SizedBox(width: 6),
            Text('下载json'),
            SizedBox(width: 40, height: 40),
          ],
        ),
      ),
      // 上传json
      InkWell(
        canRequestFocus: false,
        onTap: () {
          uploadAndParseJsonDesktop();
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
        return HomeConfigPage();
      case indexBoardOutputPage:
        return BoardOutputPage();
      case indexAirConPage:
        return ACConfigPage();
      case indexPanelPage:
        return PanelConfigPage();
      case indexOtherDevicePage:
        return OtherDeviceConfigPage();
      case indexLampPage:
        return LampConfigPage();
      case indexBoardInputPage:
        return BoardInputPage();
      case indexRS485Page:
        return RS485ConfigPage();
      case indexCurtainPage:
        return CurtainConfigPage();
      case indexVoiceCommandPage:
        return VoiceConfigPage();
      default:
        return Placeholder();
    }
  }

  // 生成并下载json文件
  Future<void> generateAndDownloadJson() async {
    String jsonStr = jsonEncode(generateJson(context));

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

  Future<void> uploadAndParseJsonDesktop() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'], // 限制只选择 JSON 文件
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      try {
        final jsonString = await File(filePath).readAsString();
        await parseJsonString(jsonString, context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("读取 JSON 文件失败: $e"),
          duration: Duration(seconds: 1),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("未选择任何文件"),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
