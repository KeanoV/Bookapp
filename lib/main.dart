import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.purple),
      home: MyHomePage(title: 'Book Search'),
    );
  }
}

class BookListItem extends StatefulWidget {
  const BookListItem({
    this.thumbnail,
    this.title,
    this.releaseDate,
    this.author,
  });

  final Widget thumbnail;
  final String title;
  final String releaseDate;
  final String author;

  @override
  _BookListItemState createState() => _BookListItemState();
}

class _BookListItemState extends State<BookListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: widget.thumbnail,
          ),
          const Icon(
            Icons.more_vert,
            size: 16.0,
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String search = "a";
  String userSearch = "";
  String aURL = "https://www.googleapis.com/books/v1/volumes?q=";
  final myController = TextEditingController();
  TextEditingController controller = TextEditingController();
  Object get jsonData => null;
  filtersearch(String text) {
    setState(() {
      if (text != "") {
        this.search = text;
      }
    });
  }

  validate(data, opdata) {
    if (data == null) {
      return opdata;
    }

    return data;
  }

  //fetch data from api
  Future<List<Book>> _getUsers() async {
    //use this site to generate json data

    print(this.search + " search");
    var url = "https://www.googleapis.com/books/v1/volumes?q=" + this.search;
    var data = await http.get(url);

    //convert response to json Object
    var jsonData = json.decode(data.body);

    //Store data in User list from JsonData
    List<Book> books = [];
    for (var item in jsonData["items"]) {
      Book book = Book(
          item["volumeInfo"]["title"],
          item["volumeInfo"]["subtitle"],
          item["volumeInfo"]["imageLinks"]["thumbnail"],
          item["volumeInfo"]["authors"][0],
          item["volumeInfo"]["publishedDate"]);

      //add data to  object

      books.add(book);
    }

    //return user list
    return books;
  }

  Icon seaicon = Icon(Icons.search);

  Widget seabar = Text(
    "My Book Search Bar",
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
            centerTitle: true,
            title: seabar,
            actions: <Widget>[
              IconButton(
                  icon: seaicon,
                  onPressed: () {
                    setState(() {
                      if (this.seaicon.icon == Icons.search) {
                        this.seaicon = Icon(Icons.cancel);
                        this.seabar = TextField(
                          controller: controller,
                          textInputAction: TextInputAction.go,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search",
                          ),
                          onSubmitted: (String userInput) {
                            setState(() {
                              print(userInput);
                              if (userInput != "") {
                                this.search = userInput;
                              } else {
                                this.search = "a";
                              }
                            });
                          },
                        );
                      } else {
                        this.seaicon = Icon(Icons.search);
                        this.seabar = Text("AppBar");
                      }
                    });
                  })
            ]),
        body: Center(
            child: Container(
                child: FutureBuilder(
                    future: _getUsers(),
                    // ignore: missing_return
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      print(snapshot.data);
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemExtent: 100.0,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      child: Image.network(
                                          snapshot.data[index].thumbnail),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10.0)),
                                    Expanded(
                                      child: Text(
                                        snapshot.data[index].title +
                                            "\n" +
                                            snapshot.data[index].author +
                                            "\n" +
                                            snapshot.data[index].publishedDate,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 18.0),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.data == null &&
                          snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                              width: 160,
                              height: 150,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.purple),
                                    ),
                                    width: 70,
                                    height: 70,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      'Loading Book List...',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                ],
                              )),
                        );
                      } else if (snapshot.data == null &&
                          snapshot.connectionState == ConnectionState.none) {
                        return Center(
                            child: Container(
                                width: 100,
                                height: 90,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: null,
                                      child: Text(
                                        'no result founds',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                )));
                      }
                    }))));
  }
}

class Book {
  final String title;
  final String subtitle;
  final String thumbnail;
  final String author;
  final String publishedDate;

//Constructor to intitilize
  Book(this.title, this.subtitle, this.thumbnail, this.author,
      this.publishedDate);

  static void add(Book book) {}
}
