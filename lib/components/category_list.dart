import 'package:flutter/material.dart';
import 'package:spese_casa_nuovo/constants/all_constants.dart';
import 'package:spese_casa_nuovo/dao/category_dao.dart';
import 'package:spese_casa_nuovo/models/all_models.dart';
import 'package:spese_casa_nuovo/screens/settings.dart';

class CategoryList extends StatefulWidget {
  final Function callback;
  const CategoryList(this.callback, {Key? key}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<Category> categoryList = kCategoriesList;
  CategoryFilter categoryFilter = CategoryFilter(filterBoth: true);
  Category? selected;

  Future<List<Category>> getList() => CategoryDao().all(categoryFilter);

  refresh(Category? item) {
    setState(() {
      // selected = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: getList(),
      builder: (
        context,
        AsyncSnapshot<List<Category>> snapshot,
      ) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
              List<Category> events = snapshot.data!;
              return Column(children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final item = events[index];
                      return CategoryItem(item, widget.callback);
                    },
                  ),
                ),
              ]);
            } else {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 100.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.yellow.shade700,
                      border: Border.all(
                        color: Colors.yellow.shade700,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 0.0))
                      ]),
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Lista vuota!',
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                          'Definire le categorie prima di inserire nuovi eventi.',
                          style: TextStyle(color: Colors.grey.shade900)),
                    ],
                  )),
                ),
              );
            }
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// -----------------------------------
// CategoryItem
// -----------------------------------

class CategoryItem extends StatelessWidget {
  final Category item;
  final Function callback;

  const CategoryItem(this.item, this.callback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        leading: (item.idNature == Nature.IN)
            ? Image.asset(
                'assets/images/add.png',
                scale: 1.2,
              )
            : Image.asset(
                'assets/images/minus32.png',
                scale: 1.2,
              ),
        title: Text(
          item.label,
          textAlign: TextAlign.start,
        ),
        trailing: Wrap(
          spacing: 4, // space between two icons
          children: [
            GestureDetector(
                onTap: () {
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
                            color: Colors.yellow.shade600.withOpacity(0.7),
                            spreadRadius: 2,
                            blurRadius: 0,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                        color: Colors.grey[600],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: Center(
                        child:
                            CategoryForm(category: item, pCallback: callback),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.edit)),
            GestureDetector(
                onTap: () =>
                    CategoryDao().delete(item).then((value) => callback()),
                child: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
