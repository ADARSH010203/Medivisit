import '../models/leave_request.dart';

abstract class LeaveRepository {
  Future<void> submitLeave(LeaveRequest request);

  Future<List<LeaveRequest>> getLeaveHistory(String mrId);

  Future<List<LeaveRequest>> getPendingLeaves();
  
  Future<List<LeaveRequest>> getAllLeaves();

  Future<void> updateLeaveStatus({
    required String leaveId,
    required String status,
    required String approvedBy,
    String? adminNote,
  });
}
