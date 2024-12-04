import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_web_1/providers/board_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:provider/provider.dart';

class BoardOutputPage extends StatefulWidget {
  static final GlobalKey<BoardOutputPageState> globalKey =
      GlobalKey<BoardOutputPageState>();

  BoardOutputPage({Key? key}) : super(key: key ?? globalKey);

  @override
  BoardOutputPageState createState() => BoardOutputPageState();
}

class BoardOutputPageState extends State<BoardOutputPage> {
  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('输出配置'),
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
            itemBuilder: (context, index) => BoardOutputWidget(
              board: boardNotifier.allBoard[index],
              onDelete: () {
                boardNotifier.removeAt(index);
              },
            ),
          ),
          SizedBox(height: 80)
        ]),
      ),
      floatingActionButton: FloatButton(
          message: '添加板子',
          onPressed: () {
            boardNotifier.addBoard();
          }),
    );
  }
}

// 单块板子的所有输出 的部件
class BoardOutputWidget extends StatefulWidget {
  final BoardConfig board;
  final Function onDelete;

  const BoardOutputWidget({
    required this.board,
    required this.onDelete,
  });

  @override
  State<BoardOutputWidget> createState() => _BoardOutputWidgetState();
}

class _BoardOutputWidgetState extends State<BoardOutputWidget> {
  @override
  Widget build(BuildContext context) {
    final boardNotifier = context.watch<BoardConfigNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SectionTitle(title: '板子 ${widget.board.id} 输出配置'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => widget.onDelete(), // 调用传递进来的回调删除函数
            ),
          ],
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SectionTitle(
                        title: '序号',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: SectionTitle(
                          title: '输出类型',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SectionTitle(
                        title: '输出通道',
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          SectionTitle(
                            title: '名字',
                          ),
                          Tooltip(
                            message: '添加通道',
                            child: IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                size: 24,
                              ),
                              onPressed: () {
                                boardNotifier.addOutputToBoard(widget.board.id);
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

              // 0mg, 总之就是遍历并构造行
              for (var indexedEntry
                  in widget.board.outputs.entries.toList().asMap().entries) ...[
                BoardOutputUnit(
                  index: indexedEntry.key,
                  output: indexedEntry.value.value,
                  onDelete: () {
                    setState(() {
                      widget.board.outputs.remove(indexedEntry.value.key);
                    });
                  },
                ),
                if (indexedEntry.key < widget.board.outputs.length - 1)
                  const Divider(height: 1, thickness: 1),
              ]
              // 曾经是这么写的, 曾经是List储存
              // for (int i = 0; i < widget.board.outputs.length; i++) ...[
              //   BoardOutputUnit(
              //     index: i,
              //     output: widget.board.outputs[i],
              //     onDelete: () {
              //       setState(() {
              //         widget.board.removeOutputAt(i);
              //       });
              //     },
              //   ),
              //   if (i < widget.board.outputs.length - 1)
              //     const Divider(height: 1, thickness: 1),
              // ],
            ],
          ),
        ),
      ],
    );
  }
}

// 一个输出通道部件(行)
class BoardOutputUnit extends StatefulWidget {
  final BoardOutput output;
  final Function onDelete;
  final int index;

  const BoardOutputUnit({
    required this.output,
    required this.onDelete,
    required this.index,
  });

  @override
  State<BoardOutputUnit> createState() => _BoardOutputUnitState();
}

class _BoardOutputUnitState extends State<BoardOutputUnit> {
  TextEditingController _channelController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _channelController =
        TextEditingController(text: widget.output.channel.toString());
    _nameController = TextEditingController(text: widget.output.name);
  }

  @override
  void dispose() {
    _channelController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BoardOutputUnit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 同步 channel 字段
    if (widget.output.channel != oldWidget.output.channel) {
      _channelController.text = widget.output.channel.toString();
    }

    // 同步 name 字段
    if (widget.output.name != oldWidget.output.name) {
      _nameController.text = widget.output.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('   ${widget.index}',
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(right: 30),
              child: CustomDropdown(
                selectedValue: widget.output.type,
                items: OutputType.values,
                itemLabel: (item) => item.displayName,
                onChanged: (newValue) {
                  setState(() {
                    widget.output.type = newValue!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide:
                        BorderSide(width: 1, color: Colors.brown), // 调整边框的颜色和宽度
                  ),
                ),
                controller: _channelController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      widget.output.channel = 127;
                    } else {
                      widget.output.channel = int.parse(value);
                    }
                  });
                }),
          ),
          
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide:
                                BorderSide(width: 1, color: Colors.brown),
                          ),
                        ),
                        controller: _nameController,
                        onChanged: (value) {
                          setState(() {
                            widget.output.name = value;
                          });
                        }),
                  ),
                  Spacer(),
                  DeleteBtnDense(
                    message: '删除通道',
                    onDelete: widget.onDelete,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
