import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  const Environment._();

  static Future<void> load() async {
    const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

    String envFile;
    switch (env) {
      case 'stag':
        envFile = 'env/.env.stag';
        break;
      case 'prod':
        envFile = 'env/.env.prod';
        break;
      default:
        envFile = 'env/.env.dev';
        break;
    }

    await dotenv.load(fileName: envFile);
  }
}
