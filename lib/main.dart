import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Pages/register_page.dart';
import 'Pages/login_page.dart';
import 'accessibility/accessibility_state.dart';
import 'accessibility/accessibility_fab.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://papfdzhkntnfphgraplk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBhcGZkemhrbnRuZnBoZ3JhcGxrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDM3MTI3OSwiZXhwIjoyMDc1OTQ3Mjc5fQ.A50xPmUkfcAkbl8MOT2n3nZMoobf51vJmT2sY2GYZFA',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AccessibilityState.textSize,
      builder: (context, textSize, _) {
        double scale = textSize == 2
            ? 1.15
            : textSize == 3
            ? 1.3
            : 1.0;

        return MaterialApp(
          title: 'My Hotel App',
          debugShowCheckedModeBanner: false,

          builder: (context, child) {
            return Stack(
              children: [
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
                  child: child!,
                ),
                const AccessibilityFAB(), // 🌍 Global accessibility popup
              ],
            );
          },

          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

          home: const LoginPage(),
        );
      },
    );
  }
}
