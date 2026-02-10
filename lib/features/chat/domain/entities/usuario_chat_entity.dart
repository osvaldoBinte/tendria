class UsuarioChatEntity {
  final int id;
  final String nombre;
  final String? fotoUrl;

  UsuarioChatEntity({
    required this.id,
    required this.nombre,
    this.fotoUrl,
  });
}
