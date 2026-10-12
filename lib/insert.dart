import 'dart:convert';
import 'package:http/http.dart' as http;

final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
Future<void> createPost(String title, String body) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
      'body': body,
      'userId': '1', // You can change this to a different user ID if you want.
    }),
  );
  if (response.statusCode == 201) {
    print('Post created successfully!');
  } else {
    throw Exception('Failed to create post.');
  }
}
