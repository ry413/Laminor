import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/lamp_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
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
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;

                    final item = lampConfigNotifier.allLamp.removeAt(oldIndex);
                    lampConfigNotifier.allLamp.insert(newIndex, item);
                    lampConfigNotifier.updateWidget();
                  },
                  itemCount: lampConfigNotifier.allLamp.length,
                  itemBuilder: (context, index) {
                    final lamp = lampConfigNotifier.allLamp[index];
                    return LampWidget(
                      key: ValueKey(lamp),
                      index: index,
                      lamp: lamp,
                      onDelete: () {
                        lampConfigNotifier.removeAt(index);
                      },
                    );
                  },
                ),
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
  final int index;

  const LampWidget(
      {super.key,
      required this.lamp,
      required this.onDelete,
      required this.index});

  @override
  State<LampWidget> createState() => _LampWidgetState();
}

class _LampWidgetState extends State<LampWidget> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.lamp.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lampConfigNotifier = context.watch<LampNotifier>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 灯名字输入框
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
                  controller: nameController,
                  onChanged: (value) {
                    widget.lamp.name = value;
                    lampConfigNotifier.updateWidget(); // 输入名字时同步
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
                label: '电源',
                selectedValue: widget.lamp.channelPowerUid,
                onChanged: (newValue) {
                  setState(() {
                    widget.lamp.channelPowerUid = newValue;
                  });
                }),
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
            SizedBox(width: 40),
            ReorderableDragStartListener(
                index: widget.index, child: Icon(Icons.drag_handle))
          ],
        ),
      ),
    );
  }
}
