// Module 13 - BASIC CRUD with the http package (JSONPlaceholder)
//
// Setup: flutter pub add http   (then replace lib/main.dart with this file)
// Android release builds: add the INTERNET permission to AndroidManifest.xml
//
// JSONPlaceholder is a fake API: POST/PUT/DELETE reply "success" but nothing is
// really saved, so we also change the local list to show the result.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // ---------------- READ (GET + parse JSON) ----------------
  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          posts = jsonDecode(response.body); // parse JSON -> List
          loading = false;
        });
      } else {
        showMsg('Request failed: ${response.statusCode}');
        setState(() => loading = false);
      }
    } catch (e) {
      showMsg('Network error: $e');
      setState(() => loading = false);
    }
  }

  // ---------------- CREATE (POST) ----------------
  Future<void> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
    );

    if (response.statusCode == 201) {
      setState(() => posts.insert(0, jsonDecode(response.body)));
      showMsg('Post created!');
    } else {
      showMsg('Failed to create post.');
    }
  }

  // ---------------- UPDATE (PUT) ----------------
  Future<void> updatePost(int index, String title, String body) async {
    final id = posts[index]['id'];

    // Server only has posts 1-100; new posts (id 101) are updated locally only.
    if (id <= 100) {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'id': id, 'title': title, 'body': body, 'userId': 1}),
      );
      if (response.statusCode != 200) {
        showMsg('Failed to update post.');
        return;
      }
    }

    setState(() {
      posts[index] = {...posts[index], 'title': title, 'body': body};
    });
    showMsg('Post updated!');
  }

  // ---------------- DELETE ----------------
  Future<void> deletePost(int index) async {
    final id = posts[index]['id'];

    if (id <= 100) {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode != 200) {
        showMsg('Failed to delete post.');
        return;
      }
    }

    setState(() => posts.removeAt(index));
    showMsg('Post deleted!');
  }

  void showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Dialog used for both Add and Edit. Pass index to edit, null to add.
  void showForm({int? index}) {
    final titleCtrl = TextEditingController(
      text: index == null ? '' : posts[index]['title'],
    );
    final bodyCtrl = TextEditingController(
      text: index == null ? '' : posts[index]['body'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Post' : 'Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (index == null) {
                createPost(titleCtrl.text, bodyCtrl.text);
              } else {
                updatePost(index, titleCtrl.text, bodyCtrl.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic CRUD'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title'], maxLines: 1),
                  subtitle: Text(post['body'], maxLines: 2),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showForm(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePost(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
