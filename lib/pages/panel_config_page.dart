import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:flutter_web_1/providers/panel_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class PanelConfigPage extends StatefulWidget {
  static final GlobalKey<PanelConfigPageState> globalKey =
      GlobalKey<PanelConfigPageState>();

  PanelConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  PanelConfigPageState createState() => PanelConfigPageState();
}

class PanelConfigPageState extends State<PanelConfigPage> {
  @override
  Widget build(BuildContext context) {
    final panelConfigNotifier = context.watch<PanelConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('面板配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: panelConfigNotifier.allPanel.length,
              itemBuilder: (context, index) {
                return PanelWidget(
                  panel: panelConfigNotifier.allPanel[index],
                  onDelete: () {
                    panelConfigNotifier.removeAt(index);
                  },
                );
              },
            ),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(context, PanelType.fourButton);
                  },
                  child: const Text('新增 四键面板'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(context, PanelType.sixButton);
                  },
                  child: const Text('新增 六键面板'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(233, 234, 235, 1),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    panelConfigNotifier.addPanel(
                        context, PanelType.eightButton);
                  },
                  child: const Text('新增 八键面板'),
                ),
              ],
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class PanelWidget extends StatefulWidget {
  final Panel panel;
  final Function onDelete;

  const PanelWidget({required this.panel, required this.onDelete});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late TextEditingController panelIdController;
  late TextEditingController panelNameController;
  late List<TextEditingController> buttonIdControllers;

  @override
  void initState() {
    super.initState();
    panelIdController = TextEditingController(text: widget.panel.id.toString());
    panelNameController = TextEditingController(text: widget.panel.name);
    buttonIdControllers = List.generate(
        widget.panel.buttons.length,
        (i) =>
            TextEditingController(text: widget.panel.buttons[i].id.toString()));
  }

  @override
  void dispose() {
    panelIdController.dispose();
    panelNameController.dispose();
    for (var controller in buttonIdControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果 panel.id 发生变化，更新 panelIdController
    if (widget.panel.id != oldWidget.panel.id) {
      panelIdController.text = widget.panel.id.toString();
    }

    // 如果 panel.name 发生变化，更新 panelNameController
    if (widget.panel.name != oldWidget.panel.name) {
      panelNameController.text = widget.panel.name;
    }

    // 如果按钮数量发生变化，重新生成 buttonIdControllers
    if (widget.panel.buttons.length != oldWidget.panel.buttons.length) {
      for (var controller in buttonIdControllers) {
        controller.dispose(); // 先释放旧的资源
      }
      buttonIdControllers = List.generate(
        widget.panel.buttons.length,
        (i) =>
            TextEditingController(text: widget.panel.buttons[i].id.toString()),
      );
    } else {
      // 如果数量没变，检查每个按钮的 ID 是否需要更新
      for (int i = 0; i < widget.panel.buttons.length; i++) {
        if (widget.panel.buttons[i].id != oldWidget.panel.buttons[i].id) {
          buttonIdControllers[i].text = widget.panel.buttons[i].id.toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Color.fromRGBO(225, 227, 228, 1),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 面板ID输入框
                IdInputField(
                  controller: panelIdController,
                  initialValue: widget.panel.id,
                  onChanged: (value) {
                    setState(() {
                      widget.panel.id = value;
                    });
                  },
                ),

                // 面板名字输入框
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 240),
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
                      controller: panelNameController,
                      onChanged: (value) {
                        setState(() {
                          widget.panel.name = value;
                        });
                      }),
                ),
                Tooltip(
                  message: '删除面板',
                  child: IconButton(
                    onPressed: () => widget.onDelete(),
                    icon: Icon(
                      Icons.delete_forever,
                      size: 24, // 图标大小
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 面板按钮们
            if (widget.panel.type == PanelType.fourButton)
              Container(
                width: 275,
                height: 275,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(215, 216, 217, 1),
                  border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
                  borderRadius: BorderRadius.circular(12.0), // 设置圆角
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  children: List.generate(widget.panel.buttons.length, (index) {
                    return buildPanelButton(index, buttonIdControllers);
                  }),
                ),
              )
            else if (widget.panel.type == PanelType.sixButton)
              Container(
                width: 412,
                height: 280,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(215, 216, 217, 1),
                  border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
                  borderRadius: BorderRadius.circular(12.0), // 设置圆角
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  children: List.generate(widget.panel.buttons.length, (index) {
                    return buildPanelButton(index, buttonIdControllers);
                  }),
                ),
              )
            else if (widget.panel.type == PanelType.eightButton)
              Container(
                width: 550,
                height: 280,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(215, 216, 217, 1),
                  border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
                  borderRadius: BorderRadius.circular(12.0), // 设置圆角
                ),
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  shrinkWrap: true,
                  children: List.generate(widget.panel.buttons.length, (index) {
                    return buildPanelButton(index, buttonIdControllers);
                  }),
                ),
              )
          ],
        ),
      ),
    );
  }

  Container buildPanelButton(
      int index, List<TextEditingController> controllers) {
    final allActionGroup =
        Provider.of<ActionConfigNotifier>(context, listen: false)
            .allActionGroup;

    return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(186, 187, 188, 1), // 按键背景色
          border: Border.all(color: Color.fromRGBO(149, 154, 160, 1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IdInputField(
                controller: controllers[index],
                initialValue: widget.panel.buttons[index].id,
                onChanged: (value) {
                  setState(() {
                    widget.panel.buttons[index].id = value;
                  });
                }),
            CustomDropdown<int>(
                selectedValue: widget.panel.buttons[index].actionGroupUid,
                items: allActionGroup.keys.toList(),
                itemLabel: (item) => allActionGroup[item]!.name,
                onChanged: (uid) {
                  setState(() {
                    widget.panel.buttons[index].actionGroupUid = uid!;
                  });
                }),
          ],
        ));
  }
}
