class StudentProfileForm {
  String profileImage;
  String title;
  String university;
  String bio;
  List<String> skills;
  List<String> technologies;
  String resumeName;
  String linkedinUrl;
  String githubUrl;
  String portfolioUrl;
  String customLinkLabel;
  String customLinkUrl;

  StudentProfileForm({
    this.profileImage = '',
    this.title = '',
    this.university = '',
    this.bio = '',
    List<String>? skills,
    List<String>? technologies,
    this.resumeName = '',
    this.linkedinUrl = '',
    this.githubUrl = '',
    this.portfolioUrl = '',
    this.customLinkLabel = '',
    this.customLinkUrl = '',
  }) : skills = skills ?? [],
       technologies = technologies ?? [];
}

class ProfileStep {
  final int id;
  final String title;
  final String icon;

  const ProfileStep({
    required this.id,
    required this.title,
    required this.icon,
  });
}
class Profile {
  final String name;
  final String title;
  final String university;
  final String location;
  final String imageUrl;
  final String summary;

  Profile({
    required this.name, 
    required this.title, 
    required this.university, 
    required this.location, 
    required this.imageUrl, 
    required this.summary
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      university: json['university'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}

class Skill {
  final String name;
  Skill({required this.name});
  factory Skill.fromJson(Map<String, dynamic> json) => Skill(name: json['name']);
}

class Tool {
  final String name;
  Tool({required this.name});
  factory Tool.fromJson(Map<String, dynamic> json) => Tool(name: json['name']);
}

class Resume {
  final String filename;
  final String lastUpdated;
  final String size;

  Resume({required this.filename, required this.lastUpdated, required this.size});

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      filename: json['filename'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      size: json['size'] ?? '',
    );
  }
}