// Shared TTS utility — cleans AI response for Text-to-Speech.
// Reads the FULL response clearly without any formatting artifacts.

/// Cleans AI response text for TTS.
/// Removes markdown formatting, emojis, and symbols.
/// Keeps ALL readable text including names, titles, descriptions.
String cleanTextForTTS(String text) {
  if (text.isEmpty) return '';
  String t = text;

  // ===== STEP 1: Remove code blocks =====
  // Replace code blocks with spoken text
  final codeBlockPattern = RegExp(r'```[\s\S]*?```');
  t = t.replaceAll(codeBlockPattern, ' kode program ');

  // ===== STEP 2: Remove LaTeX/math =====
  t = t.replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), ' rumus matematika ');
  t = t.replaceAll(RegExp(r'\$[^\$\n]+\$'), ' rumus ');

  // ===== STEP 3: Strip markdown — simple removal, NO regex backreferences =====

  // Remove heading markers: "## Title" → "Title"
  t = t.replaceAll(RegExp(r'^\s*#{1,6}\s+', multiLine: true), '');

  // Remove bold markers: "**text**" → "text" (just remove the **)
  t = t.replaceAll('***', '');
  t = t.replaceAll('**', '');

  // Remove strikethrough markers: "~~text~~" → "text"
  t = t.replaceAll('~~', '');

  // Remove underline markers: "__text__" → "text"
  // Only double underscores (keep single underscore in names like S.Kom)
  t = t.replaceAll('__', '');

  // Remove inline code backticks
  t = t.replaceAll('`', '');

  // Remove blockquote markers
  t = t.replaceAll(RegExp(r'^\s*>\s?', multiLine: true), '');

  // Remove bullet point markers (only at line start)
  t = t.replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '');
  t = t.replaceAll(RegExp(r'^\s*\+\s+', multiLine: true), '');

  // Remove numbered list markers (only at line start)
  t = t.replaceAll(RegExp(r'^\s*\d+[.)]\s+', multiLine: true), '');

  // Remove italic asterisks (single * at word boundaries)
  // Process character by character to avoid backreference issues
  t = _removeItalicAsterisks(t);

  // Remove markdown links: [text](url) → text
  t = _removeMarkdownLinks(t);

  // Remove markdown images
  t = t.replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]*\)'), '');

  // Remove URLs
  t = t.replaceAll(RegExp(r'https?://\S+'), '');

  // Remove horizontal rules
  t = t.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');

  // Remove HTML tags
  t = t.replaceAll(RegExp(r'<[^>]*>'), '');

  // ===== STEP 4: Remove emojis =====
  t = _removeEmojis(t);

  // ===== STEP 5: Clean remaining symbols =====
  // Remove stray asterisks (not in words)
  t = t.replaceAll(RegExp(r'\s\*\s'), ' ');
  t = t.replaceAll(RegExp(r'^\*\s', multiLine: true), '');

  // Remove dollar signs
  t = t.replaceAll('\$', '');

  // Remove stray backslashes
  t = t.replaceAll(r'\', '');

  // Remove multiple dashes
  t = t.replaceAll(RegExp(r'-{2,}'), ' ');

  // ===== STEP 6: Natural speech pauses =====
  // Double newline → period (paragraph break)
  t = t.replaceAll(RegExp(r'\n\s*\n'), '. ');
  // Single newline → comma (brief pause)
  t = t.replaceAll(RegExp(r'\n'), ', ');

  // ===== STEP 7: Clean whitespace & punctuation =====
  t = t.replaceAll(RegExp(r'\s{2,}'), ' ');
  t = t.replaceAll(RegExp(r'\.(\s*\.)+'), '.');
  t = t.replaceAll(RegExp(r',(\s*,)+'), ',');
  t = t.replaceAll(RegExp(r'[.,]\s*[.,]'), '.');
  t = t.replaceAll(RegExp(r'^\s*[.,]\s*'), '');

  return t.trim();
}

/// Remove italic asterisks without using regex backreferences.
/// Converts "*text*" → "text" by removing lone asterisks.
String _removeItalicAsterisks(String text) {
  // After ** and *** are already removed, remaining single * are italic markers
  // Just remove them — they don't carry meaning for speech
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    if (text[i] == '*') {
      // Skip lone asterisks (italic markers)
      continue;
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}

/// Remove markdown links [text](url) → text, without regex backreferences.
String _removeMarkdownLinks(String text) {
  final linkPattern = RegExp(r'\[([^\]]*)\]\([^\)]*\)');
  String result = text;
  // Keep replacing until no more links found
  while (linkPattern.hasMatch(result)) {
    final match = linkPattern.firstMatch(result)!;
    final linkText = match.group(1) ?? '';
    result = result.replaceFirst(linkPattern, linkText);
  }
  return result;
}

/// Remove all emojis from text.
String _removeEmojis(String text) {
  // Remove by Unicode ranges
  String t = text;
  t = t.replaceAll(RegExp(
    r'[\u{1F600}-\u{1F64F}]|'
    r'[\u{1F300}-\u{1F5FF}]|'
    r'[\u{1F680}-\u{1F6FF}]|'
    r'[\u{1F1E0}-\u{1F1FF}]|'
    r'[\u{2600}-\u{26FF}]|'
    r'[\u{2700}-\u{27BF}]|'
    r'[\u{FE00}-\u{FE0F}]|'
    r'[\u{1F900}-\u{1F9FF}]|'
    r'[\u{1FA00}-\u{1FA6F}]|'
    r'[\u{1FA70}-\u{1FAFF}]|'
    r'[\u{200D}]|'
    r'[\u{20E3}]|'
    r'[\u{E0020}-\u{E007F}]',
    unicode: true,
  ), '');

  // Also remove common emojis as literal characters (fallback)
  const emojis = '📌📚📍💰📝🎯📘🟣💡👋😊😅🎉📊✨🏫🏢📞🔍❓💻🎨📈🤸⚠️❌✅⛔🚀🌐🔑⏱️🐛👨‍🏫';
  for (final emoji in emojis.runes) {
    t = t.replaceAll(String.fromCharCode(emoji), '');
  }

  return t;
}
