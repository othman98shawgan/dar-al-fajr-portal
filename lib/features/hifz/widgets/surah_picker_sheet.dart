import 'package:flutter/material.dart';

import '../../../core/models/surah_page_map.dart';
import '../../../l10n/app_localizations_tr.dart';
import 'tasmee_modal_tokens.dart';

Future<int?> openCenterSurahPickerSheet(
  BuildContext context,
  String langCode, {
  required int currentSurahId,
}) async {
  String searchFilter = '';
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TasmeeModalTokens.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (context, setPickerState) {
          final filtered = CenterQuranMap.surahs.where((s) {
            if (searchFilter.trim().isEmpty) return true;
            final q = searchFilter.trim().toLowerCase();
            return s.nameAr.contains(q) ||
                s.nameEn.toLowerCase().contains(q) ||
                s.nameHe.contains(q) ||
                s.id.toString() == q;
          }).toList();

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.45,
            builder: (_, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TasmeeModalTokens.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trByLang(
                        langCode,
                        ar: 'اختر السورة (١١٤ سورة - توزيع المركز)',
                        he: 'בחר סורה (114 סורות)',
                        en: 'Select Surah (114 Surahs - Center Map)',
                      ),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (val) => setPickerState(() => searchFilter = val),
                      decoration: InputDecoration(
                        hintText: trByLang(
                          langCode,
                          ar: 'ابحث باسم السورة أو رقمها...',
                          he: 'חפש לפי שם סורה או מספר...',
                          en: 'Search Surah by name or number...',
                        ),
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final isCurrent = s.id == currentSurahId;
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              selected: isCurrent,
                              leading: CircleAvatar(
                                backgroundColor:
                                    isCurrent ? TasmeeModalTokens.primary : TasmeeModalTokens.surfaceContainerLow,
                                foregroundColor: isCurrent ? Colors.white : TasmeeModalTokens.primary,
                                child: Text(
                                  formatTasmeeNum(s.id, langCode),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                'سورة ${s.localizedName(langCode)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                s.isJuz30
                                    ? trByLang(
                                        langCode,
                                        ar: 'الجزء ٣٠ • تحسب كصفحة واحدة في المركز (ص ${s.startPage})',
                                        he: 'ג׳וז 30 • נחשבת כיחידת עמוד אחת במרכז',
                                        en: 'Juz 30 • Counted as 1 Center Page (p. ${s.startPage})',
                                      )
                                    : trByLang(
                                        langCode,
                                        ar: 'الجزء ${formatTasmeeNum(s.primaryJuz, langCode)} • الصفحات ${formatTasmeeNum(s.startPage, langCode)}-${formatTasmeeNum(s.endPage, langCode)} (${formatTasmeeNum(s.centerPageCount, langCode)} صفحات)',
                                        he: 'ג׳וז ${s.primaryJuz} • עמודים ${s.startPage}-${s.endPage} (${s.centerPageCount} עמ׳)',
                                        en: 'Juz ${s.primaryJuz} • Pages ${s.startPage}-${s.endPage} (${s.centerPageCount} pages)',
                                      ),
                              ),
                              trailing: isCurrent
                                  ? const Icon(Icons.check_circle_rounded, color: TasmeeModalTokens.primary)
                                  : null,
                              onTap: () => Navigator.of(sheetCtx).pop(s.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
