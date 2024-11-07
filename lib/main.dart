import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool? myBool;
  final SharedPreferencesAsync sharedPreferences = SharedPreferencesAsync();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Das bool ist: $myBool'),
                OutlinedButton(
                  onPressed: setBoolean,
                  child: const Text('Boolean setzen'),
                ),
                OutlinedButton(
                  onPressed: readBoolean,
                  child: const Text('Boolean auslesen'),
                ),
                OutlinedButton(
                  onPressed: deleteBoolean,
                  child: const Text('Boolean löschen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setBoolean() async {
    await sharedPreferences.setBool('boolean', true);

    setState(() {});
  }

  void readBoolean() async {
    myBool = await sharedPreferences.getBool('boolean');
    setState(() {});
  }

  void deleteBoolean() async {
    await sharedPreferences.remove('boolean');
    setState(() {});
  }
}
