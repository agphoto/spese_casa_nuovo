import 'package:awesome_dialog/awesome_dialog.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spese_casa_nuovo/components/event_form.dart';
import 'package:spese_casa_nuovo/constants/all_constants.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/dao/user_dao.dart';
import 'package:spese_casa_nuovo/screens/dbbackup.dart';
import 'package:spese_casa_nuovo/screens/dbrestore.dart';
import 'package:spese_casa_nuovo/screens/settings.dart';
import 'package:spese_casa_nuovo/screens/statistics.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'components/events_list.dart';
import 'package:spese_casa_nuovo/components/filter_form.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterUdid.udid.then((value) => {
          debugPrint("udid:$value"),
          if (!GetIt.I.isRegistered<AppSettings>())
            GetIt.I.registerSingleton<AppSettings>(AppSettings(udid: value))
        });

    return MaterialApp(
      home: const MyHomePage(
        title: 'Quanto Spendo',
      ), // SplashScreen(),
      title: 'Spese casa',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.red,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 150.0,
          iconTheme: IconThemeData(
            color: Colors.purple,
            size: 16,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.purple,
            size: 16,
          ),
        ),
        /* light theme settings */

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
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.grey.shade900))),
          appBarTheme: AppBarTheme(
            toolbarHeight: 110.0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.grey[900],
            centerTitle: false,
          ),
          scaffoldBackgroundColor: Colors.grey[850],
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: Colors.grey[700]),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              unselectedItemColor: Colors.yellow[200],
              selectedItemColor: Colors.yellow[600],
              backgroundColor: Colors.grey.shade900),
          canvasColor: Colors.grey[900]
          /* dark theme settings */
          ),
      themeMode: ThemeMode.dark,
      /* ThemeMode.system to follow system theme,
         ThemeMode.light for light theme,
         ThemeMode.dark for dark theme
      */
      debugShowCheckedModeBanner: false,
      // initialRoute: '/',
      routes: {
        MyHomePage.route: (context) =>
            const MyHomePage(title: 'Quanto spendo?'),
        SettingsScreen.route: (context) => const SettingsScreen(),
        StatisticsScreen.route: (context) => const StatisticsScreen(),
        DbBackupScreen.route: (context) => const DbBackupScreen(),
        DbRestoreScreen.route: (context) => const DbRestoreScreen()
      },
      // home: MyHomePage(title: 'Quanto spendo?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title})  ;

  static String route = "/home";

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedNavigationItemIndex = 0;
  EventFilter _filter = EventFilter();
  List<Category> categories = [];

  Future getUser() async {
    User? value = await UserDao().userById(1);
    if (value == null) {
      debugPrint("User is NULL");
      User user = User(
          name: 'user_name',
          surname: 'user_sur',
          login: 'login',
          passwd: 'passwd',
          uuid: const Uuid().v1());
      user.id = await UserDao().insert(user);
      debugPrint("user created with id = ${user.id}");
    } else {
      debugPrint("User id${value.uuid}");
    }
  }

  Future getCategoryList() async {
    List<Category> value = await CategoryDao().all(CategoryFilter());
    setState(() {
      categories = value;
    });
  }

  @override
  void initState() {
    super.initState();
    // getUser();
    getCategoryList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // final args = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            const SizedBox(height: 8.0),
            Text('V$version', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: "Quanto Spendo ?",
              desc: 'Version $version\ninfo@alessiogiuliano.it',
              titleTextStyle: const TextStyle(
                color: Color.fromARGB(255, 212, 200, 23),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              descTextStyle: TextStyle(
                color: Colors.blue[500],
                fontSize: 14,
              ),
              btnOkOnPress: () {},
            ).show();
          },
          icon: Image.asset(
            'assets/images/logo.png',
            scale: 2.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Ink(
              width: 30.0,
              height: 30.0,
              decoration: const ShapeDecoration(
                color: Color.fromARGB(255, 231, 216, 80),
                shape: CircleBorder(),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                icon: const Icon(Icons.add),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    _filter = EventFilter(filterIn: true, filterOut: false);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Ink(
              width: 30.0,
              height: 30.0,
              decoration: const ShapeDecoration(
                color: Color.fromARGB(255, 231, 216, 80),
                shape: CircleBorder(),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                icon: const Icon(Icons.remove),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    _filter = EventFilter(filterIn: false, filterOut: true);
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Ink(
              width: 30.0,
              height: 30.0,
              decoration: const ShapeDecoration(
                color: Color.fromARGB(255, 231, 216, 80),
                shape: CircleBorder(),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                splashRadius: 20,
                icon: const Icon(Icons.refresh),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    _filter = EventFilter(filterIn: true, filterOut: true);
                  });
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationItemIndex,
        onTap: (value) {
          _selectedNavigationItemIndex = value;
          switch (value) {
            case 0:
              setState(() {
                _filter = EventFilter();
              });
              break;

            case 1:
              Navigator.pushReplacementNamed(context, StatisticsScreen.route);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, SettingsScreen.route);
              break;
            default:
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      body: EventsList(_filter, categories),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                elevation: 0,
                barrierColor: Colors.black.withAlpha(0),
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade600.withValues(alpha: 0.7),
                          spreadRadius: 2,
                          blurRadius: 0,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      color: Colors.grey[600],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: const Center(
                      child: FilterForm(),
                    ),
                  ),
                ),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    _filter = value;
                  });
                }
              });
            },
            tooltip: 'Filter',
            child: Image.asset('assets/images/filter.png'),
          ),
          const SizedBox(
            height: 4.0,
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                elevation: 0,
                barrierColor: Colors.black.withAlpha(0),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    height: 400,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade600.withValues(alpha: 0.7),
                          spreadRadius: 2,
                          blurRadius: 0,
                          offset:
                              const Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      color: Colors.grey[600],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Center(
                      child: EventForm(categories: categories),
                    ),
                  ),
                ),
              ).then(
                (_) {
                  setState(() {});
                },
              );
            },

            tooltip: 'Add',
            child: Icon(
              Icons.add,
              color: Colors.yellow[600],
            ), //Image.asset('assets/images/add.png'),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


// Modifica