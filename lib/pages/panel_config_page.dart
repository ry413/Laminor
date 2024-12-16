import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/uid_manager.dart';
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
                    setState(() {
                      panelConfigNotifier.removeAt(index);
                    });
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
        widget.button.actionGroups[widget.button.currentActionGroupIndex];

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
                Text('指示灯受控于'),
                CustomDropdown<int>(
                  selectedValue: widget.button.explicitAssociatedDeviceUid,
                  items: DeviceManager().allDevices.keys.toList(),
                  itemLabel: (uid) => DeviceManager().allDevices[uid] != null
                      ? DeviceManager().allDevices[uid]!.name
                      : '无',
                  onChanged: (value) {
                    setState(() {
                      widget.button.explicitAssociatedDeviceUid = value!;
                    });
                  },
                ),
                ScenarioCheckbox(
                  value: widget.button.modeName ?? '',
                  onChange: (name) {
                    setState(() {
                      widget.button.modeName = name;
                    });
                  },
                ),
                Spacer(),
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
                          widget.button.actionGroups.length - 1
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
                      if (DeviceManager().allDevices.values.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('请先添加设备'),
                            duration: Duration(seconds: 1)));
                        return;
                      }
                      setState(() {
                        if (widget.button.actionGroups.length < 4) {
                          final actionGroup = PanelButtonActionGroup(
                              uid: UidManager().generateActionGroupUid(),
                              atomicActions: [],
                              pressedPolitAction: ButtonPolitAction.ignore,
                              pressedOtherPolitAction:
                                  ButtonOtherPolitAction.ignore);

                          actionGroup.parent = widget.button;
                          ActionGroupManager().addActionGroup(actionGroup);
                          widget.button.actionGroups.add(actionGroup);
                          widget.button.currentActionGroupIndex =
                              widget.button.actionGroups.length - 1;
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
                    onPressed: widget.button.actionGroups.length > 1
                        ? () {
                            setState(() {
                              // 删除当前动作组
                              // 从Manager里删除
                              widget
                                  .button
                                  .actionGroups[
                                      widget.button.currentActionGroupIndex]
                                  .remove();
                              // 从动作组列表里删除
                              widget.button.actionGroups.removeAt(
                                  widget.button.currentActionGroupIndex);

                              // 调整 currentActionGroupIndex
                              if (widget.button.currentActionGroupIndex >=
                                  widget.button.actionGroups.length) {
                                widget.button.currentActionGroupIndex =
                                    widget.button.actionGroups.length - 1;
                              }
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            Column(
              children: List.generate(
                  currentActionGroup.atomicActions.length,
                  (index) => AtomicActionRowWidget(
                      atomicAction: widget
                          .button
                          .actionGroups[widget.button.currentActionGroupIndex]
                          .atomicActions[index],
                      onDelete: () => {
                            setState(() {
                              widget
                                  .button
                                  .actionGroups[
                                      widget.button.currentActionGroupIndex]
                                  .atomicActions
                                  .removeAt(index);
                            })
                          })),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 按钮指示灯行为下拉菜单
                Row(
                  children: [
                    Text('执行完成后将本指示灯'),
                    // SectionTitle(title: '执行完成后将本指示灯'),
                    CustomDropdown<ButtonPolitAction>(
                      selectedValue: (widget.button.actionGroups[
                                  widget.button.currentActionGroupIndex]
                              as PanelButtonActionGroup)
                          .pressedPolitAction,
                      items: ButtonPolitAction.values,
                      itemLabel: (item) => item.displayName,
                      onChanged: (value) {
                        setState(() {
                          (widget.button.actionGroups[
                                      widget.button.currentActionGroupIndex]
                                  as PanelButtonActionGroup)
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
                    Text('将同面板其他指示灯'),
                    // SectionTitle(title: '将同面板其他指示灯'),
                    CustomDropdown<ButtonOtherPolitAction>(
                      selectedValue: (widget.button.actionGroups[
                                  widget.button.currentActionGroupIndex]
                              as PanelButtonActionGroup)
                          .pressedOtherPolitAction,
                      items: ButtonOtherPolitAction.values,
                      itemLabel: (item) => item.displayName,
                      onChanged: (value) {
                        setState(() {
                          (widget.button.actionGroups[
                                      widget.button.currentActionGroupIndex]
                                  as PanelButtonActionGroup)
                              .pressedOtherPolitAction = value!;
                        });
                      },
                    ),
                  ],
                ),
                Spacer(),
                // 添加动作按钮
                Tooltip(
                  message: '',
                  child: IconButton(
                    icon: Icon(Icons.add_circle),
                    onPressed: () {
                      if (DeviceManager().allDevices.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('请先添加设备'),
                            duration: Duration(seconds: 1)));
                        return;
                      }
                      setState(() {
                        currentActionGroup.atomicActions.add(
                          AtomicAction.defaultAction(),
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
}
