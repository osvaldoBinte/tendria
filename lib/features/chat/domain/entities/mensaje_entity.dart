class MensajeEntity {
  final int id;
  final int chatId;
  final int senderId;
  final String? senderNombre;
  final String? senderFoto;
  final String? mensaje;
  final DateTime enviadoEn;
  final bool esPropio;

  MensajeEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.senderNombre,
    this.senderFoto,
    this.mensaje,
    required this.enviadoEn,
    required this.esPropio,
  });
}
