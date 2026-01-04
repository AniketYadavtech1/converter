import 'package:http/http.dart' as http;

class ApiService {
  static Future<http.StreamedResponse> uploadDocx(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/api/convert'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    return await request.send();
  }
}
