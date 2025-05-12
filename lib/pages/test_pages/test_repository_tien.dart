import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách Chủ đề"),
      ),
      body: const Center(
        child: Text('Chủ đề sẽ được hiển thị ở trang TestPageTien'),
      ),
    );
  }
}
