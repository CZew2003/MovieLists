import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPage = 1;

  String url = 'https://yts.mx/api/v2/list_movies.json?limit=30';

  Future<http.Response> fetchData(int page) async {
    final http.Response response = await http.get(Uri.parse('$url&page=$page'));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Lists'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<http.Response>(
              future: fetchData(currentPage),
              builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }
                final Map<String, dynamic> snapshotData = jsonDecode(snapshot.data!.body) as Map<String, dynamic>;
                final Map<String, dynamic> data = snapshotData['data'] as Map<String, dynamic>;
                final List<dynamic> movies = data['movies']! as List<dynamic>;
                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> movie = movies[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(movie['title_english'].toString()),
                        subtitle: Text(movie['year'].toString()),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FilledButton(
                    onPressed: () {
                      if (currentPage != 1) {
                        setState(() {
                          currentPage--;
                        });
                      }
                    },
                    child: const Text('Prev'),
                  ),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        currentPage++;
                      });
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
