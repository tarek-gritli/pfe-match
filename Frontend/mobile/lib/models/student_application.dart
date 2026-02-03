import 'dart:convert';
import 'pfe_listing.dart';

class StudentApplication {
  final String id;
  final String status; // 'pending', 'accepted', 'rejected', 'interview', 'reviewed'
  final double matchScore;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final PFEListing? pfeListing;

  StudentApplication({
    required this.id,
    required this.status,
    required this.matchScore,
    required this.appliedAt,
    this.updatedAt,
    this.pfeListing,
  });

  factory StudentApplication.fromJson(Map<String, dynamic> json) {
    return StudentApplication(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      matchScore: (json['matchScore'] ?? 0).toDouble(),
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      pfeListing: json['pfe_listing'] != null
          ? PFEListing.fromJson(json['pfe_listing'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'matchScore': matchScore,
        'appliedAt': appliedAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'pfe_listing': pfeListing?.toJson(),
      };

  @override
  String toString() => jsonEncode(toJson());

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'interview':
        return 'Interview';
      case 'reviewed':
        return 'Reviewed';
      default:
        return 'Pending';
    }
  }

  String get matchScoreLabel {
    if (matchScore >= 70) return 'Great Match';
    if (matchScore >= 50) return 'Good Match';
    return 'Low Match';
  }
}
