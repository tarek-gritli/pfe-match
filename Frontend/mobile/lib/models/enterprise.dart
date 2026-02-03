class Enterprise {
  final String name;
  final String? logo;
  final String industry;
  final String? location;
  final String? size; // employee_count
  final String? description; // company_description
  final List<String> technologies;
  final String? website;
  final int? foundedYear;
  final String? linkedinUrl;
  final String? contactEmail;

  Enterprise({
    required this.name,
    this.logo,
    required this.industry,
    this.location,
    this.size,
    this.description,
    required this.technologies,
    this.website,
    this.foundedYear,
    this.linkedinUrl,
    this.contactEmail,
  });

  /// Create an Enterprise object from JSON
  factory Enterprise.fromJson(Map<String, dynamic> json) {
    return Enterprise(
      name: json['name'] ?? '',
      logo: json['logo'],
      industry: json['industry'] ?? '',
      location: json['location'],
      size: json['size'],
      description: json['description'],
      technologies: (json['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      website: json['website'],
      foundedYear: json['foundedYear'],
      linkedinUrl: json['linkedinUrl'],
      contactEmail: json['contactEmail'],
    );
  }

  /// Convert Enterprise object to JSON (useful for updates)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logo': logo,
      'industry': industry,
      'location': location,
      'size': size,
      'description': description,
      'technologies': technologies,
      'website': website,
      'foundedYear': foundedYear,
      'linkedinUrl': linkedinUrl,
      'contactEmail': contactEmail,
    };
  }
}
