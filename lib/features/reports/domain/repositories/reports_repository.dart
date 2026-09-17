import '../entities/reports_summary.dart';

abstract class ReportsRepository {
  Stream<ReportsSummary> watchSummary();
  Future<ReportsSummary> getSummary();
}
