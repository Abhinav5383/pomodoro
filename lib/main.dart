import 'package:flutter/material.dart';
import 'package:pomodoro/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: base.scaffoldBackgroundColor),
      child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 32,

        children: [
          Container(
            decoration: BoxDecoration(
              color: base.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: Text(
                "00:00",
                style: TextStyle(
                  color: base.colorScheme.primary,
                  decoration: TextDecoration.none,
                  fontSize: 48,
                ),
              ),
            ),
          ),

          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: base.buttonTheme.colorScheme!.primary,
              foregroundColor: base.buttonTheme.colorScheme!.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),

            onPressed: () {
              print("btn clicked");
            },
            child: Text("Start"),
          ),
        ],
      ),
    );
  }
}
