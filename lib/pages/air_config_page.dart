import 'package:flutter/material.dart';
import 'package:flutter_web_1/providers/air_config_provider.dart';
import 'package:flutter_web_1/commons/common_widgets.dart';
import 'package:provider/provider.dart';

class ACConfigPage extends StatefulWidget {
  static final GlobalKey<ACConfigPageState> globalKey =
      GlobalKey<ACConfigPageState>();

  ACConfigPage({Key? key}) : super(key: key ?? globalKey);

  @override
  ACConfigPageState createState() => ACConfigPageState();
}

class ACConfigPageState extends State<ACConfigPage> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final acConfigNotifier = context.watch<AirConNotifier>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('空调配置'),
          backgroundColor: Color.fromRGBO(238, 239, 240, 1),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            color: Color.fromRGBO(238, 239, 240, 1),
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // 添加侧边距
            child: Column(
              children: [
                const SectionTitle(title: '一般配置'),
                ConfigSection(children: [
                  ConfigRowDropdown<int>(
                      label: '默认目标温度',
                      selectedValue: acConfigNotifier.defaultTargetTemp,
                      items: [20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
                      itemLabel: (temp) => temp.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.defaultTargetTemp = value;
                        }
                      }),
                  ConfigRowDropdown<ACMode>(
                      label: '默认模式',
                      selectedValue: acConfigNotifier.defaultMode,
                      items: ACMode.values,
                      itemLabel: (mode) => mode.displayName,
                      onChanged: (value) {
                        if (value != null) acConfigNotifier.defaultMode = value;
                      }),
                  ConfigRowDropdown<ACFanSpeed>(
                      label: '默认风速',
                      selectedValue: acConfigNotifier.defaultFanSpeed,
                      items: ACFanSpeed.values,
                      itemLabel: (fandSpeed) => fandSpeed.displayName,
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.defaultFanSpeed = value;
                        }
                      }),
                  ConfigRowDropdown<int>(
                      label: '超出目标温度后停止工作的阈值',
                      selectedValue: acConfigNotifier.stopThreshold,
                      items: [1, 2, 3, 4, 5],
                      itemLabel: (value) => value.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.stopThreshold = value;
                        }
                      }),
                  ConfigRowDropdown<int>(
                      label: '回温后重新开始工作的阈值',
                      selectedValue: acConfigNotifier.reworkThreshold,
                      items: [1, 2, 3, 4, 5],
                      itemLabel: (value) => value.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.reworkThreshold = value;
                        }
                      }),
                  ConfigRowDropdown<ACStopAction>(
                      label: '盘管空调达到停止工作的阈值后',
                      selectedValue: acConfigNotifier.stopAction,
                      items: ACStopAction.values,
                      itemLabel: (action) => action.displayName,
                      onChanged: (value) {
                        if (value != null) acConfigNotifier.stopAction = value;
                      }),
                ]),
                const SectionTitle(title: '当风速为[自动]时'),
                ConfigSection(children: [
                  ConfigRowDropdown<int>(
                      label: '低风 所需温差小于等于',
                      selectedValue: acConfigNotifier.lowFanTempDiff,
                      items: [1, 2, 3, 4, 5],
                      itemLabel: (diff) => diff.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.lowFanTempDiff = value;
                        }
                      }),
                  ConfigRowDropdown<int>(
                      label: '高风 所需温差大于等于',
                      selectedValue: acConfigNotifier.highFanTempDiff,
                      items: [3, 4, 5, 6, 7],
                      itemLabel: (diff) => diff.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.highFanTempDiff = value;
                        }
                      }),
                  ConfigRowDropdown<ACAutoVentSpeed>(
                      label: '风速[自动]且工作模式为[通风]时',
                      selectedValue: acConfigNotifier.autoVentSpeed,
                      items: ACAutoVentSpeed.values,
                      itemLabel: (speed) => speed.displayName,
                      onChanged: (value) {
                        if (value != null) {
                          acConfigNotifier.autoVentSpeed = value;
                        }
                      }),
                ]),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: acConfigNotifier.allAirCons.length,
                  itemBuilder: (context, index) {
                    final airCon = acConfigNotifier.allAirCons[index];
                    return AirConWidget(
                      airCon: airCon,
                      onDelete: () {
                        if (airCon.type == ACType.single) {
                          airCon.lowOutput!.removeUsage();
                          airCon.midOutput!.removeUsage();
                          airCon.highOutput!.removeUsage();
                          airCon.water1Output!.removeUsage();
                        }
                        acConfigNotifier.removeDevice(airCon.uid);
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
            message: '添加 空调',
            onPressed: () {
              acConfigNotifier.addAirCon(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              });
            }));
  }
}

// 单个空调配置组件
class AirConWidget extends StatefulWidget {
  final AirCon airCon;
  final Function onDelete; // 希望接收一个删除回调函数

  const AirConWidget({required this.airCon, required this.onDelete});

  @override
  State<AirConWidget> createState() => _AirConWidgetState();
}

class _AirConWidgetState extends State<AirConWidget> {
  late TextEditingController idController;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.airCon.id.toString());
    nameController = TextEditingController(text: widget.airCon.name);
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AirConWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 airCon.id 发生变化，更新 idController
    if (widget.airCon.id != oldWidget.airCon.id) {
      idController.text = widget.airCon.id.toString();
    }

    // 如果 airCon.name 发生变化，更新 nameController
    if (widget.airCon.name != oldWidget.airCon.name) {
      nameController.text = widget.airCon.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        color: Color.fromRGBO(233, 234, 235, 1),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              // 空调ID输入框
              IdInputField(
                  label: "空调ID: ",
                  controller: idController,
                  initialValue: widget.airCon.id,
                  onChanged: (value) {
                    widget.airCon.id = value;
                  }),
              // 空调名输入框
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
                      widget.airCon.name = value;
                    }),
              ),
              Spacer(),
              // 删除空调的按钮
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => widget.onDelete(), // 调用传递进来的回调删除函数
              ),
            ]),

            SizedBox(height: 8.0),
            // 空调类型选择
            SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ToggleButtons(
                    borderRadius: BorderRadius.circular(8.0),
                    selectedColor: Colors.black,
                    fillColor: Colors.white,
                    color: Colors.black,
                    constraints: BoxConstraints(
                      minHeight: 10,
                      minWidth: constraints.maxWidth / 3 - 4,
                    ),
                    splashColor: Colors.transparent, // 取消墨水飞溅效果
                    highlightColor: Colors.transparent, // 取消点击时的高亮效果
                    isSelected: [
                      widget.airCon.type == ACType.single,
                      widget.airCon.type == ACType.infrared,
                      widget.airCon.type == ACType.double,
                    ],
                    onPressed: (index) {
                      setState(() {
                        widget.airCon.type = ACType.values[index];
                      });
                    },
                    children: [
                      Text("单管空调", textAlign: TextAlign.center),
                      Text("红外空调", textAlign: TextAlign.center),
                      Text("双管空调", textAlign: TextAlign.center),
                    ],
                  );
                },
              ),
            ),

            // 根据空调类型生成不同部件树
            if (widget.airCon.type != ACType.infrared) ...[
              SizedBox(height: 16),
              Text('继电器设定', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BoardOutputDropdown(
                    label: '低风',
                    selectedOutput: widget.airCon.lowOutput!,
                    onChanged: (newValue) {
                      setState(() {
                        widget.airCon.lowOutput = newValue;
                      });
                    },
                  ),
                  BoardOutputDropdown(
                    label: '中风',
                    selectedOutput: widget.airCon.midOutput!,
                    onChanged: (newValue) {
                      setState(() {
                        widget.airCon.midOutput = newValue;
                      });
                    },
                  ),
                  BoardOutputDropdown(
                    label: '高风',
                    selectedOutput: widget.airCon.highOutput!,
                    onChanged: (newValue) {
                      setState(() {
                        widget.airCon.highOutput = newValue;
                      });
                    },
                  ),
                  BoardOutputDropdown(
                    label: widget.airCon.type == ACType.single ? '水阀' : '冷水阀',
                    selectedOutput: widget.airCon.water1Output!,
                    onChanged: (newValue) {
                      setState(() {
                        widget.airCon.water1Output = newValue;
                      });
                    },
                  ),
                ],
              ),
            ] else if (widget.airCon.type == ACType.infrared) ...[
              SectionTitle(title: '空调型号'),
              CustomDropdown(
                  selectedValue: widget.airCon.codeBases,
                  items: CodeBases.values,
                  itemLabel: (item) => item!.displayName,
                  onChanged: (value) {
                    setState(() {
                      widget.airCon.codeBases = value;
                    });
                  }),
            ]
          ],
        ),
      ),
    );
  }
}
