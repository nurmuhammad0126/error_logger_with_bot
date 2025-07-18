# Error Logger With Bot

[![pub package](https://img.shields.io/pub/v/error_logger_with_bot.svg)](https://pub.dev/packages/error_logger_with_bot)
[![popularity](https://img.shields.io/pub/popularity/error_logger_with_bot?logo=dart)](https://pub.dev/packages/error_logger_with_bot/score)
[![likes](https://img.shields.io/pub/likes/error_logger_with_bot?logo=dart)](https://pub.dev/packages/error_logger_with_bot/score)
[![pub points](https://img.shields.io/pub/points/error_logger_with_bot?logo=dart)](https://pub.dev/packages/error_logger_with_bot/score)

A powerful Flutter package for sending error logs and custom messages to Telegram bot with automatic device info collection and detailed error reporting! 🚀

## ✨ Features

- **Easy Setup**: Get started with just 3 lines of code
- **Detailed Error Reports**: Automatic device info, app version, request/response details
- **Automatic Fallback**: Falls back to plain text if HTML format fails
- **Custom Templates**: Create your own error message templates
- **Telegram Groups Support**: Send to private chats or groups
- **Multiple Formats**: HTML, MarkdownV2, and plain text support
- **Stack Trace Formatting**: Shows only relevant stack trace parts
- **Pre-built Templates**: Ready-to-use templates for success, warning, and error messages

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  error_logger_with_bot: ^1.0.0
```

Then run:
```bash
flutter pub get
```

## 📱 Telegram Bot Setup

### 1. Create a Bot
1. Open Telegram and search for `@BotFather`
2. Send `/newbot` command
3. Enter bot name and username
4. Save the bot token (e.g., `123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw`)

### 2. Get Chat ID

#### For Private Chat:
1. Search for `@userinfobot` in Telegram
2. Send `/start` to the bot
3. Copy your Chat ID (e.g., `123456789`)

#### For Group Chat:
1. Add your bot to the group
2. Give the bot admin permissions (to send messages)
3. Send any message to the group
4. Visit this URL in your browser:
   ```
   https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
   ```
   Replace `<BOT_TOKEN>` with your actual bot token
5. Find the group chat ID in the response (e.g., `-1001234567890`)

**Note:** Group chat IDs always start with a minus (-) sign!

## 🔧 Usage

### 1. Initialize the Package

```dart
import 'package:error_logger_with_bot/error_logger_with_bot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ErrorLoggerWithBot
  TelegramLogger.init(
    botToken: '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw',
    chatId: '123456789', // or for groups: '-1001234567890'
    appName: 'My Awesome App',
    logSuccessText: '✅ Log sent successfully',
    logFailText: '❌ Failed to send log:',
  );
  
  runApp(MyApp());
}
```

### 2. Send Error Reports

```dart
import 'package:dio/dio.dart';
import 'package:error_logger_with_bot/error_logger_with_bot.dart';

class ApiService {
  final Dio _dio = Dio();
  
  Future<void> fetchData() async {
    try {
      final response = await _dio.get('https://api.example.com/data');
      // Handle API response...
    } on DioException catch (e, stackTrace) {
      // Send error to Telegram
      await TelegramLogger.sendError(
        error: e,
        stackTrace: stackTrace,
        context: context, // optional
      );
      
      // Rethrow or handle the error
      rethrow;
    }
  }
}
```

### 3. Custom Error Templates

```dart
await TelegramLogger.sendError(
  error: dioError,
  stackTrace: stackTrace,
  context: context,
  customTemplate: (error, time, appName) {
    return '''
🔥 Critical Error in $appName!

⏰ Time: ${time.toString()}
❌ Error: $error

Please check immediately! 🚨
''';
  },
);
```

### 4. Send Other Message Types

```dart
// Success message
final successMessage = TelegramMessageFormatter.createSuccessTemplate(
  title: 'Operation Successful',
  message: 'User registration completed',
  data: {'user_id': 123, 'email': 'user@example.com'},
);

await TelegramMessageFormatter.sendHtmlMessage(
  botToken: 'YOUR_BOT_TOKEN',
  chatId: 'YOUR_CHAT_ID',
  dio: Dio(),
  text: successMessage,
  logSuccessText: 'Success log sent',
  logFailText: 'Failed to send success log',
);

// Warning message
final warningMessage = TelegramMessageFormatter.createWarningTemplate(
  title: 'System Warning',
  message: 'System resources running low',
  details: 'RAM: 95%, Disk: 88%',
);

await TelegramMessageFormatter.sendHtmlMessage(
  botToken: 'YOUR_BOT_TOKEN',
  chatId: 'YOUR_CHAT_ID',
  dio: Dio(),
  text: warningMessage,
  logSuccessText: 'Warning sent',
  logFailText: 'Failed to send warning',
);

// Custom message with different formats
await TelegramMessageFormatter.sendCustomMessage(
  botToken: 'YOUR_BOT_TOKEN',
  chatId: 'YOUR_CHAT_ID',
  dio: Dio(),
  message: 'Hello! This is a custom message.',
  format: MessageFormat.html,
  logSuccessText: 'Custom message sent',
  logFailText: 'Failed to send custom message',
);
```

## 📋 Package Structure

```
error_logger_with_bot/
├── lib/
│   ├── error_logger_with_bot.dart          # Main export file
│   └── src/
│       ├── device_info.dart                # Device info collection
│       ├── telegram_logger.dart            # Main logger class
│       └── telegram_message_formatter.dart # Message formatting utilities
├── example/
│   ├── lib/
│   │   └── main.dart                       # Example application
│   └── pubspec.yaml
├── test/
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

## 🔧 API Reference

### TelegramLogger.init()
Initialize the package with your bot configuration:

```dart
TelegramLogger.init({
  required String botToken,    // Your Telegram bot token
  required String chatId,      // Chat ID (private or group)
  required String appName,     // Your application name
  String? logSuccessText,      // Custom success log message
  String? logFailText,         // Custom error log message
});
```

### TelegramLogger.sendError()
Send detailed error reports:

```dart
await TelegramLogger.sendError({
  required DioException error,                    // The Dio exception
  required StackTrace stackTrace,                 // Stack trace
  required BuildContext? context,                 // Widget context
  bool includeScreenshot = false,                 // Screenshot (future feature)
  String Function(String, DateTime, String)? customTemplate,  // Custom template function
});
```

### TelegramMessageFormatter Methods

#### Pre-built Templates:
- `createErrorTemplate()` - Error message template
- `createSuccessTemplate()` - Success message template  
- `createWarningTemplate()` - Warning message template

#### Message Sending:
- `sendHtmlMessage()` - Send HTML formatted message
- `sendPlainText()` - Send plain text message
- `sendCustomMessage()` - Send message with custom format

#### Utility Methods:
- `escapeHtml()` - Escape HTML special characters
- `escapeMarkdownV2()` - Escape MarkdownV2 special characters
- `formatStackTrace()` - Format stack trace for readability

## 📱 Example Application

Check out the [example](example/) directory for a complete working application that demonstrates:

- Basic error logging
- Custom error templates
- Success and warning messages
- Different message formats
- Group chat integration

## 🎯 Use Cases

- **API Error Monitoring**: Automatically log API failures with request/response details
- **Crash Reporting**: Send detailed crash reports with device information
- **User Activity Logging**: Log important user actions and system events
- **Development Debugging**: Get real-time error notifications during development
- **Production Monitoring**: Monitor your app's health in production

## 🔒 Privacy & Security

- **No Data Storage**: This package doesn't store any data locally or remotely
- **Direct Communication**: Messages are sent directly to Telegram's servers
- **Configurable**: You control what information is included in error reports
- **Open Source**: Full source code is available for review

## 📝 Error Report Contents

The default error template includes:

- **Timestamp**: Date and time of the error
- **Device Information**: Device model, OS version
- **App Information**: App version and build number
- **Network Details**: URL, HTTP method, status code
- **Error Information**: Error type and message
- **Request Data**: Headers, query parameters, request body
- **Response Data**: Response status and body
- **Stack Trace**: Formatted and filtered stack trace

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Support

If you find this package helpful, please give it a ⭐ on [GitHub](https://github.com/yourusername/error_logger_with_bot) and a 👍 on [pub.dev](https://pub.dev/packages/error_logger_with_bot)!

For issues and feature requests, please use the [GitHub Issues](https://github.com/yourusername/error_logger_with_bot/issues) page.