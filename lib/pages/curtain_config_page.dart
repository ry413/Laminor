import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/curtain_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
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
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;

                    final keys =
                        curtainConfigNotifier.allCurtains.keys.toList();
                    final values =
                        curtainConfigNotifier.allCurtains.values.toList();

                    final key = keys.removeAt(oldIndex);
                    final value = values.removeAt(oldIndex);

                    keys.insert(newIndex, key);
                    values.insert(newIndex, value);

                    curtainConfigNotifier
                        .updateCurtainMap(Map.fromIterables(keys, values));
                  },
                  itemCount: curtainConfigNotifier.allCurtains.length,
                  itemBuilder: (context, index) {
                    final curtain = curtainConfigNotifier.allCurtains.values
                        .toList()[index];
                    final key =
                        curtainConfigNotifier.allCurtains.keys.toList()[index];

                    return CurtainWidget(
                      key: ValueKey(key),
                      curtain: curtain,
                      onDelete: () {
                        curtainConfigNotifier.removeCurtain(key);
                      },
                      index: index,
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
  final int index;

  const CurtainWidget(
      {super.key,
      required this.curtain,
      required this.onDelete,
      required this.index});

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
                    selectedValue: widget.curtain.channelOpenUid,
                    onChanged: (newValue) {
                      setState(() {
                        widget.curtain.channelOpenUid = newValue;
                      });
                    }),
                // 继电器设定
                BoardOutputDropdown(
                    label: '关: ',
                    selectedValue: widget.curtain.channelCloseUid,
                    onChanged: (newValue) {
                      setState(() {
                        widget.curtain.channelCloseUid = newValue;
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
            DeleteBtnDense(message: '删除', onDelete: () => widget.onDelete()),
            SizedBox(width: 40),
            ReorderableDragStartListener(
                index: widget.index, child: Icon(Icons.drag_handle))
          ],
        ),
      ),
    );
  }
}
