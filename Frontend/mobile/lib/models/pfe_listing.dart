// filepath: /Users/fedynouri/Desktop/pfe-match/Frontend/mobile/lib/models/pfe_listing.dart

import 'dart:convert';

class CompanyInfo {
  final String id;
  final String name;
  final String? logoUrl;
  final String? industry;

  CompanyInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.industry,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'],
      industry: json['industry'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'industry': industry,
      };
}

class PFEListing {
  final String id;
  final String title;
  final String status; // 'open' | 'closed'
  final String category;
  final String duration;
  final List<String> skills;
  final int applicantCount;
  final String? description;
  final String? department;
  final DateTime? postedDate;
  final DateTime? deadline;
  final String? location;
  final CompanyInfo company;

  PFEListing({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.duration,
    required this.skills,
    required this.applicantCount,
    this.description,
    this.department,
    this.postedDate,
    this.deadline,
    this.location,
    required this.company,
  });

  factory PFEListing.fromJson(Map<String, dynamic> json) {
    return PFEListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      status: json['status'] ?? 'open',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      skills: (json['skills'] as List? ?? []).map((s) => s.toString()).toList(),
      applicantCount: json['applicantCount'] ?? 0,
      description: json['description'],
      department: json['department'],
      postedDate: json['postedDate'] != null ? DateTime.tryParse(json['postedDate']) : null,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      location: json['location'],
      company: CompanyInfo.fromJson(json['company'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'category': category,
        'duration': duration,
        'skills': skills,
        'applicantCount': applicantCount,
        'description': description,
        'department': department,
        'postedDate': postedDate?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'location': location,
        'company': company.toJson(),
      };

  @override
  String toString() => jsonEncode(toJson());
}

