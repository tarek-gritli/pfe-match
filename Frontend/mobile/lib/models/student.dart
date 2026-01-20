class Student {
  final int id;
  final Profile profile;
  final List<Skill> skills;
  final List<Tool> tools;
  final Resume? resume;
  final int profileIntegrity;

  Student({
    required this.id,
    required this.profile,
    required this.skills,
    required this.tools,
    this.resume,
    required this.profileIntegrity,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,  // Add default value
      profile: Profile.fromJson(json['profile']),
      skills: (json['skills'] as List? ?? []).map((s) => Skill.fromJson(s)).toList(),  // Handle null list
      tools: (json['tools'] as List? ?? []).map((t) => Tool.fromJson(t)).toList(),  // Handle null list
      resume: json['resume'] != null ? Resume.fromJson(json['resume']) : null,
      profileIntegrity: json['profileIntegrity'] ?? 0,  // Add default value
    );
  }
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