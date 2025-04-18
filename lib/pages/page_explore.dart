import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rss_feed/models/rss.dart';
import 'package:rss_feed/pages/page_choose_topic.dart';

class ResultController extends GetxController{
  List<Article> results = [
    Article(
      title: "Concert Chị đẹp - họp cộng đồng lớn nhất Việt Nam",
      link: "https://example.com/flutter-3.10",
      pudDate: "2025-04-18",
      description: "Sự kiện âm nhạc kết hợp gặp mặt cộng đồng với sự góp mặt của các nghệ sĩ nổi tiếng, quy tụ hàng nghìn người tham gia trên khắp cả nước.",
      imageUrl: "https://giadinh.mediacdn.vn/296230595582509056/2025/4/12/chi-dep-dap-gio-re-song-1744451404512728413359.jpg",
    ),
    Article(
      title: "avatar - Làm mưa làm gió với loạt tạo hình cực đỉnh",
      link: "https://example.com/ai-sang-tao",
      pudDate: "2025-04-17",
      description: "Các công cụ AI hiện nay giúp việc thiết kế, viết lách và sáng tạo trở nên dễ dàng hơn bao giờ hết.",
      imageUrl: "https://nld.mediacdn.vn/291774122806476800/2022/12/28/avatar-the-way-of-water-1670943667-1672220380184583234571.jpeg",
    ),
  ].obs;

}

class PageExplore extends StatelessWidget {
  PageExplore({super.key});

  final SetupController controller = Get.put(SetupController());
  final ResultController controller2 = Get.put(ResultController());

  TextEditingController txtfind = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //tìm kiếm theo tên báo
              TextField(
                controller: txtfind,
                decoration: InputDecoration(
                  hintText: "Tên bài báo...",
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20,),
              //tìm kiếm theo chủ đề
              Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButton<String>(
                    hint: Text("Chọn chủ đề"),
                    isExpanded: true,
                    value: controller.selectedTopic.value.isEmpty? null: controller.selectedTopic.value,
                    items: controller.topics.map(
                            (e){
                          return DropdownMenuItem<String>(
                              value: e,
                              child: Text(e, style: TextStyle(fontSize: 16),)
                          );
                        }
                    ).toList(),
                    onChanged:(value){
                      if (value != null) {
                        controller.selectedTopic.value = value;
                      }
                    }
                ),
              )),
              SizedBox(height: 20,),
              //list các bài báo tìm kiếm
              Text("Kết quả tìm kiếm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),),
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index){
                  Article a = controller2.results[index];
                  return Card(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: a.imageUrl == null? Icon(Icons.image, size: 40,): ClipRRect(borderRadius: BorderRadius.circular(8),
                            child: Image.network(a.imageUrl ?? ""),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          flex: 3,
                          child: Text(a.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),
                  );
                },
                itemCount: controller2.results.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}