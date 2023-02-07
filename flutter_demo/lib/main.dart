import 'package:flutter/material.dart';
import 'package:heart_rate_flutter/heart_rate_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:wear/wear.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: podometerScreen(),
    );
  }
}

class podometerScreen extends StatefulWidget {
  podometerScreen({Key? key}) : super(key: key);

  @override
  State<podometerScreen> createState() => _podometerScreenState();
}

class _podometerScreenState extends State<podometerScreen> {

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: WatchShape(
              builder: (BuildContext context, WearShape shape, Widget? child) {
                return AmbientMode(
                  builder: (BuildContext context, WearMode mode, Widget? child) {
                    return mode == WearMode.active
                        ? const MainScreen()
                        : const Ambient();
                  },
                );
              }),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final HeartRateFlutter _heartRateFlutterPlugin = HeartRateFlutter();
  var heartBeatValue = 0;
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _heartRateFlutterPlugin.init();
    _listener();
    setState(() {

    });
  }

  void onStepCount(StepCount event) {
    /// Handle step count changed
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    /// Handle status changed
    print(event);
    setState(() {
      _status = event.status;
    });
  }
  void _listener() {
    _heartRateFlutterPlugin.heartBeatStream.listen((double event) {
      if (mounted) {
        setState(() {
          heartBeatValue = event.toInt();
        });
      }
    });
  }

  void onPedestrianStatusError(error) {
    print("Error: $error");
    setState(() {
      _status = "No se puede acceder";
    });
    print(_status);
  }

  void onStepCountError(error) {
    print("Error: $error");
    setState(() {
      _steps = "Not aviable";
    });
    print(_steps); }

  void initPlatformState() {
    checkPermissions();
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void checkPermissions() async {
    var status = await Permission.activityRecognition.status;

    Map<Permission, PermissionStatus> statuses =
    await [Permission.activityRecognition].request();
    if (statuses[Permission.activityRecognition.isDenied] != null) {
      print("sensor access is Denied");
    } else {
      print("Permission Granted");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Divider(
              height: 20,
              thickness: 0,
              color: Colors.black,
            ),
            Text(
              'Steps taken:',
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
            Text(
              _steps,
              style: TextStyle(fontSize: 17, color: Colors.white),
            ),
            Divider(
              height: 20,
              thickness: 0,
              color: Colors.black,
            ),
            Text(
              'Pedestrian status:',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'
                  ? Icons.accessibility_new
                  : Icons.error, color: Colors.yellowAccent,
              size: 70,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 15)
                    : TextStyle(fontSize: 15, color: Colors.red),
              ),
            ),
            Text(
              'Heart Rate: $heartBeatValue',
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class Ambient extends StatefulWidget {
  const Ambient({Key? key}) : super(key: key);

  @override
  State<Ambient> createState() => _AmbientState();
}

class _AmbientState extends State<Ambient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'FlutterOS',
              style: TextStyle(color: Colors.blue[600], fontSize: 30),
            ),
            SizedBox(height: 15),
            const FlutterLogo(size: 60.0),
          ],
        ),
      ),
    );
  }
}