import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String coviTaskId = "com.covi.app";

class Scheduler {
  static final Scheduler _scheduler = Scheduler._internal();

  bool _backgroundFetchConfigured = false;

  factory Scheduler() {
    return _scheduler;
  }

  /// Get the delay for when the task should run
  Future<DateTime> getDelay() async {
    // Open the shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the random hour in the day, generate it if null
    int hourInDay = await prefs.getInt("hour_in_day");

    if (hourInDay == null) {
      hourInDay = Random().nextInt(24);

      prefs.setInt("hour_in_day", hourInDay);
    }

    Logger().d(hourInDay);

    // Generate the seconds
    int secondsInHour = Random().nextInt(3601);

    DateTime delayTime = new DateTime.now();

    // Reset the seconds and minutes
    delayTime = delayTime.subtract(Duration(
        hours: delayTime.hour,
        seconds: delayTime.second,
        minutes: delayTime.minute));

    delayTime =
        delayTime.add(Duration(seconds: secondsInHour, hours: hourInDay));

    if (DateTime.now().hour > hourInDay) {
      delayTime = delayTime.add(Duration(days: 1));
    }

    return delayTime;
  }

  /// Do push here and etc
  void backgroundTask() async {
    scheduleTask(await getDelay());
  }

  void configureBackgroundFetch() async {
    if (_backgroundFetchConfigured == false) {
      BackgroundFetch.configure(
          BackgroundFetchConfig(minimumFetchInterval: 15, startOnBoot: true),
          (String taskId) async {
        // Use a switch statement to route task-handling.
        switch (taskId) {
          case coviTaskId:
            backgroundTask();
            break;

          default:
            break;
        }
        // Finish, providing received taskId.
        BackgroundFetch.finish(taskId);
      });
    }

    scheduleTask(await getDelay());
  }

  /// Schedule a task at a specific time
  void scheduleTask(DateTime time) {
    // Get the time difference between now and the future timestamp
    Duration runAt = time.difference(DateTime.now());

    BackgroundFetch.scheduleTask(
        TaskConfig(taskId: coviTaskId, delay: runAt.inMilliseconds));
  }

  Scheduler._internal();
}
