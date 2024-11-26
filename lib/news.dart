import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class News {
  final String title;
  final String description;
  final String author;
  final String imgUrl;
  final String category;
  final String date;

  News(
      {required this.title,
      required this.description,
      required this.author,
      required this.imgUrl,
      required this.category,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'imgUrl': imgUrl,
      'category': category,
      'date': date,
    };
  }

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      title: map['title'],
      description: map['description'],
      author: map['author'],
      imgUrl: map['imgUrl'],
      category: map['category'],
      date: map['date'],
    );
  }

  String toJson() => json.encode(toMap());

  factory News.fromJson(String source) => News.fromMap(json.decode(source));
}

class NewsStorage {
  static const String _newsKey = 'saved_news';

  static Future<void> addNews(News news) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedNewsJson = prefs.getStringList(_newsKey) ?? [];

    bool isNewsDuplicate = savedNewsJson.any((newsJson) {
      var savedNewsMap = jsonDecode(newsJson);

      return savedNewsMap['title'] == news.title &&
          savedNewsMap['date'] == news.date;
    });

    if (!isNewsDuplicate) {
      if (savedNewsJson.length >= 5) {
        savedNewsJson.removeAt(0);
      }

      savedNewsJson.add(news.toJson());
      await prefs.setStringList(_newsKey, savedNewsJson);
    }
  }

  static Future<List<News>> getSavedNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedNewsJson = prefs.getStringList(_newsKey) ?? [];
    return savedNewsJson
        .map((jsonString) => News.fromJson(jsonString))
        .toList();
  }
}
