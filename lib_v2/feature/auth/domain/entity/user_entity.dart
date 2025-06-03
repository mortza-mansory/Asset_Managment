class UserEntity {
  final String username;
  final String phoneNumber;
  final String? governmentId;
  final String? governmentName;

  const UserEntity({
    required this.username,
    required this.phoneNumber,
    this.governmentId,
    this.governmentName,
  });
}