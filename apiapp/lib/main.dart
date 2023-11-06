import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: FutureBuilder<List<User>>(
          future: fetchUsersFromGitHub(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(snapshot.data?[index].name ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Divider(),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<List<User>> fetchUsersFromGitHub() async {
    final response = await http.get(Uri.parse('https://api.github.com/users'));
    if (response.statusCode == 200) {
      List responseJson = json.decode(response.body);
      List<User> userList = createUserList(responseJson);
      return userList;
    } else {
      throw Exception('Failed to load data from GitHub');
    }
  }

  List<User> createUserList(List data) {
    List<User> list = [];
    for (int i = 0; i < data.length; i++) {
      String name = data[i]["login"];
      int id = data[i]["id"];
      User user = User(name: name, id: id);
      list.add(user);
    }
    return list;
  }
}

class User {
  final String name;
  final int id;
  User({required this.name, required this.id});
}
