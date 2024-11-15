import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
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
                      .updateActionGroups(Map.fromIterables(keys, values));
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
          ],
        ),
      ),
      floatingActionButton: FloatButton(
          message: '添加动作组',
          onPressed: () {
            actionConfigNotifier.addOrUpdateActionGroup(
                Action(type: getAvailableActionTypes(context).first));
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
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 120),
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
              controller: controller,
              onChanged: (value) {
                widget.actionGroup.name = value;
                actionConfigNotifier.updateWidget();
              }),
        ),
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
                  SizedBox(width: 25),
                  SectionTitle(title: '操作类型'),
                  SizedBox(width: 25),
                  SectionTitle(title: '目标'),
                  Spacer(),
                  Tooltip(
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
                  Tooltip(
                    message: '删除动作组',
                    child: IconButton(
                      onPressed: () => widget.onDelete(),
                      icon: Icon(
                        Icons.delete_forever,
                        size: 24, // 图标大小
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
        TextEditingController(text: widget.action.delayTime.toString());
  }

  @override
  void dispose() {
    _delayTimeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ActionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步 _delayTimeController 的内容
    if (widget.action.delayTime != oldWidget.action.delayTime) {
      _delayTimeController.text = widget.action.delayTime?.toString() ??
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

    final allLamp = context.watch<LampNotifier>().allLamp;
    final allACConfig = context.watch<AirConNotifier>().allAirCons;
    final allActionGroup = context.watch<ActionConfigNotifier>().allActionGroup;

    if (widget.action.type == ActionType.lamp) {
      if (!allLamp.contains(widget.action.lamp)) {
        widget.action.lamp = allLamp[0];
      }

      widgets = [
        SectionTitle(title: '对'),
        // 目标灯
        CustomDropdown<Lamp>(
            selectedValue: widget.action.lamp!,
            items: allLamp,
            itemLabel: (lamp) => lamp.name,
            onChanged: (lamp) {
              setState(() {
                widget.action.lamp = lamp!;
              });
            }),
        SectionTitle(title: '执行'),
        // 操作
        CustomDropdown<String>(
          selectedValue: widget.action.operation,
          items: widget.action.lamp!.operations,
          itemLabel: (operation) => operation,
          onChanged: (oparation) {
            setState(() {
              widget.action.operation = oparation!;
            });
          },
        )
      ];
    }
    // 操作空调
    else if (widget.action.type == ActionType.airCon) {
      if (!allACConfig.contains(widget.action.airCon)) {
        widget.action.airCon = allACConfig[0];
      }

      widgets = [
        SectionTitle(title: '对'),
        // 目标空调
        CustomDropdown<AirCon>(
            selectedValue: widget.action.airCon!,
            items: allACConfig,
            itemLabel: (airCon) => airCon.name,
            onChanged: (airCon) {
              setState(() {
                widget.action.airCon = airCon!;
              });
            }),
        SectionTitle(title: '执行'),
        // 操作
        CustomDropdown<String>(
          selectedValue: widget.action.operation,
          items: widget.action.airCon!.operations,
          itemLabel: (operation) => operation,
          onChanged: (oparation) {
            setState(() {
              widget.action.operation = oparation!;
            });
          },
        )
      ];
    } else if (widget.action.type == ActionType.actionGroup) {
      widget.action.actionGroupUid ??= allActionGroup.values.first.uid;
      widgets = [
        // 调用动作组
        CustomDropdown<int>(
            selectedValue: widget.action.actionGroupUid!,
            items: allActionGroup.keys.toList(),
            itemLabel: (uid) => allActionGroup[uid]!.name,
            onChanged: (uid) {
              setState(() {
                widget.action.actionGroupUid = uid;
              });
            }),
      ];
    }
    // 延时
    else if (widget.action.type == ActionType.delay) {
      if (widget.action.delayTime == null) {
        widget.action.delayTime ??= 0;
        _delayTimeController.text = widget.action.delayTime.toString();
      }

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
                  widget.action.delayTime = int.tryParse(value);
                });
              }),
        ),
        SizedBox(width: 6),
        Text('秒'),
        Spacer(),
      ];
    } else {
      widgets = [];
    }

    widgets.addAll([
      Spacer(),
      Tooltip(
        message: '删除',
        child: InkWell(
          onTap: () => widget.onDelete(),
          child: Icon(
            Icons.delete_forever,
            size: 20, // 图标大小
          ),
        ),
      ),
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
}

// 返回可用的操作类型
List<ActionType> getAvailableActionTypes(BuildContext context) {
  final allLamp = Provider.of<LampNotifier>(context, listen: false).allLamp;
  final allAirCon =
      Provider.of<AirConNotifier>(context, listen: false).allAirCons;
  final allActionGroup =
      Provider.of<ActionConfigNotifier>(context, listen: false).allActionGroup;

  List<ActionType> availableTypes = [];

  if (allLamp.isNotEmpty) {
    availableTypes.add(ActionType.lamp);
  }

  if (allAirCon.isNotEmpty) {
    availableTypes.add(ActionType.airCon);
  }

  // 但是, 这个部件不就是动作组吗, 动作组难道会被删光?
  if (allActionGroup.isNotEmpty) {
    availableTypes.add(ActionType.actionGroup);
  }
  // 最极端的就是只有延时, 看谁能把这个删光, 所以无论如何都会有一个延时可以选择
  availableTypes.add(ActionType.delay);

  return availableTypes;
}
