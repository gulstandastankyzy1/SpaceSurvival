import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_survival/main.dart';
import 'package:space_survival/models/game_settings.dart';
import 'package:space_survival/services/storage_service.dart';

void main() {
  testWidgets('Space Survival opens on the intro screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    final settings = GameSettings();
    await settings.load();

    await tester.pumpWidget(SpaceSurvivalApp(settings: settings));
    await tester.pump();

    expect(find.text('SPACE SURVIVAL'), findsOneWidget);
    expect(find.text('Tap to Start'), findsOneWidget);
  });
}
