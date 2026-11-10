import 'package:equatable/equatable.dart';

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.currency,
    required this.hourlyRate,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String currency;
  final double hourlyRate;
  final DateTime createdAt;

  Project copyWith({String? name, String? currency, double? hourlyRate}) {
    return Project(
      id: id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, currency, hourlyRate, createdAt];
}
