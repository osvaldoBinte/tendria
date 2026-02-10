import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tendria/features/user/domain/entities/upload_media_entity.dart';

class UploadMediaModel extends UploadMediaEntity {
  UploadMediaModel({
    required super.mediaPath,
  });

  factory UploadMediaModel.fromEntity(UploadMediaEntity entity) {
    return UploadMediaModel(
      mediaPath: entity.mediaPath,
    );
  }

Future<void> addFileToRequest(http.MultipartRequest request) async {
  if (mediaPath.isEmpty) {
    print("⚠️ No hay archivo para subir");
    return;
  }

  final file = File(mediaPath);

  if (!await file.exists()) {
    print("❌ Archivo no encontrado: $mediaPath");
    return;
  }

  final fileName = file.path.split('/').last;
  final ext = fileName.split('.').last.toLowerCase();

  final mimeType = _getImageMediaType(ext);

  if (mimeType == null) {
    throw Exception('Solo se permiten imágenes');
  }

  print('🖼 Subiendo Foto: $fileName');

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      mediaPath,
      filename: fileName,
      contentType: mimeType,
    ),
  );

  print("✅ Foto agregada correctamente");
}

MediaType? _getImageMediaType(String ext) {
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'gif':
      return MediaType('image', 'gif');
    case 'webp':
      return MediaType('image', 'webp');
    default:
      return null; 
  }
}

}
