// lib/common/services/translation_service.dart
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService extends GetxService {
  OnDeviceTranslator? _toEnglish;
  OnDeviceTranslator? _toSpanish;

  final _modelManager = OnDeviceTranslatorModelManager();

  // Cache para no traducir lo mismo dos veces
  final Map<String, String> _cacheEn = {};
  final Map<String, String> _cacheEs = {};

  final RxBool isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initTranslators();
  }

  Future<void> _initTranslators() async {
    try {
      // Descargar modelos si no están
      final hasEs = await _modelManager.isModelDownloaded(
        TranslateLanguage.spanish.bcpCode,
      );
      final hasEn = await _modelManager.isModelDownloaded(
        TranslateLanguage.english.bcpCode,
      );

      if (!hasEs) {
        await _modelManager.downloadModel(
          TranslateLanguage.spanish.bcpCode,
        );
      }
      if (!hasEn) {
        await _modelManager.downloadModel(
          TranslateLanguage.english.bcpCode,
        );
      }

      _toEnglish = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.spanish,
        targetLanguage: TranslateLanguage.english,
      );

      _toSpanish = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.spanish,
      );

      isReady.value = true;
    } catch (e) {
      print('Error iniciando traducción: $e');
    }
  }

  /// Traduce un texto al idioma destino.
  /// [targetLanguage] debe ser 'Inglés' o 'Español'
  Future<String> translate(String text, String targetLanguage) async {
    if (text.isEmpty) return text;
    if (!isReady.value) return text;

    if (targetLanguage == 'Inglés') {
      if (_cacheEn.containsKey(text)) return _cacheEn[text]!;
      final result = await _toEnglish?.translateText(text) ?? text;
      _cacheEn[text] = result;
      return result;
    } else {
      if (_cacheEs.containsKey(text)) return _cacheEs[text]!;
      final result = await _toSpanish?.translateText(text) ?? text;
      _cacheEs[text] = result;
      return result;
    }
  }

  /// Traduce una lista de textos al idioma destino
  Future<List<String>> translateList(
      List<String> texts, String targetLanguage) async {
    if (!isReady.value) return texts;
    return Future.wait(texts.map((t) => translate(t, targetLanguage)));
  }

  @override
  void onClose() {
    _toEnglish?.close();
    _toSpanish?.close();
    super.onClose();
  }
}