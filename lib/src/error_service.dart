part of '../error_bot_service.dart';

class ErrorService with ErrorMessageFormatter {
  static late final String _botToken;
  static late final String _chatId;
  static late final String _appName;
  static late final Dio _dio;

  static String _logSuccessText = '✅ Text sent success';
  static String _logFailText = '❌ Text send failed:';

  static void init({
    required String botToken,
    required String chatId,
    required String appName,
    String? logSuccessText,
    String? logFailText,
  }) {
    _dio = Dio();
    _botToken = botToken;
    _chatId = chatId;
    _appName = appName;
    _logSuccessText = logSuccessText ?? _logSuccessText;
    _logFailText = logFailText ?? _logFailText;
  }

  static Future<void> sendError({
    required DioException error,
    required StackTrace stackTrace,
    bool includeScreenshot = false,
    String Function(String error, DateTime time, String appName)?
        customTemplate,
  }) async {
    final now = DateTime.now();
    final info = await AppDeviceInfo.getInfo();
    log("Info success");

    final message = customTemplate != null
        ? customTemplate(error.message ?? 'Unknown', now, _appName)
        : ErrorMessageFormatter.buildDefaultTemplate(
            info,
            error,
            stackTrace,
          );

    log(message);

    try {
      await ErrorMessageFormatter.sendHtmlMessage(
        botToken: _botToken,
        chatId: _chatId,
        dio: _dio,
        text: message,
        logSuccessText: _logSuccessText,
        logFailText: _logFailText,
      );
    } catch (e) {
      log("$_logFailText $e");
      try {
        await ErrorMessageFormatter.sendPlainText(
          botToken: _botToken,
          chatId: _chatId,
          dio: _dio,
          text: message,
          logSuccessText: _logSuccessText,
          logFailText: _logFailText,
        );
      } catch (e2) {
        log("$_logFailText (fallback) $e2");
      }
    }
  }
}

enum MessageFormat { html, markdownV2, plain }
