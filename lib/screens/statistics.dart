import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/statistics_component.dart';
import 'package:spese_casa_nuovo/main.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);
  static String route = "/statistics_screen";
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    int _selectedNavigationItemIndex = 1;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quanto spendo?"),
            SizedBox(height: 8.0),
          ],
        ),
        leading: Image.asset(
          'assets/images/logo.png',
          scale: 2.0,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: const StatisticsComponent(),
        // child: Text(
        //   'Statistic Screen',
        //   style: TextStyle(color: Colors.white),
        // ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationItemIndex,
        onTap: (value) {
          _selectedNavigationItemIndex = value;
          switch (value) {
            case 0:
              Navigator.pushReplacementNamed(context, MyHomePage.route);
              break;

            default:
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stat'),
        ],
      ),
    );
  }
}
