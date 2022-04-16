import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view_app/data/repository/auth/auth.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';
import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/providers/media/media.dart';
import 'package:story_view_app/providers/story/story.dart';
import 'package:story_view_app/services/navigation.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerLazySingleton(() => NavigationService());

  getIt.registerLazySingleton(() => AuthRepo());
  getIt.registerLazySingleton(() => MediaRepo());
  getIt.registerLazySingleton(() => StoryRepo(
    ar: getIt(),
    ap: getIt()
  ));

  getIt.registerFactory(() => MediaProvider(
    mr: getIt()
  ));

  getIt.registerFactory(() => StoryProvider(
    sr: getIt(),
    mr: getIt(),
    ns: getIt()
  ));
  
  getIt.registerFactory(() => AuthProvider(
    ar: getIt(),
    mr: getIt(), 
    sp: getIt(),
    ns: getIt()
  ));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
}