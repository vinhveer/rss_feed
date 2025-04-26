import 'package:get/get.dart';

class SetupController extends GetxController {
  var selectedLanguage = 'Tiếng Việt'.obs;
  var selectedTopics = <String>{}.obs;
  var selectedTopic = ''.obs;

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
}