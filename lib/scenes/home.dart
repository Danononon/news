import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'newbie.dart';
import 'package:intl/intl.dart';
import 'package:news/news.dart';

class HomeScene extends StatefulWidget {
  const HomeScene({super.key});

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene> {
  List<Map<String, dynamic>>? news;
  List<String>? filters;
  List<String>? sorts = ['По дате', 'По умолчанию', 'По алфавиту'];
  List<String>? dateSorts = [
    'Все',
    'Этот месяц',
    'Прошлый месяц',
    'Прошлый год'
  ];
  String? selectedDateSort = 'Все';
  List<String> savedCategories = ['Все'];
  String? selectedCategory;
  String? selectedSort = 'По умолчанию';
  DateTime dateNow = DateTime.now();
  List<News> savedNews = [];

  Future<void> getSavedNews() async {
    List<News> savedNews = await NewsStorage.getSavedNews();

    savedNews.forEach((news) {
      print(news.title);
    });
  }

  var response = Supabase.instance.client
      .from('news')
      .select('*, categories!inner(is_selected, name)')
      .eq('categories.is_selected', true);

  Future<void> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> loadedCategories =
        prefs.getStringList('savedCategories') ?? [];
    setState(() {
      savedCategories = loadedCategories;
    });
    print(savedCategories);
  }

  Future<void> fetchNews(String? category) async {
    if (category == 'Все') {
      response = Supabase.instance.client
          .from('news')
          .select('*, categories!inner(name)')
          .eq('categories.is_selected', true);
    } else {
      response = Supabase.instance.client
          .from('news')
          .select('*, categories!inner(name)')
          .eq('categories.name', category!)
          .eq('categories.is_selected', true);
    }
    setState(() {});
  }

  void sortNews(List<Map<String, dynamic>> news, String sortType) {
    if (sortType == 'По дате') {
      news.sort((a, b) {
        var dateA = DateTime.parse(a['created_at']);
        var dateB = DateTime.parse(b['created_at']);
        return dateB.compareTo(dateA);
      });
    } else if (sortType == 'По умолчанию') {
      news.sort((a, b) => a['id'].compareTo(b['id']));
    } else if (sortType == 'По алфавиту') {
      news.sort((a, b) => a['title'].compareTo(b['title']));
    }
  }

  @override
  void initState() {
    super.initState();
    getCategories();
    getSavedNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Новости',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCategory ?? 'Все',
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      fetchNews(selectedCategory);
                    });
                  },
                  items: savedCategories
                      .map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                )
              ],
            ),
            Row(
              children: [
                Text('Сортировка:'),
                SizedBox(width: 10,),
                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue;
                    });
                  },
                  items: sorts!.map<DropdownMenuItem<String>>((String sort) {
                    return DropdownMenuItem<String>(
                      value: sort,
                      child: Text(sort),
                    );
                  }).toList(),
                )
              ],
            ),
            Row(
              children: [
                Text('Фильтр по дате:'),
                SizedBox(width: 10,),
                DropdownButton<String>(
                  value: selectedDateSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDateSort = newValue;
                    });
                  },
                  items:
                      dateSorts!.map<DropdownMenuItem<String>>((String sort) {
                    return DropdownMenuItem<String>(
                      value: sort,
                      child: Text(sort),
                    );
                  }).toList(),
                )
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: response,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final news = snapshot.data!;
                  sortNews(news, selectedSort!);
                  return ListView.builder(
                    itemCount: news.length,
                    itemBuilder: ((context, index) {
                      final newbie = news[index];
                      String formattedDate = DateFormat('dd.MM.yyyy')
                          .format(DateTime.parse(newbie['created_at']));
                      if (selectedDateSort == 'Этот месяц' &&
                          DateTime.parse(newbie['created_at']).month !=
                              dateNow.month) {
                        return SizedBox.shrink();
                      } else if (selectedDateSort == 'Прошлый месяц') {
                        int lastMonth =
                            dateNow.month == 1 ? 12 : dateNow.month - 1;
                        int lastMonthYear = dateNow.month == 1
                            ? dateNow.year - 1
                            : dateNow.year;

                        if (DateTime.parse(newbie['created_at']).month !=
                                lastMonth ||
                            DateTime.parse(newbie['created_at']).year !=
                                lastMonthYear) {
                          return SizedBox.shrink();
                        }
                      } else if (selectedDateSort == 'Прошлый год' &&
                          DateTime.parse(newbie['created_at']).year !=
                              dateNow.year - 1) {
                        return SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewbieScene(
                                        title: newbie['title'],
                                        fullDesc: newbie['full_desc'],
                                        imgUrl: newbie['img_url'],
                                        author: newbie['author'],
                                        category: newbie['categories']['name'],
                                        date: formattedDate,
                                      )));
                          News newNews = News(
                              title: newbie['title'],
                              description: newbie['full_desc'],
                              author: newbie['author'],
                              imgUrl: newbie['img_url'],
                              category: newbie['categories']['name'],
                              date: formattedDate);

                          setState(() {
                            NewsStorage.addNews(newNews);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Image.network(
                                newbie['img_url'] ??
                                    'https://img.freepik.com/premium-vector/window-operating-system-error-warning-dialog-window-popup-message-with-system-failure-flat-design_812892-54.jpg?semt=ais_hybrid',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(newbie['title'], softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                    Text(
                                        'Категория: ${newbie['categories']['name']}', style: TextStyle(fontSize: 12, color: Colors.grey[800]),),
                                    Text(
                                      'Дата: ${formattedDate}',
                                      softWrap: true,
                                      style: TextStyle(fontSize: 13, color: Colors.grey[800])
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/savednews');
                },
                child: Text('Сохраненные новости'))
          ],
        ),
      ),
    );
  }
}
