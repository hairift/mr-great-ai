// Shared TTS utility for cleaning text before speech synthesis.
// Used by all chat pages to ensure TTS only reads clean, natural text.

/// Thoroughly cleans text for Text-to-Speech output.
///
/// Strips ALL markdown formatting, emojis, LaTeX math, code blocks,
/// URLs, special symbols, and other non-speech characters.
/// Returns clean, natural Indonesian text ready for TTS.
String cleanTextForTTS(String text) {
  if (text.isEmpty) return '';
  String t = text;

  // 1. Remove code blocks (``` ... ```) → replace with "kode program"
  t = t.replaceAll(RegExp(r'```[\s\S]*?```'), ' kode program. ');

  // 2. Remove inline code (`...`)
  t = t.replaceAll(RegExp(r'`[^`]*`'), '');

  // 3. Remove LaTeX math ($$...$$ and $...$)
  t = t.replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), ' rumus matematika. ');
  t = t.replaceAll(RegExp(r'\$[^\$]+\$'), ' rumus ');

  // 4. Remove markdown heading markers (# ## ### etc.)
  t = t.replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '');

  // 5. Remove bold/italic/strikethrough markers (keep the text inside)
  t = t.replaceAll(RegExp(r'\*\*\*(.*?)\*\*\*'), r'$1');  // ***bold italic***
  t = t.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');       // **bold**
  t = t.replaceAll(RegExp(r'(?<!\w)\*(?!\s)(.*?)\*'), r'$1'); // *italic*
  t = t.replaceAll(RegExp(r'__(.*?)__'), r'$1');            // __underline__
  t = t.replaceAll(RegExp(r'_([^_]+)_'), r'$1');            // _italic_
  t = t.replaceAll(RegExp(r'~~(.*?)~~'), r'$1');            // ~~strikethrough~~

  // 6. Remove blockquote markers
  t = t.replaceAll(RegExp(r'^\s*>\s*', multiLine: true), '');

  // 7. Remove bullet point markers (-, *, +)
  t = t.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');

  // 8. Remove numbered list markers (1. or 1))
  t = t.replaceAll(RegExp(r'^\s*\d+[.)]\s+', multiLine: true), '');

  // 9. Remove URLs
  t = t.replaceAll(RegExp(r'https?://\S+'), '');

  // 10. Remove markdown links [text](url) → keep text
  t = t.replaceAll(RegExp(r'\[([^\]]*)\]\([^\)]*\)'), r'$1');

  // 11. Remove markdown images ![alt](url)
  t = t.replaceAll(RegExp(r'!\[[^\]]*\]\([^\)]*\)'), '');

  // 12. Remove horizontal rules (---, ***, ___)
  t = t.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');

  // 13. Remove ALL emojis and special unicode symbols
  t = t.replaceAll(RegExp(
    r'[\u{1F600}-\u{1F64F}]|'  // Emoticons
    r'[\u{1F300}-\u{1F5FF}]|'  // Misc Symbols and Pictographs
    r'[\u{1F680}-\u{1F6FF}]|'  // Transport and Map
    r'[\u{1F1E0}-\u{1F1FF}]|'  // Flags
    r'[\u{2600}-\u{26FF}]|'    // Misc symbols
    r'[\u{2700}-\u{27BF}]|'    // Dingbats
    r'[\u{FE00}-\u{FE0F}]|'    // Variation Selectors
    r'[\u{1F900}-\u{1F9FF}]|'  // Supplemental Symbols
    r'[\u{1FA00}-\u{1FA6F}]|'  // Chess Symbols
    r'[\u{1FA70}-\u{1FAFF}]|'  // Symbols Extended-A
    r'[\u{200D}]|'              // Zero Width Joiner
    r'[\u{20E3}]|'              // Combining Enclosing Keycap
    r'[\u{FE0F}]|'              // Variation Selector-16
    r'[\u{E0020}-\u{E007F}]',   // Tags
    unicode: true,
  ), '');

  // 14. Remove remaining special symbols
  t = t.replaceAll(RegExp(r'[⚠️❌✅📌📚📍💰📝🎯📘🟣💡👋😊😅🎉📊✨🏫🏢📞🔍❓💻🎨📈🤸👨‍🏫⛔🚀🌐🔑⏱️🐛]'), '');

  // 15. Remove stray asterisks, underscores, tildes, backticks, dollar signs
  t = t.replaceAll(RegExp(r'[*_~`\$\\]'), '');

  // 16. Remove HTML tags
  t = t.replaceAll(RegExp(r'<[^>]*>'), '');

  // 17. Clean up punctuation: multiple dots, dashes
  t = t.replaceAll(RegExp(r'\.{2,}'), '.');
  t = t.replaceAll(RegExp(r'-{2,}'), ' ');

  // 18. Clean up whitespace
  t = t.replaceAll(RegExp(r'\n{2,}'), '. ');
  t = t.replaceAll(RegExp(r'\n'), '. ');
  t = t.replaceAll(RegExp(r'\s{2,}'), ' ');

  // 19. Clean up multiple periods
  t = t.replaceAll(RegExp(r'\.\s*\.'), '.');
  t = t.replaceAll(RegExp(r',\s*,'), ',');

  return t.trim();
}
