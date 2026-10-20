import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quran_metadata.dart';

class QuranMetadataService {
  static const String defaultAssetPath = 'assets/data/quran_metadata.json';

  List<Surah> _surahs;

  QuranMetadataService({List<Surah>? surahs}) : _surahs = surahs ?? [];

  List<Surah> get surahs => List.unmodifiable(_surahs);

  /// Loads and parses `assets/data/quran_metadata.json` into a `List<Surah>`.
  Future<List<Surah>> loadMetadata({
    AssetBundle? bundle,
    String assetPath = defaultAssetPath,
  }) async {
    final assetBundle = bundle ?? rootBundle;
    final jsonString = await assetBundle.loadString(assetPath);
    return loadFromJsonString(jsonString);
  }

  /// Alias for [loadMetadata] for convenience.
  Future<List<Surah>> load({
    AssetBundle? bundle,
    String assetPath = defaultAssetPath,
  }) =>
      loadMetadata(bundle: bundle, assetPath: assetPath);

  /// Parses a JSON string into a `List<Surah>` and caches it in the service.
  List<Surah> loadFromJsonString(String jsonString) {
    final decoded = json.decode(jsonString);
    return loadFromJson(decoded);
  }

  /// Parses decoded JSON (either a top-level List or a Map with a `surahs` list)
  /// into a `List<Surah>`.
  List<Surah> loadFromJson(dynamic decoded) {
    if (decoded is List) {
      _surahs = decoded
          .whereType<Map<String, dynamic>>()
          .map(Surah.fromJson)
          .toList();
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['surahs'] is List) {
        _surahs = (decoded['surahs'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Surah.fromJson)
            .toList();
      } else if (decoded.containsKey('id')) {
        _surahs = [Surah.fromJson(decoded)];
      } else {
        _surahs = [];
      }
    } else {
      _surahs = [];
    }
    return surahs;
  }

  /// Finds a [Surah] by its [surahId], or returns `null` if not found.
  Surah? getSurahById(int surahId) {
    for (final surah in _surahs) {
      if (surah.id == surahId) {
        return surah;
      }
    }
    return null;
  }

  /// Determines which page numbers are touched by the range [fromAyah] to [toAyah]
  /// in the given [surahId]. Returns a list of unique page integers.
  List<int> calculatePages(int surahId, int fromAyah, int toAyah) {
    final surah = getSurahById(surahId);
    if (surah == null || surah.pageBoundaries.isEmpty || fromAyah > toAyah) {
      return [];
    }

    if (toAyah < 1 || fromAyah > surah.totalVerses) {
      return [];
    }

    final start = fromAyah.clamp(1, surah.totalVerses);
    final end = toAyah.clamp(1, surah.totalVerses);

    final boundaries = List<PageBoundary>.from(surah.pageBoundaries)
      ..sort((a, b) {
        final cmp = a.startAyah.compareTo(b.startAyah);
        return cmp != 0 ? cmp : a.page.compareTo(b.page);
      });

    final touchedPages = <int>{};

    for (var i = 0; i < boundaries.length; i++) {
      final current = boundaries[i];
      final boundaryStart = current.startAyah;
      final boundaryEnd = (i + 1 < boundaries.length)
          ? math.max(boundaryStart, boundaries[i + 1].startAyah - 1)
          : surah.totalVerses;

      if (start <= boundaryEnd && end >= boundaryStart) {
        touchedPages.add(current.page);
      }
    }

    return touchedPages.toList();
  }

  /// Determines which Juz' numbers are touched by the range [fromAyah] to [toAyah]
  /// in the given [surahId]. Returns a list of unique Juz integers.
  List<int> calculateJuz(int surahId, int fromAyah, int toAyah) {
    final surah = getSurahById(surahId);
    if (surah == null || surah.juzBoundaries.isEmpty || fromAyah > toAyah) {
      return [];
    }

    if (toAyah < 1 || fromAyah > surah.totalVerses) {
      return [];
    }

    final start = fromAyah.clamp(1, surah.totalVerses);
    final end = toAyah.clamp(1, surah.totalVerses);

    final boundaries = List<JuzBoundary>.from(surah.juzBoundaries)
      ..sort((a, b) {
        final cmp = a.startAyah.compareTo(b.startAyah);
        return cmp != 0 ? cmp : a.juz.compareTo(b.juz);
      });

    final touchedJuz = <int>{};

    for (var i = 0; i < boundaries.length; i++) {
      final current = boundaries[i];
      final boundaryStart = current.startAyah;
      final boundaryEnd = (i + 1 < boundaries.length)
          ? math.max(boundaryStart, boundaries[i + 1].startAyah - 1)
          : surah.totalVerses;

      if (start <= boundaryEnd && end >= boundaryStart) {
        touchedJuz.add(current.juz);
      }
    }

    return touchedJuz.toList();
  }
}

final quranMetadataServiceProvider = Provider<QuranMetadataService>((ref) {
  return QuranMetadataService();
});
