import 'package:error_logger_with_bot/error_bot_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ErrorLoggerWithBot
  ErrorService.init(
    botToken: 'YOUR_BOT_TOKEN_HERE', // Replace with your bot token
    chatId:
        'YOUR_CHAT_ID_HERE', // Replace with your chat ID (for groups: '-1001234567890')
    appName: 'Error Logger Demo',
    logSuccessText: '✅ Log sent successfully',
    logFailText: '❌ Failed to send log:',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Logger Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio _dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Logger Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test Error Logger With Bot',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildTestButton(
              'Test Network Error',
              'Test a real network error',
              Icons.wifi_off,
              Colors.red,
              _testNetworkError,
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test Custom Error Template',
              'Test custom error formatting',
              Icons.build,
              Colors.orange,
              _testCustomError,
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test Success Message',
              'Send a success notification',
              Icons.check_circle,
              Colors.green,
              _testSuccessMessage,
            ),
            const SizedBox(height: 16),
            _buildTestButton(
              'Test Warning Message',
              'Send a warning notification',
              Icons.warning,
              Colors.amber,
              _testWarningMessage,
            ),
            const SizedBox(height: 32),
            Text(
              'Make sure to replace YOUR_BOT_TOKEN_HERE and YOUR_CHAT_ID_HERE in main.dart with your actual values!',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Future<void> _testNetworkError() async {
    try {
      _showSnackBar('Sending test network request...', Colors.blue);

      // Make a request to a non-existent endpoint to generate an error
      await _dio.get('https://jsonplaceholder.typicode.com/posts/999999');
    } on DioException catch (e, stackTrace) {
      // Send error to Telegram
      await ErrorService.sendError(
        error: e,
        stackTrace: stackTrace,
      );

      _showSnackBar('Network error sent to Telegram!', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to send error: $e', Colors.red);
    }
  }

  Future<void> _testCustomError() async {
    try {
      // Simulate an application error
      throw Exception('This is a test application error!');
    } catch (e, stackTrace) {
      // Create a fake DioException for demonstration
      final fakeError = DioException(
        requestOptions: RequestOptions(path: '/test-endpoint'),
        message: e.toString(),
        type: DioExceptionType.unknown,
      );

      await ErrorService.sendError(
        error: fakeError,
        stackTrace: stackTrace,
        customTemplate: (error, time, appName) {
          return '''
🔥 Critical Error in $appName!

⏰ Timestamp: ${time.toIso8601String()}
🚨 Error Details: $error
📱 This was a custom template test!

Please investigate immediately! 🔍
''';
        },
      );

      _showSnackBar('Custom error template sent!', Colors.green);
    }
  }

  Future<void> _testSuccessMessage() async {
    try {
      final successMessage = ErrorMessageFormatter.createSuccessTemplate(
        title: 'Operation Completed Successfully',
        message: 'User registration process completed without errors',
        data: {
          'user_id': 12345,
          'email': 'test.user@example.com',
          'registration_time': DateTime.now().toIso8601String(),
          'ip_address': '192.168.1.100',
        },
      );

      await ErrorMessageFormatter.sendHtmlMessage(
        botToken: 'YOUR_BOT_TOKEN_HERE', // Replace with your actual token
        chatId: 'YOUR_CHAT_ID_HERE', // Replace with your actual chat ID
        dio: _dio,
        text: successMessage,
        logSuccessText: '✅ Success message sent to Telegram',
        logFailText: '❌ Failed to send success message',
      );

      _showSnackBar('Success message sent to Telegram!', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to send success message: $e', Colors.red);
    }
  }

  Future<void> _testWarningMessage() async {
    try {
      final warningMessage = ErrorMessageFormatter.createWarningTemplate(
        title: 'System Resource Warning',
        message: 'Application resources are running low',
        details: '''
Memory Usage: 85%
CPU Usage: 92%
Storage Available: 1.2 GB
Active Users: 1,247
Response Time: 2.8s (above threshold)
''',
      );

      await ErrorMessageFormatter.sendHtmlMessage(
        botToken: 'YOUR_BOT_TOKEN_HERE', // Replace with your actual token
        chatId: 'YOUR_CHAT_ID_HERE', // Replace with your actual chat ID
        dio: _dio,
        text: warningMessage,
        logSuccessText: '⚠️ Warning message sent to Telegram',
        logFailText: '❌ Failed to send warning message',
      );

      _showSnackBar('Warning message sent to Telegram!', Colors.green);
    } catch (e) {
      _showSnackBar('Failed to send warning message: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
