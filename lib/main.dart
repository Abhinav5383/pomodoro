import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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
      home: const AppRoot(),
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => AppRootState();
}

class AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        decoration: BoxDecoration(color: base.scaffoldBackgroundColor),

        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: PomodoroTimer(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum PomodoroState { focusPeriod, breakPeriod }

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => PomodoroTimerState();
}

class PomodoroTimerState extends State<PomodoroTimer> {
  PomodoroTimerState() {
    timeRemaining = getStateDuration(state);
  }

  final btnIconSize = 24.0;
  final btnPadding = 28.0;

  final focusDuration = Duration(minutes: 25);
  final breakDuration = Duration(minutes: 5);

  PomodoroState state = PomodoroState.focusPeriod;
  bool isRunning = false;
  Timer? _timerHandle;
  AudioPlayer? _audioPlayer;
  bool _isTransitioningState = false;

  int timeRemaining = 0;

  void start() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    _timerHandle = Timer.periodic(Duration(seconds: 1), (Timer _) async {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining -= 1;
        });
      } else {
        await _handlePeriodComplete();
      }
    });
  }

  Future<void> _handlePeriodComplete() async {
    if (_isTransitioningState || !mounted) return;
    _isTransitioningState = true;

    await playAlarm();
    pause();
    next();

    _isTransitioningState = false;
  }

  void pause() {
    setState(() {
      _timerHandle?.cancel();
      _timerHandle = null;
      isRunning = false;
    });
  }

  Future<void> playAlarm() async {
    await _audioPlayer?.dispose();

    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setSource(AssetSource("alarm.mp3"));
    await player.resume();

    setState(() {
      _audioPlayer = player;
    });
  }

  Future<void> stopAlarmAndContinue() async {
    await _audioPlayer?.dispose();
    setState(() {
      _audioPlayer = null;
    });

    start();
  }

  @override
  void dispose() {
    _timerHandle?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void reset() {
    pause();

    setState(() {
      state = PomodoroState.focusPeriod;
      timeRemaining = getStateDuration(state);
    });
  }

  void next() {
    setState(() {
      state = getNextState(state);
      timeRemaining = getStateDuration(state);
    });
  }

  void toggleTimer() {
    if (isRunning) {
      pause();
    } else {
      start();
    }
  }

  int getStateDuration(PomodoroState state) {
    if (state == PomodoroState.breakPeriod) {
      return breakDuration.inSeconds;
    } else {
      return focusDuration.inSeconds;
    }
  }

  PomodoroState getNextState(PomodoroState state) {
    if (state == PomodoroState.breakPeriod) {
      return PomodoroState.focusPeriod;
    } else {
      return PomodoroState.breakPeriod;
    }
  }

  String formatTime(int time) {
    final minutes = (time / 60).floor();
    final seconds = time % 60;

    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext ctx) {
    final base = Theme.of(ctx);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 32,

      children: [
        Container(
          decoration: BoxDecoration(
            color: base.cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            child: Text(
              formatTime(timeRemaining),
              style: TextStyle(
                color: base.colorScheme.primary,
                decoration: TextDecoration.none,
                fontSize: 84,
              ),
            ),
          ),
        ),

        _audioPlayer == null ? controlButtons(base) : alarmControls(base),

        Text(
          state == PomodoroState.focusPeriod ? "Focus Time" : "Break Time",
          style: base.textTheme.labelLarge?.copyWith(
            color: base.colorScheme.primary,
            fontSize: 22,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget controlButtons(ThemeData base) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,

      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: isRunning
                ? base.colorScheme.primary
                : base.colorScheme.primaryContainer,
            foregroundColor: isRunning
                ? base.colorScheme.onPrimary
                : base.colorScheme.onPrimaryContainer,
            padding: EdgeInsetsGeometry.symmetric(
              vertical: btnPadding,
              horizontal: btnPadding + 12,
            ),
          ),
          icon: Transform.translate(
            offset: Offset(isRunning ? 0 : btnIconSize / 12, 0),
            child: Icon(
              isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
              size: btnIconSize,
            ),
          ),
          onPressed: toggleTimer,
        ),

        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: base.colorScheme.secondaryContainer,
            foregroundColor: base.colorScheme.onSecondaryContainer,
            padding: EdgeInsetsGeometry.all(btnPadding),
          ),
          icon: Icon(
            CupertinoIcons.arrow_counterclockwise,
            size: btnIconSize,
            fontWeight: FontWeight.w900,
          ),
          onPressed: reset,
        ),

        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: base.colorScheme.secondaryContainer,
            foregroundColor: base.colorScheme.onSecondaryContainer,
            padding: EdgeInsetsGeometry.symmetric(
              vertical: btnPadding,
              horizontal: btnPadding - 8,
            ),
          ),
          icon: Icon(
            CupertinoIcons.forward_end_fill,
            size: btnIconSize,
            fontWeight: FontWeight.w100,
          ),
          onPressed: next,
        ),
      ],
    );
  }

  Widget alarmControls(ThemeData base) {
    return ElevatedButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: base.colorScheme.primaryContainer,
        foregroundColor: base.colorScheme.onPrimaryContainer,
        padding: EdgeInsetsGeometry.all(btnPadding),
      ),
      onPressed: stopAlarmAndContinue,
      icon: Icon(CupertinoIcons.stop_fill, size: btnIconSize),
      label: Text("Stop Alarm", style: TextStyle(fontSize: 20)),
    );
  }
}
