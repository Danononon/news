import 'package:flutter/material.dart';
import 'scenes/home.dart';
import 'scenes/categories/select.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'scenes/saved_news.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://bxehfpovccbqokkigpyc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ4ZWhmcG92Y2NicW9ra2lncHljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIzNjIyMzEsImV4cCI6MjA0NzkzODIzMX0.QLink_5lrlW2VonwvJOIAO4TJ-nzGflPqDEvPUWmRBk');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News',
        home: SelectCategoriesScene(),
        routes: <String, WidgetBuilder>{
          '/news': (BuildContext context) => HomeScene(),
          '/savednews': (BuildContext context) => SavedNewsScene(),
        });
  }
}
