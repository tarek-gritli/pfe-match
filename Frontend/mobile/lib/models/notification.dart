class Notification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final int? pfeListingId;
  final int? applicationId;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.pfeListingId,
    this.applicationId,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool,
      pfeListingId: json['pfe_listing_id'] as int?,
      applicationId: json['application_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'pfe_listing_id': pfeListingId,
      'application_id': applicationId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
