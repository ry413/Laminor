import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:provider/provider.dart';

// 好可怕

class PanelConfigPage extends StatefulWidget {
  static final GlobalKey<PanelConfigPageState> globalKey =
      GlobalKey<PanelConfigPageState>();

  PanelConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  PanelConfigPageState createState() => PanelConfigPageState();
}

class PanelConfigPageState extends State<PanelConfigPage> {
  @override
  Widget build(BuildContext context) {
    final panelConfigNotifier = context.watch<PanelConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('面板配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: panelConfigNotifier.allPanel.length,
              itemBuilder: (context, index) {
                return PanelWidget(
                  panel: panelConfigNotifier.allPanel[index],
                  onDelete: () {
                    panelConfigNotifier.removeAt(index);
                  },
                );
              },
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(context, PanelType.fourButton);
                  },
                  child: const Text('新增 四键面板'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(context, PanelType.sixButton);
                  },
                  child: const Text('新增 六键面板'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(
                        context, PanelType.eightButton);
                  },
                  child: const Text('新增 八键面板'),
                ),
              ],
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class PanelWidget extends StatefulWidget {
  final Panel panel;
  final Function onDelete;

  const PanelWidget({required this.panel, required this.onDelete});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late TextEditingController panelIdController;
  late TextEditingController panelNameController;
  late List<TextEditingController> buttonIdControllers;

  @override
  void initState() {
    super.initState();
    panelIdController = TextEditingController(text: widget.panel.id.toString());
    panelNameController = TextEditingController(text: widget.panel.name);
    buttonIdControllers = List.generate(
        widget.panel.buttons.length,
        (i) =>
            TextEditingController(text: widget.panel.buttons[i].id.toString()));
  }

  @override
  void dispose() {
    panelIdController.dispose();
    panelNameController.dispose();
    for (var controller in buttonIdControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果 panel.id 发生变化，更新 panelIdController
    if (widget.panel.id != oldWidget.panel.id) {
      panelIdController.text = widget.panel.id.toString();
    }

    // 如果 panel.name 发生变化，更新 panelNameController
    if (widget.panel.name != oldWidget.panel.name) {
      panelNameController.text = widget.panel.name;
    }

    // 如果按钮数量发生变化，重新生成 buttonIdControllers
    if (widget.panel.buttons.length != oldWidget.panel.buttons.length) {
      for (var controller in buttonIdControllers) {
        controller.dispose(); // 先释放旧的资源
      }
      buttonIdControllers = List.generate(
        widget.panel.buttons.length,
        (i) =>
            TextEditingController(text: widget.panel.buttons[i].id.toString()),
      );
    } else {
      // 如果数量没变，检查每个按钮的 ID 是否需要更新
      for (int i = 0; i < widget.panel.buttons.length; i++) {
        if (widget.panel.buttons[i].id != oldWidget.panel.buttons[i].id) {
          buttonIdControllers[i].text = widget.panel.buttons[i].id.toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color.fromRGBO(225, 227, 228, 1),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 面板ID输入框
                IdInputField(
                  label: "面板ID: ",
                  controller: panelIdController,
                  initialValue: widget.panel.id,
                  onChanged: (value) {
                    setState(() {
                      widget.panel.id = value;
                    });
                  },
                ),

                // 面板名字输入框
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
                      controller: panelNameController,
                      onChanged: (value) {
                        setState(() {
                          widget.panel.name = value;
                        });
                      }),
                ),
                Tooltip(
                  message: '删除面板',
                  child: IconButton(
                    onPressed: () => widget.onDelete(),
                    icon: Icon(
                      Icons.delete_forever,
                      size: 24, // 图标大小
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.panel.buttons.length,
              itemBuilder: (context, index) {
                final button = widget.panel.buttons[index];
                return PanelButtonWidget(
                  key: ValueKey(button.id),
                  button: button,
                  buttonIdController: buttonIdControllers[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 构建操作目标设备的下拉菜单
  CustomDropdown<IDeviceBase> buildTargetDevice(int index, int i) {
    final deviceUid = widget
        .panel.buttons[index].panelActions[i].atomicActions.first.deviceUid;
    final allDevices = DeviceManager().allDevices;

    final selectedDevice = allDevices[deviceUid] ?? allDevices.values.first;

    return CustomDropdown<IDeviceBase>(
      selectedValue: selectedDevice,
      items: allDevices.values.toList(),
      itemLabel: (device) => device.name,
      onChanged: (device) {
        setState(() {
          widget.panel.buttons[index].panelActions[i].atomicActions.first
              .deviceUid = device!.uid;
          // 在更改目标设备时, 要同时重置选择的操作
          widget.panel.buttons[index].panelActions[i].atomicActions.first
              .operation = device.operations.first;
        });
      },
    );
  }
}

class PanelButtonWidget extends StatefulWidget {
  final PanelButton button;
  final TextEditingController buttonIdController;

  const PanelButtonWidget({
    super.key,
    required this.button,
    required this.buttonIdController,
  });

  @override
  State<PanelButtonWidget> createState() => _PanelButtonWidgetState();
}

class _PanelButtonWidgetState extends State<PanelButtonWidget> {
  @override
  Widget build(BuildContext context) {
    final currentActionGroup =
        widget.button.panelActions[widget.button.currentActionGroupIndex];

    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 208, 215, 223), // 按键背景色
          border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 按钮ID和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: IdInputField(
                      label: "按钮ID:",
                      controller: widget.buttonIdController,
                      initialValue: widget.button.id,
                      onChanged: (value) {
                        setState(() {
                          widget.button.id = value;
                        });
                      }),
                ),
                // 左翻页按钮
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 20),
                  onPressed: widget.button.currentActionGroupIndex > 0
                      ? () {
                          setState(() {
                            widget.button.currentActionGroupIndex--;
                          });
                        }
                      : null,
                ),
                Text(
                  '动作组 ${widget.button.currentActionGroupIndex + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // 右翻页按钮
                IconButton(
                  icon: Icon(Icons.arrow_forward, size: 20),
                  onPressed: widget.button.currentActionGroupIndex <
                          widget.button.panelActions.length - 1
                      ? () {
                          setState(() {
                            widget.button.currentActionGroupIndex++;
                          });
                        }
                      : null,
                ),
                SizedBox(width: 20),
                Tooltip(
                  message: '添加动作组',
                  child: IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 24,
                    ),
                    onPressed: () {
                      if (DeviceManager().allDevices.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('请先添加设备')));
                        return;
                      }
                      setState(() {
                        if (widget.button.panelActions.length < 4) {
                          widget.button.panelActions.add(PanelButtonAction(
                              atomicActions: [
                                AtomicAction(
                                    deviceUid: DeviceManager()
                                        .allDevices
                                        .values
                                        .first
                                        .uid,
                                    operation: DeviceManager()
                                        .allDevices
                                        .values
                                        .first
                                        .operations
                                        .first,
                                    parameter: 0)
                              ],
                              pressedPolitAction: ButtonPolitAction.ignore,
                              pressedOtherPolitAction:
                                  ButtonOtherPolitAction.ignore));
                          widget.button.currentActionGroupIndex =
                              widget.button.panelActions.length - 1;
                        }
                      });
                    },
                  ),
                ),
                // 删除动作组按钮
                Tooltip(
                  message: '删除当前动作组',
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 24,
                      color: Colors.red, // 设置删除按钮为红色，突出显示
                    ),
                    onPressed: widget.button.panelActions.length > 1
                        ? () {
                            setState(() {
                              // 删除当前动作组
                              widget.button.panelActions.removeAt(
                                  widget.button.currentActionGroupIndex);

                              // 调整 currentActionGroupIndex
                              if (widget.button.currentActionGroupIndex >=
                                  widget.button.panelActions.length) {
                                widget.button.currentActionGroupIndex =
                                    widget.button.panelActions.length - 1;
                              }
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            Column(
              children: List.generate(currentActionGroup.atomicActions.length,
                  (i) => buildAtomicActionRow(i)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: '添加新的动作',
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (DeviceManager().allDevices.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('请先添加设备')));
                        return;
                      }
                      setState(() {
                        currentActionGroup.atomicActions.add(
                          AtomicAction(
                              deviceUid:
                                  DeviceManager().allDevices.values.first.uid,
                              operation: DeviceManager()
                                  .allDevices
                                  .values
                                  .first
                                  .operations
                                  .first,
                              parameter: 0),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget buildAtomicActionRow(int index) {
    return Row(
      children: [
        // 目标设备下拉菜单
        Row(
          children: [
            SectionTitle(title: '对'),
            buildTargetDevice(index),
          ],
        ),
        // 展示此Device拥有的动作（操作）
        Row(
          children: [
            SectionTitle(title: '执行'),
            buildDeviceAction(index),
          ],
        ),

        Spacer(),
        // 按钮指示灯行为下拉菜单
        Row(
          children: [
            SectionTitle(title: '将本指示灯'),
            CustomDropdown<ButtonPolitAction>(
              selectedValue: widget
                  .button
                  .panelActions[widget.button.currentActionGroupIndex]
                  .pressedPolitAction,
              items: ButtonPolitAction.values,
              itemLabel: (item) => item.displayName,
              onChanged: (value) {
                setState(() {
                  widget
                      .button
                      .panelActions[widget.button.currentActionGroupIndex]
                      .pressedPolitAction = value!;
                });
              },
            ),
          ],
        ),
        SizedBox(width: 8),
        // 同面板其他指示灯行为下拉菜单
        Row(
          children: [
            SectionTitle(title: '将其他指示灯'),
            CustomDropdown<ButtonOtherPolitAction>(
              selectedValue: widget
                  .button
                  .panelActions[widget.button.currentActionGroupIndex]
                  .pressedOtherPolitAction,
              items: ButtonOtherPolitAction.values,
              itemLabel: (item) => item.displayName,
              onChanged: (value) {
                setState(() {
                  widget
                      .button
                      .panelActions[widget.button.currentActionGroupIndex]
                      .pressedOtherPolitAction = value!;
                });
              },
            ),
          ],
        ),
        // Spacer(),
        // 删除动作按钮
        DeleteBtnDense(
            message: '删除动作',
            onDelete: () {
              setState(() {
                widget
                    .button
                    .panelActions[widget.button.currentActionGroupIndex]
                    .atomicActions
                    .removeAt(index);
              });
            },
            size: 20),
        SizedBox(width: 8),
      ],
    );
  }

  // 构建目标设备的下拉菜单
  Widget buildTargetDevice(int index) {
    final deviceUid = widget
        .button
        .panelActions[widget.button.currentActionGroupIndex]
        .atomicActions[index]
        .deviceUid;
    final allDevices = DeviceManager().allDevices;

    final selectedDevice = allDevices[deviceUid] ?? allDevices.values.first;

    return CustomDropdown<IDeviceBase>(
      selectedValue: selectedDevice,
      items: allDevices.values.toList(),
      itemLabel: (device) => device.name,
      onChanged: (device) {
        setState(() {
          widget.button.panelActions[widget.button.currentActionGroupIndex]
              .atomicActions[index].deviceUid = device!.uid;
          // 重置操作
          widget.button.panelActions[widget.button.currentActionGroupIndex]
              .atomicActions[index].operation = device.operations.first;
        });
      },
    );
  }

  // 构建设备操作的下拉菜单
  Widget buildDeviceAction(int index) {
    final atomicAction = widget
        .button
        .panelActions[widget.button.currentActionGroupIndex]
        .atomicActions[index];

    final device = DeviceManager().allDevices[atomicAction.deviceUid];
    if (device == null) return SizedBox.shrink();

    return Row(
      children: [
        CustomDropdown<String>(
          selectedValue: atomicAction.operation,
          items: device.operations,
          itemLabel: (operation) => operation,
          onChanged: (value) {
            setState(() {
              atomicAction.operation = value!;
            });
          },
        ),
        if (device.runtimeType == Lamp &&
            (device as Lamp).type == LampType.dimmableLight) ...[
          SectionTitle(title: '至'),
          CustomDropdown<int>(
              selectedValue: atomicAction.parameter,
              items: List.generate(11, (i) => i),
              itemLabel: (value) => '${value * 10}%',
              onChanged: (value) {
                setState(() {
                  atomicAction.parameter = value!;
                });
              })
        ]
      ],
    );
  }
}
