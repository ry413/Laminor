import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/rs485_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: rs485ConfigNotifier.allCommands.length,
                  itemBuilder: (context, index) {
                    final command =
                        rs485ConfigNotifier.allCommands[index];
                    return RS485Widget(
                      command: command,
                      onDelete: () {
                        rs485ConfigNotifier.removeDevice(command.uid);
                      },
                    );
                  },
                ),
                SizedBox(height: 80)
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

  const RS485Widget(
      {super.key,
      required this.command,
      required this.onDelete});

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
  void didUpdateWidget(RS485Widget oldWidget) {
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
    final rs485ConfigNotifier = context.watch<RS485ConfigNotifier>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 指令码名字输入框
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
                  controller: nameController,
                  onChanged: (value) {
                    widget.command.name = value;
                    rs485ConfigNotifier.updateWidget();
                  }),
            ),
            Spacer(),
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
            SizedBox(width: 60),
            Tooltip(
              message: '删除',
              child: InkWell(
                canRequestFocus: false,
                onTap: () => widget.onDelete(),
                child: Icon(
                  Icons.delete_forever,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}
