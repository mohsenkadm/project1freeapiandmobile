import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Stream<DashboardSummary> watchSummary();
  Future<DashboardSummary> getSummary();
}
