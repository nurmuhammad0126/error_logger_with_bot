part of '../error_bot_service.dart';

mixin ErrorMessageFormatter {
  static String escapeMarkdownV2(String text) {
    final pattern = RegExp(r'([_*\[\]()~`>#+=|{}.!\\-])');
    return text.replaceAllMapped(pattern, (match) => '\\${match[0]}');
  }

  static String escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  static String formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    final formattedLines = <String>[];

    for (int i = 0; i < lines.length && i < 10; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        if (line.contains('package:') || line.contains('.dart')) {
          formattedLines.add(line);
        }
      }
    }

    return formattedLines.join('\n');
  }

  static String buildDefaultTemplate(
    AppDeviceInfo info,
    DioException error,
    StackTrace trace,
  ) {
    final r = error.requestOptions;
    final now = info.now;
    final formattedStack = formatStackTrace(trace);
    final rawResponse = error.response?.data;
    final parsedResponse =
        extractBeaconJson(rawResponse?.toString()) ??
        rawResponse?.toString() ??
        'No response';

    return '''
<b> #ERORR </b>
<b>🚨 Error Report</b>

<b>📅 Date:</b> ${now.day}/${now.month}/${now.year} | <b>🕐 Time:</b> ${now.toIso8601String().split("T")[1].split(".")[0]} |  <b>🌍 Timezone:</b> ${info.timezone}


<b>📱 Device:</b> <code>${escapeHtml(info.device)}</code>
<b>🛠️ OS:</b> <code>${escapeHtml(info.os)}</code>
<b>📦 App Version:</b> <code>${escapeHtml(info.appVersion)}</code>

<b>🔗 URL:</b> <pre>${escapeHtml('${r.baseUrl}${r.path}')}</pre>
<b>📥 Method:</b> <code>${r.method}</code>
<b>❌ Error Type:</b> <code>${error.type}</code>

<b>🧾 Message:</b>
<pre>${escapeHtml(error.message ?? 'Unknown error')}</pre>

<b>📋 Request</b>
<b>Headers:</b> <code>${escapeHtml(r.headers.toString())}</code>
<b>Query:</b> <code>${escapeHtml(r.queryParameters.toString())}</code>
<b>Body:</b> <code>${r.data == null ? "No body" : escapeHtml(r.data.toString())}</code>

<b>📤 Response</b>
<b>Status Code:</b> <code>${error.response?.statusCode ?? 'N/A'}</code>
<b>Response:</b> <pre>${escapeHtml(parsedResponse)}</pre>

<b>🧵 Stack Trace</b>
<pre>${escapeHtml(formattedStack)}</pre>
''';
  }

  static Future<void> sendCustomMessage({
    required String botToken,
    required String chatId,
    required Dio dio,
    required String message,
    MessageFormat format = MessageFormat.html,
    bool enablePreview = false,
    required String logSuccessText,
    required String logFailText,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/sendMessage';

    try {
      String formattedMessage = message;
      String? parseMode = switch (format) {
        MessageFormat.html => 'HTML',
        MessageFormat.markdownV2 => escapeMarkdownV2(message),
        MessageFormat.plain => null,
      };

      final res = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'chat_id': chatId,
          'text': formattedMessage,
          if (parseMode != null) 'parse_mode': parseMode,
          'disable_web_page_preview': !enablePreview,
        },
      );

      log(res.statusCode == 200 ? logSuccessText : "$logFailText ${res.data}");
    } catch (e) {
      log("$logFailText $e");
    }
  }

  static Future<void> sendHtmlMessage({
    required String botToken,
    required String chatId,
    required Dio dio,
    required String text,
    required String logSuccessText,
    required String logFailText,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/sendMessage';

    try {
      final res = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'chat_id': chatId, 'text': text, 'parse_mode': 'HTML'},
      );

      log(res.statusCode == 200 ? logSuccessText : "$logFailText ${res.data}");
    } catch (e) {
      log("$logFailText $e");
      rethrow;
    }
  }

  static Future<void> sendPlainText({
    required String botToken,
    required String chatId,
    required Dio dio,
    required String text,
    required String logSuccessText,
    required String logFailText,
  }) async {
    final url = 'https://api.telegram.org/bot$botToken/sendMessage';

    try {
      final res = await dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'chat_id': chatId, 'text': text},
      );

      log(res.statusCode == 200 ? logSuccessText : "$logFailText ${res.data}");
    } catch (e) {
      log("$logFailText $e");
      rethrow;
    }
  }

  static String? extractBeaconJson(String? html) {
    if (html == null) return null;

    final regex = RegExp(r"data-cf-beacon='([^']+)'");
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  static String createErrorTemplate({
    required String title,
    required String message,
    String? url,
    int? statusCode,
    String? stackTrace,
  }) {
    return '''
<b>🚨 $title</b>

<b>📝 Message:</b>
<pre>${escapeHtml(message)}</pre>

${url != null ? '<b>🔗 URL:</b> <code>${escapeHtml(url)}</code>' : ''}
${statusCode != null ? '<b>📊 Status Code:</b> <code>$statusCode</code>' : ''}
${stackTrace != null ? '<b>🧵 Stack Trace:</b>\n<pre>${escapeHtml(stackTrace)}</pre>' : ''}

<i>📅 Time: ${DateTime.now().toIso8601String()}</i>
''';
  }

  static String createSuccessTemplate({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    return '''
<b>✅ $title</b>

<b>📝 Message:</b>
<pre>${escapeHtml(message)}</pre>

${data != null ? '<b>📊 Data:</b>\n<pre>${escapeHtml(data.toString())}</pre>' : ''}

<i>📅 Time: ${DateTime.now().toIso8601String()}</i>
''';
  }

  static String createWarningTemplate({
    required String title,
    required String message,
    String? details,
  }) {
    return '''
<b>⚠️ $title</b>

<b>📝 Message:</b>
<pre>${escapeHtml(message)}</pre>

${details != null ? '<b>📋 Details:</b>\n<pre>${escapeHtml(details)}</pre>' : ''}

<i>📅 Time: ${DateTime.now().toIso8601String()}</i>
''';
  }
}
