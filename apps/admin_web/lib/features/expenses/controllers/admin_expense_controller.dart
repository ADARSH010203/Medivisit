import 'package:get/get.dart';
import 'package:core/core.dart';
import '../../auth/controllers/admin_auth_controller.dart';

class AdminExpenseController extends GetxController {
  final ExpenseRepository _expenseRepo = Get.find<ExpenseRepository>();
  final UserRepository _userRepo = Get.find<UserRepository>();
  final AdminAuthController _authController = Get.find<AdminAuthController>();

  final RxList<Expense> allExpenses = <Expense>[].obs;
  final RxList<Expense> filteredExpenses = <Expense>[].obs;
  final RxBool isLoading = true.obs;
  
  final RxString selectedTab = 'Pending'.obs;
  
  final Map<String, String> mrNames = {};

  @override
  void onInit() {
    super.onInit();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    isLoading.value = true;
    try {
      // In a real app we might paginate or only fetch recent. Here we fetch pending first.
      final expenses = await _expenseRepo.getPendingExpenses(); // For 'All', we'd need a broader query.
      allExpenses.value = expenses;
      
      // Fetch MR names
      for (final exp in expenses) {
        if (!mrNames.containsKey(exp.mrId)) {
          final user = await _userRepo.getUserById(exp.mrId);
          mrNames[exp.mrId] = user?.name ?? 'Unknown MR';
        }
      }
      
      _filterExpenses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(String tab) {
    selectedTab.value = tab;
    // Realistically, we should query Firestore for 'All' or 'Approved'.
    // For now we'll just mock it or only show pending.
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

  Future<void> approveExpense(String expenseId) async {
    try {
      final admin = _authController.currentUser.value;
      await _expenseRepo.updateExpenseStatus(
        expenseId, 
        ExpenseStatus.approved,
        approvedBy: admin?.uid,
      );
      Get.snackbar('Success', 'Expense approved');
      _loadExpenses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve expense: $e');
    }
  }

  Future<void> rejectExpense(String expenseId) async {
    try {
      final admin = _authController.currentUser.value;
      await _expenseRepo.updateExpenseStatus(
        expenseId, 
        ExpenseStatus.rejected,
        approvedBy: admin?.uid,
      );
      Get.snackbar('Success', 'Expense rejected');
      _loadExpenses();
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject expense: $e');
    }
  }
}
