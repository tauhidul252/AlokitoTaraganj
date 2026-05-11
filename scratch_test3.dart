void main() {
  try {
    Map<String, dynamic> m = {"a": 1};
    dynamic x = m;
    print(x.take(5));
  } catch (e) {
    print("Test 6: $e");
  }
}
