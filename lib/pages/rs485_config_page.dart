import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class RS485ConfigPage extends StatefulWidget {
  static final GlobalKey<RS485ConfigPageState> globalKey =
      GlobalKey<RS485ConfigPageState>();

  RS485ConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  RS485ConfigPageState createState() => RS485ConfigPageState();
}

class RS485ConfigPageState extends State<RS485ConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final rs485ConfigNotifier = context.watch<RS485ConfigNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('485配置'),
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

                    final keys =
                        rs485ConfigNotifier.allCommands.keys.toList();
                    final values = rs485ConfigNotifier.allCommands.values.toList();

                    final key = keys.removeAt(oldIndex);
                    final value = values.removeAt(oldIndex);

                    keys.insert(newIndex, key);
                    values.insert(newIndex, value);
                    
                    rs485ConfigNotifier.updateWidget();
                  },
                  itemCount: rs485ConfigNotifier.allCommands.length,
                  itemBuilder: (context, index) {
                    final command =
                        rs485ConfigNotifier.allCommands.values.toList()[index];
                    final key = rs485ConfigNotifier.allCommands.keys.toList()[index];
                    return RS485Widget(
                      key: ValueKey(key),
                      command: command,
                      onDelete: () {
                        rs485ConfigNotifier.removeRS485Command(key);
                      },
                      index: index,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatButton(
          message: '添加 485指令码',
          onPressed: () {
            rs485ConfigNotifier.addCommand();
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

class RS485Widget extends StatefulWidget {
  final RS485Command command;
  final Function onDelete;
  final int index;

  const RS485Widget(
      {super.key,
      required this.command,
      required this.onDelete,
      required this.index});

  @override
  State<RS485Widget> createState() => _RS485WidgetState();
}

class _RS485WidgetState extends State<RS485Widget> {
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
  Widget build(BuildContext context) {
    final rs485ConfigNotifier = context.watch<RS485ConfigNotifier>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 指令码名字输入框
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 140),
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
                    widget.command.name = value;
                    rs485ConfigNotifier.updateWidget();
                  }),
            ),
            SizedBox(width: 20),
            // 指令码本体输入框
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250),
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
                  controller: codeController,
                  onChanged: (value) {
                    widget.command.code = value;
                    rs485ConfigNotifier.updateWidget();
                  }),
            ),
            Spacer(),
            Tooltip(
              message: '删除',
              child: InkWell(
                onTap: () => widget.onDelete(),
                child: Icon(
                  Icons.delete_forever,
                  size: 20,
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
