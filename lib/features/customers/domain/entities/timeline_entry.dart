import 'package:equatable/equatable.dart';

enum TimelineEntryType { debt, payment }

class TimelineEntry extends Equatable {
  const TimelineEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    this.subtitle,
    required this.date,
  });

  final String id;
  final TimelineEntryType type;
  final int amount;
  final String title;
  final String? subtitle;
  final DateTime date;

  @override
  List<Object?> get props => [id, type, amount, title, subtitle, date];
}
