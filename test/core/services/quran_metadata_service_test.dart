import 'package:flutter_test/flutter_test.dart';
import 'package:dar_al_fajr_portal/core/models/quran_metadata.dart';
import 'package:dar_al_fajr_portal/core/services/quran_metadata_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranMetadataService', () {
    test(
      'querying Surah 2, Ayahs 140 to 145 spans across page and Juz boundaries in the data model',
      () {
        final surah2 = Surah.fromJson({
          'id': 2,
          'name': 'البقرة',
          'name_english': 'Al-Baqarah',
          'name_hebrew': 'אל-בקרה',
          'total_verses': 286,
          'page_boundaries': [
            {'start_ayah': 1, 'page': 2},
            {'start_ayah': 6, 'page': 3},
            {'start_ayah': 135, 'page': 21},
            {'start_ayah': 142, 'page': 22},
            {'start_ayah': 146, 'page': 23},
          ],
          'juz_boundaries': [
            {'start_ayah': 1, 'juz': 1},
            {'start_ayah': 142, 'juz': 2},
          ],
        });

        final service = QuranMetadataService(surahs: [surah2]);

        // Ayahs 140..145 start in page 21 (ayahs 135..141) and cross into page 22 (ayahs 142..145)
        final pages = service.calculatePages(2, 140, 145);
        expect(pages, equals([21, 22]));

        // Ayahs 140..145 start in Juz 1 (ayahs 1..141) and cross into Juz 2 (ayahs 142..286)
        final juzList = service.calculateJuz(2, 140, 145);
        expect(juzList, equals([1, 2]));
      },
    );

    test(
      'loads assets/data/quran_metadata.json and calculates pages and Juz for Surah 2, Ayahs 140 to 145',
      () async {
        final service = QuranMetadataService();
        final surahs = await service.loadMetadata();

        expect(surahs, isNotEmpty);
        expect(service.getSurahById(2)?.nameEnglish, 'Al-Baqarah');

        final pages = service.calculatePages(2, 140, 145);
        expect(pages, equals([21, 22]));

        final juzList = service.calculateJuz(2, 140, 145);
        expect(juzList, equals([1, 2]));
      },
    );

    test('handles exact boundary start/end ayahs and invalid inputs', () {
      final surah2 = Surah.fromJson({
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
      });

      final service = QuranMetadataService(surahs: [surah2]);

      // Ayahs 1..5 stay on page 2 only
      expect(service.calculatePages(2, 1, 5), equals([2]));
      // Ayahs 5..6 cross from page 2 to page 3
      expect(service.calculatePages(2, 5, 6), equals([2, 3]));
      // Ayahs 140..145 on the 2-page snippet stay on page 3 (6..286) and cross Juz [1, 2]
      expect(service.calculatePages(2, 140, 145), equals([3]));
      expect(service.calculateJuz(2, 140, 145), equals([1, 2]));

      // Invalid surah or invalid range returns empty list
      expect(service.calculatePages(999, 1, 5), isEmpty);
      expect(service.calculateJuz(2, 10, 5), isEmpty);
    });
  });
}
