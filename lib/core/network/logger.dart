import 'package:logger/logger.dart';

class LoggerUtil {
  static final _logger = Logger(
    printer: PrefixPrinter(
      HybridPrinter(
        PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ),
    ),
  );

  static Logger get logger => _logger;

  static e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      logger.e(
        message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
  static d(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      logger.d(
        message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
  static i(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      logger.i(
        message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
  static t(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      logger.t(
        message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
  static w(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      logger.w(
        message,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
}
