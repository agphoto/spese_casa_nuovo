import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/statistics_component.dart';
import 'package:spese_casa_nuovo/main.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});
  static String route = "/statistics_screen";
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    int selectedNavigationItemIndex = 1;
    return Scaffold(
      appBar: AppBar(
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedNavigationItemIndex,
        onTap: (value) {
          selectedNavigationItemIndex = value;
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
