import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_1/providers/action_config_provider.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/widgets/common_widgets.dart';
import 'package:provider/provider.dart';

class BoardInputPage extends StatefulWidget {
  static final GlobalKey<BoardInputPageState> globalKey =
      GlobalKey<BoardInputPageState>();

  BoardInputPage({Key? key}) : super(key: key ?? globalKey);

  @override
  BoardInputPageState createState() => BoardInputPageState();
}

class BoardInputPageState extends State<BoardInputPage> {
  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('输入配置'),
        backgroundColor: Color.fromRGBO(238, 239, 240, 1),
      ),
      body: Container(
        color: Color.fromRGBO(238, 239, 240, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(children: [
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: boardNotifier.allBoard.length,
            itemBuilder: (context, index) => BoardInputWidget(
              board: boardNotifier.allBoard[index],
            ),
          )
        ]),
      ),
    );
  }
}

// 单块板子的所有输入 的部件
class BoardInputWidget extends StatefulWidget {
  final BoardConfig board;

  const BoardInputWidget({
    required this.board,
  });

  @override
  State<BoardInputWidget> createState() => _BoardInputWidgetState();
}

class _BoardInputWidgetState extends State<BoardInputWidget> {
  List<TextEditingController> _inputChannelControllers = [];
  // List<TextEditingController> _inputNameControllers = [];

  @override
  void initState() {
    super.initState();
    _inputChannelControllers = List.generate(
        widget.board.inputs.length,
        (i) => TextEditingController(
            text: widget.board.inputs[i].channel.toString()));
    // _inputNameControllers = List.generate(widget.board.inputs.length,
    //     (i) => TextEditingController(text: widget.board.inputs[i].name));
  }

  @override
  void dispose() {
    for (var controller in _inputChannelControllers) {
      controller.dispose();
    }
    // for (var controller in _inputNameControllers) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: '板子 ${widget.board.id} 输入配置'),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SectionTitle(
                        title: '输入通道',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SectionTitle(
                        title: '输入电平',
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          SectionTitle(
                            title: '执行动作',
                          ),
                          Tooltip(
                            message: '添加通道',
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                size: 24,
                              ),
                              onPressed: () {
                                boardNotifier.addInputToBoard(
                                    context, widget.board.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              for (int i = 0; i < widget.board.inputs.length; i++) ...[
                BoardInputUnit(
                    input: widget.board.inputs[i],
                    onDelete: () {
                      setState(() {
                        widget.board.removeInputAt(i);
                      });
                    }),
                if (i < widget.board.inputs.length - 1)
                  const Divider(height: 1, thickness: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// 一个输入通道部件(行)
class BoardInputUnit extends StatefulWidget {
  final BoardInput input;
  final Function onDelete;
  // final int index;

  const BoardInputUnit({
    required this.input,
    required this.onDelete,
    // required this.index,
  });

  @override
  State<BoardInputUnit> createState() => _BoardInputUnitState();
}

class _BoardInputUnitState extends State<BoardInputUnit> {
  TextEditingController _channelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _channelController =
        TextEditingController(text: widget.input.channel.toString());
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BoardInputUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步 channel 字段
    if (widget.input.channel != oldWidget.input.channel) {
      _channelController.text = widget.input.channel.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allActionGroup = context.watch<ActionConfigNotifier>().allActionGroup;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          // 输入通道
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(right: 40),
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
                  controller: _channelController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        widget.input.channel = 127;
                      } else {
                        widget.input.channel = int.parse(value);
                      }
                    });
                  }),
            ),
          ),
          // 输入电平
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(right: 30),
              child: CustomDropdown(
                selectedValue: widget.input.level,
                items: InputLevel.values,
                itemLabel: (item) => item.displayName,
                onChanged: (newValue) {
                  setState(() {
                    widget.input.level = newValue!;
                  });
                },
              ),
            ),
          ),
          // 执行动作
          Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.only(right: 30),
                child: Row(
                  children: [
                    CustomDropdown<ActionGroup>(
                        selectedValue:
                            allActionGroup[widget.input.actionGroupUid] ??
                                allActionGroup.values.first,
                        items: allActionGroup.values.toList(),
                        itemLabel: (actionGroup) => actionGroup.name,
                        onChanged: (actionGroup) {
                          setState(() {
                            widget.input.actionGroupUid = actionGroup!.uid;
                          });
                        }),
                    Spacer(),
                    DeleteBtnDense(message: '删除通道', onDelete: widget.onDelete)
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
