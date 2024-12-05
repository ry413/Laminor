import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/other_device_config_provider.dart';
import 'package:provider/provider.dart';

class OtherDeviceConfigPage extends StatefulWidget {
  static final GlobalKey<OtherDeviceConfigPageState> globalKey =
      GlobalKey<OtherDeviceConfigPageState>();

  OtherDeviceConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  OtherDeviceConfigPageState createState() => OtherDeviceConfigPageState();
}

class OtherDeviceConfigPageState extends State<OtherDeviceConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final otherDeviceConfigNotifier = context.watch<OtherDeviceNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('其他设备配置'),
          backgroundColor: Color.fromRGBO(238, 239, 240, 1),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            color: Color.fromRGBO(238, 239, 240, 1),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: otherDeviceConfigNotifier.allOtherDevices.length,
                  itemBuilder: (context, index) {
                    final device =
                        otherDeviceConfigNotifier.allOtherDevices[index];
                    return OtherDeviceWidget(
                      device: device,
                      onDelete: () {
                        otherDeviceConfigNotifier.removeDevice(device.uid);
                      },
                    );
                  },
                ),
                SizedBox(height: 80)
              ],
            ),
          ),
        ),
        floatingActionButton: FloatButton(
          message: '添加 新设备',
          onPressed: () {
            otherDeviceConfigNotifier.addOtherDevice(context);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            });
          },
        ));
  }
}

class OtherDeviceWidget extends StatefulWidget {
  final OtherDevice device;
  final Function onDelete;

  const OtherDeviceWidget(
      {super.key, required this.device, required this.onDelete});

  @override
  State<OtherDeviceWidget> createState() => _OtherDeviceWidgetState();
}

class _OtherDeviceWidgetState extends State<OtherDeviceWidget> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.device.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherDeviceConfigNotifier = context.watch<OtherDeviceNotifier>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 设备名字输入框
            IntrinsicWidth(
              child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide(width: 1, color: Colors.brown),
                    ),
                  ),
                  controller: nameController,
                  onChanged: (value) {
                    widget.device.name = value;
                    otherDeviceConfigNotifier.updateWidget(); // 输入名字时同步
                  }),
            ),
            // 类型选择
            CustomDropdown(
                selectedValue: widget.device.type,
                items: OtherDeviceType.values,
                itemLabel: (type) => type.displayName,
                onChanged: (value) {
                  setState(() {
                    widget.device.type = value!;
                    if (widget.device.type == OtherDeviceType.outputControl) {
                      widget.device.output = BoardManager().allOutputs.values.first;
                    }
                  });
                }),
            SizedBox(width: 8),
            if (widget.device.type == OtherDeviceType.outputControl) ...[
              // 继电器设定
              BoardOutputDropdown(
                  label: '通道',
                  selectedOutput: widget.device.output!,
                  onChanged: (newValue) {
                    setState(() {
                      widget.device.output = newValue;
                    });
                  }),
            ],
            Spacer(),
            DeleteBtnDense(
                message: '删除', onDelete: () => widget.onDelete(), size: 20),
            SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
