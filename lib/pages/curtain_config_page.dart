import 'package:flutter/material.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:provider/provider.dart';

class CurtainConfigPage extends StatefulWidget {
  static final GlobalKey<CurtainConfigPageState> globalKey =
      GlobalKey<CurtainConfigPageState>();

  CurtainConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  CurtainConfigPageState createState() => CurtainConfigPageState();
}

class CurtainConfigPageState extends State<CurtainConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final curtainConfigNotifier = context.watch<CurtainNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('窗帘配置'),
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
                  itemCount: curtainConfigNotifier.allCurtains.length,
                  itemBuilder: (context, index) {
                    final curtain = curtainConfigNotifier.allCurtains[index];
                    return CurtainWidget(
                      curtain: curtain,
                      onDelete: () {
                        curtainConfigNotifier.removeDevice(curtain.uid);
                      }
                    );
                  },
                ),
                SizedBox(height: 80)
              ],
            ),
          ),
        ),
        floatingActionButton: FloatButton(
          message: '添加 窗帘',
          onPressed: () {
            curtainConfigNotifier.addCurtain(context);
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

class CurtainWidget extends StatefulWidget {
  final Curtain curtain;
  final Function onDelete;

  const CurtainWidget(
      {super.key,
      required this.curtain,
      required this.onDelete});

  @override
  State<CurtainWidget> createState() => _CurtainWidgetState();
}

class _CurtainWidgetState extends State<CurtainWidget> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.curtain.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curtainConfigNotifier = context.watch<CurtainNotifier>();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 窗帘名字输入框
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
                    widget.curtain.name = value;
                    curtainConfigNotifier.updateWidget(); // 输入名字时同步
                  }),
            ),
            SizedBox(width: 20),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 继电器设定
                BoardOutputDropdown(
                    label: '开: ',
                    selectedOutput: widget.curtain.outputOpen,
                    onChanged: (newValue) {
                      setState(() {
                        widget.curtain.outputOpen = newValue;
                      });
                    }),
                // 继电器设定
                BoardOutputDropdown(
                    label: '关: ',
                    selectedOutput: widget.curtain.outputClose,
                    onChanged: (newValue) {
                      setState(() {
                        widget.curtain.outputClose = newValue;
                      });
                    }),
              ],
            ),
            InputField(
                label: '运行时长(秒): ',
                value: widget.curtain.runDuration,
                onChanged: (value) {
                  widget.curtain.runDuration = value;
                }),
            SizedBox(width: 20),
            DeleteBtnDense(message: '删除', onDelete: () => widget.onDelete(), size: 20),
            SizedBox(width: 40),
          ],
        ),
      ),
    );
  }
}