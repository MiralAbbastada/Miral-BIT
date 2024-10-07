import 'package:logger/logger.dart';


var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

void demo(String message, {level = Level.debug}) { // Use LogLevel here
  switch (level) {
    case Level.verbose:
      logger.v(message);
      break;
    case Level.debug:
      logger.d(message);
      break;
    case Level.info:
      logger.i(message);
      break;
    case Level.warning:
      logger.w(message);
      break;
    case Level.error:
      logger.e(message);
      break;
    case Level.wtf:
      logger.wtf(message);
      break;
    default:
      logger.d(message);
  }
}