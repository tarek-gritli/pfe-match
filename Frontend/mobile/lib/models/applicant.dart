import 'dart:convert';

class Applicant {
  final int id;
  final String name;
  final String initials;
  final String email;
  final String university;
  final String fieldOfStudy;
  final int matchRate;
  final String avatarColor;
  final String appliedTo;
  final int? pfeId;
  final DateTime applicationDate;
  final String status;
  final List<String> skills;
  final String? resumeUrl;

  // Extra details (only present in detail view)
  final String? bio;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final List<String>? technologies;
  final String? profilePicture;

  Applicant({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    required this.university,
    required this.fieldOfStudy,
    required this.matchRate,
    required this.avatarColor,
    required this.appliedTo,
    this.pfeId,
    required this.applicationDate,
    required this.status,
    required this.skills,
    this.resumeUrl,
    this.bio,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.technologies,
    this.profilePicture,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      initials: json['initials'] ?? '?',
      email: json['email'] ?? '',
      university: json['university'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      matchRate: json['matchRate'] is int
          ? json['matchRate']
          : (json['matchRate'] ?? 0).toInt(),
      avatarColor: json['avatarColor'] ?? '#6366F1',
      appliedTo: json['appliedTo'] ?? '',
      pfeId: json['pfeId'],
      applicationDate: json['applicationDate'] != null
          ? DateTime.parse(json['applicationDate'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : [],
      resumeUrl: json['resumeUrl'],
      bio: json['bio'],
      linkedinUrl: json['linkedinUrl'],
      githubUrl: json['githubUrl'],
      portfolioUrl: json['portfolioUrl'],
      technologies: json['technologies'] != null
          ? List<String>.from(json['technologies'])
          : null,
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'email': email,
        'university': university,
        'fieldOfStudy': fieldOfStudy,
        'matchRate': matchRate,
        'avatarColor': avatarColor,
        'appliedTo': appliedTo,
        'pfeId': pfeId,
        'applicationDate': applicationDate.toIso8601String(),
        'status': status,
        'skills': skills,
        'resumeUrl': resumeUrl,
        if (bio != null) 'bio': bio,
        if (linkedinUrl != null) 'linkedinUrl': linkedinUrl,
        if (githubUrl != null) 'githubUrl': githubUrl,
        if (portfolioUrl != null) 'portfolioUrl': portfolioUrl,
        if (technologies != null) 'technologies': technologies,
        if (profilePicture != null) 'profilePicture': profilePicture,
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
      case 'shortlisted':
        return 'Shortlisted';
      case 'reviewed':
        return 'Reviewed';
      default:
        return 'Pending';
    }
  }

  String get matchScoreLabel {
    if (matchRate >= 70) return 'Great Match';
    if (matchRate >= 50) return 'Good Match';
    return 'Low Match';
  }
}
