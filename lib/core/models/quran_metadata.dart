class PageBoundary {
  final int startAyah;
  final int page;

  const PageBoundary({
    required this.startAyah,
    required this.page,
  });

  factory PageBoundary.fromJson(Map<String, dynamic> json) {
    return PageBoundary(
      startAyah: json['start_ayah'] as int,
      page: json['page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_ayah': startAyah,
      'page': page,
    };
  }

  @override
  String toString() => 'PageBoundary(startAyah: $startAyah, page: $page)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PageBoundary &&
        other.startAyah == startAyah &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(startAyah, page);
}

class JuzBoundary {
  final int startAyah;
  final int juz;

  const JuzBoundary({
    required this.startAyah,
    required this.juz,
  });

  factory JuzBoundary.fromJson(Map<String, dynamic> json) {
    return JuzBoundary(
      startAyah: json['start_ayah'] as int,
      juz: json['juz'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_ayah': startAyah,
      'juz': juz,
    };
  }

  @override
  String toString() => 'JuzBoundary(startAyah: $startAyah, juz: $juz)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JuzBoundary &&
        other.startAyah == startAyah &&
        other.juz == juz;
  }

  @override
  int get hashCode => Object.hash(startAyah, juz);
}

class Surah {
  final int id;
  final String name;
  final String nameEnglish;
  final String nameHebrew;
  final int totalVerses;
  final List<PageBoundary> pageBoundaries;
  final List<JuzBoundary> juzBoundaries;

  const Surah({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.nameHebrew,
    required this.totalVerses,
    required this.pageBoundaries,
    required this.juzBoundaries,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      name: json['name'] as String,
      nameEnglish: json['name_english'] as String,
      nameHebrew: json['name_hebrew'] as String,
      totalVerses: json['total_verses'] as int,
      pageBoundaries: (json['page_boundaries'] as List<dynamic>?)
              ?.map((e) => PageBoundary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      juzBoundaries: (json['juz_boundaries'] as List<dynamic>?)
              ?.map((e) => JuzBoundary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_english': nameEnglish,
      'name_hebrew': nameHebrew,
      'total_verses': totalVerses,
      'page_boundaries': pageBoundaries.map((e) => e.toJson()).toList(),
      'juz_boundaries': juzBoundaries.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns the localized name of the Surah based on the provided [languageCode].
  String getName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEnglish;
      case 'he':
        return nameHebrew;
      case 'ar':
      default:
        return name;
    }
  }

  @override
  String toString() =>
      'Surah(id: $id, name: $name, totalVerses: $totalVerses)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Surah && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
