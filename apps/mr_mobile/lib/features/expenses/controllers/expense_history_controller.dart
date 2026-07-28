import 'package:get/get.dart';
import 'package:core/core.dart';
import '../../auth/controllers/auth_controller.dart';

class ExpenseHistoryController extends GetxController {
  final ExpenseRepository _expenseRepo = Get.find<ExpenseRepository>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Expense> allExpenses = <Expense>[].obs;
  final RxList<Expense> filteredExpenses = <Expense>[].obs;
  final RxBool isLoading = true.obs;
  
  final RxString selectedTab = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    isLoading.value = true;
    try {
      final user = _authController.currentUser.value;
      if (user != null) {
        final expenses = await _expenseRepo.getExpenses(user.uid);
        allExpenses.value = expenses;
        _filterExpenses();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expense history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    selectedTab.value = tab;
    _filterExpenses();
  }

  void _filterExpenses() {
    if (selectedTab.value == 'All') {
      filteredExpenses.value = allExpenses;
    } else {
      ExpenseStatus statusToMatch;
      switch (selectedTab.value) {
        case 'Approved':
          statusToMatch = ExpenseStatus.approved;
          break;
        case 'Rejected':
          statusToMatch = ExpenseStatus.rejected;
          break;
        case 'Pending':
        default:
          statusToMatch = ExpenseStatus.pending;
          break;
      }
      filteredExpenses.value = allExpenses.where((e) => e.status == statusToMatch).toList();
    }
  }

  void refreshExpenses() {
    _loadExpenses();
  }
}
