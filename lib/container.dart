import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_view_app/data/repository/media/media.dart';
import 'package:story_view_app/data/repository/story/story.dart';

import 'package:story_view_app/providers/media/media.dart';
import 'package:story_view_app/providers/story/story.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  getIt.registerLazySingleton(() => MediaRepo());
  getIt.registerLazySingleton(() => StoryRepo());

  getIt.registerFactory(() => MediaProvider(
    mr: getIt()
  ));

  getIt.registerFactory(() => StoryProvider(
    sr: getIt(),
    mr: getIt(),
  ));
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
}