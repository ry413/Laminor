import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/uid_manager.dart';
import 'package:provider/provider.dart';

class BoardInputPage extends StatefulWidget {
  static final GlobalKey<BoardInputPageState> globalKey =
      GlobalKey<BoardInputPageState>();

  BoardInputPage({Key? key}) : super(key: key ?? globalKey);

  @override
  BoardInputPageState createState() => BoardInputPageState();
}

class BoardInputPageState extends State<BoardInputPage> {
  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('输入配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(children: [
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: boardNotifier.allBoard.length,
              itemBuilder: (context, index) {
                return BoardInputWidget(
                    board: boardNotifier.allBoard[index],
                    onDelete: () {
                      boardNotifier.allBoard.removeAt(index);
                    });
              })
        ]),
      ),
    );
  }
}

// 单块板子的所有输入 的部件
class BoardInputWidget extends StatefulWidget {
  final BoardConfig board;
  final Function onDelete;

  const BoardInputWidget({required this.board, required this.onDelete});

  @override
  State<BoardInputWidget> createState() => _BoardInputWidgetState();
}

class _BoardInputWidgetState extends State<BoardInputWidget> {
  List<TextEditingController> _inputChannelControllers = [];

  @override
  void initState() {
    super.initState();
    _inputChannelControllers = List.generate(
        widget.board.inputs.length,
        (i) => TextEditingController(
            text: widget.board.inputs[i].channel.toString()));
  }

  @override
  void dispose() {
    for (var controller in _inputChannelControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '板子 ${widget.board.id} 输入配置'),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(
              horizontal: 12.0, vertical: 4.0), // 调整padding以减少行间距
          decoration: BoxDecoration(
            color: Color.fromRGBO(234, 235, 236, 1),
            border: Border.all(color: Color.fromRGBO(221, 222, 223, 1)),
            borderRadius: BorderRadius.circular(12.0), // 设置圆角
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 通道列表
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.board.inputs.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      BoardInputUnit(
                        input: widget.board.inputs[index],
                        onDelete: () {
                          setState(() {
                            widget.board.removeInputAt(index);
                          });
                        },
                      ),
                      if (index < widget.board.inputs.length - 1)
                        const Divider(height: 1, thickness: 1),
                    ],
                  );
                },
              ),
              // 添加通道按钮
              Tooltip(
                message: '添加通道',
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    size: 28,
                  ),
                  onPressed: () {
                    if (DeviceManager().allDevices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('请先添加设备'),
                            duration: Duration(seconds: 1)),
                      );
                      return;
                    }
                    setState(() {
                      final input = BoardInput(
                        channel: 1,
                        level: InputLevel.high,
                        hostBoardId: widget.board.id,
                        actionGroups: [
                          InputActionGroup(
                            uid: UidManager().generateActionGroupUid(),
                            atomicActions: [],
                          ),
                        ],
                      );
                      for (var actionGroup in input.actionGroups) {
                        actionGroup.parent = input;
                        ActionGroupManager().addActionGroup(actionGroup);
                      }
                      widget.board.inputs.add(input);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 一个输入通道部件(行)
class BoardInputUnit extends StatefulWidget {
  final BoardInput input;
  final Function onDelete;

  const BoardInputUnit({
    required this.input,
    required this.onDelete,
  });

  @override
  State<BoardInputUnit> createState() => _BoardInputUnitState();
}

class _BoardInputUnitState extends State<BoardInputUnit> {
  late TextEditingController _channelController;

  @override
  void initState() {
    super.initState();
    _channelController =
        TextEditingController(text: widget.input.channel.toString());
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BoardInputUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步 channel 字段
    if (widget.input.channel != oldWidget.input.channel) {
      _channelController.text = widget.input.channel.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentActionGroupIndex = widget.input.currentActionGroupIndex;
    final actionGroup = widget.input.actionGroups[currentActionGroupIndex];
    final atomicActions = actionGroup.atomicActions;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 208, 215, 223), // 背景色
        border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 通道信息和控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 通道号输入框
              SectionTitle(title: '通道'),
              SizedBox(width: 8),
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
                    controller: _channelController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          widget.input.channel = 127;
                        } else {
                          widget.input.channel = int.parse(value);
                        }
                      });
                    }),
              ),
              SizedBox(width: 8),
              SectionTitle(title: '输入电平'),
              // 输入电平下拉菜单
              CustomDropdown<InputLevel>(
                selectedValue: widget.input.level,
                items: InputLevel.values,
                itemLabel: (item) => item.displayName,
                onChanged: (newValue) {
                  setState(() {
                    widget.input.level = newValue!;
                  });
                },
              ),
              // 删除通道按钮
              Tooltip(
                message: '删除通道',
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 24,
                  ),
                  onPressed: () => widget.onDelete(),
                ),
              ),
              ScenarioCheckbox(
                value: widget.input.modeName ?? '',
                onChange: (name) {
                  setState(() {
                    widget.input.modeName = name;
                  });
                },
              ),
              Spacer(),
              // 左翻页按钮
              IconButton(
                icon: Icon(Icons.arrow_back, size: 20),
                onPressed: widget.input.currentActionGroupIndex > 0
                    ? () {
                        setState(() {
                          widget.input.currentActionGroupIndex--;
                        });
                      }
                    : null, // 禁用当已经是第一个动作组
              ),
              // 动作组名称
              Text(
                '动作组 ${widget.input.currentActionGroupIndex + 1}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // 右翻页按钮
              IconButton(
                icon: Icon(Icons.arrow_forward, size: 20),
                onPressed: widget.input.currentActionGroupIndex <
                        widget.input.actionGroups.length - 1
                    ? () {
                        setState(() {
                          widget.input.currentActionGroupIndex++;
                        });
                      }
                    : null, // 禁用当已经是最后一个动作组
              ),
              // 添加动作组按钮
              Tooltip(
                message: '添加动作组',
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (widget.input.actionGroups.length < 4) {
                        final actionGroup = InputActionGroup(
                            uid: UidManager().generateActionGroupUid(),
                            atomicActions: []);
                        actionGroup.parent = widget.input;
                        ActionGroupManager().addActionGroup(actionGroup);
                        widget.input.actionGroups.add(actionGroup);
                        widget.input.currentActionGroupIndex =
                            widget.input.actionGroups.length - 1;
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
                  onPressed: widget.input.actionGroups.length > 1
                      ? () {
                          setState(() {
                            // 删除当前动作组
                            widget
                                .input
                                .actionGroups[
                                    widget.input.currentActionGroupIndex]
                                .remove();

                            widget.input.actionGroups
                                .removeAt(widget.input.currentActionGroupIndex);

                            // 更新 currentActionGroupIndex
                            if (widget.input.currentActionGroupIndex >=
                                widget.input.actionGroups.length) {
                              widget.input.currentActionGroupIndex =
                                  widget.input.actionGroups.length - 1;
                            }
                          });
                        }
                      : null,
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
          // 添加新的动作到当前动作组
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: '添加新的动作',
                child: IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () {
                    if (DeviceManager().allDevices.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('请先添加设备')),
                      );
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
      ),
    );
  }
}
