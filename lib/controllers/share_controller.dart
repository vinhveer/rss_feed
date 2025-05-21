import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ShareController extends GetxController {
  void shareItem(String title) {
    SharePlus.instance.share(
      ShareParams(
        text: 'Tin tức thú vị hôm nay! $title',
      ),
    );
  }
}
