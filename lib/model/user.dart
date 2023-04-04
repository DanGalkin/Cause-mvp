class User {
  final String id;
  String email;
  String displayName;

  User({
    required this.id,
    this.email = '',
    this.displayName = '',
  });
}
