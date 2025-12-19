import 'package:get_it/get_it.dart';
import '../services/memo_repository.dart';
import '../services/settings_repository.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/home_view_model.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton<MemoRepository>(() => MemoRepository());
  locator.registerLazySingleton<SettingsRepository>(() => SettingsRepository());

  // ViewModels
  locator.registerFactory<HomeViewModel>(() => HomeViewModel(locator<MemoRepository>()));
  locator.registerFactory<SettingsViewModel>(() => SettingsViewModel(locator<SettingsRepository>(), locator<MemoRepository>()));
}
