import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/providers/voice_config_provider.dart';
import 'package:provider/provider.dart';

class VoiceConfigPage extends StatefulWidget {
  static final GlobalKey<VoiceConfigPageState> globalKey =
      GlobalKey<VoiceConfigPageState>();

  VoiceConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  VoiceConfigPageState createState() => VoiceConfigPageState();
}

class VoiceConfigPageState extends State<VoiceConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final voiceNotifier = context.watch<VoiceConfigNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('语音配置'),
          backgroundColor: Color.fromRGBO(238, 239, 240, 1),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            color: Color.fromRGBO(238, 239, 240, 1),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: voiceNotifier.allVoiceCommands.length,
                itemBuilder: (context, index) {
                  return VoiceCommandWidget(
                    command: voiceNotifier.allVoiceCommands[index],
                    onDelete: () {
                      setState(() {
                        voiceNotifier.allVoiceCommands.removeAt(index);
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 80)
            ]),
          ),
        ),
        floatingActionButton: FloatButton(
          message: '添加 指令码',
          onPressed: () {
            voiceNotifier.addCommand();
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

class VoiceCommandWidget extends StatefulWidget {
  final VoiceCommand command;
  final Function onDelete;

  const VoiceCommandWidget({required this.command, required this.onDelete});

  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  late TextEditingController nameController;
  late TextEditingController codeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.command.name);
    codeController = TextEditingController(text: widget.command.code);
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoiceCommandWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.command.name != widget.command.name) {
      nameController.text = widget.command.name;
    }
    if (oldWidget.command.code != widget.command.code) {
      codeController.text = widget.command.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentActionGroupIndex = widget.command.currentActionGroupIndex;
    final actionGroup = widget.command.actionGroups[currentActionGroupIndex];
    final atomicActions = actionGroup.atomicActions;

    return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 208, 215, 223), // 按键背景色
          border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 按钮ID和操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 70),
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '名称',
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.brown),
                          ),
                        ),
                        controller: nameController,
                        onChanged: (value) {
                          setState(() {
                            widget.command.name = value;
                          });
                        }),
                  ),
                ),
                SizedBox(width: 8),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 140),
                    child: TextField(
                        decoration: InputDecoration(
                          labelText: '指令码',
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.brown),
                          ),
                        ),
                        controller: codeController,
                        onChanged: (value) {
                          setState(() {
                            widget.command.code = value;
                          });
                        }),
                  ),
                ),
                Spacer(),
                Tooltip(
                  message: '删除',
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 24,
                    ),
                    onPressed: () => widget.onDelete(),
                  ),
                ),
              ],
            ),
            // 当前动作组的动作列表
            ReorderableListView(
              buildDefaultDragHandles: false, // 关闭默认长按拖拽
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // 不要滚动
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = atomicActions.removeAt(oldIndex);
                  atomicActions.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < atomicActions.length; i++)
                  AtomicActionRowWidget(
                    key: ValueKey('atomicAction-$i'),
                    atomicAction: atomicActions[i],
                    index: i,
                    onDelete: () {
                      setState(() {
                        atomicActions.removeAt(i);
                      });
                    },
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                        actionGroup.atomicActions.add(
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
