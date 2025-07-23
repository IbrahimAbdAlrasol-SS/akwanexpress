✅ الهيكلية المقترحة (Directory Structure)
lib/
├── core/
│   ├── constants/            ← الثوابت العامة (الألوان، النصوص، الأحجام...)
│   ├── errors/               ← الأخطاء العامة وتفسيرها
│   ├── helpers/              ← أدوات مساعدة (Formatters, Validators)
│   ├── services/             ← GPS, Notification, Permission, Camera, etc.
│   └── theme/                ← الثيم العام
│
├── config/
│   ├── router.dart           ← التوجيه بين الصفحات
│   ├── di.dart               ← ربط الكيوبت والخدمات (Dependency Injection)
│   └── localization.dart     ← دعم اللغات
│
├── features/
│   ├── auth/                 ← الدخول، التسجيل، otp، تغيير كلمة السر
│   │   ├── cubit/
│   │   ├── data/             ← API / Repository
│   │   ├── view/
│   │   └── widgets/
│   │
│   ├── orders/               ← الطلبات الجارية والمكتملة والتفاصيل
│   │   ├── cubit/
│   │   ├── data/
│   │   ├── view/
│   │   └── widgets/
│   │
│   ├── delivery_lists/       ← قوائم الاستلام والتوصيل
│   │   ├── cubit/
│   │   ├── data/
│   │   ├── view/
│   │   └── widgets/
│   │
│   ├── support/              ← التذاكر والدعم الفني
│   │   ├── cubit/
│   │   ├── data/
│   │   ├── view/
│   │   └── widgets/
│   │
│   ├── wallet/               ← المحفظة، المستحقات، المدفوعات
│   │   ├── cubit/
│   │   ├── data/
│   │   ├── view/
│   │   └── widgets/
│   │
│   ├── profile/              ← تعديل الملف الشخصي، الإعدادات، تسجيل الخروج
│   │   ├── cubit/
│   │   ├── data/
│   │   ├── view/
│   │   └── widgets/
│   │
│   └── terms/                ← الشروط والأحكام
│       ├── view/
│       └── cubit/
│
└── main.dart


| المجلد                     | يحتوي على                                              |
| -------------------------- | ------------------------------------------------------ |
| `core/`                    | أدوات مشتركة لا تتبع ميزة محددة (ثيم، خدمات، أدوات...) |
| `config/`                  | ملفات الإعدادات (DI, Routes, Localization...)          |
| `features/auth/`           | تسجيل الدخول، إنشاء الحساب، OTP، استعادة كلمة السر     |
| `features/orders/`         | الطلبات بكل حالاتها وتفاصيلها                          |
| `features/delivery_lists/` | القوائم (استلام وتوصيل)                                |
| `features/support/`        | الدعم الفني والتذاكر                                   |
| `features/wallet/`         | المحفظة، الأرباح، المستحقات                            |
| `features/profile/`        | حسابي، الإعدادات، تسجيل الخروج                         |
| `features/terms/`          | عرض الشروط والأحكام                                    |


✅ المجلد داخل كل ميزة:
داخل كل feature ستجد:

cubit/: يحتوي الكيوبت وحالاته.

data/: يحتوي على الـ repository، و API، ونماذج البيانات.

view/: يحتوي على الشاشات الأساسية.

widgets/: يحتوي على الواجهات الصغيرة القابلة لإعادة الاستخدام داخل هذه الميزة.