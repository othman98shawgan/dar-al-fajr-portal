import 'package:flutter/material.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import 'surah_picker_sheet.dart';
import 'tasmee_modal_tokens.dart';

class TasmeeRecitationUnitCard extends StatelessWidget {
  final String langCode;
  final int index;
  final int totalUnits;
  final TasmeeRecitationUnit unit;
  final GradingPenaltyConfig penaltyConfig;
  final ValueChanged<TasmeeRecitationUnit> onUpdateUnit;
  final VoidCallback? onDeleteUnit;

  const TasmeeRecitationUnitCard({
    super.key,
    required this.langCode,
    required this.index,
    required this.totalUnits,
    required this.unit,
    required this.penaltyConfig,
    required this.onUpdateUnit,
    this.onDeleteUnit,
  });

  @override
  Widget build(BuildContext context) {
    final surahDef = CenterQuranMap.getSurahById(unit.surahId);
    final score = unit.computedScore(penaltyConfig);
    final isPassed = unit.isPassed(penaltyConfig);
    final minThreshold = unit.unitType == RecitationUnitType.juzExam
        ? penaltyConfig.juzExamPassingThreshold
        : penaltyConfig.pagePassingThreshold;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TasmeeModalTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !unit.isGraded
              ? TasmeeModalTokens.outline.withValues(alpha: 0.4)
              : (isPassed
                  ? TasmeeModalTokens.primary.withValues(alpha: 0.35)
                  : TasmeeModalTokens.error.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalUnits > 1
                    ? trByLang(
                        langCode,
                        ar: 'مقطع التسميع #${formatTasmeeNum(index + 1, langCode)}',
                        he: 'יחידת שינון #${index + 1}',
                        en: 'Recitation Unit #${index + 1}',
                      )
                    : trByLang(
                        langCode,
                        ar: 'نوع المقطع المسمّع',
                        he: 'סוג יחידת השינון',
                        en: 'Recited Unit Type',
                      ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: TasmeeModalTokens.onSurfaceVariant,
                ),
              ),
              if (onDeleteUnit != null)
                IconButton(
                  onPressed: onDeleteUnit,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: TasmeeModalTokens.error),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: RecitationUnitType.values.map((t) {
              final selected = unit.unitType == t;
              return ChoiceChip(
                label: Text(
                  t.localizedName(langCode),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? TasmeeModalTokens.onPrimaryFixed : TasmeeModalTokens.onSurfaceVariant,
                  ),
                ),
                selected: selected,
                selectedColor: TasmeeModalTokens.primaryFixed,
                backgroundColor: TasmeeModalTokens.surfaceContainerLowest,
                onSelected: (_) {
                  onUpdateUnit(
                    unit.copyWith(
                      unitType: t,
                      juzNumber: t == RecitationUnitType.juzExam
                          ? (unit.juzNumber ?? surahDef.primaryJuz)
                          : unit.juzNumber,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          if (unit.unitType == RecitationUnitType.juzExam)
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 18, color: TasmeeModalTokens.primary),
                const SizedBox(width: 8),
                Text(
                  trByLang(
                    langCode,
                    ar: 'مراجعة / اختبار الجزء الكامل:',
                    he: 'מבחן / חזרה על ג׳וז מלא:',
                    en: 'Whole Juz Exam / Revision:',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: (unit.juzNumber ?? 30).clamp(1, 30),
                  items: List.generate(30, (i) => i + 1)
                      .map(
                        (j) => DropdownMenuItem<int>(
                          value: j,
                          child: Text(
                            trByLang(
                              langCode,
                              ar: 'الجزء ${formatTasmeeNum(j, langCode)}',
                              he: 'ג׳וז $j',
                              en: 'Juz $j',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      onUpdateUnit(unit.copyWith(juzNumber: val));
                    }
                  },
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      final pickedId = await openCenterSurahPickerSheet(
                        context,
                        langCode,
                        currentSurahId: unit.surahId,
                      );
                      if (pickedId != null) {
                        final pickedSurah = CenterQuranMap.getSurahById(pickedId);
                        onUpdateUnit(
                          unit.copyWith(
                            surahId: pickedSurah.id,
                            surahName: pickedSurah.nameAr,
                            pageNumber: pickedSurah.startPage,
                            juzNumber: pickedSurah.primaryJuz,
                            fromAyah: 1,
                            toAyah: pickedSurah.totalVerses,
                            unitType: pickedSurah.isJuz30 && unit.unitType == RecitationUnitType.page
                                ? RecitationUnitType.surah
                                : unit.unitType,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: TasmeeModalTokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TasmeeModalTokens.surfaceContainerHigh),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'سورة ${surahDef.localizedName(langCode)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                if (unit.unitType == RecitationUnitType.page && !surahDef.isJuz30) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: TasmeeModalTokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: TasmeeModalTokens.surfaceContainerHigh),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: surahDef.pages.contains(unit.pageNumber) ? unit.pageNumber : surahDef.startPage,
                          items: surahDef.pages
                              .map(
                                (p) => DropdownMenuItem<int>(
                                  value: p,
                                  child: Text(
                                    trByLang(
                                      langCode,
                                      ar: 'صفحة ${formatTasmeeNum(p, langCode)}',
                                      he: 'עמוד $p',
                                      en: 'Page $p',
                                    ),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (p) {
                            if (p != null) {
                              onUpdateUnit(unit.copyWith(pageNumber: p));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 10),
          if (!unit.isGraded)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TasmeeModalTokens.secondaryFixed.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: TasmeeModalTokens.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trByLang(
                        langCode,
                        ar: 'قراءة جزئية (أقل من صفحة أو سورة كاملة): تُسجّل كملاحظة متابعة فقط بدون علامة رقمية ولا تُحتسب كصفحة منجزة حتى يتم تسميعها كاملة.',
                        he: 'קריאה חלקית: נרשמת כהערת מעקב בלבד ללא ציון מספרי.',
                        en: 'Partial read (< 1 full page/surah): Recorded with teacher notes only (no numeric grade).',
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: TasmeeModalTokens.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: MistakeCounterTile(
                    label: trByLang(langCode, ar: 'خطأ لفظي', he: 'טעות הגייה', en: 'Verbal (Lafzi)'),
                    penaltyLabel: '-${penaltyConfig.lafziPenalty}',
                    count: unit.lafziCount,
                    color: TasmeeModalTokens.error,
                    onDecrement: unit.lafziCount > 0
                        ? () => onUpdateUnit(
                              unit.copyWith(lafziCount: unit.lafziCount - 1, clearManualScore: true),
                            )
                        : null,
                    onIncrement: () => onUpdateUnit(
                      unit.copyWith(lafziCount: unit.lafziCount + 1, clearManualScore: true),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MistakeCounterTile(
                    label: trByLang(langCode, ar: 'فتح (توقف)', he: 'פתיחה (עצירה)', en: 'Prompt (Fath)'),
                    penaltyLabel: '-${penaltyConfig.fathPenalty}',
                    count: unit.fathCount,
                    color: TasmeeModalTokens.secondary,
                    onDecrement: unit.fathCount > 0
                        ? () => onUpdateUnit(
                              unit.copyWith(fathCount: unit.fathCount - 1, clearManualScore: true),
                            )
                        : null,
                    onIncrement: () => onUpdateUnit(
                      unit.copyWith(fathCount: unit.fathCount + 1, clearManualScore: true),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: MistakeCounterTile(
                    label: trByLang(langCode, ar: 'تعتعة / استدراك', he: 'תיקון עצמי', en: 'Self-Correct'),
                    penaltyLabel: penaltyConfig.tataaPenalty == 0 ? '0' : '-${penaltyConfig.tataaPenalty}',
                    count: unit.tataaCount,
                    color: TasmeeModalTokens.tertiary,
                    onDecrement: unit.tataaCount > 0
                        ? () => onUpdateUnit(
                              unit.copyWith(tataaCount: unit.tataaCount - 1, clearManualScore: true),
                            )
                        : null,
                    onIncrement: () => onUpdateUnit(
                      unit.copyWith(tataaCount: unit.tataaCount + 1, clearManualScore: true),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isPassed
                    ? TasmeeModalTokens.primaryFixed.withValues(alpha: 0.45)
                    : TasmeeModalTokens.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPassed ? TasmeeModalTokens.primary : TasmeeModalTokens.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${formatTasmeeNum(score ?? 100, langCode)} / ${formatTasmeeNum(100, langCode)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPassed
                                    ? trByLang(langCode, ar: 'مجتاز بنجاح ✓', he: 'עבר בהצלחה ✓', en: 'Passed ✓')
                                    : trByLang(langCode, ar: 'يحتاج إعادة التسميع', he: 'דורש חזרה', en: 'Needs Repeat'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: isPassed ? TasmeeModalTokens.primary : TasmeeModalTokens.error,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                trByLang(
                                  langCode,
                                  ar: 'علامة النجاح: ${formatTasmeeNum(minThreshold, langCode)} فأعلى',
                                  he: 'ציון מעבר: $minThreshold ומעלה',
                                  en: 'Passing score: >= $minThreshold',
                                ),
                                style: const TextStyle(fontSize: 11, color: TasmeeModalTokens.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: unit.forceRepeat,
                        activeColor: TasmeeModalTokens.error,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) => onUpdateUnit(unit.copyWith(forceRepeat: val ?? false)),
                      ),
                      Text(
                        trByLang(langCode, ar: 'إلزام بالإعادة', he: 'חייב חזרה', en: 'Force Repeat'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: TasmeeModalTokens.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
