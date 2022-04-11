import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:story_view_app/providers/media/media.dart';
import 'package:story_view_app/providers/story/story.dart';

import 'container.dart' as c;

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => c.getIt<StoryProvider>()),
  ChangeNotifierProvider(create: (_) => c.getIt<MediaProvider>()),
  Provider.value(value: const <String, dynamic>{})
];