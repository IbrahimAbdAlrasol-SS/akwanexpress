import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AddTicketDialog extends StatefulWidget {
  const AddTicketDialog({super.key});

  @override
  State<AddTicketDialog> createState() => _AddTicketDialogState();
}

class _AddTicketDialogState extends State<AddTicketDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomTextFormField(
              label: 'عنوان التذكرة',
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجا ادخال عنوان التذكرة';
                }
                return null;
              },
            ),
            const Gap(AppSpaces.exLarge),
            FillButton(
              label: 'فتح التذكرة',
              onPressed: () {
                context.pop(_descriptionController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
