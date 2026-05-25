import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:tendria/common/settings/language_controller.dart';

class TranslationService extends GetxService {
  OnDeviceTranslator? _toEnglish;
  OnDeviceTranslator? _toSpanish;

  final _modelManager = OnDeviceTranslatorModelManager();

  final Map<String, String> _cacheEn = {};
  final Map<String, String> _cacheEs = {};

  final RxBool isReady = false.obs;
 
  String get _currentLanguage => Get.find<LanguageController>().lang;
 
  @override
  void onInit() {
    super.onInit();
    _initTranslators();
  }

  Future<void> _initTranslators() async {
    try {
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
  Future<String> translate(String text, [String? targetLanguage]) async {
    if (text.isEmpty) return text;
    if (!isReady.value) return text;
 
    final lang = targetLanguage ?? _currentLanguage;
 
    if (lang == 'Español') return text;

    if (lang == 'Inglés') {
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
  Future<List<String>> translateList(
      List<String> texts, [String? targetLanguage]) async {
    if (!isReady.value) return texts;

    final lang = targetLanguage ?? _currentLanguage;
 
    if (lang == 'Español') return texts;

    return Future.wait(texts.map((t) => translate(t, lang)));
  }
 

  @override
  void onClose() {
    _toEnglish?.close();
    _toSpanish?.close();
    super.onClose();
  }
}