
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<File?> urlToFile(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) return null;

  try {
    // Download the image
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // Get the device's temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create a temporary file path with the correct extension
      final file = File('${tempDir.path}/${basename(imageUrl)}');

      // Write the image bytes to the file
      return await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download image');
    }
  } catch (e) {
    print('Error converting URL to file: $e');
    return null;
  }
}