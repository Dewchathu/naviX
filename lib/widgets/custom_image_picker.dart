import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef CustomImagePickerCallback = void Function(ImageSource source);

class CustomImagePicker extends StatelessWidget {
  final CustomImagePickerCallback onImageSourceSelected;

  const CustomImagePicker({Key? key, required this.onImageSourceSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Image Source'),
      content: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.camera);
              },
              child: Icon(Icons.camera_alt_rounded, size: 40, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                onImageSourceSelected(ImageSource.gallery);
              },
              child: Icon(Icons.image_rounded, size: 40, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

void showImageSourceDialog(BuildContext context, CustomImagePickerCallback onImageSourceSelected) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CustomImagePicker(onImageSourceSelected: onImageSourceSelected);
    },
  );
}