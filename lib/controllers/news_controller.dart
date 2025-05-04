import 'package:get/get.dart';
import 'package:rss_feed/models/newspaper_local.dart';

class NewsController extends GetxController {
  final RxList<Newspaper> newspapers = <Newspaper>[].obs;
  final RxList<Topic> topics = <Topic>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAllNewspaper();
    getAllTopic();
  }

  void getAllNewspaper() {
    try {
      newspapers.value = newspapersList;
    } catch (e) {
      print('Error fetching newspapers: $e');
    }
  }

  void getAllTopic() {
    try {
      topics.value = topicsList;
    } catch (e) {
      print('Error fetching topics: $e');
    }
  }
}

List<Newspaper> newspapersList = [
  Newspaper(id: 1, name: 'VnExpress'),
  Newspaper(id: 2, name: 'Tuổi Trẻ'),
  Newspaper(id: 3, name: 'Thanh Niên'),
  Newspaper(id: 4, name: 'Dân Trí'),
  Newspaper(id: 5, name: 'Người Lao Động'),
];

List<Topic> topicsList = [
  Topic(id: 1, name: 'Thời sự', iconName: 'newspaper'),
  Topic(id: 2, name: 'Thể thao', iconName: 'sports_soccer'),
  Topic(id: 3, name: 'Giải trí', iconName: 'movie'),
  Topic(id: 4, name: 'Kinh doanh', iconName: 'business'),
  Topic(id: 5, name: 'Công nghệ', iconName: 'computer'),
];


class Topic {
  final int id;
  final String name;
  final String iconName;

  Topic({
    required this.id,
    required this.name,
    required this.iconName,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      name: json['name'],
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
    };
  }
}