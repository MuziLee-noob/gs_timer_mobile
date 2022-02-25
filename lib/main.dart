import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GS 计时器',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'GS 计时器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final _isHours = true;
  final _scrollController = ScrollController();
  final timeList = <TimeRecord>[];
  bool emergency = false;

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var timeRecord = TimeRecord();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 50,
                margin: const EdgeInsets.all(8),
                child: StreamBuilder<bool>(
                  stream: Stream.periodic(const Duration(milliseconds: 500), (value) {
                    return emergency;
                  }),
                  initialData: emergency,
                  builder: (context, snapshot) {
                    final value = snapshot.data!;
                    if (value) {
                      return const Text(
                        "你快生了",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                      );
                    } else {
                      return const Text(
                        "还不是时候",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      );
                    }
                  },
                )
/*              child: Text(
                "状态：${(emergency ? "你快生了" : "还不是时候")}",
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
              ),*/
            ),
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
                  final value = snapshot.data;
                  final displayTime =
                      StopWatchTimer.getDisplayTime(value!, hours: _isHours);
                  return Text(displayTime,
                      style: const TextStyle(
                          fontSize: 40.0, fontWeight: FontWeight.bold));
                }),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /**
                 * 开始按钮
                 */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: const EdgeInsets.all(4),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    timeRecord = TimeRecord();
                    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                    timeRecord.startTime = DateTime.now();
                  },
                  child: const Text('开始'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                /**
                 * 停止按钮
                 */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    padding: const EdgeInsets.all(4),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                    timeRecord.endTime = DateTime.now();
                    timeRecord.interval = _stopWatchTimer.rawTime.value;
                    timeList.add(timeRecord);
                    // 停止stream
                  },
                  child: const Text('停止'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                padding: const EdgeInsets.all(4),
                shape: const BeveledRectangleBorder(),
              ),
              onPressed: () {
                _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                timeList.clear();
                setState(() {
                  emergency = false;
                });
              },
              child: const Text('清空'),
            ),
            const SizedBox(
              height: 20.0,
              child: Text(
                '开始时间    结束时间      持续    距上次时间',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ),
            Container(
              height: 200,
              margin: const EdgeInsets.all(8),
              child: StreamBuilder<List<TimeRecord>>(
                stream: Stream.periodic(const Duration(milliseconds: 500), (value) {
                  return timeList;
                }),
                initialData: timeList,
                builder: (context, snapshot) {
                  final value = snapshot.data;
                  if (value!.isEmpty) {
                    return Container();
                  }
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut);
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      final data = value[index];
                      Duration timeDiff = const Duration();
                      if (index >= 1) {
                        final lastData = value[index - 1];
                        timeDiff = data.startTime.difference(lastData.endTime);
                        if (timeDiff.inMinutes < 10) {
                          if (emergency == false) {
                            emergency = true;
                          }
                        }
                      }
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${data.formatStartTime()}       ${data.formatEndTime()}       ${(data.interval / 1000).ceil().toString().padLeft(2, '0')} Sec       ${timeDiff.inMinutes.toString().padLeft(2, '0')} Min',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(
                            height: 1.0,
                          )
                        ],
                      );
                    },
                    itemCount: value.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRecord {
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int interval = 0;

  @override
  String toString() {
    return startTime.toString() + '-' + interval.toString();
  }
  String formatStartTime() {
    return "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}:${startTime.second.toString().padLeft(2,'0')}";
  }
  String formatEndTime() {
    return "${endTime.hour.toString().padLeft(2,'0')}:${endTime.minute.toString().padLeft(2,'0')}:${endTime.second.toString().padLeft(2,'0')}";
  }
}
