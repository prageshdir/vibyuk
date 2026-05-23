class UpdateProfileDto {
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? location;
  final String? website;
  final Map<String, String?>? socialLinks;
  final Map<String, dynamic>? creatorInfo;
  final Map<String, dynamic>? businessInfo;

  const UpdateProfileDto({
    this.firstName,
    this.lastName,
    this.bio,
    this.location,
    this.website,
    this.socialLinks,
    this.creatorInfo,
    this.businessInfo,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (firstName != null) json['first_name'] = firstName;
    if (lastName != null) json['last_name'] = lastName;
    if (bio != null) json['bio'] = bio;
    if (location != null) json['location'] = location;
    if (website != null) json['website'] = website;
    if (socialLinks != null) json['social_links'] = socialLinks;
    if (creatorInfo != null) json['creator_info'] = creatorInfo;
    if (businessInfo != null) json['business_info'] = businessInfo;
    return json;
  }
}
