class UserModel {
  final int idUser;
  final String username;
  final String nama;
  final String level;
  final String? nim;
  final String? nip;
  final String? email;
  
  UserModel({
    required this.idUser,
    required this.username,
    required this.nama,
    required this.level,
    this.nim,
    this.nip,
    this.email,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] ?? 0,
      username: json['username'] ?? '',
      nama: json['nama'] ?? '',
      level: json['level'] ?? '',
      nim: json['nim'],
      nip: json['nip'],
      email: json['email'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'nama': nama,
      'level': level,
      'nim': nim,
      'nip': nip,
      'email': email,
    };
  }
  
  bool get isAdmin => level == 'admin';
  bool get isDosen => level == 'dosen';
  bool get isMahasiswa => level == 'mahasiswa';
}
