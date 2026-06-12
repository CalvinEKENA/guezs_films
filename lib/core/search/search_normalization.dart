const int minimumSearchLength = 2;

String normalizeSearchText(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) return '';

  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(_foldedCharacters[character] ?? character);
  }

  return buffer
      .toString()
      .replaceAll(RegExp(r"[^a-z0-9]+"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

List<String> buildSearchQueryTokens(String query) {
  final raw = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final folded = normalizeSearchText(query);
  if (folded.length < minimumSearchLength) return const [];

  final tokens = <String>{};
  final values = <String>{raw, folded};
  if (folded.contains('epouse') || folded.contains('femme')) {
    values.addAll(const [
      'la femme du mbenguiste',
      'femme',
      'l epouse du mbenguiste',
      'epouse',
    ]);
  }
  if (folded.contains('elle') &&
      (folded.contains('moi') || folded.contains('moa'))) {
    values.addAll(const ['elle et moi', 'elle et moa', 'moi', 'moa']);
  }

  for (final value in values) {
    if (value.length >= minimumSearchLength) tokens.add(value);
    for (final word in value.split(' ')) {
      if (word.length >= minimumSearchLength) tokens.add(word);
    }
  }

  return tokens.take(20).toList(growable: false);
}

bool matchesSearchQuery(String query, Iterable<String> searchableValues) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.length < minimumSearchLength) return false;

  final terms = normalizedQuery
      .split(' ')
      .where((term) => term.length >= minimumSearchLength)
      .toList(growable: false);
  final haystack = normalizeSearchText(searchableValues.join(' '));
  return terms.every(haystack.contains);
}

const Map<String, String> _foldedCharacters = {
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'æ': 'ae',
  'ç': 'c',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ñ': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'œ': 'oe',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ý': 'y',
  'ÿ': 'y',
};
