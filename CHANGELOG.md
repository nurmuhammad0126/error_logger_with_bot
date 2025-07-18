# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-07-17

### ✨ Added
- **Initial Release** - Complete Flutter package for sending error logs to Telegram bot
- **Automatic Device Info Collection** - Automatically collects device model, OS version, app version, and timezone
- **Detailed Error Reporting** - Comprehensive error reports including request/response data, headers, and formatted stack traces
- **Multiple Message Formats** - Support for HTML, MarkdownV2, and plain text message formats
- **Automatic Fallback System** - Automatically falls back to plain text if HTML formatting fails
- **Custom Template Support** - Ability to create custom error message templates
- **Telegram Group Support** - Send messages to private chats or group chats
- **Pre-built Message Templates** - Ready-to-use templates for success, warning, and error messages
- **Comprehensive Documentation** - Complete setup guide including Telegram bot creation and chat ID retrieval

### 🛠️ Technical Features
- **Dio Integration** - Native support for DioException handling
- **Device Info Integration** - Uses device_info_plus and package_info_plus for comprehensive device information
- **Robust Error Handling** - Built-in error handling and logging for reliability
- **Smart Stack Trace Formatting** - Filters and formats stack traces to show only relevant information
- **HTML Escaping** - Automatic HTML character escaping for safe message transmission
- **Request/Response Logging** - Detailed logging of HTTP requests and responses

### 📚 Documentation
- **Complete README** - Comprehensive installation and usage guide
- **Telegram Bot Setup Guide** - Step-by-step instructions for creating bots and obtaining chat IDs
- **Working Examples** - Multiple usage examples for different scenarios
- **API Documentation** - Detailed documentation for all public methods and classes
- **Package Structure Guide** - Clear explanation of package organization

### 🚀 Supported Platforms
- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

### 📦 Dependencies
- `flutter: >=3.0.0`
- `dio: ^5.0.0`
- `device_info_plus: ^9.0.0`
- `package_info_plus: ^4.0.0`

### 🔧 Breaking Changes
- None (initial release)

### 🐛 Known Issues
- None reported

### 📈 Performance
- Lightweight implementation with minimal overhead
- Asynchronous operations for non-blocking error reporting
- Efficient memory usage with automatic cleanup