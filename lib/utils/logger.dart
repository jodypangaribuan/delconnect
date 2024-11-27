class AppLogger {
  static void log(String message, [Object? data]) {
    print('🟦 LOG: $message${data != null ? '\n     DATA: $data' : ''}');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('🟥 ERROR: $message');
    if (error != null) print('   DETAILS: $error');
    if (stackTrace != null) print('   STACK: $stackTrace');
  }
}
