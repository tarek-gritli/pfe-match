class Student {
  final int? id;
  final String? email;
  final String firstName;
  final String lastName;
  final String? university;
  final String? bio;
  final String? title;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? customLinkUrl;
  final String? customLinkLabel;
  final String? profileImage;
  final String? resumeUrl;
  final String? resumeName;
  final List<String> skills;
  final List<String> technologies;
  final bool profileCompleted;

  Student({
    this.id,
    this.email,
    required this.firstName,
    required this.lastName,
    this.university,
    this.bio,
    this.title,
    this.linkedinUrl,
    this.githubUrl,
    this.customLinkUrl,
    this.customLinkLabel,
    this.profileImage,
    this.resumeUrl,
    this.resumeName,
    this.skills = const [],
    this.technologies = const [],
    this.profileCompleted = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  // Alias getters for compatibility with profile screen
  String? get shortBio => bio;
  String? get desiredJobRole => title;
  String? get profilePictureUrl => profileImage;
  String? get portfolioUrl => customLinkUrl;

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      university: json['university'],
      bio: json['bio'] ?? json['short_bio'],
      title: json['title'] ?? json['desired_job_role'],
      linkedinUrl: json['linkedinUrl'] ?? json['linkedin_url'],
      githubUrl: json['githubUrl'] ?? json['github_url'],
      customLinkUrl:
          json['customLinkUrl'] ??
          json['custom_link_url'] ??
          json['portfolio_url'],
      customLinkLabel:
          json['customLinkLabel'] ?? json['custom_link_label'] ?? 'Portfolio',
      profileImage:
          json['profileImage'] ??
          json['profile_image'] ??
          json['profile_picture_url'],
      resumeUrl: json['resumeUrl'] ?? json['resume_url'],
      resumeName: json['resumeName'] ?? json['resume_name'],
      skills: _parseStringList(json['skills']),
      technologies: _parseStringList(json['technologies']),
      profileCompleted:
          json['profileCompleted'] ?? json['profile_completed'] ?? false,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'university': university,
      'bio': bio,
      'title': title,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'customLinkUrl': customLinkUrl,
      'customLinkLabel': customLinkLabel,
      'profileImage': profileImage,
      'resumeUrl': resumeUrl,
      'resumeName': resumeName,
      'skills': skills,
      'technologies': technologies,
      'profileCompleted': profileCompleted,
    };
  }
}
