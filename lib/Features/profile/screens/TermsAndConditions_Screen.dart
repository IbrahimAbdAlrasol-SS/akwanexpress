import 'package:flutter/material.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';

List<(String, String)> questions = [
  (
    "التعريفات",
    "الشركة: الجهة المالكة والمشغلة لتطبيق التوصيل.\nالمندوب: الشخص الذي يوافق على استخدام التطبيق لتنفيذ خدمات التوصيل مقابل عمولة.\nالعميل: الشخص الذي يطلب خدمة التوصيل عبر التطبيق.\nالطلب: كل عملية نقل أو توصيل معتمدة من خلال التطبيق."
  ),
  (
    "شروط التسجيل كمندوب",
    "أن يكون عمر المندوب 18 سنة فما فوق.\nامتلاك وسيلة نقل صالحة ومُرخّصة (دراجة، سيارة، إلخ).\nتقديم مستندات الهوية والمستندات المطلوبة الأخرى (رخصة، تأمين... إلخ).\nالالتزام باستخدام التطبيق حصرياً في تنفيذ الطلبات المعتمدة من النظام."
  ),
  (
    "مسؤوليات المندوب",
    "توصيل الطلبات في الوقت المحدد وبشكل آمن.\nالحفاظ على سرية معلومات العملاء والطلبات.\nعدم استغلال التطبيق لأغراض غير مشروعة.\nالالتزام بجميع القوانين والأنظمة المرورية.\nتسليم المبالغ المستلمة من العملاء إلى الشركة خلال الفترة المحددة (حسب سياسة الشركة المالية)."
  ),
  (
    "العمولات والمستحقات",
    "يتم احتساب عمولة المندوب بناءً على كل طلب مكتمل حسب جدول العمولة المحدد و المتفق عليه مسبقا.\nالشركة تحتفظ بحقها في مراجعة أو تعديل العمولة وفق إشعار مسبق.\nلا تُعتبر المبالغ المستلمة من العملاء ملكاً للمندوب، ويجب تسليمها للشركة خلال 24 ساعة أو حسب المتفق عليه.\nفي حال تأخر المندوب عن تسليم الأموال، تُحتسب عليه غرامة تأخير وفق سياسة الشركة."
  ),
  (
    "الطلبات المُرجعة والمؤجلة",
    "المندوب مسؤول عن إرجاع الطلب إلى مصدره أو الوجهة المعتمدة عند فشل التوصيل.\nفي حال تأجيل أو إلغاء الطلب، يجب تحديث الحالة فورًا عبر التطبيق.\nالطلبات غير المحدثة قد تُحسب على المندوب كطلبات غير منفذة."
  ),
  (
    "إنهاء أو تعليق الحساب",
    "يحق للشركة تعليق أو إنهاء حساب المندوب في الحالات التالية:\nعدم الالتزام بالشروط المذكورة.\nالشكاوى المتكررة من العملاء.\nإساءة استخدام التطبيق أو التلاعب في البيانات.\nالتأخر المتكرر في تسليم المبالغ."
  ),
  (
    "حدود المسؤولية",
    "الشركة غير مسؤولة عن أي أضرار ناتجة عن حوادث أو تأخير خارجة عن إرادتها.\nالشركة غير مسؤولة عن أي التزامات قانونية نتيجة مخالفات مرورية يرتكبها المندوب أثناء تنفيذ الطلبات."
  ),
  (
    "الموافقة",
    "باستخدامك للتطبيق كمندوب، فأنت تُقر وتوافق على كافة الشروط والأحكام الواردة أعلاه، وتلتزم بتطبيقها بشكل كامل."
  ),
];

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const CustomAppBar(
              title: "الشروط و الأحكام",
              showBackButton: true,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    questions[index].$1,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Text(
                                questions[index].$2,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF70798F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
