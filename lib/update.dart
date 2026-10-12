import 'dart:convert';
import 'package:http/http.dart' as http;

final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

Future<void> updatePost(int postId, String title, String body) async {
  final response = await http.put(
    Uri.parse('$apiUrl/$postId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'id': '$postId',
      'title': title,
      'body': body,
      'userId': '1', // You can change this to a different user ID if you want.
    }),
  );

  if (response.statusCode == 200) {
    print('Post updated successfully!');
  } else {
    throw Exception('Failed to update post.');
  }
}
