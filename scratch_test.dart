void main() {
  try {
    dynamic x = null;
    int y = x;
    print(y);
  } catch (e) {
    print("Test 1: $e");
  }

  try {
    Map<String, dynamic> m = {"a": null};
    int z = m["a"];
    print(z);
  } catch (e) {
    print("Test 2: $e");
  }

  try {
    List<dynamic> l = [null];
    int w = l[0];
    print(w);
  } catch (e) {
    print("Test 3: $e");
  }

  try {
    dynamic n = null;
    print(n[0]);
  } catch (e) {
    print("Test 4: $e");
  }
}
