import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_1/commons/interface.dart';
import 'package:flutter_web_1/commons/managers.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/providers/other_device_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class ConfigSection extends StatelessWidget {
  const ConfigSection({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(
          horizontal: 12.0, vertical: 4.0), // 调整padding以减少行间距
      decoration: BoxDecoration(
        color: Color.fromRGBO(234, 235, 236, 1),
        border: Border.all(color: Color.fromRGBO(221, 222, 223, 1)),
        borderRadius: BorderRadius.circular(12.0), // 设置圆角
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0), // 进一步缩小每行之间的间距
              child: children[i],
            ),
            if (i < children.length - 1)
              const Divider(height: 0.5, thickness: 0.5), // 添加分割线，保持紧凑
          ],
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// 配置行部件
class ConfigRowDropdown<T> extends StatelessWidget {
  final String label;
  final T selectedValue;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;

  ConfigRowDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        CustomDropdown(
            selectedValue: selectedValue,
            items: items,
            itemLabel: itemLabel,
            onChanged: onChanged)
      ],
    );
  }
}

class BoardOutputDropdown extends StatefulWidget {
  final String label;
  final BoardOutput selectedOutput;
  final void Function(BoardOutput) onChanged;

  BoardOutputDropdown(
      {required this.label,
      required this.selectedOutput,
      required this.onChanged});

  @override
  State<BoardOutputDropdown> createState() => _BoardOutputDropdownState();
}

class _BoardOutputDropdownState extends State<BoardOutputDropdown> {
  @override
  Widget build(BuildContext context) {
    final allOutput = context.watch<BoardConfigNotifier>().allOutputs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        CustomDropdown<BoardOutput>(
          selectedValue: allOutput.containsValue(widget.selectedOutput)
              ? widget.selectedOutput
              : allOutput.values.first,
          items: allOutput.values.toList(),
          itemLabel: (output) =>
              '${output.name} (板 ${output.hostBoardId} 输出 ${output.channel})',
          onChanged: (output) => widget.onChanged(output!),
          itemStyleBuilder: (output, isSelected, isHovered) {
            // 如果是 BoardOutput 类型，检查 inUse 状态
            // 若 inUse 为 true 则使用橙色底色，否则使用默认逻辑
            if (output.inUse) {
              return BoxDecoration(
                color: isSelected
                    ? Colors.orange.withOpacity(0.3)
                    : isHovered
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              );
            } else {
              // 未被占用的输出通道，使用默认颜色方案
              return BoxDecoration(
                color: isSelected
                    ? Colors.blue.withOpacity(0.1)
                    : isHovered
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class IdInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final int initialValue;
  final Function(int) onChanged;

  IdInputField(
      {required this.controller,
      required this.label,
      required this.initialValue,
      required this.onChanged});

  @override
  State<IdInputField> createState() => _IDInputFieldState();
}

class _IDInputFieldState extends State<IdInputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 60),
          child: TextField(
              decoration: InputDecoration(
                labelText: widget.label,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: widget.controller,
              onChanged: (value) {
                if (value.isEmpty) {
                  widget.onChanged(0);
                } else {
                  widget.onChanged(int.parse(value));
                }
              })),
    );
  }
}

// 单个输入框组件
class InputField extends StatefulWidget {
  final String label;
  final int value;
  final Function(int) onChanged;
  final bool isRow; // 新增的布尔参数

  InputField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isRow = false, // 默认为false，默认使用Column
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 根据 isRow 的值决定返回 Row 或 Column
    final layout = widget.isRow
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildChildren(context),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildChildren(context),
          );

    return layout;
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      Text(
        widget.label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(width: 8, height: 8), // 调整间距
      SizedBox(
        width: 50,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(1.0),
              borderSide: const BorderSide(
                width: 1.0,
                color: Colors.brown,
              ), // 调整边框的颜色和宽度
            ),
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          cursorWidth: 1.0,
          cursorHeight:
              Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16.0 * 1.2,
          cursorColor: Colors.brown,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isEmpty) {
              widget.onChanged(0);
            } else {
              widget.onChanged(int.parse(value));
            }
          },
        ),
      ),
    ];
  }
}

class CustomDropdown<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final BoxDecoration Function(T item, bool isSelected, bool isHovered)?
      itemStyleBuilder;

  const CustomDropdown(
      {super.key,
      required this.selectedValue,
      required this.items,
      required this.itemLabel,
      required this.onChanged,
      this.itemStyleBuilder});

  @override
  CustomDropdownState<T> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final MenuController _menuController = MenuController();
  T? _hoveredItem; // 用于存储当前悬停的项
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      alignmentOffset: Offset(0, 0),
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) {
            setState(() {
              _isHovered = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isHovered = false;
            });
          },
          child: GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Container(
              constraints: BoxConstraints(
                minWidth: 80, // 设置最小宽度
              ),
              padding: EdgeInsets.only(left: 4, top: 1, bottom: 1),
              decoration: BoxDecoration(
                color: _isHovered || controller.isOpen ? Colors.white : null,
                border: _isHovered || controller.isOpen
                    ? Border.all(width: 0.2, color: Colors.grey)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Text(widget.itemLabel(widget.selectedValue),
                          overflow: TextOverflow.ellipsis, maxLines: 1)),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        );
      },
      menuChildren: widget.items.map((T item) {
        bool isSelected = item == widget.selectedValue;
        bool isHovered = item == _hoveredItem; // 判断是否悬停

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredItem = item),
          onExit: (_) => setState(() => _hoveredItem = null),
          child: GestureDetector(
            onTap: () {
              widget.onChanged(item);
              _menuController.close();
            },
            child: Container(
              constraints: BoxConstraints(
                minWidth: 80, // 设置最小宽度
              ),
              padding: EdgeInsets.only(left: 4, top: 3, bottom: 3),
              decoration: widget.itemStyleBuilder != null
                  ? widget.itemStyleBuilder!(item, isSelected, isHovered)
                  : // 如果未传入自定义回调, 则使用默认逻辑
                  BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : isHovered
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
              child: Row(
                children: [
                  Text(
                    widget.itemLabel(item),
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Spacer(),
                  if (isSelected)
                    Icon(Icons.check, color: Colors.blue), // 选中项的勾选图标
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// 小型删除按钮, 不会把行挤高
class DeleteBtnDense extends StatelessWidget {
  final String message;
  final Function onDelete;
  final double size;
  const DeleteBtnDense(
      {required this.message, required this.onDelete, required this.size});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: InkWell(
        canRequestFocus: false,
        onTap: () => onDelete(),
        child: Icon(
          Icons.delete_forever,
          size: size,
        ),
      ),
    );
  }
}

// 悬浮于页面右下角的按钮
class FloatButton extends StatelessWidget {
  final String message;
  final Function onPressed;

  const FloatButton({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: FloatingActionButton(
        onPressed: () => onPressed(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AtomicActionRowWidget extends StatefulWidget {
  final AtomicAction atomicAction;
  final Function onDelete;
  final int index;

  const AtomicActionRowWidget({
    super.key,
    required this.atomicAction,
    required this.onDelete,
    required this.index
  });

  @override
  AtomicActionRowWidgetState createState() => AtomicActionRowWidgetState();
}

class AtomicActionRowWidgetState extends State<AtomicActionRowWidget> {
  late TextEditingController _paramController;

  @override
  void initState() {
    super.initState();
    // 初始化延时输入框文本
    _paramController =
        TextEditingController(text: widget.atomicAction.parameter.toString());
  }

  @override
  void dispose() {
    _paramController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AtomicActionRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.atomicAction.parameter != oldWidget.atomicAction.parameter) {
      _paramController.text = widget.atomicAction.parameter.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final atomicAction = widget.atomicAction;

    return Row(
      children: [
        // 拖拽手柄
        ReorderableDragStartListener(
          index: widget.index, // 绑定拖拽索引
          child: Icon(Icons.drag_handle, size: 20), // 手柄图标
        ),
        // 目标设备下拉菜单
        Row(
          children: [
            SectionTitle(title: '目标:'),
            buildTargetDevice(atomicAction, atomicAction.deviceUid),
          ],
        ),
        SizedBox(width: 20),
        // 展示此Device拥有的操作
        Row(
          children: [
            SectionTitle(title: '操作:'),
            buildDeviceOperation(atomicAction),
          ],
        ),
        Spacer(),
        // 删除动作按钮
        DeleteBtnDense(
          message: '',
          onDelete: () => widget.onDelete(),
          size: 20,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget buildTargetDevice(AtomicAction atomicAction, int oldDeviceUid) {
    final allDevices = DeviceManager().allDevices;
    final selectedDevice =
        allDevices[atomicAction.deviceUid] ?? allDevices.values.first;

    return CustomDropdown<IDeviceBase>(
      selectedValue: selectedDevice,
      items: allDevices.values.toList(),
      itemLabel: (device) => device.name,
      onChanged: (device) {
        setState(() {
          // 删除对旧设备的引用计数
          DeviceManager().allDevices[oldDeviceUid]?.removeUsage();

          atomicAction.deviceUid = device!.uid;
          // 增加对新设备的引用计数
          device.addUsage();

          // 重置操作
          atomicAction.operation = device.operations.first;
          // 重置参数
          atomicAction.parameter = "";
        });
      },
      itemStyleBuilder: (device, isSelected, isHovered) {
        // 若 inUse 为 true 则使用橙色底色，否则使用默认逻辑
        if (device.inUse) {
          return BoxDecoration(
            color: isSelected
                ? Colors.orange.withOpacity(0.3)
                : isHovered
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          );
        } else {
          return BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.1)
                : isHovered
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          );
        }
      },
    );
  }

  Widget buildDeviceOperation(AtomicAction atomicAction) {
    final device = DeviceManager().allDevices[atomicAction.deviceUid];
    if (device == null) return SizedBox.shrink();

    List<Widget> children = [
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
    ];

    if (device is Lamp && device.type == LampType.dimmableLight) {
      children.addAll([
        SectionTitle(title: '至'),
        CustomDropdown<int>(
          selectedValue: atomicAction.parameter.isNotEmpty
              ? int.parse(atomicAction.parameter)
              : 0,
          items: List.generate(11, (i) => i),
          itemLabel: (value) => '${value * 10}%',
          onChanged: (value) {
            setState(() {
              atomicAction.parameter = value.toString();
            });
          },
        ),
      ]);
    } else if (device is OtherDevice &&
        device.type == OtherDeviceType.delayer) {
      children.addAll([
        IntrinsicWidth(
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(width: 1, color: Colors.brown),
              ),
            ),
            controller: _paramController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {
                atomicAction.parameter = value;
              });
            },
          ),
        ),
        SectionTitle(title: '秒'),
      ]);
    } else if (device is OtherDevice &&
        device.type == OtherDeviceType.actionGroup) {
      int selectedValue = atomicAction.parameter.isNotEmpty
          ? int.parse(atomicAction.parameter)
          : 0;

      if (!ActionGroupManager().allActionGroups.containsKey(selectedValue)) {
        selectedValue = ActionGroupManager().allActionGroups.keys.first;
      }

      children.addAll([
        CustomDropdown(
            selectedValue: selectedValue,
            items: ActionGroupManager().allActionGroups.keys.toList(),
            itemLabel: (uid) {
              ActionGroupBase actionGroup =
                  ActionGroupManager().allActionGroups[uid] ??
                      ActionGroupManager().allActionGroups.values.first;
              return '动作组${actionGroup.uid.toString()}';
            },
            onChanged: (uid) {
              setState(() {
                atomicAction.parameter = uid.toString();
              });
            })
      ]);
    } else if (device is OtherDevice &&
        device.type == OtherDeviceType.stateSetter) {
      children.addAll([
        IntrinsicWidth(
          child: TextField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(width: 1, color: Colors.brown),
              ),
            ),
            controller: _paramController,
            onChanged: (value) {
              setState(() {
                atomicAction.parameter = value;
              });
            },
          ),
        ),
        // SectionTitle(title: '秒'),
      ]);
    } else if (device is AirCon &&
        // device.type == ACType.single &&
        atomicAction.operation == "调节温度") {
      children.addAll([
        SectionTitle(title: '至'),
        CustomDropdown<int>(
            selectedValue: atomicAction.parameter.isNotEmpty
            ? int.parse(atomicAction.parameter)
            : 16,
            items: List.generate(16, (i) => i + 16),
            itemLabel: (value) => value.toString(),
            onChanged: (value) {
              setState(() {
                atomicAction.parameter = value.toString();
              });
            }),
      ]);
    }

    return Row(children: children);
  }
}

class ScenarioCheckbox extends StatefulWidget {
  final String value; // 初始模式名称
  final Function(String)? onChange; // 模式名称变化回调

  const ScenarioCheckbox({
    super.key,
    this.value = '',
    this.onChange,
  });

  @override
  ScenarioCheckboxState createState() => ScenarioCheckboxState();
}

class ScenarioCheckboxState extends State<ScenarioCheckbox> {
  late TextEditingController _controller; // 输入框控制器

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value); // 初始化控制器
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 120),
            child: TextField(
              controller: _controller, // 绑定控制器
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(width: 1, color: Colors.brown),
                ),
                labelText: '进入模式',
                hintText: '留空则禁用',
              ),
              onChanged: (value) {
                // 回调通知模式名称变化
                if (widget.onChange != null) {
                  widget.onChange!(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelect<T> extends StatefulWidget {
  final String title;
  final String describe;
  final List<T> selectedItems;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(List<T>) onConfirm;

  const MultiSelect(
      {super.key,
      required this.title,
      required this.describe,
      required this.selectedItems,
      required this.items,
      required this.itemLabel,
      required this.onConfirm});

  @override
  MultiSelectState<T> createState() => MultiSelectState<T>();
}

class MultiSelectState<T> extends State<MultiSelect<T>> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MultiSelectDialogField<T>(
          buttonText: Text(
            "${widget.title}\n${widget.selectedItems.length}",
          ),
          items: widget.items
              .map((item) => MultiSelectItem<T>(item, widget.itemLabel(item)))
              .toList(),
          title: Row(
            children: [
              Text(widget.title),
              SizedBox(width: 8),
              Text(
                widget.describe,
                style: TextStyle(fontSize: 14),
              )
            ],
          ),
          initialValue: widget.selectedItems,
          selectedColor: Colors.blue,
          onConfirm: (values) {
            widget.onConfirm(values.cast<T>());
          },
          chipDisplay: MultiSelectChipDisplay.none()),
    );
  }
}


class NoScrollController extends ScrollController {
  @override
  void attach(ScrollPosition position) {
    // 不调用 super.attach(position);
    // 或者你调用了也行，但要确保不会做任何 offset 变化
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition
  ) {
    // 给它一个不会动的 position
    return ScrollPositionWithSingleContext(
      physics: const NeverScrollableScrollPhysics(),
      context: context,
      oldPosition: oldPosition,
    );
  }

  // 其它 animateTo / jumpTo 都可以重写空实现
  @override
  void jumpTo(double value) {}
  @override
  Future<void> animateTo(double offset, {required Duration duration, required Curve curve}) {
    return Future.value();
  }
}