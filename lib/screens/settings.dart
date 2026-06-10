import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/components/category_list.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/db/app_database.dart';
import 'package:spese_casa_nuovo/main.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:spese_casa_nuovo/screens/dbbackup.dart';
import 'package:spese_casa_nuovo/screens/dbrestore.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static String route = "/settings_screen";

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void callBack() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int selectedNavigationItemIndex = 4;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // ignore: prefer_const_literals_to_create_immutables
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
      body: CategoryList(callBack),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedNavigationItemIndex,
        onTap: (value) {
          selectedNavigationItemIndex = value;
          switch (value) {
            case 0:
              Navigator.pushReplacementNamed(context, MyHomePage.route);
              break;
            case 1:
              Navigator.pushReplacementNamed(context, DbBackupScreen.route);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, DbRestoreScreen.route);
              break;
            case 3:
              // new DB
              AwesomeDialog(
                context: context,
                dialogType: DialogType.question,
                title: 'New DB',
                desc: 'Do you want to create a new DB?',
                btnOkText: 'Yes',
                btnCancelText: 'No',
                btnOkColor: Colors.green,
                btnOkOnPress: () async {
                  await AppDatabase.instance.deleteDb();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, MyHomePage.route);
                },
                btnCancelOnPress: () {},
              ).show();
              debugPrint("CaSE 3");
              break;
            case 4:
              break;
            default:
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload), label: 'Backup'),
          BottomNavigationBarItem(
              icon: Icon(Icons.cloud_download), label: 'Restore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New DB'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            elevation: 0,
            barrierColor: Colors.black.withAlpha(0),
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade600.withValues(alpha: 0.7),
                    spreadRadius: 2,
                    blurRadius: 0,
                    offset: const Offset(0, 0), // changes position of shadow
                  ),
                ],
                color: Colors.grey[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Center(
                child: CategoryForm(pCallback: callBack),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.yellow.shade600,
        ),
      ),
    );
  }
}

// ---------------------
// CategoryForm
// ---------------------

class CategoryForm extends StatefulWidget {
  final Category? selectedCategory;
  final Function callback;
  const CategoryForm({Category? category, required Function pCallback, super.key})
      : selectedCategory = category,
        callback = pCallback;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  bool isIn = true;
  bool isUpdate = false;

  TextEditingController labelController = TextEditingController();
  late Category item;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isUpdate = widget.selectedCategory != null;
    item = widget.selectedCategory ?? Category(idNature: 0, label: "");
    // newCategoryLabel = item?.label;
    labelController = TextEditingController(text: item.label);
    isIn = item.idNature == Nature.inId;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    labelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.only(top: 20.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    TextFormField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(label: Text('Nome categoria')),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onChanged: (value) => item.label = value,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Entrata'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Uscita'),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                      selected: {isIn},
                      onSelectionChanged: (selection) {
                        setState(() {
                          isIn = selection.first;
                          item.idNature = isIn ? Nature.inId : Nature.outId;
                        });
                      },
                    ),

                    // Add TextFormFields and ElevatedButton here.
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  if (isUpdate) {
                    await CategoryDao().update(item);
                  } else {
                    await CategoryDao().insert(item);
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                  widget.callback();
                  Navigator.pop(context);
                }
              },
              child: const Text('Aggiorna'),
            ),
          ],
        ),
      ),
    );
  }
}
