// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_web_1/providers/air_config_provider.dart';
// import 'package:flutter_web_1/widgets/common_widgets.dart';
// import 'package:provider/provider.dart';

// class CurtainConfigPage extends StatefulWidget {
//   CurtainConfigPage({Key? key}) : super(key: key ?? globalKey);

//   static final GlobalKey<CurtainConfigPageState> globalKey =
//       GlobalKey<CurtainConfigPageState>();

//   @override
//   CurtainConfigPageState createState() => CurtainConfigPageState();
// }

// class CurtainConfigPageState extends State<CurtainConfigPage> {
//   ScrollController _scrollController = ScrollController();

//   @override
//   Widget build(BuildContext context) {
//     final acConfigNotifier = context.watch<ACConfigNotifier>();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('窗帘配置'),
//         backgroundColor: Color.fromRGBO(238, 239, 240, 1),
//       ),
//       body: Container(
//         color: Color.fromRGBO(238, 239, 240, 1),
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ListView(
//           controller: _scrollController,
//           children: [
//             const SectionTitle(title: '一般配置'),
//             ConfigSection(rows: [
//               ConfigRowDropdown(
//                   label: '盘管空调达到停止工作的阈值后',
//                   value: acConfigNotifier.stopAction,
//                   items: ['关闭风机与水阀', '仅关闭风机', '仅关闭水阀', '都不关'],
//                   onChanged: (value) {
//                     if (value != null) {
//                       acConfigNotifier.setStopAction(value);
//                     }
//                   }),
//             ]),

//             const SectionTitle(title: '当风速为[自动]时'),
//             ConfigSection(rows: [
//               ConfigRowDropdown(
//                   label: '低风 所需温差小于等于',
//                   value: acConfigNotifier.lowFanTempDiff,
//                   items: ['1', '2', '3', '4', '5'],
//                   onChanged: (value) {
//                     if (value != null) {
//                       acConfigNotifier.setLowFanTempDiff(value);
//                     }
//                   }),
//               ConfigRowDropdown(
//                   label: '高风 所需温差大于等于',
//                   value: acConfigNotifier.highFanTempDiff,
//                   items: ['3', '4', '5', '6', '7'],
//                   onChanged: (value) {
//                     if (value != null) {
//                       acConfigNotifier.setHighFanTempDiff(value);
//                     }
//                   }),
//               ConfigRowDropdown(
//                   label: '风速[自动]且工作模式为[通风]时',
//                   value: acConfigNotifier.autoVentSpeed,
//                   items: ['低风', '中风', '高风'],
//                   onChanged: (value) {
//                     if (value != null) {
//                       acConfigNotifier.setAutoVentSpeed(value);
//                     }
//                   }),
//             ]),

//             ListView.builder(
//               physics: NeverScrollableScrollPhysics(), // 禁用内部ListView滚动
//               shrinkWrap: true,
//               itemCount: acConfigNotifier.acConfigs.length,
//               itemBuilder: (context, index) {
//                 return ACConfigWidget(
//                   config: acConfigNotifier.acConfigs[index],
//                   onDelete: () {
//                     // 传入可以删除它自身的回调函数
//                     setState(() {
//                       acConfigNotifier.removeAt(index);
//                     });
//                   },
//                 );
//               },
//             ),
//             SizedBox(height: 20), // 增加一些间距
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromRGBO(233, 234, 235, 1),
//                 foregroundColor: Colors.black,
//               ),
//               onPressed: () {
//                 acConfigNotifier.addACConfig();
//                 _scrollController.animateTo(
//                   _scrollController.position.maxScrollExtent + 210,
//                   duration: Duration(milliseconds: 500),
//                   curve: Curves.easeInOut,
//                 );
//               },
//               child: const Text('新增空调配置'),
//             ),
//             SizedBox(height: 20), // 增加一些间距
//           ],
//         ),
//       ),
//     );
//   }

//   void scrollToConfig(int index) {
//     double position = 540.0;
//     for (int i = 0; i < index; i++) {
//       position += 210.0; // 根据实际每个ACConfigWidget的高度调整，这里假设每个ACConfigWidget高度为220
//     }
//     _scrollController.animateTo(
//       position,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }
// }

// class SectionTitle extends StatelessWidget {
//   final String title;

//   const SectionTitle({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 0.0),
//       child: Text(
//         title,
//         style: Theme.of(context)
//             .textTheme
//             .titleMedium!
//             .copyWith(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

// class ConfigRowDropdown extends StatefulWidget {
//   final String label;
//   final String value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;

//   ConfigRowDropdown({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   });

//   @override
//   State<ConfigRowDropdown> createState() => _ConfigRowDropdownState();
// }

// class _ConfigRowDropdownState extends State<ConfigRowDropdown> {
//   bool _isHovered = false;

//   // 创建一个透明的FocusNode
//   final FocusNode _focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             widget.label,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           MouseRegion(
//             onEnter: (_) {
//               setState(() {
//                 _isHovered = true;
//               });
//             },
//             onExit: (_) {
//               setState(() {
//                 _isHovered = false;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               decoration: BoxDecoration(
//                 color: _isHovered ? Colors.white : Colors.transparent,
//                 borderRadius: BorderRadius.circular(4.0),
//                 border: _isHovered ? Border.all(width: 0.1) : null,
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: DropdownButton<String>(
//                   dropdownColor: Color.fromRGBO(226, 227, 228, 1),
//                   focusNode: _focusNode,
//                   value: widget.value,
//                   items: widget.items.map((String item) {
//                     return DropdownMenuItem<String>(
//                       value: item,
//                       child: Text(item),
//                     );
//                   }).toList(),
//                   onChanged: (newValue) {
//                     widget.onChanged(newValue); // 触发更新值
//                     _focusNode.unfocus(); // 取消聚焦
//                   },
//                   isDense: true,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// // 单个空调配置组件
// class ACConfigWidget extends StatefulWidget {
//   final ACConfig config;
//   final Function onDelete; // 希望接收一个删除回调函数

//   ACConfigWidget({required this.config, required this.onDelete});

//   @override
//   State<ACConfigWidget> createState() => _ACConfigWidgetState();
// }

// class _ACConfigWidgetState extends State<ACConfigWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//       child: Container(
//         color: Color.fromRGBO(233, 234, 235, 1),
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(children: [
//               Text('空调 ${widget.config.id}',
//                   style: Theme.of(context).textTheme.titleMedium),
//               Spacer(),
//               IconButton(
//                 icon: Icon(Icons.delete),
//                 onPressed: () => widget.onDelete(), // 调用传递进来的回调删除函数
//               ),
//             ]),

//             SizedBox(height: 8.0),

//             SizedBox(
//               width: double.infinity,
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return ToggleButtons(
//                     borderRadius: BorderRadius.circular(8.0),
//                     selectedColor: Colors.black,
//                     fillColor: Colors.white,
//                     color: Colors.black,
//                     constraints: BoxConstraints(
//                       minHeight: 10,
//                       minWidth: constraints.maxWidth / 3 - 4,
//                     ),
//                     splashColor: Colors.transparent, // 取消墨水飞溅效果
//                     highlightColor: Colors.transparent, // 取消点击时的高亮效果
//                     isSelected: [
//                       widget.config.type == 0,
//                       widget.config.type == 1,
//                       widget.config.type == 2,
//                     ],
//                     onPressed: (index) {
//                       setState(() {
//                         widget.config.type = index;
//                       });
//                     },
//                     children: [
//                       Text("单管空调", textAlign: TextAlign.center),
//                       Text("红外空调", textAlign: TextAlign.center),
//                       Text("双管空调", textAlign: TextAlign.center),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             // 根据空调类型生成不同部件树
//             if (widget.config.type != 1) ...[
//               SizedBox(height: 16),
//               Text('继电器设定', style: Theme.of(context).textTheme.titleMedium),
//               SizedBox(height: 8.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   InputField(
//                       label: '低风',
//                       initialValue: widget.config.relayLow,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.config.relayLow = value;
//                         });
//                       }),
//                   InputField(
//                       label: '中风',
//                       initialValue: widget.config.relayMedium,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.config.relayMedium = value;
//                         });
//                       }),
//                   InputField(
//                       label: '高风',
//                       initialValue: widget.config.relayHigh,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.config.relayHigh = value;
//                         });
//                       }),
//                   InputField(
//                       label: widget.config.type == 0 ? '水阀' : '冷水阀',
//                       initialValue: widget.config.relayWater1,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.config.relayWater1 = value;
//                         });
//                       }),
//                   if (widget.config.type == 2)
//                     InputField(
//                         label: '热水阀',
//                         initialValue: widget.config.relayWater2,
//                         onChanged: (value) {
//                           setState(() {
//                             widget.config.relayWater2 = value;
//                           });
//                         }),
//                   InputField(
//                       label: '温控器ID',
//                       initialValue: widget.config.temperatureID,
//                       onChanged: (value) {
//                         setState(() {
//                           widget.config.temperatureID = value;
//                         });
//                       })
//                 ],
//               ),
//             ] else ...[
//               Text('红外空调的配置...'),
//               Text('红外空调的配置...'),
//               Text('红外空调的配置...'),
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }

// // 单个输入框组件
// class InputField extends StatefulWidget {
//   final String label;
//   final int initialValue;
//   final Function(int) onChanged;

//   InputField(
//       {required this.label,
//       required this.initialValue,
//       required this.onChanged});

//   @override
//   State<InputField> createState() => _InputFieldState();
// }

// class _InputFieldState extends State<InputField> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialValue.toString());
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
//         SizedBox(
//           width: 50,
//           child: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               isDense: true,
//               contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(1.0),
//                 borderSide:
//                     BorderSide(width: 1.0, color: Colors.brown), // 调整边框的颜色和宽度
//               ),
//             ),
//             keyboardType: TextInputType.number,
//             textAlign: TextAlign.center,
//             cursorWidth: 1.0,
//             cursorHeight:
//                 Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16.0 * 1.2,
//             cursorColor: Colors.brown,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             onChanged: (value) {
//               widget.onChanged(int.tryParse(value)!);
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
