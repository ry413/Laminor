import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:provider/provider.dart';

class LampConfigPage extends StatefulWidget {
  static final GlobalKey<LampConfigPageState> globalKey =
      GlobalKey<LampConfigPageState>();

  LampConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  LampConfigPageState createState() => LampConfigPageState();
}

class LampConfigPageState extends State<LampConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final lampConfigNotifier = context.watch<LampNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('灯配置'),
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
                  itemCount: lampConfigNotifier.allLamps.length,
                  itemBuilder: (context, index) {
                    final lamp = lampConfigNotifier.allLamps[index];
                    return LampWidget(
                      lamp: lamp,
                      onDelete: () {
                        // 删除灯的时候减少引用
                        lamp.output.removeUsage();
                        lampConfigNotifier.removeDevice(lamp.uid);
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
          message: '添加 灯',
          onPressed: () {
            lampConfigNotifier.addLamp(context);
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

class LampWidget extends StatefulWidget {
  final Lamp lamp;
  final Function onDelete;

  const LampWidget({super.key, required this.lamp, required this.onDelete});

  @override
  State<LampWidget> createState() => _LampWidgetState();
}

class _LampWidgetState extends State<LampWidget> {
  late TextEditingController nameController;
  late TextEditingController stateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.lamp.name);
    stateController = TextEditingController(text: widget.lamp.causeState);
  }

  @override
  void dispose() {
    nameController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LampWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.lamp.name != widget.lamp.name) {
      nameController.text = widget.lamp.name;
    }
    if (oldWidget.lamp.causeState != widget.lamp.causeState) {
      stateController.text = widget.lamp.causeState;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 灯名字输入框
            IntrinsicWidth(
              child: TextField(
                  decoration: InputDecoration(
                    labelText: '名称',
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
                    setState(() {
                      widget.lamp.name = value;
                    });
                  }),
            ),
            // 灯类型选择
            CustomDropdown(
                selectedValue: widget.lamp.type,
                items: LampType.values,
                itemLabel: (type) => type.displayName,
                onChanged: (value) {
                  setState(() {
                    widget.lamp.type = value!;
                  });
                }),
            // 继电器设定
            BoardOutputDropdown(
                label: '',
                selectedOutput: widget.lamp.output,
                onChanged: (newValue) {
                  setState(() {
                    widget.lamp.output = newValue;
                  });
                }),
            Spacer(),
            // 造成状态
            IntrinsicWidth(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 90,
                ),
                child: TextField(
                    decoration: InputDecoration(
                      labelText: '影响状态',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.0),
                        borderSide: BorderSide(width: 1, color: Colors.brown),
                      ),
                    ),
                    controller: stateController,
                    onChanged: (value) {
                      setState(() {
                        widget.lamp.causeState = value;
                      });
                    }),
              ),
            ),

            // 联动设备
            MultiSelect<IDeviceBase>(
              title: '联动设备',
              describe: '对本设备的操作会同时操作联动设备设备',
              selectedItems: widget.lamp.linkDeviceUids
                  .map((uid) => DeviceManager().getDeviceByUid(uid))
                  .where((device) => device != null)
                  .cast<IDeviceBase>()
                  .toList(),
              items: DeviceManager().allDevices.values.toList(),
              itemLabel: (item) => item.name,
              onConfirm: (values) => {
                setState(() {
                  widget.lamp.linkDeviceUids =
                      values.map((item) => item.uid).toList();
                })
              },
            ),
            // 排斥设备
            MultiSelect<IDeviceBase>(
                title: '排斥设备',
                describe: '打开本设备时会关闭排斥设备',
                selectedItems: widget.lamp.repelDeviceUids
                    .map((uid) => DeviceManager().getDeviceByUid(uid))
                    .where((device) => device != null)
                    .cast<IDeviceBase>()
                    .toList(),
                items: DeviceManager().allDevices.values.toList(),
                itemLabel: (item) => item.name,
                onConfirm: (values) => {
                      setState(() {
                        widget.lamp.repelDeviceUids =
                            values.map((item) => item.uid).toList();
                      })
                    }),
            DeleteBtnDense(
                message: '删除', onDelete: () => widget.onDelete(), size: 20),
            SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
