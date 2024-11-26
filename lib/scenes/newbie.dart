import 'package:flutter/material.dart';

class NewbieScene extends StatelessWidget {
  const NewbieScene(
      {super.key,
      required this.title,
      required this.imgUrl,
      required this.fullDesc,
      required this.author,
      required this.category,
      required this.date});

  final String title;
  final String imgUrl;
  final String fullDesc;
  final String author;
  final String category;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
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
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )),
              SizedBox(
                height: 5,
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Категория: ${category}',
                    style: TextStyle(fontSize: 13),
                  )),
              SizedBox(
                height: 7,
              ),
              Image.network(
                imgUrl,
                width: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 7,
              ),
              Text(fullDesc),
              SizedBox(
                height: 7,
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Автор: ${author}',
                    style: TextStyle(fontSize: 13),
                  )),
              Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 13),
                  )),
            ],
          ),
        ));
  }
}
