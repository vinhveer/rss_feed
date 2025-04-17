import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/controllers/app_controller.dart';

class ColorSchemeSettingsPage extends StatelessWidget {
  const ColorSchemeSettingsPage({super.key});

  // Danh sách các MaterialColor tiêu chuẩn
  static const List<MaterialColor> materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Ánh xạ màu sang tên để hiển thị
  String _getColorName(MaterialColor color) {
    final Map<int, String> colorNames = {
      Colors.red.value: 'Đỏ',
      Colors.pink.value: 'Hồng',
      Colors.purple.value: 'Tím',
      Colors.deepPurple.value: 'Tím đậm',
      Colors.indigo.value: 'Chàm',
      Colors.blue.value: 'Xanh dương',
      Colors.lightBlue.value: 'Xanh dương nhạt',
      Colors.cyan.value: 'Xanh lơ',
      Colors.teal.value: 'Xanh lục lam',
      Colors.green.value: 'Xanh lá',
      Colors.lightGreen.value: 'Xanh lá nhạt',
      Colors.lime.value: 'Xanh vàng',
      Colors.yellow.value: 'Vàng',
      Colors.amber.value: 'Hổ phách',
      Colors.orange.value: 'Cam',
      Colors.deepOrange.value: 'Cam đậm',
      Colors.brown.value: 'Nâu',
      Colors.grey.value: 'Xám',
      Colors.blueGrey.value: 'Xanh xám',
    };

    return colorNames[color.value] ?? 'Màu chưa đặt tên';
  }

  @override
  Widget build(BuildContext context) {
    final AppController controller = Get.find<AppController>();
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn màu chủ đạo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Obx(() {
        final current = controller.primarySwatch;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: current,
              child: Center(
                child: Text(
                  _getColorName(current),
                  style: TextStyle(
                    color: current.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: materialColors.length,
                  itemBuilder: (context, index) {
                    final color = materialColors[index];
                    final bool selected = color.value == current.value;

                    return Tooltip(
                      message: _getColorName(color),
                      child: GestureDetector(
                        onTap: () => controller.changePrimaryColor(color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: selected
                                ? [
                              BoxShadow(
                                color: color.withOpacity(0.7),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                                : null,
                            border: selected
                                ? Border.all(
                                color: brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black,
                                width: 3)
                                : null,
                          ),
                          child: selected
                              ? Center(
                            child: Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}