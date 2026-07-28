import 'package:get/get.dart';
import 'package:core/core.dart';

class AchievementsController extends GetxController {
  final BadgeRepository _badgeRepo = Get.find<BadgeRepository>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<BadgeDefinition> myBadges = <BadgeDefinition>[].obs;
  final RxList<BadgeDefinition> allBadges = <BadgeDefinition>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    isLoading.value = true;
    try {
      final user = await _authService.getFreshUserRecord();
      if (user == null) return;

      allBadges.value = await _badgeRepo.getBadgeDefinitions();
      final earnedIds = await _badgeRepo.getMrBadges(user.uid);
      myBadges.value = allBadges.where((b) => earnedIds.contains(b.id)).toList();
    } finally {
      isLoading.value = false;
    }
  }
}
