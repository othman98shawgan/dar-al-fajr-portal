import 'package:flutter/material.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../l10n/app_localizations_tr.dart';
import '../models/teacher_models.dart';
import 'surah_picker_sheet.dart';
import 'tasmee_modal_tokens.dart';

class TasmeeHomeworkSection extends StatelessWidget {
  final String langCode;
  final bool assignOnlyMode;
  final bool isRollover;
  final AssignmentType nextAssignmentType;
  final int nextSurahId;
  final SurahPageDefinition nextSurah;
  final int nextTargetPage;
  final int nextJuzNumber;
  final TextEditingController fromAyahController;
  final TextEditingController toAyahController;
  final ValueChanged<AssignmentType> onAssignmentTypeChanged;
  final ValueChanged<int> onJuzChanged;
  final ValueChanged<SurahPageDefinition> onSurahPicked;
  final ValueChanged<int> onPageChanged;

  const TasmeeHomeworkSection({
    super.key,
    required this.langCode,
    required this.assignOnlyMode,
    required this.isRollover,
    required this.nextAssignmentType,
    required this.nextSurahId,
    required this.nextSurah,
    required this.nextTargetPage,
    required this.nextJuzNumber,
    required this.fromAyahController,
    required this.toAyahController,
    required this.onAssignmentTypeChanged,
    required this.onJuzChanged,
    required this.onSurahPicked,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: TasmeeModalTokens.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      assignOnlyMode ? (langCode == 'ar' ? '١' : '1') : (langCode == 'ar' ? '٢' : '2'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: TasmeeModalTokens.onPrimaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      assignOnlyMode
                          ? trByLang(
                              langCode,
                              ar: 'تفاصيل الواجب المقرر للطالب',
                              he: 'פרטי המטלה לתלמיד',
                              en: 'Student Assignment Details',
                            )
                          : trByLang(
                              langCode,
                              ar: 'تحديد الواجب القادم (قابل للتعديل)',
                              he: 'קביעת המטלה הבאה',
                              en: 'Next Assignment (Editable)',
                            ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: TasmeeModalTokens.primary,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (!assignOnlyMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isRollover ? TasmeeModalTokens.error.withValues(alpha: 0.12) : TasmeeModalTokens.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isRollover
                      ? trByLang(langCode, ar: 'ترحيل للإعادة', he: 'הועבר לחזרה', en: 'Rollover for Repeat')
                      : trByLang(langCode, ar: 'مقترح تلقائياً', he: 'מוצע אוטומטית', en: 'Auto-Suggested'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isRollover ? TasmeeModalTokens.error : TasmeeModalTokens.onPrimaryFixed,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TasmeeModalTokens.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => onAssignmentTypeChanged(AssignmentType.newHifz),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: nextAssignmentType == AssignmentType.newHifz
                          ? TasmeeModalTokens.surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: nextAssignmentType == AssignmentType.newHifz
                              ? TasmeeModalTokens.primary
                              : TasmeeModalTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trByLang(
                              langCode,
                              ar: 'حفظ جديد (صفحة / سورة)',
                              he: 'שינון חדש (עמוד / סורה)',
                              en: 'New Hifz (Page / Surah)',
                            ),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: nextAssignmentType == AssignmentType.newHifz
                                      ? TasmeeModalTokens.primary
                                      : TasmeeModalTokens.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  onTap: () => onAssignmentTypeChanged(AssignmentType.revision),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: nextAssignmentType == AssignmentType.revision
                          ? TasmeeModalTokens.surfaceContainerLowest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 16,
                          color: nextAssignmentType == AssignmentType.revision
                              ? TasmeeModalTokens.primary
                              : TasmeeModalTokens.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trByLang(
                              langCode,
                              ar: 'مراجعة / اختبار جزء كامل',
                              he: 'חזרה / מבחן ג׳וז מלא',
                              en: 'Whole Juz Revision / Exam',
                            ),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: nextAssignmentType == AssignmentType.revision
                                      ? TasmeeModalTokens.primary
                                      : TasmeeModalTokens.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (nextAssignmentType == AssignmentType.revision)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TasmeeModalTokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TasmeeModalTokens.surfaceContainerHigh),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trByLang(
                    langCode,
                    ar: 'الجزء المقرر للمراجعة / الاختبار:',
                    he: 'הג׳וז שנקבע לחזרה / מבחן:',
                    en: 'Assigned Juz for Revision / Exam:',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                DropdownButton<int>(
                  value: nextJuzNumber.clamp(1, 30),
                  items: List.generate(30, (i) => i + 1)
                      .map(
                        (j) => DropdownMenuItem<int>(
                          value: j,
                          child: Text(
                            trByLang(
                              langCode,
                              ar: 'الجزء ${formatTasmeeNum(j, langCode)} كامل',
                              he: 'ג׳וז $j מלא',
                              en: 'Whole Juz $j',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onJuzChanged(val);
                  },
                ),
              ],
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Material(
                  color: TasmeeModalTokens.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () async {
                      final picked = await openCenterSurahPickerSheet(
                        context,
                        langCode,
                        currentSurahId: nextSurahId,
                      );
                      if (picked != null) {
                        onSurahPicked(CenterQuranMap.getSurahById(picked));
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TasmeeModalTokens.surfaceContainerHigh),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'سورة ${nextSurah.localizedName(langCode)} (${formatTasmeeNum(nextSurah.id, langCode)})',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: TasmeeModalTokens.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  nextSurah.isJuz30
                                      ? trByLang(
                                          langCode,
                                          ar: 'الجزء ٣٠ • سورة كاملة (صفحة واحدة بجدول المركز)',
                                          he: 'ג׳וז 30 • סורה מלאה',
                                          en: 'Juz 30 • Whole Surah (1 Center Page)',
                                        )
                                      : trByLang(
                                          langCode,
                                          ar: 'الجزء ${formatTasmeeNum(nextSurah.primaryJuz, langCode)} • الصفحات ${formatTasmeeNum(nextSurah.startPage, langCode)}-${formatTasmeeNum(nextSurah.endPage, langCode)}',
                                          he: 'ג׳וז ${nextSurah.primaryJuz} • עמ׳ ${nextSurah.startPage}-${nextSurah.endPage}',
                                          en: 'Juz ${nextSurah.primaryJuz} • Pages ${nextSurah.startPage}-${nextSurah.endPage}',
                                        ),
                                  style: const TextStyle(color: TasmeeModalTokens.onSurfaceVariant, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.expand_more_rounded, color: TasmeeModalTokens.outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!nextSurah.isJuz30) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TasmeeModalTokens.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: TasmeeModalTokens.surfaceContainerHigh),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: nextSurah.pages.contains(nextTargetPage) ? nextTargetPage : nextSurah.startPage,
                        items: nextSurah.pages
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) onPageChanged(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: fromAyahController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: trByLang(langCode, ar: 'من آية', he: 'מפסוק', en: 'From Ayah'),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: toAyahController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: trByLang(langCode, ar: 'إلى آية', he: 'עד פסוק', en: 'To Ayah'),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
