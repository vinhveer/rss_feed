import 'package:rss_feed/models/favourite_item.dart';

class FavouriteController {
  final List<String> categories = [
    'Tất cả',
    'Thể thao',
    'Giải trí',
    'Khoa học',
    'Công nghệ',
    'Âm nhạc',
  ];

  final List<FavouriteItem> _favourites = [
    FavouriteItem(
      id: '1',
      title: 'Khám phá vùng biển sâu: Những sinh vật kỳ lạ dưới đáy đại dương',
      description: 'Các nhà khoa học phát hiện nhiều loài sinh vật mới chưa từng được biết đến tại vùng biển sâu.',
      category: 'Khoa học',
      imageUrl: 'assets/images/ocean.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FavouriteItem(
      id: '2',
      title: 'Đội tuyển Việt Nam chuẩn bị cho vòng loại World Cup 2026',
      description: 'HLV trưởng công bố danh sách 26 cầu thủ cho các trận đấu sắp tới.',
      category: 'Thể thao',
      imageUrl: 'assets/images/football_team.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    FavouriteItem(
      id: '3',
      title: 'Top 10 phim đáng chờ đợi nhất năm 2025',
      description: 'Những bom tấn Hollywood và các tác phẩm điện ảnh độc lập được mong chờ nhất.',
      category: 'Giải trí',
      imageUrl: 'assets/images/movies.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FavouriteItem(
      id: '4',
      title: 'Xu hướng công nghệ AI mới nhất trong năm 2025',
      description: 'Trí tuệ nhân tạo đang thay đổi cách chúng ta làm việc và sống như thế nào.',
      category: 'Công nghệ',
      imageUrl: 'assets/images/ai_tech.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FavouriteItem(
      id: '5',
      title: 'Festival âm nhạc quốc tế sẽ diễn ra tại Hà Nội vào tháng 6',
      description: 'Hàng loạt nghệ sĩ hàng đầu thế giới xác nhận tham gia sự kiện âm nhạc lớn nhất năm.',
      category: 'Âm nhạc',
      imageUrl: 'assets/images/music_festival.jpg',
      savedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  String selectedFilter = 'Tất cả';
  bool isSelectMode = false;

  List<FavouriteItem> get favourites => _favourites;

  List<FavouriteItem> get filteredFavourites {
    if (selectedFilter == 'Tất cả') {
      return _favourites;
    } else {
      return _favourites.where((item) => item.category == selectedFilter).toList();
    }
  }

  int get selectedCount => _favourites.where((item) => item.isSelected).length;

  void setFilter(String category) {
    selectedFilter = category;
  }

  void toggleItemSelection(FavouriteItem item) {
    if (!isSelectMode) {
      isSelectMode = true;
      item.isSelected = true;
    } else {
      item.isSelected = !item.isSelected;
      if (selectedCount == 0) isSelectMode = false;
    }
  }

  void enableSelectMode() {
    isSelectMode = true;
  }

  void cancelSelection() {
    for (var item in _favourites) {
      item.isSelected = false;
    }
    isSelectMode = false;
  }

  void deleteSelected() {
    _favourites.removeWhere((item) => item.isSelected);
    isSelectMode = false;
  }

  void deleteFavouriteItem(FavouriteItem item) {
    _favourites.removeWhere((favItem) => favItem.id == item.id);
  }

  void sortByDate(bool newestFirst) {
    if (newestFirst) {
      _favourites.sort((a, b) => b.savedDate.compareTo(a.savedDate));
    } else {
      _favourites.sort((a, b) => a.savedDate.compareTo(b.savedDate));
    }
  }

  void sortByTitle(bool ascending) {
    if (ascending) {
      _favourites.sort((a, b) => a.title.compareTo(b.title));
    } else {
      _favourites.sort((a, b) => b.title.compareTo(a.title));
    }
  }
}