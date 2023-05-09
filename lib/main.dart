import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:statistics/statistics.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;
  List<String?> texts = [];
  List<Statistics> statistics = [];
  List<StatisticsData> c = [];
  List<StatisticsData> hn = [];
  List<StatisticsData> tn = [];
  List<StatisticsData> sh = [];
  List<StatisticsData> yom = [];
  List<StatisticsData> yor = [];
  final DateFormat formatterHour = DateFormat('yyyy.MM.dd HH:mm');
  final controller = ScrollController();


  @override
  void initState() {
    super.initState();
    getAllSms();
    initPlatformState();
  }

  test(String? text, String dateTime) {
    int startIndex = 0;
    String temp = "";
    List<double> qiymatlar = [];

    for (int i = 0; i < text!.length; i++) {
      if (text[i] == ',') {
        temp = text.substring(startIndex, i);
        startIndex = i + 1;
        qiymatlar.add(double.parse(temp));
      }
    }
    c.add(StatisticsData(dateTime, qiymatlar[0]));
    hn.add(StatisticsData(dateTime, qiymatlar[1]));
    tn.add(StatisticsData(dateTime, qiymatlar[2]));
    sh.add(StatisticsData(dateTime, qiymatlar[3]));
    yom.add(StatisticsData(dateTime, qiymatlar[4]));
    yor.add(StatisticsData(dateTime, qiymatlar[5]));
  }

  getAllSms() async {
    texts.clear();
    c.clear();
    hn.clear();
    tn.clear();
    sh.clear();
    yom.clear();
    yor.clear();
    List<SmsMessage> messages = await telephony.getInboxSms(
        filter: SmsFilter.where(SmsColumn.ADDRESS).equals("1212"),
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.ASC)]);
    messages.forEach((element) {
      var date = formatterHour
          .format(DateTime.fromMillisecondsSinceEpoch(element.date!));
      test(element.body, date);
      setState(() {
        texts.add(element.body);
      });
    });
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Wait for layout to be completed before scrolling to the end
      controller.jumpTo(controller.position.maxScrollExtent);
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: ListView(
              children: [
                Container(
                  height: 300,
                  child: Scrollbar(
                    thumbVisibility: true,
                    showTrackOnHover: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: controller,
                      child: SizedBox(
                        width: c.length*50,
                        child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            // Chart title
                            title: ChartTitle(text: 'Half yearly sales analysis'),
                            // Enable legend
                            legend: Legend(isVisible: true,position: LegendPosition.auto),
                            // Enable tooltip
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<StatisticsData, String>>[
                              LineSeries<StatisticsData, String>(
                                  dataSource: c,
                                  xValueMapper: (StatisticsData sales, _) =>
                                      sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                      sales.number,
                                  name: 'Temperatura',
                                  // Enable data label
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true)),
                              LineSeries<StatisticsData, String>(
                                color: Colors.red,
                                  dataSource: hn,
                                  xValueMapper: (StatisticsData sales, _) =>
                                  sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                  sales.number,
                                  name: 'Havo namligi',
                                  // Enable data label
                                  dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                              LineSeries<StatisticsData, String>(
                                  color: Colors.blue,
                                  dataSource: tn,
                                  xValueMapper: (StatisticsData sales, _) =>
                                  sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                  sales.number,
                                  name: 'tn',
                                  // Enable data label
                                  dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                              LineSeries<StatisticsData, String>(
                                  color: Colors.orange,
                                  dataSource: sh,
                                  xValueMapper: (StatisticsData sales, _) =>
                                  sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                  sales.number,
                                  name: 'tn',
                                  // Enable data label
                                  dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                              LineSeries<StatisticsData, String>(
                                  color: Colors.grey,
                                  dataSource: yom,
                                  xValueMapper: (StatisticsData sales, _) =>
                                  sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                  sales.number,
                                  name: 'yom',
                                  // Enable data label
                                  dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                              LineSeries<StatisticsData, String>(
                                  color: Colors.black,
                                  dataSource: yor,
                                  xValueMapper: (StatisticsData sales, _) =>
                                  sales.dateTime,
                                  yValueMapper: (StatisticsData sales, _) =>
                                  sales.number,
                                  name: 'yom',
                                  // Enable data label
                                  dataLabelSettings:
                                  DataLabelSettings(isVisible: true)),
                            ]),
                      ),
                    ),
                  ),
                ),
              ],
            )
            // body: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Center(child: Text("Latest received SMS: $_message")),
            //     TextButton(
            //         onPressed: () async {
            //           await telephony.openDialer("123413453");
            //         },
            //         child: Text('Open Dialer'))
            //   ],
            // ),
            ));
  }
}

class StatisticsData {
  String dateTime;
  double number;

  StatisticsData(this.dateTime, this.number);
}
