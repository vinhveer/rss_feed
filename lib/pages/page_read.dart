import 'package:flutter/material.dart';

class PageRead extends StatelessWidget {
  const PageRead({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Không có title
        actions: [
          // Nút Dịch
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'Dịch',
            onPressed: () {},
          ),
          // Nút Cỡ chữ
          IconButton(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Cỡ chữ',
            onPressed: () {},
          ),
          // Nút Chế độ đọc (icon trái đất)
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Chế độ đọc',
            onPressed: () {},
          ),
          // Nút Chia sẻ
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Chia sẻ',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề bài báo
            const Text(
              "Công nghệ AI sẽ định hình tương lai như thế nào trong thập kỷ tới",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Thông tin tác giả và thời gian
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                      "https://randomuser.me/api/portraits/men/32.jpg"
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Nguyễn Văn A",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "19/04/2025",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Ảnh bài báo
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://images.unsplash.com/photo-1677442135197-9eec44d211ba?q=80&w=2070",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // Nội dung bài báo
            const Text(
              "Trí tuệ nhân tạo (AI) đang thay đổi cách chúng ta sống, làm việc và tương tác với thế giới xung quanh. Trong thập kỷ tới, AI sẽ tiếp tục phát triển mạnh mẽ và ảnh hưởng đến mọi lĩnh vực của đời sống.",
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "1. AI trong y tế",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Trí tuệ nhân tạo đang cách mạng hóa lĩnh vực y tế thông qua việc cải thiện chẩn đoán, phát triển thuốc và cá nhân hóa điều trị. Các hệ thống AI có thể phân tích hàng nghìn hình ảnh y tế để phát hiện các dấu hiệu của bệnh tật sớm hơn và chính xác hơn các chuyên gia con người.\n\nĐồng thời, AI đang giúp các công ty dược phẩm phát triển thuốc mới nhanh hơn và với chi phí thấp hơn. Các thuật toán học máy có thể dự đoán cách các phân tử sẽ tương tác với các mục tiêu sinh học cụ thể, giúp các nhà nghiên cứu ưu tiên các hợp chất tiềm năng cho thử nghiệm thêm.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "2. AI trong giáo dục",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Trong lĩnh vực giáo dục, AI đang tạo ra các hệ thống học tập thích ứng có thể cá nhân hóa trải nghiệm học tập dựa trên nhu cầu và khả năng của từng học sinh. Các nền tảng AI có thể xác định lỗ hổng kiến thức và điều chỉnh tài liệu để giải quyết những lỗ hổng đó.\n\nGiáo viên cũng được hưởng lợi từ AI thông qua các công cụ tự động hóa các nhiệm vụ hành chính như chấm điểm và theo dõi tiến độ, cho phép họ tập trung nhiều thời gian hơn vào tương tác trực tiếp với học sinh.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "3. AI trong giao thông",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Phương tiện tự lái đang dần trở thành hiện thực nhờ những tiến bộ trong AI, máy học và thị giác máy tính. Các xe tự lái có tiềm năng giảm đáng kể tai nạn giao thông, giảm tắc nghẽn và cải thiện hiệu quả nhiên liệu.\n\nNgoài ô tô, AI đang được sử dụng để tối ưu hóa hệ thống giao thông công cộng, quản lý luồng giao thông và giảm tắc nghẽn trong các thành phố lớn. Các thuật toán dự đoán có thể phân tích dữ liệu lịch sử và thời gian thực để điều chỉnh tín hiệu giao thông và định tuyến phương tiện một cách hiệu quả hơn.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 150), // Để không bị che bởi floating buttons
          ],
        ),
      ),

      // Các nút phía dưới
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bên trái: Nút yêu thích và dấu trang
            Row(
              children: [
                FloatingActionButton(
                  heroTag: 'favorite',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.favorite_border, color: Colors.black),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'bookmark',
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  elevation: 2,
                  child: const Icon(Icons.bookmark_border, color: Colors.black),
                ),
              ],
            ),

            // Giữa và bên phải: Nút play và chữ "Chế độ đọc"
            Row(
              children: [
                FloatingActionButton(
                  heroTag: 'play',
                  onPressed: () {},
                  backgroundColor: Colors.blue,
                  elevation: 2,
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}