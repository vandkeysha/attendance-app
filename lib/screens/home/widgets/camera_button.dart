import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraButton extends StatelessWidget {
  final Function(String imagePath)  onImageCaptured;
  final String buttonText;

  const CameraButton({super.key, required this.onImageCaptured, required this.buttonText});

  Future<void> _takePhoto (BuildContext context) async{
    try {
      // request camera permission 
      final status = await Permission.camera.request();

      if (status.isDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission is required to take photos.'),
              backgroundColor: Colors.orange,
            )
          );
        }
        return;
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera permission is denied, please enable it from settings.'),
              backgroundColor: Colors.red,
              action: SnackBarAction( // untuk pergi ke settings
                label: 'settings',
                onPressed: () => openAppSettings(),
              ),
            )
          );
        }
        return;
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(  // xfile adalah file dari image picker
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70 // kualitas gambar 0-100, compress biar ga terlalu besar
        );   


        if (photo != null) {
          onImageCaptured(photo.path);
        }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:Text('Error capturing photo : ${e.toString()}'),
            backgroundColor: Colors.red,
           )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _takePhoto(context),
      icon: Icon(Icons.camera_alt),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)
      ),
    );
  }
}