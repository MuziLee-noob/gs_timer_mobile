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

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    padding: const EdgeInsets.all(4),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                  },
                  child: const Text('开始'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                    padding: const EdgeInsets.all(4),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                  },
                  child: const Text('停止'),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    padding: const EdgeInsets.all(4),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                  },
                  child: const Text('重置'),
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
                _stopWatchTimer.onExecute.add(StopWatchExecute.lap);
              },
              child: const Text('计次'),
            ),
            Container(
              height: 120,
              margin: const EdgeInsets.all(8),
              child: StreamBuilder<List<StopWatchRecord>>(
                stream: _stopWatchTimer.records,
                initialData: _stopWatchTimer.records.value,
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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${index + 1} - ${data.displayTime}',
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
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
            )
          ],
        ),
      ),
    );
  }
}
