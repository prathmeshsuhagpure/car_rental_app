import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<void> addPhoto({
  required BuildContext context,
  required String carId,
  required List<File> carImages,
  required void Function(List<File> newImages) onImagesAdded,
}) async {
  if (carImages.length >= 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can only upload up to 10 photos.')),
    );
    return;
  }

  final ImagePicker picker = ImagePicker();
  final List<XFile>? pickedImages = await picker.pickMultiImage();

  if (pickedImages == null || pickedImages.isEmpty) return;

  final allowedCount = 10 - carImages.length;
  final selectedImages =
      pickedImages.take(allowedCount).map((xfile) => File(xfile.path)).toList();

  if (selectedImages.isEmpty) return;

  // Add images to local list
  onImagesAdded(selectedImages);

  // Show feedback
  final messenger = ScaffoldMessenger.of(context);
  if (carImages.length + selectedImages.length < 5) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Please add at least 5 images.')),
    );
  } else {
    messenger.showSnackBar(
      SnackBar(
          content:
              Text('${selectedImages.length} image(s) added successfully.')),
    );
  }
}

class CloudinaryService {
  static const String cloudName = 'Car-Rental-Cloud';
  static const String uploadPreset = 'car_images_unsigned';

  static Future<Map<String, dynamic>> uploadImage(
      File imageFile, String userId) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'cars/$userId'
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Cloudinary upload failed: $responseBody');
    }

    return jsonDecode(responseBody);
  }
}

Future<List<String>> uploadCarImages(List<File> images, String userId) async {
  final List<String> uploadedUrls = [];

  for (final image in images) {
    final result = await CloudinaryService.uploadImage(image, userId);

    uploadedUrls.add(result['secure_url']);
  }

  return uploadedUrls;
}
