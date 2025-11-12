class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final DateTime createdAt;

  UserProfile({required this.id, required this.email, required this.fullName, required this.createdAt});

 factory UserProfile.json(Map<String, dynamic> json) {
   return UserProfile(
    id: json['id'] as String, 
    email: json ['email'] as String, 
    fullName: json ['fullname'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String)
    );
 }
}