import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          textTheme: Theme.of(context).textTheme.copyWith()),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _screen = [
    HomePage(),
    DataPage(),
    ContactPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_currentIndex],
      bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.data_usage), label: "Data"),
            NavigationDestination(
                icon: Icon(Icons.contact_page), label: "Contact"),
          ]),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assignment 2"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/goodness+favour.jpg"),
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.secondary,
                child: Center(
                    child: Transform.rotate(
                        angle: 0.15,
                        child: Text(
                          "Goodness Ade",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )))),
          )
        ],
      ),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Product>> _data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Assignment 2"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: FutureBuilder<List<Product>>(
            future: _data,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text("Error loading data");
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemBuilder: (contex, index) {
                    return Card(
                      child: ListTile(
                        leading: Image.network(snapshot.data![index].thumbnail),
                        title: Text(snapshot.data![index].title),
                        subtitle: Text(snapshot.data![index].description),
                      ),
                    );
                  },
                );
              } else {
                return Text("No data available");
              }
            }));
  }

  Future<List<Product>> fetchData() async {
    final response =
        await http.get(Uri.parse("https://dummyjson.com/products"));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['products'];
      return jsonData
          .map((data) => Product(
                id: data['id'],
                title: data['title'],
                description: data['description'],
                thumbnail: data['thumbnail'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Assignment 2"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Text(
                    "Want Something? Contact Us.",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: "Enter your name",
                      labelText: "Name",
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) => _name = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      hintText: "How do we reach you",
                      labelText: "Email",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) => _email = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.message),
                      hintText: "Enter your message",
                      labelText: "Message",
                    ),
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 5,
                    onSaved: (value) => _message = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Message is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Submitting...")),
                        );
                      }
                    },
                    child: Text("Submit"),
                  )
                ]))));
  }
}

class Product {
  final int id;
  final String title;
  final String description;
  final String thumbnail;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.thumbnail});
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}
