import 'package:http/http.dart' as http;
import 'package:tendria/features/verifications/domain/entities/verification_selfie_entity.dart';

class VerificationSelfieModel extends VerificationSelfieEntity {
  VerificationSelfieModel({
    super.type,
    required super.foto,
    required super.fotoPerfil,
  });

  factory VerificationSelfieModel.fromJson(Map<String, dynamic> json) {
    return VerificationSelfieModel(
      type: json['\$type'],
      foto: json['foto'],
      fotoPerfil: json['fotoPerfil'],
    );
  }
  factory VerificationSelfieModel.fromEntity(VerificationSelfieEntity entity) {
    return VerificationSelfieModel(
      foto: entity.foto,
      fotoPerfil: entity.fotoPerfil,
    );
  }
  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['FotoPerfil'] = fotoPerfil;

    request.files.add(
      await http.MultipartFile.fromPath(
        'Foto ',
        foto.path,
        filename: foto.path.split('/').last,
      ),
    );
    return request;
  }
}
