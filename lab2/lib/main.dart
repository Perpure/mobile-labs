import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Мой МГТУ';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const String dataUrl = 'https://library.bmstu.ru/Pages/Edu/Books/1kurs/1semestr/informatika_programmirovanie';
  static const TextStyle optionStyle =
  TextStyle(fontSize: 18, fontWeight: FontWeight.normal);

  Future<String> getBooks() async {
    var resp = await http.get(Uri.parse(dataUrl));
    var doc = parse(resp.body);
    var cs = doc.getElementsByClassName("content-section")[0];
    String books = '';
    bool contentStarted = false;
    for (var v in cs.children.sublist(0, cs.children.length - 2)) {
      if (v.localName == 'hr') {
        if (contentStarted) {
          books += '\n----------------\n\n';
        }
        contentStarted = true;
      } else if (contentStarted) {
        books += '${v.text}\n';
      }
    }
    return books;
  }

  Widget getWidget(int index) {
    if (index == 0) {
      return DefaultTextStyle(
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium!,
        child: FutureBuilder<String>(
          future: getBooks(), // a previously-obtained Future<String> or null
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Text(
                  '${snapshot.data}',
                  style: optionStyle,
                )
              );
            } else if (snapshot.hasError) {
              return const Text(
                'Ошибка при загрузке',
                style: optionStyle,
              );
            } else {
              return const Text(
                'Подождите',
                style: optionStyle,
              );
            }
          }
        )
      );
    }
    return const Image(image: AssetImage('assets/qr.gif'));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: getWidget(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add_check),
            label: 'Книги',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_2_rounded),
            label: 'Код',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
