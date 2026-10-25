import 'package:flutter_test/flutter_test.dart';
import 'package:dar_al_fajr_portal/core/models/quran_metadata.dart';

void main() {
  group('Quran Metadata Models', () {
    test('Surah fromJson parses sample JSON structure correctly', () {
      final json = {
        'id': 2,
        'name': 'البقرة',
        'name_english': 'Al-Baqarah',
        'name_hebrew': 'אל-בקרה',
        'total_verses': 286,
        'page_boundaries': [
          {'start_ayah': 1, 'page': 2},
          {'start_ayah': 6, 'page': 3},
        ],
        'juz_boundaries': [
          {'start_ayah': 1, 'juz': 1},
          {'start_ayah': 142, 'juz': 2},
        ],
      };

      final surah = Surah.fromJson(json);

      expect(surah.id, 2);
      expect(surah.name, 'البقرة');
      expect(surah.nameEnglish, 'Al-Baqarah');
      expect(surah.nameHebrew, 'אל-בקרה');
      expect(surah.totalVerses, 286);
      expect(surah.pageBoundaries.length, 2);
      expect(surah.pageBoundaries[0].startAyah, 1);
      expect(surah.pageBoundaries[0].page, 2);
      expect(surah.pageBoundaries[1].startAyah, 6);
      expect(surah.pageBoundaries[1].page, 3);
      expect(surah.juzBoundaries.length, 2);
      expect(surah.juzBoundaries[0].startAyah, 1);
      expect(surah.juzBoundaries[0].juz, 1);
      expect(surah.juzBoundaries[1].startAyah, 142);
      expect(surah.juzBoundaries[1].juz, 2);

      // Localized name helper
      expect(surah.getName('ar'), 'البقرة');
      expect(surah.getName('en'), 'Al-Baqarah');
      expect(surah.getName('he'), 'אל-בקרה');

      // toJson test
      final encoded = surah.toJson();
      expect(encoded['id'], 2);
      expect(encoded['name_english'], 'Al-Baqarah');
      expect((encoded['page_boundaries'] as List).length, 2);
    });
  });
}
