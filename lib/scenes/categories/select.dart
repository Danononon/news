import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectCategoriesScene extends StatefulWidget {
  const SelectCategoriesScene({super.key});

  @override
  State<SelectCategoriesScene> createState() => _SelectCategoriesSceneState();
}

class _SelectCategoriesSceneState extends State<SelectCategoriesScene> {
  List<Map<String, dynamic>>? categories;
  List<String> savedCategories = ['Все'];

  final response = Supabase.instance.client.from('categories').select();

  Future<void> updateCategories(int id, bool isSelected) async {
    await Supabase.instance.client.from('categories').update({
      'is_selected': isSelected,
    }).eq('id', id);
  }

  Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> setCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('savedCategories', savedCategories);
  }

  Future<void> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> loadedCategories =
        prefs.getStringList('savedCategories') ?? ['Все'];
    setState(() {
      savedCategories = loadedCategories;
    });
    print(savedCategories);
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Выберите категории', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: response,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final categories = snapshot.data!;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category['is_selected'] ?? false;

                    return ListTile(
                      title: Text(category['name']),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            category['is_selected'] = newValue!;
                          });

                          updateCategories(category['id'], newValue!);

                          if (newValue) {
                            savedCategories.add(category['name']);
                          } else {
                            savedCategories.remove(category['name']);
                          }
                          setCategories();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/news');
            },
            child: Text('К новостям!'),
          ),
        ],
      ),
    );
  }
}
