import 'package:http/http.dart' as http;

Future<void> fetchData() async {
  try {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode == 200) {
      // Do something with the response data
      print(response.body);
    } else {
      // Handle the error
      print('Request failed with status: ${response.statusCode}.');
    }
  } catch (e) {
    print('Network error: $e');
  }
}
