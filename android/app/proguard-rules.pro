# Untuk flutter_math_fork (parser LaTeX & font)
-keep class org.potassco.** { *; }

# Untuk flutter_highlight (syntax highlight)
-keep class com.github.** { *; }
-keep class com.github.flutterhighlight.** { *; }

# Library latex parser
-keep class io.github.kartik.** { *; }

# Hindari warning tidak penting
-dontwarn org.potassco.**
-dontwarn com.github.**
-dontwarn io.github.kartik.**
