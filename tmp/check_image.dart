
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/Logo.jpeg');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  print('Width: ${image.width}, Height: ${image.height}');
}
