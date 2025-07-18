import 'package:error_logger_with_bot/error_bot_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorService.init(
    botToken: '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw',
    chatId: '123456789',
    appName: 'My Flutter App',
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
      ),
      home: const MyHomePage(),
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _testNetworkError(),
              child: const Text('Test Network Error'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testCustomError(),
              child: const Text('Test Custom Error'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testSuccessMessage(),
              child: const Text('Test Success Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _testWarningMessage(),
              child: const Text('Test Warning Message'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testNetworkError() async {
    try {
      // Xato URL bilan request yuborish
      await _dio.get('https://jsonplaceholder.typicode.com/posts/999999');
    } on DioException catch (e, stackTrace) {
      // Xatolikni Telegram'ga yuborish
      await ErrorService.sendError(
        error: e,
        stackTrace: stackTrace,
      );

      // Foydalanuvchiga xabar ko'rsatish
      _showSnackBar('Network error yuborildi!');
    }
  }

  Future<void> _testCustomError() async {
    try {
      throw Exception('Bu test xatolik!');
    } catch (e, stackTrace) {
      final fakeError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: e.toString(),
        type: DioExceptionType.unknown,
      );

      await ErrorService.sendError(
        error: fakeError,
        stackTrace: stackTrace,
        customTemplate: (error, time, appName) {
          return '''
🔥 $appName da custom xatolik!

⏰ Vaqt: ${time.toString()}
❌ Xatolik: $error

Bu test xatolik edi! 🚨
''';
        },
      );

      _showSnackBar('Custom error yuborildi!');
    }
  }

  Future<void> _testSuccessMessage() async {
    final successMessage = ErrorMessageFormatter.createSuccessTemplate(
      title: 'Muvaffaqiyatli amal',
      message: 'Foydalanuvchi ro\'yxatdan o\'tdi',
      data: {'user_id': 123, 'email': 'test@example.com'},
    );

    await ErrorMessageFormatter.sendHtmlMessage(
      botToken:
          '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw', // O'z token'ingizni qo'ying
      chatId: '123456789', // O'z chat ID'ingizni qo'ying
      dio: _dio,
      text: successMessage,
      logSuccessText: '✅ Success message yuborildi',
      logFailText: '❌ Success message yuborishda xatolik',
    );

    _showSnackBar('Success message yuborildi!');
  }

  Future<void> _testWarningMessage() async {
    final warningMessage = ErrorMessageFormatter.createWarningTemplate(
      title: 'Tizim ogohlantirishi',
      message: 'Tizim resurslari tugamoqda',
      details: 'RAM: 95%, Disk: 88%',
    );

    await ErrorMessageFormatter.sendHtmlMessage(
      botToken:
          '123456789:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw', // O'z token'ingizni qo'ying
      chatId: '123456789', // O'z chat ID'ingizni qo'ying
      dio: _dio,
      text: warningMessage,
      logSuccessText: '⚠️ Warning message yuborildi',
      logFailText: '❌ Warning message yuborishda xatolik',
    );

    _showSnackBar('Warning message yuborildi!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
