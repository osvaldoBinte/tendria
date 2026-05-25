import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tendria/features/stories/domain/entities/post/post_stories_entity.dart';

class PostStoriesModel extends PostStoriesEntity {
  PostStoriesModel({
    required super.contentType,
    required super.file,
  });
 
  factory PostStoriesModel.fromEntity(PostStoriesEntity entity) {
    return PostStoriesModel(
      contentType: entity.contentType,
      file: entity.file,
    );
  }
 
  void addFieldsToRequest(http.MultipartRequest request) {
    request.fields['TipoContenido'] = contentType; 
 
    print("✅ Campos agregados correctamente");
  }

  Future<void> addFileToRequest(http.MultipartRequest request) async {
    if (file.isEmpty) {
      print("⚠️ No hay archivo para subir");
      return;
    }

    final File f = File(file);

    if (!await f.exists()) {
      print("❌ Archivo no encontrado: $file");
      return;
    }

    final String fileName = f.path.split('/').last;
    final String ext = fileName.split('.').last.toLowerCase();
    final MediaType? mimeType = _getMediaType(ext);

    print('📤 Agregando archivo:');
    print('   - Nombre: $fileName');
    print('   - Extensión: $ext');
    print('   - MimeType: ${mimeType?.mimeType ?? "desconocido"}');

    request.files.add(
      await http.MultipartFile.fromPath(
        'Archivo',
        file,
        filename: fileName,
        contentType: mimeType,
      ),
    );

    print("✅ Archivo agregado correctamente");
  }

  MediaType? _getMediaType(String ext) {
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
 
      case 'mp4':
        return MediaType('video', 'mp4');
      case 'mov':
        return MediaType('video', 'quicktime');
      case 'avi':
        return MediaType('video', 'x-msvideo');
      case 'mkv':
        return MediaType('video', 'x-matroska');

      default:
        return null;
    }
  }
}
