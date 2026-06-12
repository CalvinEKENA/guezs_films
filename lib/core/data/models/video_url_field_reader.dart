const List<String> videoUrlFieldCandidates = [
  'videoUrl',
  'videoURL',
  'video_url',
  'playbackUrl',
  'streamUrl',
  'sourceUrl',
  'url',
];

String readVideoUrl(Map<String, dynamic> data) {
  for (final field in videoUrlFieldCandidates) {
    final value = data[field];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}
