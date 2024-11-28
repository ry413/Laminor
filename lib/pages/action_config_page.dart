import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class ActionConfigPage extends StatefulWidget {
  static final GlobalKey<ActionConfigPageState> globalKey =
      GlobalKey<ActionConfigPageState>();

  ActionConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  ActionConfigPageState createState() => ActionConfigPageState();
}

class ActionConfigPageState extends State<ActionConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final actionConfigNotifier = context.watch<ActionConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('动作配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                scrollController: _scrollController,
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;

                  final keys =
                      actionConfigNotifier.allActionGroup.keys.toList();
                  final values =
                      actionConfigNotifier.allActionGroup.values.toList();

                  final key = keys.removeAt(oldIndex);
                  final value = values.removeAt(oldIndex);

                  keys.insert(newIndex, key);
                  values.insert(newIndex, value);

                  actionConfigNotifier
                      .updateActionGroupsMap(Map.fromIterables(keys, values));
                },
                itemCount: actionConfigNotifier.allActionGroup.length,
                itemBuilder: (context, index) {
                  final actionGroup = actionConfigNotifier.allActionGroup.values
                      .toList()[index];
                  final key =
                      actionConfigNotifier.allActionGroup.keys.toList()[index];

                  return ActionGroupWidget(
                    key: ValueKey(key), // 设置唯一的 key
                    actionGroup: actionGroup,
                    onDelete: () {
                      actionConfigNotifier.removeActionGroup(key);
                    },
                    index: index,
                  );
                },
              ),
            ),
            SizedBox(height: 80)
          ],
        ),
      ),
      floatingActionButton: FloatButton(
          message: '添加动作组',
          onPressed: () {
            actionConfigNotifier.addOrUpdateActionGroup(
                Action(type: getAvailableActionTypes(context).first));
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            });
          }),
    );
  }
}

// 一个动作组
class ActionGroupWidget extends StatefulWidget {
  final ActionGroup actionGroup;
  final Function onDelete;
  final int index;
  const ActionGroupWidget(
      {super.key,
      required this.actionGroup,
      required this.onDelete,
      required this.index});

  @override
  State<ActionGroupWidget> createState() => _ActionGroupWidgetState();
}

class _ActionGroupWidgetState extends State<ActionGroupWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.actionGroup.name);
  }

  @override
  Widget build(BuildContext context) {
    final actionConfigNotifier = context.watch<ActionConfigNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    widget.index.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  IntrinsicWidth(
                    child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.brown),
                          ),
                        ),
                        controller: controller,
                        onChanged: (value) {
                          widget.actionGroup.name = value;
                          actionConfigNotifier.updateWidget();
                        }),
                  ),
                  Spacer(),
                  ExcludeFocus(
                    child: Tooltip(
                      message: '添加动作',
                      child: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.actionGroup.actions.add(Action(
                                type: getAvailableActionTypes(context).first));
                          });
                        },
                      ),
                    ),
                  ),
                  ExcludeFocus(
                    child: Tooltip(
                      message: '删除动作组',
                      child: IconButton(
                        onPressed: () => widget.onDelete(),
                        icon: Icon(
                          Icons.delete_forever,
                          size: 24, // 图标大小
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Icon(Icons.drag_handle, size: 32),
                  ),
                ],
              ),
              const Divider(height: 1, thickness: 1),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false, // 禁用默认的拖动句柄
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final action =
                        widget.actionGroup.actions.removeAt(oldIndex);
                    widget.actionGroup.actions.insert(newIndex, action);
                  });
                },
                itemCount: widget.actionGroup.actions.length,
                itemBuilder: (context, index) {
                  final action = widget.actionGroup.actions[index];
                  return ActionWidget(
                    key: ValueKey(action), // 设置唯一的 key
                    action: action,
                    onDelete: () {
                      setState(() {
                        widget.actionGroup.actions.removeAt(index);
                      });
                    },
                    index: index,
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }
}

// 一个动作组件(行)
class ActionWidget extends StatefulWidget {
  final Action action;
  final Function onDelete;
  final int index;

  const ActionWidget(
      {super.key,
      required this.action,
      required this.onDelete,
      required this.index});

  @override
  State<ActionWidget> createState() => _ActionWidgetState();
}

class _ActionWidgetState extends State<ActionWidget> {
  late TextEditingController _delayTimeController;

  @override
  void initState() {
    super.initState();
    _delayTimeController =
        TextEditingController(text: widget.action.parameter.toString());
  }

  @override
  void dispose() {
    _delayTimeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action.parameter != oldWidget.action.parameter) {
      _delayTimeController.text = widget.action.parameter?.toString() ??
          ''; // 如果 delayTime 为 null，设置为空字符串
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 序号
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: SizedBox(
                width: 20,
                child: Text(
                  '${widget.index + 1}',
                  textAlign: TextAlign.right,
                )),
          ),

          VerticalDivider(width: 1, thickness: 1),

          // 操作类型
          Expanded(
            flex: 1,
            child: CustomDropdown<ActionType>(
                selectedValue: widget.action.type,
                items: getAvailableActionTypes(context),
                itemLabel: (type) => type.displayName,
                onChanged: (type) {
                  setState(() {
                    widget.action.type = type!;
                  });
                }),
          ),

          VerticalDivider(width: 1, thickness: 1),

          // 动作内容
          Expanded(
            flex: 6,
            child: _buildActionContent(widget.index),
          )
        ],
      ),
    );
  }

  Widget _buildActionContent(int index) {
    List<Widget> widgets;

    final allOutputs = context.watch<BoardConfigNotifier>().allOutputs;
    final allLamps = context.watch<LampNotifier>().allLamps;
    final allAirCons = context.watch<AirConNotifier>().allAirCons;
    final allCurtains = context.watch<CurtainNotifier>().allCurtains;
    final allRS485Commands = context.watch<RS485ConfigNotifier>().allCommands;
    final allActionGroup = context.watch<ActionConfigNotifier>().allActionGroup;

    // 灯
    if (widget.action.type == ActionType.lamp) {
      repairUID(allLamps);
      final lampType = allLamps[widget.action.targetUID]!.type;

      // 没法在widgets里写这逻辑, 只能在这里初始化
      if (widget.action.operation == '调光' && widget.action.parameter == null) {
        widget.action.parameter = 1;
      }

      widgets = [
        SectionTitle(title: '对'),
        buildTargetDropdown(allLamps),
        SectionTitle(title: '执行'),

        // 普通灯
        if (lampType == LampType.normalLight) ...[
          buildOperationDropdown(LampType.normalLight.operations)
        ]
        // 调光灯
        else if (lampType == LampType.dimmableLight) ...[
          buildOperationDropdown(LampType.dimmableLight.operations),
          if (widget.action.operation == '调光') ...[
            SectionTitle(title: '至'),
            CustomDropdown<int>(
                selectedValue: widget.action.parameter as int,
                items: List.generate(11, (i) => i),
                itemLabel: (value) => '${value * 10}%',
                onChanged: (value) {
                  setState(() {
                    widget.action.parameter = value;
                  });
                })
          ]
        ]
      ];
    }
    // 空调
    else if (widget.action.type == ActionType.airCon) {
      repairUID(allAirCons);

      widgets = [
        SectionTitle(title: '对'),
        buildTargetDropdown(allAirCons),
        SectionTitle(title: '执行'),
        buildOperationDropdown(AirCon.operations),
      ];
    }
    // 窗帘
    else if (widget.action.type == ActionType.curtain) {
      repairUID(allCurtains);

      widgets = [
        SectionTitle(title: '对'),
        buildTargetDropdown(allCurtains),
        SectionTitle(title: '执行'),
        buildOperationDropdown(Curtain.operations)
      ];
    }
    // 485
    else if (widget.action.type == ActionType.rs485) {
      repairUID(allRS485Commands);

      widgets = [
        SectionTitle(title: '发送'),
        buildTargetDropdown(allRS485Commands),
      ];
      widget.action.operation = '发送'; // 485就一种操作
    }
    // 直接操控输出
    else if (widget.action.type == ActionType.output) {
      repairUID(allOutputs);

      widgets = [
        SectionTitle(title: '对'),
        buildTargetDropdown(allOutputs),
        SectionTitle(title: '执行'),
        buildOperationDropdown(['开', '关']),
      ];
    }
    // 动作组
    else if (widget.action.type == ActionType.actionGroup) {
      repairUID(allActionGroup);

      widgets = [
        SectionTitle(title: '对'),
        buildTargetDropdown(allActionGroup),
        SectionTitle(title: '执行'),
        buildOperationDropdown(ActionGroup.operations),
      ];
    }
    // 延时
    else if (widget.action.type == ActionType.delay) {
      if (widget.action.parameter == null) {
        widget.action.parameter = 0;
        _delayTimeController.text = widget.action.parameter.toString();
      } else if (widget.action.parameter is! int) {
        throw Exception('delay parameter 应该是 int 类型');
      }
      widget.action.operation = '延时';

      widgets = [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 120),
          child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              controller: _delayTimeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    widget.action.parameter = 0;
                  } else {
                    widget.action.parameter = int.parse(value);
                  }
                });
              }),
        ),
        SizedBox(width: 6),
        Text('秒'),
        Spacer(),
      ];
    } else {
      widgets = [];
      print("不可能的");
    }

    widgets.addAll([
      Spacer(),
      DeleteBtnDense(message: '删除动作', onDelete: () => widget.onDelete()),
      SizedBox(width: 20),
      ReorderableDragStartListener(
        index: index,
        child: Icon(Icons.drag_handle),
      ),
    ]);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      ),
    );
  }

  /// 保证targetUID指向绝对可用的对象
  void repairUID(Map<int, dynamic> deviceMap) {
    if (!deviceMap.containsKey(widget.action.targetUID) ||
        deviceMap[widget.action.targetUID] == null) {
      widget.action.targetUID = deviceMap.keys.first;
      print(
          '${widget.action.type}: widget.action.targetUID不存在, 修改为${widget.action.targetUID}');
    }
  }

  CustomDropdown<int> buildTargetDropdown(Map<int, dynamic> deviceMap) {
    return CustomDropdown<int>(
        selectedValue: widget.action.targetUID!,
        items: deviceMap.keys.toList(),
        itemLabel: (uid) => deviceMap[uid]!.name,
        onChanged: (uid) {
          setState(() {
            widget.action.targetUID = uid!;
          });
        });
  }

  CustomDropdown<String> buildOperationDropdown(List<String> operations) {
    if (!operations.contains(widget.action.operation)) {
      widget.action.operation = operations.first;
    }
    return CustomDropdown<String>(
      selectedValue: widget.action.operation,
      items: operations,
      itemLabel: (operation) => operation,
      onChanged: (oparation) {
        setState(() {
          widget.action.operation = oparation!;
        });
      },
    );
  }
}

// 返回可用的操作类型
List<ActionType> getAvailableActionTypes(BuildContext context) {
  final allLamp = Provider.of<LampNotifier>(context, listen: false).allLamps;
  final allAirCon =
      Provider.of<AirConNotifier>(context, listen: false).allAirCons;
  final allCurtain = Provider.of<CurtainNotifier>(context, listen: false).allCurtains;
  final allRS485Command =
      Provider.of<RS485ConfigNotifier>(context, listen: false).allCommands;
  final allOutputs =
      Provider.of<BoardConfigNotifier>(context, listen: false).allOutputs;
  final allActionGroup =
      Provider.of<ActionConfigNotifier>(context, listen: false).allActionGroup;

  List<ActionType> availableTypes = [];

  if (allLamp.isNotEmpty) {
    availableTypes.add(ActionType.lamp);
  }

  if (allAirCon.isNotEmpty) {
    availableTypes.add(ActionType.airCon);
  }

  if (allCurtain.isNotEmpty) {
    availableTypes.add(ActionType.curtain);
  }

  if (allRS485Command.isNotEmpty) {
    availableTypes.add(ActionType.rs485);
  }

  if (allOutputs.isNotEmpty) {
    availableTypes.add(ActionType.output);
  }

  // 但是, 这个部件不就是动作组吗, 动作组难道会被删光?
  if (allActionGroup.isNotEmpty) {
    availableTypes.add(ActionType.actionGroup);
  }
  // 最极端的就是只有延时, 看谁能把这个删光, 所以无论如何都会有一个延时可以选择
  availableTypes.add(ActionType.delay);

  return availableTypes;
}
