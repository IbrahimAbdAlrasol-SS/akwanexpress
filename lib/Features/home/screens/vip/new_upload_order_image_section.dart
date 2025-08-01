import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Tosell/core/utils/extensions.dart';

class NewUploadOrderImageSection extends StatefulWidget {
  final void Function(List<String>)? onImagesChanged;
  const NewUploadOrderImageSection({super.key, this.onImagesChanged});

  @override
  State<NewUploadOrderImageSection> createState() =>
      _NewUploadOrderImageSectionState();
}

class _NewUploadOrderImageSectionState
    extends State<NewUploadOrderImageSection> {
  final List<File> _capturedImages = [];

  void _notifyImagesChanged() {
    widget.onImagesChanged?.call(_capturedImages.map((f) => f.path).toList());
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      setState(() {
        _capturedImages.add(File(pickedFile.path));
        _notifyImagesChanged();
      });
    }
  }

  void _deletePhoto(int index) {
    setState(() {
      _capturedImages.removeAt(index);
      _notifyImagesChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Take photo
        GestureDetector(
          onTap: _takePhoto,
          child: DottedBorder(
            color: context.colorScheme.primary,
            strokeWidth: 1.5,
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            dashPattern: const [6, 4],
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: context.colorScheme.primary.withOpacity(0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 32, color: context.colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'التقط صورة للطلب',
                    style: TextStyle(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (_capturedImages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'الصور المرفوعة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_capturedImages.length, (index) {
                  final image = _capturedImages[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Image.file(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/trash-bin-minimalistic-2-svgrepo-com.svg',
                                color: context.colorScheme.error,
                                width: 28,
                                height: 28,
                              ),
                              onPressed: () => _deletePhoto(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
      ],
    );
  }
}
