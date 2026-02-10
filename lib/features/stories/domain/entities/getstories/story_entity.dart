class StoryEntity {
  final int id;
  final String tipoContenido;
  final String urlContenido;
  final DateTime fechaCreacion;
  final DateTime fechaExpiracion;
  final int vistas;
  final int likes;
  final bool yaVista;
  final bool yaLikeada;

  StoryEntity({
    required this.id,
    required this.tipoContenido,
    required this.urlContenido,
    required this.fechaCreacion,
    required this.fechaExpiracion,
    required this.vistas,
    required this.likes,
    required this.yaVista,
    required this.yaLikeada,
  });
}
