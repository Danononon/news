import 'package:flutter/material.dart';
import 'newbie.dart';
import 'package:news/news.dart';

class SavedNewsScene extends StatefulWidget {
  const SavedNewsScene({super.key});

  @override
  State<SavedNewsScene> createState() => _SavedNewsSceneState();
}

class _SavedNewsSceneState extends State<SavedNewsScene> {
  List<Map<String, dynamic>>? news;
  List<News> savedNews = [];

  Future<void> loadSavedNews() async {
    List<News> newsList = await NewsStorage.getSavedNews();
    setState(() {
      savedNews = newsList;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSavedNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Сохраненные новости',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<News>>(
                future: NewsStorage.getSavedNews(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final news = snapshot.data!;
                  return ListView.builder(
                    itemCount: news.length,
                    itemBuilder: ((context, index) {
                      final newbie = news[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewbieScene(
                                        title: newbie.title,
                                        fullDesc: newbie.description,
                                        imgUrl: newbie.imgUrl,
                                        author: newbie.author,
                                        category: newbie.category,
                                        date: newbie.date,
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Image.network(
                                newbie.imgUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(newbie.title, softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                    Text('Категория: ${newbie.category}', style: TextStyle(fontSize: 12, color: Colors.grey[800]),),
                                    Text('Дата: ${newbie.date}', softWrap: true, style: TextStyle(fontSize: 12, color: Colors.grey[800]),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
