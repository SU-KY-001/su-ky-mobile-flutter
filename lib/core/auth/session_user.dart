/// Signed-in account as the app needs it. Pure Dart so `core` stays UI-free.
final class SessionUser {
  const SessionUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is SessionUser &&
      other.id == id &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);
}
