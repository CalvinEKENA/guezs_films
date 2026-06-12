const String mbenguisteDisplayTitle = "L'EPOUSE DU MBENGUISTE";
const String elleEtMoaDisplayTitle = 'ELLE ET MOA';

String canonicalContentTitle(String value) {
  final normalized = _normalizeContentIdentity(value);

  if (normalized == 'la femme du mbenguiste' ||
      normalized == 'femme du mbenguiste' ||
      normalized == 'l epouse du mbenguiste' ||
      normalized == 'epouse du mbenguiste') {
    return mbenguisteDisplayTitle;
  }

  if (normalized == 'elle et moi' || normalized == 'elle et moa') {
    return elleEtMoaDisplayTitle;
  }

  return value.trim();
}

String canonicalContentCopy(String value) {
  return value
      .replaceAll(
        RegExp(r'la femme du mbenguiste', caseSensitive: false),
        mbenguisteDisplayTitle,
      )
      .replaceAll(
        RegExp(r'elle et moi', caseSensitive: false),
        elleEtMoaDisplayTitle,
      );
}

bool isMbenguisteContent({required String id, required String title}) {
  final normalizedId = _normalizeContentIdentity(id);
  final normalizedTitle = _normalizeContentIdentity(title);
  return normalizedId.contains('femme mbenguiste') ||
      normalizedId.contains('epouse mbenguiste') ||
      normalizedTitle.contains('femme du mbenguiste') ||
      normalizedTitle.contains('epouse du mbenguiste');
}

bool isElleEtMoaContent({required String id, required String title}) {
  final normalizedId = _normalizeContentIdentity(id);
  final normalizedTitle = _normalizeContentIdentity(title);
  return normalizedId.contains('elle et moi') ||
      normalizedId.contains('elle et moa') ||
      normalizedTitle.contains('elle et moi') ||
      normalizedTitle.contains('elle et moa');
}

int contentEditorialPriority({required String id, required String title}) {
  if (isMbenguisteContent(id: id, title: title)) return 0;
  if (isElleEtMoaContent(id: id, title: title)) return 1;
  return 2;
}

String _normalizeContentIdentity(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r"['’]"), ' ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
