import 'dart:io';

import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class NewUploadImagesArgs {
  final String shipmentId;
  const NewUploadImagesArgs({required this.shipmentId});
}

class NewUploadImagesDialog extends ConsumerStatefulWidget {
  final NewUploadImagesArgs args;
  const NewUploadImagesDialog({super.key, required this.args});

  @override
  ConsumerState<NewUploadImagesDialog> createState() =>
      _NewUploadImagesDialogState();
}

class _NewUploadImagesDialogState extends ConsumerState<NewUploadImagesDialog> {
  bool isLoading = false;
  bool _isPickingImage = false;

  final List<File> _uploadedImages = [];
  final List<String> _selectedImages = [];
  final TextEditingController _notesController = TextEditingController();

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked != null) {
        setState(() {
          _selectedImages.add(picked.path);
          _uploadedImages.add(File(picked.path));
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _uploadedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogMaxHeight = MediaQuery.of(context).size.height * 0.8;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان مع الأيقونة
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Gap(4),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'تأكيد الاستلام',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(6),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'التقط صورة واضحة تثبت استلامك للطلب من التاجر',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Gap(8),

                    // قسم الصور
                    Text(
                      'صور المنتج',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Gap(4),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _uploadedImages.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return GestureDetector(
                              onTap: _pickImage,
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                dashPattern: const [6, 4],
                                color: Colors.blue.shade700,
                                strokeWidth: 2,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_photo_alternate,
                                      size: 30,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final image = _uploadedImages[index - 1];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.file(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.black.withOpacity(0.4),
                                  child: Center(
                                    child: IconButton(
                                      icon: SvgPicture.asset(
                                        'assets/svg/trash-bin-minimalistic-2-svgrepo-com.svg',
                                        color: context.colorScheme.error,
                                        width: 28,
                                        height: 28,
                                      ),
                                      onPressed: () => _removeImage(index - 1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Gap(14),

                    // قسم الملاحظات الإضافية
                    Text(
                      'ملاحظات إضافية',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Gap(4),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أضف ملاحظاتك هنا...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: context.colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    Gap(8),

                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    final result = await ref
                                        .read(
                                            shipmentsNotifierProvider.notifier)
                                        .vipReceived(
                                          shipmentId: widget.args.shipmentId,
                                          attachments: _selectedImages,
                                        );
                                    setState(() => isLoading = false);
                                    if (result.$1 != null) {
                                      GlobalToast.show(
                                        context: context,
                                        message: "تم تحديث الحالة",
                                        backgroundColor:
                                            context.colorScheme.primary,
                                        textColor: Colors.white,
                                      );
                                      if (context.mounted) {
                                        context.go(AppRoutes.vipHome);
                                      }
                                    } else {
                                      GlobalToast.show(
                                        context: context,
                                        message: result.$2 ??
                                            'حدث خطأ في قبول الطلبية ',
                                        backgroundColor:
                                            context.colorScheme.error,
                                        textColor: Colors.white,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'تم الاستلام',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        Gap(8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _uploadedImages.clear();
                                _selectedImages.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              side: BorderSide(
                                  color: context.colorScheme.primary),
                            ),
                            child: Text(
                              'إعادة التقاط',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
