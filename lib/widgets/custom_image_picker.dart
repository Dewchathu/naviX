import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart'; // Ensure you have this package in your pubspec.yaml

typedef CustomImagePickerCallback = void Function(ImageSource source, String? imageUrl);

void showImagePickerBottomSheet(BuildContext context, CustomImagePickerCallback onImageSourceSelected) {
  String baseUrl = "https://firebasestorage.googleapis.com/v0/b/navix-dew.appspot.com/o/Profile%20Pictures%2F";
  final Map<String, String> imgDetails = {
    '01': '781b9714-6321-45b8-98c2-36a2f421b43e',
    '02': '88368338-92a1-4092-a0da-6fdc2288b864',
    '03': '85459d45-9c8c-4297-8889-69590a580899',
    '04': '18b40a4d-c098-4868-bc5e-a1e51350993e',
    '05': 'fbd47f39-ebda-4fd1-94d2-d426bab93819',
    '06': '4be5de27-0c8b-4722-896f-e40ad6c4ae7c',
    '07': 'ec72210f-d9ae-43f3-b728-4a960e42531e',
    '08': 'd5e53b17-5616-4ccf-8d02-2ccd773fd72f',
    '09': 'd5cf61a2-1aa1-4555-a973-3352e98cf210',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Choose Image Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onImageSourceSelected(ImageSource.camera, null);
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 40, color: Color(0xFF0F75BC)),
                      SizedBox(height: 4),
                      Text('Camera'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onImageSourceSelected(ImageSource.gallery, null);
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_rounded, size: 40, color: Color(0xFF0F75BC)),
                      SizedBox(height: 4),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Or choose from preset images:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: imgDetails.length,
              itemBuilder: (BuildContext context, int index) {
                String key = imgDetails.keys.elementAt(index);
                String imageUrl = "$baseUrl$key.jpg?alt=media&token=${imgDetails[key]}";
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onImageSourceSelected(ImageSource.gallery, imageUrl);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // Image is loaded
                        }
                        return const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: LoadingIndicator(
                              indicatorType: Indicator.lineSpinFadeLoader,
                              colors: [Colors.blue],
                              strokeWidth: 1,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
