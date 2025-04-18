import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/app.dart';

class SetupController extends GetxController {
  var selectedLanguage = 'Tiếng Việt'.obs;
  var selectedTopics = <String>{}.obs;
}

class PageChooseTopic extends StatelessWidget {
  PageChooseTopic({super.key});

  final SetupController controller = Get.put(SetupController());

  List<String> languages = [
    "Tiếng Việt",
    "English",
    "Español",
    "Français",
    "Deutsch",
    "中文",
    "日本語"
  ];

  List<String> topics = [
    "Phụ kiện",
    "Nghệ thuật",
    "Công nghệ",
    "Thời trang",
    "Ẩm thực",
    "Du lịch",
    "Thể thao",
    "Sức khỏe",
    "Giải trí",
    "Giáo dục",
    "Kinh doanh",
    "Âm nhạc",
    "Phim ảnh",
    "Sách",
    "Chơi game",
    "Khoa học",
    "Đời sống",
    "Thiết kế",
    "Môi trường",
    "Tâm lý học",
    "Chụp ảnh",
    "Startup",
    "Lập trình",
    "Thiền & Yoga",
    "Tin tức",
    "Xe cộ",
    "Tình yêu",
    "Nuôi thú cưng",
    "Phong thủy",
    "Nội thất",
    "Lịch sử",
    "Chứng khoán",
    "Crypto",
    "Marketing",
    "Nông nghiệp"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tùy chỉnh",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn ngôn ngữ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              //chọn ngôn ngữ
              Obx(() => DropdownButton<String>(
                hint: Text("chọn một ngôn ngữ"),
                isExpanded: true,
                value: controller.selectedLanguage.value.isEmpty
                    ? null
                    : controller.selectedLanguage.value,
                items: languages.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                          fontSize: 16, color: Colors.blueAccent),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedLanguage.value = value;
                  }
                },
              )),
              SizedBox(height: 10),
              Text(
                "Chọn các danh mục bạn thích",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Các danh mục sẽ được dùng để cá nhân hóa nội dung cho bạn",
                style: TextStyle(fontSize: 15),
              ),
              Text(
                "Chọn ít nhất 5 danh mục trở lên",
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 10),
              //các danh mục
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: topics.map((e) {
                  return Obx(() {
                    bool selected = controller.selectedTopics.contains(e);
                    return GestureDetector(
                      onTap: () {
                        if (selected) {
                          controller.selectedTopics.remove(e);
                        } else {
                          controller.selectedTopics.add(e);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.blueAccent
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Colors.blueAccent
                                : Colors.grey[200]?? Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                            selected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
              SizedBox(height: 20),
              // Nút tới trang chủ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.selectedTopics.length < 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text("Vui lòng chọn ít nhất 5 danh mục"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => App()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    "Tới trang chủ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Nút Bỏ qua
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => App()),
                    );
                  },
                  child: Text(
                    "Bỏ qua",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
