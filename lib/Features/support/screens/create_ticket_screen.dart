import 'package:Tosell/Features/support/models/ticket.dart';
import 'package:Tosell/Features/support/providers/ticket_provider.dart';
import 'package:Tosell/Features/support/screens/chat/chat_screen.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // استدعاء API لإنشاء التذكرة
      final result =
          await ref.read(ticketNotifierProvider.notifier).createGeneralTicket(
                subject: _subjectController.text.trim(),
                description: _descriptionController.text.trim(),
              );

      if (result != null && result.singleData != null) {
        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إنشاء التذكرة بنجاح'),
              backgroundColor: context.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // الانتقال مباشرة لشاشة المحادثة مع تمرير ticket ID
          context.pushReplacement(
            AppRoutes.chat,
            extra: result.singleData!.id!,
          );
        }
      } else {
        // إظهار رسالة خطأ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('حدث خطأ أثناء إنشاء التذكرة'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          title: const Text('إنشاء تذكرة دعم فني'),
          backgroundColor: context.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس الشاشة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 48,
                        color: context.colorScheme.primary,
                      ),
                      const Gap(AppSpaces.small),
                      Text(
                        'الدعم الفني',
                        style: context.textTheme.headlineSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(AppSpaces.exSmall),
                      Text(
                        'نحن هنا لمساعدتك. اكتب مشكلتك وسنتواصل معك قريباً',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Gap(AppSpaces.large),

                // حقل عنوان التذكرة
                Text(
                  'عنوان التذكرة',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpaces.small),
                CustomTextFormField(
                  controller: _subjectController,
                  label: 'اكتب عنوان مختصر للمشكلة',
                  radius: 12,
                  prefixInner: Icon(
                    Icons.title,
                    color: context.colorScheme.primary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال عنوان التذكرة';
                    }
                    if (value.trim().length < 5) {
                      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const Gap(AppSpaces.large),

                // حقل وصف المشكلة
                Text(
                  'وصف المشكلة',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(AppSpaces.small),
                CustomTextFormField(
                  controller: _descriptionController,
                  label: 'اشرح المشكلة بالتفصيل...',
                  radius: 12,
                  maxLines: 5,
                  prefixInner: Icon(
                    Icons.description,
                    color: context.colorScheme.primary,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال وصف المشكلة';
                    }
                    if (value.trim().length < 10) {
                      return 'الوصف يجب أن يكون 10 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const Gap(AppSpaces.exLarge),

                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  child: FillButton(
                    label: _isLoading ? 'جاري الإرسال...' : 'إرسال التذكرة',
                    onPressed: _createTicket,
                  ),
                ),

                const Gap(AppSpaces.large),

                // معلومات إضافية
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const Gap(AppSpaces.small),
                      Expanded(
                        child: Text(
                          'بعد إرسال التذكرة، ستنتقل مباشرة لشاشة المحادثة للتواصل مع فريق الدعم',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
