
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart'; // Этот файл сгенерируется автоматически!

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();