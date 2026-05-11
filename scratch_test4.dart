import 'dart:convert';
void main() {
  dynamic data = json.decode('{"count": 10, "results": []}');
  try {
    List<dynamic> list = data;
    print(list);
  } catch (e) {
    print("Test 7: $e");
  }
}
