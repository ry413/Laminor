import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/providers/home_config_provider.dart';
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

  @override
  void dispose() {
    configVerController.dispose();
    hotelNameController.dispose();
    roomNameController.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 添加侧边距
        child: Column(
          children: [
            ConfigSection(
              children: [
                _buildRow(
                  title: '此配置版本号',
                  controller: configVerController,
                  value: homeNotifier.configVersion,
                ),
                _buildRow(
                  title: '酒店名',
                  controller: hotelNameController,
                  value: homeNotifier.hotelName,
                ),
                _buildRow(
                  title: '房号',
                  controller: roomNameController,
                  value: homeNotifier.roomName,
                ),
                SizedBox(height: 80),
              ],
            ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(width: 1, color: Colors.brown),
              ),
            ),
            controller: controller,
          ),
        ),
      ],
    );
  }
}
