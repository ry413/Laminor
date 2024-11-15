import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
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
  final int selectedValue;    // 这是UID, 而不是索引什么的
  final void Function(int) onChanged;

  BoardOutputDropdown(
      {required this.label,
      required this.selectedValue,
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
            selectedValue: allOutput[widget.selectedValue] ?? allOutput.values.first,
            items: allOutput.values.toList(),
            itemLabel: (output) =>
                '${output.name} (板 ${output.hostBoardId} 输出通道 ${output.channel})',
            onChanged: (output) => widget.onChanged(output!.uid)),
      ],
    );
  }
}

class IdInputField extends StatefulWidget {
  final TextEditingController controller;
  final int initialValue;
  final Function(int) onChanged;

  IdInputField({
    required this.controller,
    required this.initialValue,
    required this.onChanged
  });

  @override
  State<IdInputField> createState() => _IDInputFieldState();
}

class _IDInputFieldState extends State<IdInputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Text('ID: ', style: Theme.of(context).textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 50),
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
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: widget.controller,
                onChanged: (value) => widget.onChanged(int.tryParse(value)!)),
          ),
        ),
      ],
    );
  }  
}

// 单个输入框组件
class InputField extends StatefulWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  InputField(
      {required this.label, required this.value, required this.onChanged});

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
    return Column(
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(
          width: 50,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.0),
                borderSide:
                    BorderSide(width: 1.0, color: Colors.brown), // 调整边框的颜色和宽度
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
              widget.onChanged(int.tryParse(value)!);
            },
          ),
        ),
      ],
    );
  }
}


class CustomDropdown<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

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
                border: _isHovered || controller.isOpen ? Border.all(width: 0.2, color: Colors.grey) : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(widget.itemLabel(widget.selectedValue), overflow: TextOverflow.ellipsis, maxLines: 1)),
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
              decoration: BoxDecoration(
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
  const DeleteBtnDense({
    required this.message,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: InkWell(
        onTap: () => onDelete(),
        child: Icon(
          Icons.delete_forever,
          size: 20,
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