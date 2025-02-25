import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_function.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/providers/home_config_provider.dart';
import 'package:network_tools/network_tools.dart';
import 'package:provider/provider.dart';

class HomeConfigPage extends StatefulWidget {
  static final GlobalKey<HomeConfigPageState> globalKey =
      GlobalKey<HomeConfigPageState>();

  HomeConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  HomeConfigPageState createState() => HomeConfigPageState();
}

class HomeConfigPageState extends State<HomeConfigPage> {
  final TextEditingController configVerController = TextEditingController();
  final TextEditingController hotelNameController = TextEditingController();
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController =
      TextEditingController(text: '8080');

  bool _isScanning = false; // 是否正在扫描

  @override
  void dispose() {
    configVerController.dispose();
    hotelNameController.dispose();
    roomNameController.dispose();
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeNotifier = context.read<HomePageNotifier>();

    // 初始化输入框数据
    configVerController.text = homeNotifier.configVersion;
    hotelNameController.text = homeNotifier.hotelName;
    roomNameController.text = homeNotifier.roomName;

    // 添加监听，输入框修改时更新数据
    configVerController.addListener(() {
      homeNotifier.configVersion = configVerController.text;
    });
    hotelNameController.addListener(() {
      homeNotifier.hotelName = hotelNameController.text;
    });
    roomNameController.addListener(() {
      homeNotifier.roomName = roomNameController.text;
    });
  }

  // 扫描局域网设备
  Future<void> scanNetwork() async {
    final homeNotifier = context.read<HomePageNotifier>();
    setState(() {
      homeNotifier.clearScannedIPs();
      _isScanning = true;
    });

    const String targetPrefix = '5C'; // 目标 MAC 地址前缀

    try {
      final wifiIP = await getLocalIPAddress(); // 调用本地命令获取 IP 地址

      if (wifiIP != null) {
        final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
        print('扫描网段: $subnet.0/24');

        // 使用 network_tools 扫描当前网段
        await for (final host in HostScanner.discover(subnet)) {
          final ip = host.ip;
          final macAddress = await getMacAddress(ip);

          if (macAddress != null) {
            final ipInfo = '$ip ($macAddress)';
            print(ipInfo);
            homeNotifier.addScannedIP(ipInfo);
          }
        }
      } else {
        print('无法获取本机 IP 地址，请检查网络连接');
      }
    } catch (e) {
      print('扫描失败: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// 获取本地 IP 地址（适用于 macOS）
  Future<String?> getLocalIPAddress() async {
    try {
      final result = Platform.isWindows
          ? await Process.run('ipconfig', [])
          : await Process.run('ifconfig', []);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();

        // 使用不同的正则解析输出
        final regex = Platform.isWindows
            ? RegExp(r'IPv4 Address.*?: (\d+\.\d+\.\d+\.\d+)')
            : RegExp(r'inet (\d+\.\d+\.\d+\.\d+)');

        final matches = regex.allMatches(output);

        for (final match in matches) {
          final ip = match.group(1);
          if (ip != null && !ip.startsWith('127.')) {
            return ip;
          }
        }
      }
    } catch (e) {
      print('获取 IP 地址失败: $e');
    }

    return null; // 未找到有效 IP 地址时返回 null
  }

  Future<String?> getMacAddress(String ip) async {
    try {
      // 执行 arp 命令查询 IP 对应的 MAC 地址
      final result = await Process.run('arp', [ip]);
      if (result.exitCode == 0) {
        var output = result.stdout.toString();
        // print('ARP: $output');

        // 正则匹配 MAC 地址格式：XX:XX:XX:XX:XX:XX
        final regex = RegExp(r'([0-9A-Fa-f]{1,2}(:[0-9A-Fa-f]{1,2}){5})');
        final match = regex.firstMatch(output);

        if (match != null) {
          // 修正 MAC 地址格式，补全单字符的段为两位
          var macAddress = match.group(0)!;
          var correctedMac = macAddress
              .split(':')
              .map((segment) => segment.padLeft(2, '0'))
              .join(':');
          print(correctedMac.toLowerCase());
          return correctedMac.toUpperCase(); // 返回大写格式的 MAC 地址
        }
      }
    } catch (e) {
      print('获取 MAC 地址失败: $e');
    }
    return null; // 未找到 MAC 地址时返回 null
  }

  @override
  Widget build(BuildContext context) {
    final homeNotifier = context.watch<HomePageNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('一般配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            ConfigSection(
              children: [
                _buildRow(
                  title: '此配置版本号',
                  controller: configVerController,
                  value: homeNotifier.configVersion,
                ),
                // _buildRow(
                //   title: '酒店名',
                //   controller: hotelNameController,
                //   value: homeNotifier.hotelName,
                // ),
                // _buildRow(
                //   title: '房号',
                //   controller: roomNameController,
                //   value: homeNotifier.roomName,
                // ),
              ],
            ),
            Spacer(),
            // ConfigSection(
            //   children: [
            //     Row(
            //       children: [
            //         // 扫描按钮
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.end,
            //           children: [
            //             ElevatedButton(
            //               onPressed: _isScanning ? null : scanNetwork,
            //               style: ElevatedButton.styleFrom(
            //                 backgroundColor: Colors.blue, // 按钮背景颜色
            //                 foregroundColor: Colors.white, // 按钮文字颜色
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(8), // 设置圆角
            //                 ),
            //               ),
            //               child: Text(
            //                 _isScanning ? '扫描中...' : '扫描',
            //               ),
            //             ),
            //           ],
            //         ),
            //         Spacer(),
            //         // IP 输入框
            //         ConstrainedBox(
            //           constraints: BoxConstraints(maxWidth: 150),
            //           child: TextField(
            //             decoration: InputDecoration(
            //               labelText: "IP 地址",
            //               isDense: true,
            //               contentPadding:
            //                   EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            //               border: OutlineInputBorder(),
            //             ),
            //             controller: ipController,
            //           ),
            //         ),
            //         SizedBox(width: 10),
            //         // Port 输入框
            //         ConstrainedBox(
            //           constraints: BoxConstraints(maxWidth: 80),
            //           child: TextField(
            //             decoration: InputDecoration(
            //               labelText: "端口",
            //               isDense: true,
            //               contentPadding:
            //                   EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            //               border: OutlineInputBorder(),
            //             ),
            //             controller: portController,
            //           ),
            //         ),
            //         Spacer(),
            //         // 获取远程配置按钮
            //         ElevatedButton(
            //           onPressed: () {
            //             getRCUConfig(
            //                 ipController.text, int.parse(portController.text));
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.blue, // 按钮背景颜色
            //             foregroundColor: Colors.white, // 按钮文字颜色
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(8), // 设置圆角
            //             ),
            //           ),
            //           child: Row(
            //             children: [
            //               Icon(Icons.cloud_download),
            //               SizedBox(width: 6),
            //               Text('获取目标配置'),
            //             ],
            //           ),
            //         ),
            //         SizedBox(width: 10),
            //         // 发送
            //         ElevatedButton(
            //           onPressed: () {
            //             generateAndSendJson(ipController.text,
            //                 int.parse(portController.text), context);
            //           },
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Colors.blue, // 按钮背景颜色
            //             foregroundColor: Colors.white, // 按钮文字颜色
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(8), // 设置圆角
            //             ),
            //           ),
            //           child: Row(
            //             children: [
            //               Icon(Icons.send_and_archive),
            //               SizedBox(width: 6),
            //               Text('下发配置'),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // // 扫描结果列表
            // Expanded(
            //     child: homeNotifier.scannedIPs.isEmpty
            //         ? Center(child: Text(_isScanning ? '正在扫描...' : '未发现设备'))
            //         : Container(
            //             margin: EdgeInsets.all(8), // 外边距
            //             decoration: BoxDecoration(
            //               color: Colors.white, // 背景颜色
            //               borderRadius: BorderRadius.circular(8), // 圆角
            //             ),
            //             child: ListView.builder(
            //               itemCount: homeNotifier.scannedIPs.length,
            //               itemBuilder: (context, index) {
            //                 final ipInfo = homeNotifier.scannedIPs[index];
            //                 return ListTile(
            //                   title: Text(ipInfo),
            //                   onTap: () {
            //                     final ip = ipInfo.split(' ')[0];
            //                     setState(() {
            //                       ipController.text = ip; // 填充IP输入框
            //                     });
            //                   },
            //                 );
            //               },
            //             ),
            //           )),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    required TextEditingController controller,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionTitle(title: title),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Future<void> getRCUConfig(String ip, int port) async {
    try {
      String jsonStr = await fetchFileFromDevice(ip, port);
      print(jsonStr);
      parseJsonString(jsonStr, context);
    } catch (e) {
      print('获取配置失败: $e');
    }
  }

  Future<String> fetchFileFromDevice(String ipAddress, int port) async {
    Socket socket = await Socket.connect(ipAddress, port);
    print('已连接到: ${socket.remoteAddress.address}:${socket.remotePort}');

    socket.writeln('GET_FILE');
    await socket.flush();

    const endMarker = '\nEND_OF_JSON\n';
    StringBuffer buffer = StringBuffer();
    Completer<String> completer = Completer<String>();

    List<int> incompleteBytes = []; // 缓存未完成的字节数据

    socket.listen((data) {
      try {
        // 拼接上一次缓存的字节和本次接收到的数据
        incompleteBytes.addAll(data);

        // 尝试解码，成功的话将解码后的字符串写入 buffer
        String decodedData =
            utf8.decode(incompleteBytes, allowMalformed: false);

        buffer.write(decodedData); // 保存解码后的字符串
        incompleteBytes.clear(); // 解码成功，清空缓存

        // 检查是否接收到结束标记
        if (buffer.toString().contains(endMarker)) {
          String fullData = buffer.toString();
          int endIndex = fullData.indexOf(endMarker);
          String jsonData = fullData.substring(0, endIndex);

          if (!completer.isCompleted) {
            completer.complete(jsonData);
          }
          socket.destroy();
        }
      } catch (e) {
        // 解码失败，说明字节流不完整，继续缓存数据等待下一次拼接
      }
    }, onError: (error) {
      if (!completer.isCompleted) completer.completeError(error);
      socket.destroy();
    }, onDone: () {
      // 监听结束时，尝试最后一次解码剩余缓存的数据
      if (incompleteBytes.isNotEmpty) {
        try {
          String decodedData =
              utf8.decode(incompleteBytes, allowMalformed: false);
          buffer.write(decodedData);
        } catch (e) {
          print('最后解码失败: $e');
        }
      }

      if (!completer.isCompleted) {
        completer.completeError('未接收到END_OF_JSON标记，连接已关闭');
      }
      socket.destroy();
    });

    return completer.future;
  }
}
