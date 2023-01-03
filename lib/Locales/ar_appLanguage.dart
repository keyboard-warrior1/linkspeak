import 'appLanguage.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class AR_Language implements AppLanguage {
  AR_Language();
  @override
  final String logo = 'لينكسبيك';
  final String admin_feedbacks = 'ملاحظات';
  final String admin_allposts = 'جميع المنشورات';
  final String admin_alluserclubs1 = 'جميع المستخدمين';
  final String admin_alluserclubs2 = 'جميع النوادي';
  final String admin_archiveFind1 = 'عثور ';
  final String admin_archiveFind2 = 'عثور';
  final String admin_archiveFind_field1 = 'معرّف المنشور';
  final String admin_archiveFind_field2 = 'معرّف التعليق';
  final String admin_archiveFind_field3 = 'معرّف الردّ';
  final String admin_archiveFind_field4 = 'معرّف الفلير';
  final String admin_archiveFind_field5 = 'معرّف الحساب المحذوف';
  final String admin_archiveFind_field6 = 'معرّف حساب فلير المحذوف';
  final String admin_controlDailyDetails = 'معلومات';
  final String admin_controlDailyLogins = 'عمليّات الدخول';
  final String admin_controlDailyLoginSearch1 = 'بحث عمليّات الدخول';
  final String admin_controlDailyLoginSearch2 = 'حذف';
  final String admin_controlDailyLoginSearch3 = 'لم يتم العثور على نتائج';
  final String admin_controlDailyScreen = 'أيام';
  final String admin_controlDayScreen1 = 'عمليّات الدخول';
  final String admin_controlDayScreen2 = 'معلومات';
  final String admin_barTitle1 = 'العثور على منشور';
  final String admin_barTitle2 = 'العثور على تعليق منشور';
  final String admin_barTitle3 = 'العثور على ردّ لتعليق منشور';
  final String admin_barTitle4 = 'العثور على فلير';
  final String admin_barTitle5 = 'العثور على تعليق فلير';
  final String admin_barTitle6 = 'لعثور على ردّ لتعليق فلير';
  final String admin_barTitle7 = 'العثور';
  final String admin_findField1 = 'معرّف المنشور';
  final String admin_findField2 = 'معرّف التعليق';
  final String admin_findField3 = 'معرّف الردّ';
  final String admin_findField4 = 'صاحب الفلير';
  final String admin_findField5 = 'معرّف مجموعة الفلير';
  final String admin_findField7 = 'معرّف الفلير';
  final String admin_findField8 = 'معرّف تعليق الفلير';
  final String admin_findField9 = 'معرّف ردّ تعليق الفلير';
  final String admin_findButton = 'العثور';
  final String admin_generalControl = 'التحكم العام';
  final String admin_generalItemBar1 = 'حسابات';
  final String admin_generalItemBar2 = 'نوادي';
  final String admin_generalItemBar3 = 'منشورات';
  final String admin_generalItemBar4 = 'تعليقات المنشورات';
  final String admin_generalItemBar5 = 'ردود تعليقات المنشورات';
  final String admin_generalItemBar6 = 'فليرز';
  final String admin_generalItemBar7 = 'تعليقات الفليرز';
  final String admin_generalItemBar8 = 'ردود تعليقات الفليرز';
  final String admin_mainAdmin1 = 'مشرف';
  final String admin_mainAdmin2 = 'حسابات';
  final String admin_mainAdmin3 = 'نوادي';
  final String admin_mainAdmin4 = 'منشورات';
  final String admin_mainAdmin5 = 'تعليقات المنشورات';
  final String admin_mainAdmin6 = 'ردود تعليقات المنشورات';
  final String admin_mainAdmin7 = 'فليرز';
  final String admin_mainAdmin8 = 'تعليقات الفليرز';
  final String admin_mainAdmin9 = 'ردود تعليقات الفليرز';
  final String admin_mainAdmin10 = 'شتائم';
  final String admin_mainAdmin11 = 'أرشيف';
  final String admin_mainAdmin12 = 'التحكم';
  final String admin_mainAdmin13 = 'جميع المستخدمين';
  final String admin_mainAdmin14 = 'جميع النوادي';
  final String admin_mainAdmin15 = 'جميع المنشورات';
  final String admin_mainAdmin16 = 'فليرز جدد';
  final String admin_mainAdmin17 = 'تقيمات';
  final String admin_mainAdmin18 = 'بث';
  final String admin_mainArchive1 = 'أرشيف';
  final String admin_mainArchive2 = 'منشورات محذوفة';
  final String admin_mainArchive3 = 'تعليقات  محذوفة';
  final String admin_mainArchive4 = 'ردود محذوفة';
  final String admin_mainArchive5 = 'فليرز  محذوفة';
  final String admin_mainArchive6 = 'حسابات محذوف';
  final String admin_mainArchive7 = 'حسابات فلير محذوف';
  final String admin_mainArchive8 = 'مستخدمين مرفوع عنهم الحظر';
  final String admin_mainArchive9 = 'نوادي مرفوع عنهم المنع';
  final String admin_mainArchive10 = 'نوادي غير ناشطة';
  final String admin_mainControl1 = 'التحكم';
  final String admin_mainControl2 = 'عمومي';
  final String admin_mainControl3 = 'يومي';
  final String admin_mainProfanity1 = 'شتائم';
  final String admin_mainProfanity2 = 'ملخّصات الحسابات';
  final String admin_mainProfanity3 = 'ملخّصات النوادي';
  final String admin_mainProfanity4 = 'ملخّصات حسابات الفلير';
  final String admin_mainProfanity5 = 'محتويات المنشورات';
  final String admin_mainProfanity6 = 'تعليقات المنشورات';
  final String admin_mainProfanity7 = 'ردود تعليقات المنشورات';
  final String admin_mainProfanity8 = 'عناوين مجموعات الفلير';
  final String admin_mainProfanity9 = 'تعليقات الفلير';
  final String admin_mainProfanity10 = 'ردود تعليقات الفلير';
  final String admin_newFlares = 'فليرز جدد';
  final String admin_profanityBar1 = 'ملخّصات الحسابات';
  final String admin_profanityBar2 = 'ملخّصات النوادي';
  final String admin_profanityBar3 = 'ملخّصات حسابات الفلير';
  final String admin_profanityBar4 = 'محتويات المنشورات';
  final String admin_profanityBar5 = 'تعليقات المنشورات';
  final String admin_profanityBar6 = 'ردود تعليقات المنشورات';
  final String admin_profanityBar7 = 'تعليقات الفلير';
  final String admin_profanityBar8 = 'ردود تعليقات الفلير';
  final String admin_profanityBar9 = 'عناوين مجموعات الفلير';
  final String admin_userDailyCollections = 'مجموعات';
  final String admin_userDailyDetails = 'معلومات';
  final String admin_userDaily1 = 'مجموعات';
  final String admin_userDaily2 = 'معلومات';
  final String admin_widgets_archiveWidget = 'تحقّق';
  final String admin_bandDialog1 = 'حظر المستخدم';
  final String admin_bandDialog2 = 'السّبب';
  final String admin_bandDialog3 = 'المدّة في الأيّام';
  final String admin_bandDialog4 = 'حظر مؤبّد';
  final String admin_bandDialog5 = 'حظر';
  final String admin_bandDialog6 = 'المدّة مطلوبة';
  final String admin_bandDialog7 = 'مدّة خطأ';
  final String admin_bandDialog8 = 'المدّة يجب أن تكون بين 1-7 أيّام';
  final String admin_bandDialog9 = 'السّبب مطلوب';
  final String admin_bandDialog10 = 'السّبب يجب أن يكون بين 20-300 حرف';
  final String admin_detailsDialog1 = 'نسخ';
  final String admin_detailsDialog2 = 'حذف';
  final String admin_prohibitDialog1 = 'المدّة مطلوبة';
  final String admin_prohibitDialog2 = 'مدّة خطأ';
  final String admin_prohibitDialog3 = 'المدّة يجب أن تكون بين 1-7 أيّام';
  final String admin_prohibitDialog4 = 'السّبب مطلوب';
  final String admin_prohibitDialog5 = 'السّبب يجب أن يكون بين 20-300 حرف';
  final String admin_prohibitDialog6 = 'منع';
  final String admin_prohibitDialog7 = 'السّبب';
  final String admin_prohibitDialog8 = 'المدّة في الأيّام';
  final String admin_prohibitDialog9 = 'حظر مؤبّد';
  final String admin_prohibitDialog10 = 'منع';
  final String admin_profanityWidget = 'تحقّق';
  final String clubs_adminItem1 = 'ازالة';
  final String clubs_adminItem2 = 'تعيين';
  final String clubs_adminScreen1 = 'مشرفين';
  final String clubs_adminScreen2 = 'حصل خطأ ما';
  final String clubs_adminScreen3 = 'حاول';
  final String clubs_assignAdmin1 = 'تعيين مشرفين';
  final String clubs_assignAdmin2 = 'حصل خطأ ما';
  final String clubs_assignAdmin3 = 'حاول';
  final String clubs_assignAdmin4 = 'بحث مشاركين';
  final String clubs_assignAdmin5 = 'حذف';
  final String clubs_assignAdmin6 = 'البحت عن مشاركين النادي';
  final String clubs_assignAdmin7 = 'لم يتم العثور على نتائج';
  final String clubs_banItem1 = 'رفع الحظر';
  final String clubs_banItem2 = 'حظر';
  final String clubs_banMember1 = 'احظر مشارك';
  final String clubs_banMember2 = 'حصل خطأ ما';
  final String clubs_banMember3 = 'حاول';
  final String clubs_banMember4 = 'حذف';
  final String clubs_banMember5 = 'بحث مشاركين';
  final String clubs_banMember6 = 'البحت عن مشاركين النادي';
  final String clubs_banMember7 = 'لم يتم العثور على نتائج';
  final String clubs_about1 = 'هذا النادي خاص';
  final String clubs_about2 = 'تم منع هذا النادي';
  final String clubs_about3 = 'هذا النادي غير مفعّل';
  final String clubs_about4 = 'أنتم محظورون من رؤية هذا النادي';
  final String clubs_about5 = 'هذا النادي مخفي';
  final String clubs_about6 = 'مشرفين';
  final String clubs_alerts1 = 'اشعارات النادي';
  final String clubs_alerts2 = 'حذف الاشعارات';
  final String clubs_alerts3 = 'نعم';
  final String clubs_alerts4 = 'لا';
  final String clubs_alerts5 = 'حذف جميع الاشعارات';
  final String clubs_alerts6 = 'ليس هناك أيّ اشعارات';
  final String clubs_alerts7 = 'مشاركين جدد';
  final String clubs_alerts8 = 'طلبات مشاركة';
  final String clubs_banned1 = 'مشاركين محظورون';
  final String clubs_banned2 = 'حصل خطأ ما';
  final String clubs_banned3 = 'حاول';
  final String clubs_banned4 = 'لا يوجد أيّ مشاركين محظورون';
  final String clubs_banner1 = 'تغيير اللافتة';
  final String clubs_banner2 = 'ازالة اللافتة';
  final String clubs_banner3 = 'حفّظ';
  final String clubs_center1 = 'مركز النوادي';
  final String clubs_center2 = 'حصل خطأ ما';
  final String clubs_center3 = 'حاول';
  final String clubs_center4 = 'لا يوجد أيّ نادي';
  final String clubs_joinButton1 = 'نعم';
  final String clubs_joinButton2 = 'لا';
  final String clubs_joinButton3 = 'غادر النادي';
  final String clubs_joinButton4 = 'الغاء الطلب';
  final String clubs_joinButton5 = 'مشارك';
  final String clubs_joinButton6 = 'الطلب مرسل';
  final String clubs_joinButton7 = 'انضمام';
  final String clubs_request1 = ' طلب المشاركة في النادي';
  final String clubs_request2 = 'قبول';
  final String clubs_request3 = 'رفض';
  final String clubs_members1 = 'مشاركين';
  final String clubs_members2 = 'حصل خطأ ما';
  final String clubs_members3 = 'حاول';
  final String clubs_members4 = 'حذف';
  final String clubs_members5 = 'بحث المشاركين';
  final String clubs_members6 = 'لم يتم العثور على نتائج';
  final String clubs_clubPosts1 = 'هذا النادي خاص';
  final String clubs_clubPosts2 = 'تم منع هذا النادي';
  final String clubs_clubPosts3 = 'هذا النادي غير مفعّل';
  final String clubs_clubPosts4 = 'أنتم محظورون من رؤية هذا النادي';
  final String clubs_clubPosts5 = 'هذا النادي مخفي';
  final String clubs_clubPosts6 = 'حصل خطأ ما';
  final String clubs_clubPosts7 = 'حاول';
  final String clubs_clubPosts8 = 'لا يوجد منشورات حتى الآن';
  final String clubs_requests = 'طلبات';
  final String clubs_screen1 = 'حصل خطأ ما';
  final String clubs_screen2 = 'حاول';
  final String clubs_screen3 = 'نادي';
  final String clubs_screen4 = 'مشاركين';
  final String clubs_screen5 = 'ادارة';
  final String clubs_screen6 = 'نشر';
  final String clubs_screen7 = 'اشعارات';
  final String clubs_sensitive1 = 'اللافتة محتواها حسّاس';
  final String clubs_sensitive2 = 'اظهار';
  final String clubs_tabbar1 = 'منشورات';
  final String clubs_tabbar2 = 'ملخّص';
  final String clubs_tabbar3 = 'مواضيع';
  final String clubs_topics1 = 'هذا النادي خاص';
  final String clubs_topics2 = 'تم منع هذا النادي';
  final String clubs_topics3 = 'هذا النادي غير مفعّل';
  final String clubs_topics4 = 'أنتم محظورون من رؤية هذا النادي';
  final String clubs_topics5 = 'هذا النادي مخفي';
  final String clubs_topics6 = 'لم يضاف أي موضوع';
  final String clubs_create1 = 'ملخّص النادي مطلوب';
  final String clubs_create2 = 'الملخّص يجب أن لا يتعدّى 2000 حرف';
  final String clubs_create3 = 'اسم النادي مطلوب';
  final String clubs_create4 = 'اسم النادي يجب ان يكون بين 2-30 حرف';
  final String clubs_create5 = 'الاسم غير صالح';
  final String clubs_create6 = 'الاسم غير صالح';
  final String clubs_create7 = 'الاسم مأخوذ';
  final String clubs_create8 = 'ملاحظة';
  final String clubs_create9 = "هذا الاسم مأخوذ";
  final String clubs_create10 = 'ملاحظة';
  final String clubs_create11 = "يجب ألا تتجاوز الصورة حجم 30 ميغا بايت";
  final String clubs_create12 = 'ملاحظة';
  final String clubs_create13 =
      "تحتوي الصورة على محتوى ينتهك ارشادات أمان الصّور الخاصة بنا";
  final String clubs_create14 = 'خطأ';
  final String clubs_create15 = 'حصل خطأ ما';
  final String clubs_create16 = 'خطأ';
  final String clubs_create17 = 'حصل خطأ ما';
  final String clubs_create18 = 'خطأ';
  final String clubs_create19 = 'حصل خطأ ما';
  final String clubs_create20 = 'تغيير الصورة';
  final String clubs_create21 = 'ازالة الصورة';
  final String clubs_create22 = 'أنشئ نادي';
  final String clubs_create23 = 'عام';
  final String clubs_create24 = 'خاص';
  final String clubs_create25 = 'خفي';
  final String clubs_create26 = 'اسم النادي';
  final String clubs_create27 = 'ملخّص النادي';
  final String clubs_create28 = 'اضافة مواضيع';
  final String clubs_create29 = 'انشاء';
  final String clubs_manage1 = 'الملخّص يجب أن لا يتعدّى 2000 حرف';
  final String clubs_manage2 = 'يجب تحديد الحد الأقصى للمنشورات';
  final String clubs_manage3 = 'الحدّ خطأ';
  final String clubs_manage4 = 'الحدّ الأقصى يجب أن يكون بين 1-50';
  final String clubs_manage5 = 'خاص';
  final String clubs_manage6 = 'عام';
  final String clubs_manage7 = 'خفي';
  final String clubs_manage8 = 'ملاحظة';
  final String clubs_manage9 = "يجب ألا تتجاوز الصورة حجم 30 ميغا بايت";
  final String clubs_manage10 = 'ملاحظة';
  final String clubs_manage11 =
      "تحتوي الصورة على محتوى ينتهك ارشادات أمان الصّور الخاصة بنا";
  final String clubs_manage12 = 'نجح';
  final String clubs_manage13 = 'فشل';
  final String clubs_manage14 = 'فشل';
  final String clubs_manage15 = 'نجح';
  final String clubs_manage16 = 'فشل';
  final String clubs_manage17 = 'نجح';
  final String clubs_manage18 = 'فشل';
  final String clubs_manage19 = 'تغيير الصورة';
  final String clubs_manage20 = 'ازالة الصورة';
  final String clubs_manage21 = 'عام';
  final String clubs_manage22 = 'خاص';
  final String clubs_manage23 = 'خفي';
  final String clubs_manage24 = 'المشاركين المحظورين';
  final String clubs_manage25 = 'مشرفين';
  final String clubs_manage26 = 'ادارة النادي';
  final String clubs_manage27 = 'السماح للمشاركين بنشر المنشورات';
  final String clubs_manage28 = 'السماح للانضمام السريع';
  final String clubs_manage29 = 'ابطال تفعيل النادي';
  final String clubs_manage30 = 'حفظ';
  final String clubs_manage31 = 'ملخّص';
  final String clubs_manage32 = 'الحد الأقصى للمنشورات';
  final String clubs_manage33 = 'اضافة مواضيع';
  final String clubs_newPost1 = 'الرجاء تزويد وصف أو صورة - مقطع';
  final String clubs_newPost2 = 'الوصف لا يجب ان يتخطى 10000 حرف';
  final String clubs_newPost3 = 'ملاحظة';
  final String clubs_newPost4 = "المقاطع لا يجب ان تتخطى حجم 150 ميغا بايت";
  final String clubs_newPost5 = 'ملاحظة';
  final String clubs_newPost6 = "يجب ألا تتجاوز الصور حجم 30 ميغا بايت";
  final String clubs_newPost7 = 'ملاحظة';
  final String clubs_newPost8 = 'المشاركين بامكانهم نشر';
  final String clubs_newPost9 = 'منشور يوميا';
  final String clubs_newPost10 = 'تم النشر';
  final String clubs_newPost11 = 'فشل';
  final String clubs_newPost12 = 'ينشر';
  final String clubs_newPost13 = 'مقطع غير مقبول';
  final String clubs_newPost14 = "يجب لمقاطع الفيديو الا تتخطى مدّة دقيقة";
  final String clubs_newPost15 = 'نشر';
  final String clubs_newPost16 = 'محتوى حساس';
  final String clubs_newPost17 = 'اغلاق التعليقات';
  final String clubs_newPost18 = 'نشر';
  final String clubs_newPost19 = 'ماذا تودّون المشاركة';
  final String clubs_newPost20 = 'المعرض';
  final String clubs_newPost21 = 'الكاميرا';
  final String clubs_newPost22 = 'موضوع جديد';
  final String clubs_newPost23 = 'اضافة مواضيع النادي';
  final String clubs_newPost24 = 'اضافة مواضيعي';
  final String clubs_newPost25 = 'اضافة ملاحظة';
  final String clubs_newPost26 = 'اضافة مقاطع';
  final String clubs_newPost27 = 'اضافة نص';
  final String flares_addComment1 = 'الرجاء كتابة تعليق';
  final String flares_addComment2 = 'يجب على التعليقات الا تتجاوز 1500 حرف';
  final String flares_addComment3 = 'ملاحظة';
  final String flares_addComment4 = "تم حظركم من قبل صاحب الفلير";
  final String flares_addComment5 =
      "ليس بامكانكم اضافة اكثر من 30 تعليق خلال ساعة";
  final String flares_addComment6 = "يجب ألا تتجاوز الصورة حجم 15 ميغا بايت";
  final String flares_addComment7 = 'أضف تغليق';
  final String flares_addComment8 = 'نشر';
  final String flares_addComment9 = 'التعليقات مغلقة من قبل الناشر';
  final String flares_addReply1 = 'الرجاء كتابة رد';
  final String flares_addReply2 = 'يجب على الردود الا تتجاوز 1500 حرف';
  final String flares_addReply3 = "تم حظركم من قبل صاحب الفلير";
  final String flares_addReply4 = "تم حظركم من قبل صاحب التعليق";
  final String flares_addReply5 = "ليس بامكانكم اضافة اكثر من 30 رد خلال ساعة";
  final String flares_addReply6 = 'أضف رد';
  final String flares_addReply7 = 'نشر';
  final String flares_customize1 = 'تم الحفظ';
  final String flares_customize2 = 'حفظ';
  final String flares_alerts1 = 'اشعارات';
  final String flares_alerts2 = 'حذف الاشعارات';
  final String flares_alerts3 = 'نعم';
  final String flares_alerts4 = 'لا';
  final String flares_alerts5 = 'حذف كل الاشعارات';
  final String flares_alerts6 = 'لا اشعارات جديدة';
  final String flares_alerts7 = 'اعجابات';
  final String flares_alerts8 = 'تغليقات';
  final String flares_baseline1 = 'يتم الازالة';
  final String flares_baseline2 = 'تمّت ازالة الفلير';
  final String flares_baseline3 = 'رفع الكتم';
  final String flares_baseline4 = 'كتم';
  final String flares_baseline5 = 'تبليغ';
  final String flares_baseline6 = 'حذف الفلير';
  final String flares_baseline7 = 'اظهار المعلومات';
  final String flares_comment1 = 'ردّ';
  final String flares_comment2 = 'زيارة الحساب';
  final String flares_comment3 = 'حذف التعليق';
  final String flares_comment4 = 'ابلاغ عن التعليق';
  final String flares_comment5 = 'اظهار المعلومات';
  final String flares_comment6 = 'اظهار التعليق';
  final String flares_commentAlerts = 'تعليقات';
  final String flares_commentLikes1 = 'اعجابات';
  final String flares_commentLikes2 = 'حصل خظأ ما, الرجاء اعادة المحاولة';
  final String flares_commentLikes3 = 'حاول';
  final String flares_commentLikes4 = 'كن من أوّل المعجبين';
  final String flares_repliesScreen1 = 'اظهار جميع الردود';
  final String flares_repliesScreen2 = 'لا يوجد أي رد';
  final String flares_repliesScreen3 = 'ردود';
  final String flares_repliesScreen4 = 'لم نجد هذا الرد';
  final String flares_comments1 = 'جار التحميل';
  final String flares_comments2 = 'تم حذف التعليق';
  final String flares_comments3 = 'اظهار جميع التعليقات';
  final String flares_comments4 = 'لا يوجد أي تعليق';
  final String flares_comments5 = 'تعليقات  ';
  final String flares_comments6 = 'لم نجد هذا التعليق';
  final String flares_history1 = 'حذف السّجل';
  final String flares_history2 = 'نعم';
  final String flares_history3 = 'لا';
  final String flares_history4 = 'حذف';
  final String flares_history5 = 'السّجل';
  final String flares_likes1 = 'اعجابات  ';
  final String flares_likes2 = 'كن من أوّل المعجبين';
  final String flares_likes3 = 'حذف';
  final String flares_likes4 = 'بحث الاعجابات';
  final String flares_likes5 = 'لم يتم العثور على نتائج';
  final String flares_profile1 = 'حصل خطأ ما';
  final String flares_profile2 = 'حاول';
  final String flares_profile3 =
      'تم حظر هذا الحساب لانتهاكه شروطنا و ارشاداتنا';
  final String flares_profile4 = 'هذا الحساب خاص';
  final String flares_profile5 = 'مجموعات';
  final String flares_profile6 = 'نجح';
  final String flares_profile7 = 'فشل';
  final String flares_profile8 = 'ملخّص';
  final String flares_profile9 = 'فليرز';
  final String flares_profile10 = 'اعجابات';
  final String flares_profile11 = 'مشاهدات';
  final String flares_reply1 = 'جار التحميل';
  final String flares_reply2 = 'تم حذف الرد';
  final String flares_reply3 = 'زيارة الحساب';
  final String flares_reply4 = 'حذف الرد';
  final String flares_reply5 = 'ابلاغ عن الرد';
  final String flares_reply6 = 'اظهار المعلومات';
  final String flares_views1 = 'مشاهدين  ';
  final String flares_views2 = "لم يسجّل أي مشاهدة حتى الان";
  final String flares_views3 = 'بحث المشاهدين';
  final String flares_liked = 'الفليرز التي اعجبتكم';
  final String flares_newCollection1 =
      "المقاطع لا يجب ان تتخطى حجم 150 ميغا بايت";
  final String flares_newCollection2 = "يجب ألا تتجاوز الصور حجم 30 ميغا بايت";
  final String flares_newCollection3 = "يمكن للمستخدمين نشر 10 مجموعات يوميا ";
  final String flares_newCollection4 = "سبق أن نشرتم مجموعة بنفس هذا العنوان";
  final String flares_newCollection5 = 'تم النشر';
  final String flares_newCollection6 = 'مجموعة جديدة';
  final String flares_newCollection7 = 'عنوان';
  final String flares_newCollection8 = 'مجموعة غير مقبولة';
  final String flares_newCollection9 =
      "المجموعة عليها ان تحتوي فلير واحدة على الاقل";
  final String flares_newCollection10 = 'نشر';
  final String flares_newCollection11 = 'الرجاء ادخال عنوان مقبول';
  final String flares_newCollection12 = 'العنوان يجب الا يتخطى 75 حرف';
  final String flares_newComments = 'علّق على الفلير الخاصة بكم';
  final String flares_newLikes = 'اعجبه الفلير الخاصة بكم';
  final String flares_profileFlares1 = 'حصل خطأ ما';
  final String flares_profileFlares2 = 'لم يتم نشر أي فلير بعد';
  final String flares_profileFlares3 = 'نشر';
  final String flares_singleFlare1 = 'الفلير غير متوفرة';
  final String flares_singleFlare2 = 'ربما تم حذف أو ازالة هذه الفلير';
  final String loading_profile = 'الخلف';
  final String screens_about1 =
      "لينكسبيك مقدم لكم من قبل فريق من المطورين المخلصين بفكرة انشاء منصة آمنة و غير محدودة يمكن لأي شخص بغض النظر عن خلفيته المشاركة و التعبير عن نفسه فيها";
  final String screens_about2 = 'الشأن';
  final String screens_about3 = 'أرسل لنا ملاحظاتك';
  final String screens_additional1 = 'الرجاء ادخال رابط صحيح';
  final String screens_additional2 = 'الرجاء ادخال رقم صحيح';
  final String screens_additional3 = 'تم الحفظ';
  final String screens_additional4 = 'فشل';
  final String screens_additional5 = 'عنوان البريد الالكتروني خطأ';
  final String screens_additional6 =
      'عنوان البريد الالكتروني يجب الا يتخطى 100 حرف';
  final String screens_additional7 = 'معلومات اضافية';
  final String screens_additional8 = 'رابط';
  final String screens_additional9 = 'البريد الالكتروني';
  final String screens_additional10 = 'البريد';
  final String screens_additional11 = 'رقم الهاتف';
  final String screens_additional12 = 'الهاتف';
  final String screens_additional13 = 'هذه المعلومات ستظهر خلف صفحتكم';
  final String screens_additional14 = 'حفظ';
  final String screens_addPost = "بامكان المستخدمين نشر 50 منشور يوميا";
  final String screens_blocked1 = 'حسابات محظورة';
  final String screens_blocked2 = "لا يوجد أي حسابات محظورة";
  final String screens_clubTab = 'لا يوجد منشورات حتى الآن';
  final String screens_commentHistory1 = 'تعليقاتي';
  final String screens_commentHistory2 = 'تعليقات المنشورات';
  final String screens_commentHistory3 = 'تعليقات الفليرز';
  final String screens_customIcon1 = 'زر مشخّص';
  final String screens_customIcon2 = 'الزّر الفعّال   ';
  final String screens_customIcon3 = 'الزّر الغير فعّال';
  final String screens_customIcon4 = 'تم الحفظ';
  final String screens_customIcon5 = 'ملاحظة';
  final String screens_customIcon6 =
      "يجب تزويد كلا الزرّ الفعّال و الغير فعّال ";
  final String screens_customIcon7 = 'حفظ';
  final String screens_customLocation1 = 'الرجاء تزويد اسم صالح للاستخدام';
  final String screens_customLocation2 = 'يجب على الاسم ان يكون بين 2-50 حرف';
  final String screens_customLocation3 = 'التالي';
  final String screens_customLocation4 = 'اضغط على الموقع';
  final String screens_customLocation5 = 'اتمام';
  final String screens_customLocation6 = 'اسم المكان';
  final String screens_customLocation7 = 'مكان مشخّص';
  final String screens_editProfile1 = 'الملخّص لا يجب ان يتخطى 1000 حرف';
  final String screens_editProfile2 = '99+';
  final String screens_editProfile3 = 'خاص';
  final String screens_editProfile4 = 'عام';
  final String screens_editProfile5 = 'ملاحظة';
  final String screens_editProfile6 = "يجب ألا تتجاوز الصورة حجم 30 ميغا بايت";
  final String screens_editProfile7 =
      "تحتوي الصورة على محتوى ينتهك ارشادات أمان الصّور الخاصة بنا";
  final String screens_editProfile8 = 'نجح';
  final String screens_editProfile9 = 'فشل';
  final String screens_editProfile10 = 'تغيير الصورة';
  final String screens_editProfile11 = 'ازالة الصورة';
  final String screens_editProfile12 = 'عام';
  final String screens_editProfile13 = 'خاص';
  final String screens_editProfile14 = 'معلومات اضافية';
  final String screens_editProfile15 = 'حسابات محظورة';
  final String screens_editProfile16 = 'تعديل الحساب';
  final String screens_editProfile17 = 'حفظ';
  final String screens_editProfile18 = 'ملخّص';
  final String screens_editProfile19 = 'اضافة مواضيع';
  final String screens_favClubPosts = "لم يتم العثور على مفضّلات";
  final String screens_favorites = "مفضّلات";
  final String screens_feed = "لم يتم العثور على منشورات";
  final String screens_feedback1 = '* ملاحظة خطأ';
  final String screens_feedback2 = 'ملاحظة';
  final String screens_feedback3 = 'تم ارسال الملاحظة';
  final String screens_feedback4 = 'تم ارسال ملاحظتكم بنجاح';
  final String screens_feedback5 = 'ارسال';
  final String screens_finishSetup1 = "الرجاء اضافة 5 مواضيع على الأقل";
  final String screens_finishSetup2 = 'يتم الاتمام';
  final String screens_finishSetup3 = 'اتمام';
  final String screens_finishSetup4 = 'اتمام الحساب';
  final String screens_finishSetup5 = 'تكلّم قليلا عن نفسك';
  final String screens_flareCommentHistory = 'تعليقات الفلير';
  final String screens_flareCommentReplyHistory = 'ردود تعليقات الفلير';
  final String screens_help1 = '* اسم المستخدم مطلوب';
  final String screens_help2 = '* اسم المستخدم خطأ';
  final String screens_help3 = 'معلومات خاطئة';
  final String screens_help4 =
      'امّا اسم المستخدم أو عنوان البريد الالكتروني خطأ';
  final String screens_help5 = 'تم ارسال الرمز';
  final String screens_help6 =
      'تم ارسال طلب الى عنوان البريد الالكروني الخاص بكم';
  final String screens_help7 = 'خطأ';
  final String screens_help8 = 'حصل خطأ ما';
  final String screens_help9 = '* عنوان البريد الالكتروني خطأ';
  final String screens_help10 =
      '* عنوان البريد الالكتروني يجب الا يتخطى 100 حرف';
  final String screens_help11 = 'المساعدة';
  final String screens_help12 = 'تغيير كلمة المرور';
  final String screens_help13 = 'أرسل لنا ملاحظتك';
  final String screens_help14 = 'اسم المستخدم';
  final String screens_help15 = 'عنوان البريد الالكتروني';
  final String screens_help16 = 'تم ارسال الرمز';
  final String screens_help17 =
      'تم ارسال طلب الى عنوان البريد الالكروني الخاص بكم';
  final String screens_help18 = 'اتمام';
  final String screens_likedClubPosts = "لم نجد منشورات أعجبتكم";
  final String screens_likedPosts = "منشورات أعجبتكم";
  final String screens_linkedNotif = 'متابعات';
  final String screens_linkMode1 = "لم يتم العثور على الحساب";
  final String screens_linkMode2 = "هذا الحساب لا يسمح بالمتابعة السريعة";
  final String screens_linkMode3 = "أنتم متابعون";
  final String screens_linkMode4 = "لم نجد هذا النادي";
  final String screens_linkMode5 = "هذا النادي لا يسمح بالانضمام السريع";
  final String screens_linkMode6 = "أنتم مشاركين";
  final String screens_linkMode7 = 'السماح للمتابعة السريعة';
  final String screens_linkMode8 = 'البحث عن حسابات';
  final String screens_linkMode9 = 'البحث عن نوادي';
  final String screens_requests = 'طلبات';
  final String screens_linkNotifs = 'متابعين جدد';
  final String screens_links = 'متابعين';
  final String screens_login1 =
      'من خلال تسجيل الدخول الى منصة لينكسبيك فانكم توافقون بموجب هذا على دعم ';
  final String screens_login2 = 'الشروط و الارشادات';
  final String screens_login3 = ' المنصوص عليها و الموافقة على ';
  final String screens_login4 = 'سياسة الخصوصية ';
  final String screens_login5 = 'الخاصة بنا ';
  final String screens_login6 = 'لدي حساب';
  final String screens_login7 = 'هل تواجهون المشاكل عند تسجيل الدخول؟';
  final String screens_login8 = 'انشاء حساب';
  final String screens_login9 = 'الدخول';
  final String screens_mentions = 'مذكورات';
  final String screens_messagesTab1 = 'حذف المحادثة';
  final String screens_messagesTab2 = 'هل أنت متأكد';
  final String screens_messagesTab3 = "بحث المحادثات";
  final String screens_messagesTab4 = 'لم نجد محادثات';
  final String screens_myJoined1 = "لم تنضم الى أي نادي بعد";
  final String screens_myJoined2 = 'بحث النوادي';
  final String screens_note1 = 'نص';
  final String screens_note2 = 'ملاحظة';
  final String screens_note3 = 'اتمام';
  final String screens_note4 = 'لا يمكن للملاحظة أن تكون فارغة';
  final String screens_note5 = 'لا يمكن للنص ان يكون فارغ';
  final String screens_note6 = 'الملاحظات يجب الا تتخطى 200 حرف';
  final String screens_note7 = 'النص يجب الا يتخطى 1000 حرف';
  final String screens_notifications1 = 'حذف الاشعارات';
  final String screens_notifications2 = 'اشعارات';
  final String screens_notifications3 = 'حذف جميع الاشعارات';
  final String screens_notifications4 = 'ليس هناك أيّ اشعارات';
  final String screens_notifications5 = 'اعجابات';
  final String screens_notifications6 = 'مذكورات';
  final String screens_notifications7 = 'متابعين جدد';
  final String screens_notifications8 = 'طلبات متابعة';
  final String screens_notifications9 = 'متابعات';
  final String screens_notifications10 = 'تعليقات';
  final String screens_notifications11 = 'ردود';
  final String screens_notifications12 = 'تعليقات محذوفة';
  final String screens_notifications13 = 'منشورات محذوفة';
  final String screens_notifications14 = 'ردود محذوفة';
  final String screens_alertSettings1 = 'اعدادات الاشعارات';
  final String screens_alertSettings2 = 'أبلغوني عندما';
  final String screens_alertSettings3 = "أحد يذكرني";
  final String screens_alertSettings4 = 'أحصل على متابعين جدد';
  final String screens_alertSettings5 = 'منشوري يحصل على اعجاب';
  final String screens_alertSettings6 = 'الفلير الخاصة بي تحصل على اعجاب';
  final String screens_alertSettings7 = 'تعليقي يحصل على رد';
  final String screens_alertSettings8 = 'منشوري يحصل على تعليق';
  final String screens_alertSettings9 = 'الفلير الخاصة بي تحصل على تعليق';
  final String screens_alertSettings10 = 'شخص يوافق على طلبي للمتابعة';
  final String screens_otherClubs1 = 'نوادي';
  final String screens_otherClubs2 = "المستخد لم ينضم الى أي نادي";
  final String screens_otherClubs3 = 'بحث النوادي';
  final String screens_profile = 'المزيد';
  final String screens_pickAddress1 = 'جار التحميل';
  final String screens_pickAddress2 = 'أماكن';
  final String screens_pickAddress3 = "بحث";
  final String screens_pickAddress4 = 'موقعكم غير مشغل';
  final String screens_pickAddress5 = 'شغّل';
  final String screens_postCommentHistory = 'تعليقات المنشورات';
  final String screens_postCommentReplyHistory = 'ردود تعليقات المنشورات';
  final String screens_commentNotifs = 'تعليقات';
  final String screens_likesNotif = 'اعجابات';
  final String screens_post1 = 'المنشور ليس متوفر';
  final String screens_post2 = 'هذا المنشور ممكن أن يكون قد حذف';
  final String screens_privacy = 'سياسة الخصوصية';
  final String screens_replyHistory1 = 'ردودي';
  final String screens_replyHistory2 = 'ردود تعليقات المنشورات';
  final String screens_replyHistory3 = 'ردود تعليقات الفليرز';
  final String screens_scanner1 = 'لم يعثر على المستخدم';
  final String screens_scanner2 = 'لم يعثر على النادي';
  final String screens_searchScreen1 = 'مسح';
  final String screens_searchScreen2 = 'ابحث لينكسبيك';
  final String screens_searchScreen3 = 'البحث عن أشخاص';
  final String screens_searchScreen4 = 'البحث عن أماكن';
  final String screens_searchScreen5 = 'البحث عن مواضيع';
  final String screens_searchScreen6 = 'البحث عن نوادي';
  final String screens_settings1 = 'خروج';
  final String screens_settings2 = 'يتم الخروج';
  final String screens_settings3 = 'الاعدادات';
  final String screens_settings4 = 'المظهر';
  final String screens_settings5 = 'مفضلات';
  final String screens_settings6 = 'متابعة سريعة';
  final String screens_settings7 = 'ردودي';
  final String screens_settings8 = 'مركز النوادي';
  final String screens_settings9 = 'تعليقاتي';
  final String screens_settings10 = 'فليرز أعجبتكم';
  final String screens_settings11 = 'مشاهدات الفليرز';
  final String screens_settings12 = 'اعدادات الاشعارات';
  final String screens_settings13 = 'ادارة الحساب';
  final String screens_settings14 = "منشورات أعجبتكم";
  final String screens_settings15 = 'الشروط و الارشادات';
  final String screens_settings16 = 'سياسة الخصوصية';
  final String screens_settings17 = 'الشأن';
  final String screens_settings18 = 'تبديل حساب';
  final String screens_settings19 = 'الخروج';
  final String screens_splash1 =
      'من خلال تسجيل الدخول الى منصة لينكسبيك فانكم توافقون بموجب هذا على دعم الشروط و الارشادات المنصوص عليها و الموافقة على سياسة الخصوصية الخاصة بنا';
  final String screens_theme1 = 'المظهر';
  final String screens_theme2 = 'اللون الأساسي';
  final String screens_theme3 = 'جاري العمل';
  final String screens_theme4 = 'اللون الثانوي ';
  final String screens_theme5 = 'لون الاعجاب      ';
  final String screens_theme6 = 'زر الاعجاب      ';
  final String screens_theme7 = 'الأصلي';
  final String screens_theme8 = 'قلب';
  final String screens_theme9 = 'ممتاز';
  final String screens_theme10 = 'برق';
  final String screens_theme11 = 'بسمة';
  final String screens_theme12 = 'شمس';
  final String screens_theme13 = 'قمر';
  final String screens_theme14 = 'تشخيص';
  final String screens_theme15 = 'اللغة        ';
  final String screens_theme16 = 'اظهار زر المرساة';
  final String screens_theme17 = 'غطاء على المحتوى الحساس';
  final String screens_theme18 = 'اظهار تشخيصاتي للآخرين';
  final String screens_theme19 = 'مظهر شاشة الدخول      ';
  final String widgets_alerts1 = 'أصبح من متابعيك';
  final String widgets_alerts2 = ' يود أن يتابعك';
  final String widgets_alerts3 = 'قبول';
  final String widgets_alerts4 = 'رفض';
  final String widgets_alerts5 = 'علّق على منشورك';
  final String widgets_alerts6 = 'أعجب بمنشورك';
  final String widgets_alerts7 = 'أنتم الآن تتباعون';
  final String widgets_alerts8 = 'ذكركم في ';
  final String widgets_alerts9 = 'منشور';
  final String widgets_alerts10 = 'تعليق';
  final String widgets_alerts11 = 'رد';
  final String widgets_alerts12 = 'ملخّص';
  final String widgets_alerts13 = 'فلير';
  final String widgets_alerts14 = 'رد على تعليقك';
  final String widgets_auth1 = 'أنتم اللآن تشاركون في ';
  final String widgets_auth2 = 'أنتم الآن تتباعون';
  final String widgets_auth3 = 'تمام';
  final String widgets_auth4 = '* اسم المستخدم مطلوب';
  final String widgets_auth5 = '* اسم المستخدم خطأ';
  final String widgets_auth6 = 'اما اسم المستخدم أو كلمة المرور خطأ';
  final String widgets_auth7 = 'المستخدم محظور';
  final String widgets_auth8 =
      "تم حظر هذا المستخدم حاليا لانتهاكه شروطنا و ارشاداتنا";
  final String widgets_auth9 = 'تأكيد البريد الالكروني';
  final String widgets_auth10 =
      'تم ارسال رابط تأكيد الى البريد الالكتروني الخاص بكم';
  final String widgets_auth11 = 'اسم المستخدم';
  final String widgets_auth12 = '* كلمة المرور مطلوبة';
  final String widgets_auth13 = 'يتم اضافة المستخدم';
  final String widgets_auth14 = 'يتم الدخول';
  final String widgets_auth15 = 'كلمة المرور';
  final String widgets_auth16 = 'تذكر المعلومات';
  final String widgets_auth17 = 'أضف';
  final String widgets_auth18 = 'دخول';
  final String widgets_auth19 = '* كلمات المرور لا تتطابق';
  final String widgets_auth20 = '* العمر مطلوب';
  final String widgets_auth21 = '* العمر خطأ';
  final String widgets_auth22 =
      '* يجب أن يكون عمرك على الأقل 18 عاما لدخول لينكسبيك';
  final String widgets_auth23 = '* الاسم مطلوب';
  final String widgets_auth24 = '* الاسم يجب الا يتجاوز 30 حرف';
  final String widgets_auth25 = '* اسم خطأ';
  final String widgets_auth26 = '* اسم العائلة مطلوب';
  final String widgets_auth27 = '* الاسم يجب الا يتجاوز 30 حرف';
  final String widgets_auth28 = '* اسم خطأ';
  final String widgets_auth29 = '* اسم المستخدم مطلوب';
  final String widgets_auth30 = '* الاسم يجب ان يكون بين 2-30 حرف';
  final String widgets_auth31 = '* الاسم مأخوذ';
  final String widgets_auth32 = '* الاسم خطأ';
  final String widgets_auth33 = 'البريد الالكتروني موجود';
  final String widgets_auth34 = 'هذا البريد الالكتروني سبق و أنشأ حساب';
  final String widgets_auth35 = 'اسم موجود';
  final String widgets_auth36 = 'اسم المستخدم مأخوذ';
  final String widgets_auth37 = "تم ارسال رابط تأكيد الى";
  final String widgets_auth38 = 'أنا أوفق على ';
  final String widgets_auth39 = 'الشروط';
  final String widgets_auth40 = '* البريد الالكتروني مطلوب';
  final String widgets_auth41 = '* البريد الالكتروني خطأ';
  final String widgets_auth42 =
      '* عنوان البريد الالكتروني يجب الا يتخطى 100 حرف';
  final String widgets_auth43 = '* كلمة المرور مطلوبة';
  final String widgets_auth44 = '* كلمة المرور يجب ان تكون بين 7-16 حرف';
  final String widgets_auth45 = '* كلمة المرور يجب ان تكون بين 7-16 حرف';
  final String widgets_auth46 = 'العمر';
  final String widgets_auth47 = 'الاسم';
  final String widgets_auth48 = 'اسم العائلة';
  final String widgets_auth49 = 'ذكر';
  final String widgets_auth50 = 'أنثى';
  final String widgets_auth51 = 'اسم المستخدم';
  final String widgets_auth52 = 'كلمة المرور';
  final String widgets_auth53 = 'تأكيد كلمة المرور';
  final String widgets_auth54 = 'اعادة الارسال';
  final String widgets_auth55 = 'تم ارسال البلاغ';
  final String widgets_auth56 = 'بلاغ';
  final String widgets_auth57 = 'خطاب كراهية أو عنصرية';
  final String widgets_auth58 = 'العنف أو التعنيف';
  final String widgets_auth59 = 'تمجيد الاجرام';
  final String widgets_auth60 = 'محتوى جنسي';
  final String widgets_auth61 = 'محتوى مقزز';
  final String widgets_auth62 = 'كذب أو تضليل';
  final String widgets_auth63 = 'يتضمن قاصر';
  final String widgets_auth64 = 'ارسال';
  final String widgets_auth65 = 'اللغة';
  final String widgets_chat1 = 'الفلير غير متوفرة';
  final String widgets_chat2 = 'محو المحادثة';
  final String widgets_chat3 = 'محو الرسالة';
  final String widgets_chat4 = 'نسخ';
  final String widgets_chat5 = "أنتم محوتم الرسالة";
  final String widgets_chat6 = "تم محو الرسالة";
  final String widgets_chat7 = 'شارك منشور';
  final String widgets_chat8 = 'شارك منشور';
  final String widgets_chat9 = 'رؤية المنشور';
  final String widgets_chat10 = 'رؤية المنشور';
  final String widgets_chat11 = 'هذا المنشور نشر في نادي خاص';
  final String widgets_chat12 = 'هذا المنشور نشر في نادي خفي';
  final String widgets_chat13 = 'صاحب هذا المنشور محظور';
  final String widgets_chat14 = 'أنتم محظورون من رؤية هذا النادي';
  final String widgets_chat15 = 'هذا المنشور نشر في نادي محظور';
  final String widgets_chat16 = 'هذا المنشور نشر في نادي غير فعال';
  final String widgets_chat17 = 'ربما تم حذف هذا المشور';
  final String widgets_chat18 = 'هذا المنشور قد يحتوي على محتوى حساس';
  final String widgets_chat19 = 'رؤية المنشور';
  final String widgets_chat20 = 'هذا المنشور نشر من حساب خاص';
  final String widgets_chat21 = 'هذا المنشور نشر من حساب محظور';
  final String widgets_chat22 = 'ربما تم حذف هذا المشور';
  final String widgets_chat23 = 'رؤية المنشور';
  final String widgets_chat24 = 'تم ارسال الموقع';
  final String widgets_chat25 = 'ارسال الموقع الحالي';
  final String widgets_chat26 = 'يتم الارسال';
  final String widgets_chat27 = 'فشل الارسال';
  final String widgets_chat28 = 'ارسال موقع لآخر';
  final String widgets_chat29 = 'مقطع خطأ';
  final String widgets_chat30 = "المقاطع يجب الا تتجاوز 10 دقائق";
  final String widgets_chat31 = 'تم الارسال';
  final String widgets_chat32 = 'فشل الارسال';
  final String widgets_chat33 = 'تم الارسال';
  final String widgets_chat34 = "اكتب رسالة";
  final String widgets_common1 = 'استخدم الموقع الحالي';
  final String widgets_common2 = 'استخدم موقع لآخر';
  final String widgets_common3 = 'حذف المكان';
  final String widgets_common4 = 'اضافة مكان';
  final String widgets_common5 = 'يتم محو كل شيء';
  final String widgets_common6 = 'الرجاء الانتظار';
  final String widgets_common7 = 'تم النسخ';
  final String widgets_common8 = 'أشخاص';
  final String widgets_common9 = 'نوادي';
  final String widgets_common10 = 'تم حظر الحساب';
  final String widgets_common11 = 'تم رفع الحظر';
  final String widgets_common12 = 'اخفاء';
  final String widgets_common13 = 'حظر';
  final String widgets_common14 = 'حظر';
  final String widgets_common15 = 'رفع الحظر';
  final String widgets_common16 = 'اضافة قائمة المراقبة';
  final String widgets_common17 = 'منع';
  final String widgets_common18 = 'رفع المنع';
  final String widgets_common19 = 'اظهار المعلومات';
  final String widgets_common20 = 'رفع الحظر';
  final String widgets_common21 = 'حذف';
  final String widgets_common22 = 'حذف المنشور';
  final String widgets_common23 = 'حذف';
  final String widgets_common24 = 'تفضيل';
  final String widgets_common25 = 'الأجدد';
  final String widgets_common26 = 'الأفضل';
  final String widgets_common27 = 'تعليقاتي';
  final String widgets_common28 = 'ردودي';
  final String widgets_common29 = 'منشوراتي';
  final String widgets_fullPost1 = 'الرجاء كتابة تعليق';
  final String widgets_fullPost2 = 'يجب على التعليقات الا تتجاوز 1500 حرف';
  final String widgets_fullPost3 = 'أنتم محظورون من المشاركة في هذا النادي';
  final String widgets_fullPost4 = "أنتم محظورون من قبل صاحب المنشور";
  final String widgets_fullPost5 =
      "ليس بامكانكم اضافة اكثر من 30 تعليق خلال ساعة";
  final String widgets_fullPost6 = 'أضف تغليق';
  final String widgets_fullPost7 = 'نشر';
  final String widgets_fullPost8 = 'التعليقات مغلقة من قبل الناشر';
  final String widgets_fullPost9 = 'أكثر';
  final String widgets_fullPost10 = 'أقل';
  final String widgets_fullPost11 = 'هذا التعليق قد يحتوي على محتوى حساس';
  final String widgets_fullPost12 = 'اظهار التعليق';
  final String widgets_fullPost13 = 'بحث';
  final String widgets_fullPost14 = 'لا يوجد محادثات جارية';
  final String widgets_fullPost15 = 'لم يضاف أي موضوع';
  final String widgets_home1 = 'الرئيسية';
  final String widgets_home2 = 'فليرز';
  final String widgets_home3 = 'نشر';
  final String widgets_home4 = 'نوادي';
  final String widgets_home5 = 'محادثات';
  final String widgets_home6 = 'اشعارات';
  final String widgets_home7 = 'توقف';
  final String widgets_home8 = 'سكرولر';
  final String widgets_home9 = 'عكس';
  final String widgets_home10 = 'ابدأ';
  final String widgets_home11 = 'الخروج';
  final String widgets_misc1 = 'فشل تحميل الاعلان';
  final String widgets_misc2 = 'أشخاص';
  final String widgets_misc3 = 'مواضيع';
  final String widgets_misc4 = 'نوادي';
  final String widgets_misc5 = 'أماكن';
  final String widgets_misc6 = 'نوادي مقترحة';
  final String widgets_misc7 = 'حسابات مقترحة';
  final String widgets_places1 = 'لا يوجد منشورات حتى الآن';
  final String widgets_post1 = 'لم يضاف موقع';
  final String widgets_post2 = 'لم يضاف أي موضوع';
  final String widgets_post3 = 'هذا المنشور قد يحتوي على محتوى حساس';
  final String widgets_post4 = 'رؤية المنشور';
  final String widgets_post5 = 'اعجابات  ';
  final String widgets_post6 = 'تعليقات  ';
  final String widgets_post7 = 'مواضيع  ';
  final String widgets_post8 = 'مكان';
  final String widgets_profile1 = 'حذف الحسلب';
  final String widgets_profile2 = 'احذف حسابي';
  final String widgets_profile3 = 'ابطال المتابعة';
  final String widgets_profile4 = 'ابطال الطلب';
  final String widgets_profile5 = 'متابع';
  final String widgets_profile6 = 'تم الطلب';
  final String widgets_profile7 = 'تابع';
  final String widgets_profile8_title = 'متابعات';
  final String widgets_profile9 = 'حسابكم لا يتابع أحد';
  final String widgets_profile10 = 'بحث المتابعات';
  final String widgets_profile11_title = 'متابعين';
  final String widgets_profile12 = 'حسابكم لا يتابعه أحد';
  final String widgets_profile13 = 'بحث المتابعين';
  final String widgets_profile14 = "يجب ألا تتجاوز الصورة حجم 30 ميغا بايت";
  final String widgets_profile15 = 'يتم الحفظ';
  final String widgets_profile16 = 'هذا الحساب لا يتابع أحد';
  final String widgets_profile17 = 'هذا الحساب لا يتابعه أحد';
  final String widgets_profile18 = 'عنوان';
  final String widgets_profile19 = 'رابط';
  final String widgets_profile20 = 'مستخدم';
  final String widgets_profile21 = 'اللافتة محتواها حسّاس';
  final String widgets_profile22 = 'اظهار';
  final String widgets_profile23 = 'ابحث الموضوع';
  final String widgets_profile24 = 'حذف الموضوع';
  final String widgets_profile25 = 'أضف مستخدم موجود';
  final String widgets_profile26 = 'حذف المستخدم';
  final String widgets_profile27 = 'تبديل';
  final String widgets_share1 = 'تم الارسال';
  final String widgets_share2 = 'ارسال';
  final String widgets_share3 = 'شارك';
  final String widgets_share4 = 'لا يوجد محادثات جارية';
  final String wigets_snack1 = 'تم حذف المنشور';
  final String wigets_snack2 = 'تم خفي المنشور';
  final String wigets_snack3 = 'ابطل';
  final String wigets_snack4 = 'تم الحذف';
  final String wigets_snack5 = 'الحساب أصبح ';
  final String wigets_snack6 = 'النادي أصبح ';
  final String widgets_topics1 = 'الرجاء كتابة موضوع';
  final String widgets_topics2 = 'تم اضافة الموضوع سابقا';
  final String widgets_topics3 = 'وصلتم للحد الأقصى من المواضيع';
  final String widgets_topics4 = 'الموضوع يجب أن يكون بين 2-30 حرف';
  final String widgets_topics5 = 'موضوع';
  final String widgets_topics6 = 'اضافة';
  final String general_stamp1 = 'منذ بضع ثواني';
  final String general_stamp2 = 'دقائق';
  final String general_stamp3 = 'دقيقة';
  final String general_stamp4 = 'ساعات';
  final String general_stamp5 = 'ساعة';
  final dynamic assetPickerDelegate = ArabicAssetPickerTextDelegate();
  final dynamic cameraPickerDelegate = ArabicCameraPickerTextDelegate();
  final String privacy = '''
إشعار الخصوصية

آخر تحديث في 5 يوليو 2022

شكرًا لاختيارك أن تكون جزءًا من مجتمعنا في Linkspeak ("الشركة" ، "نحن" ، "نحن" ، "لدينا").
نحن ملتزمون بحماية معلوماتك الشخصية وحقك في الخصوصية.
إذا كانت لديك أي أسئلة أو مخاوف بشأن إشعار الخصوصية هذا ، أو ممارساتنا فيما يتعلق بمعلوماتك الشخصية ، فيرجى الاتصال بنا على linkspeaksupp@gmail.com.
نحن نأخذ خصوصيتك على محمل الجد.
في إشعار الخصوصية هذا ، نسعى إلى أن نشرح لك بأوضح طريقة ممكنة ما هي المعلومات التي نجمعها وكيف نستخدمها وما هي الحقوق التي لديك فيما يتعلق بها.
نأمل أن تأخذ بعض الوقت لقراءتها بعناية ، لأنها مهمة.
إذا كانت هناك أي شروط في إشعار الخصوصية هذا لا توافق عليها ، فيرجى التوقف عن استخدام خدماتنا على الفور.
ينطبق إشعار الخصوصية هذا على جميع المعلومات التي تم جمعها من خلال خدماتنا (والتي ، كما هو موضح أعلاه ، تشمل تطبيقنا) ، وكذلك أي خدمات أو مبيعات أو تسويق أو أحداث ذات صلة.
يرجى قراءة إشعار الخصوصية هذا بعناية لأنه سيساعدك على فهم ما نفعله بالمعلومات التي نجمعها.

جدول المحتويات

1. ما هي المعلومات التي نجمعها؟
2. كيف نستخدم معلوماتك؟
3. هل سيتم تبادل المعلومات الخاصة بك مع أي شخص؟
4. كيف نتعامل مع تسجيلات الدخول الاجتماعية الخاصة بك؟
5. ما هو موقفنا من المواقع الإلكترونية للأطراف الثالثة؟
6. ما هي مدة احتفاظنا بمعلوماتك؟
7. كيف نحافظ على أمان معلوماتك؟
8. هل نجمع المعلومات من القصر؟
9. ما هي حقوق الخصوصية الخاصة بك؟
10. ضوابط ميزات "عدم التعقب"
11. هل يتمتع سكان كاليفورنيا بحقوق خصوصية محددة؟
12. هل نجري تحديثات على هذا الإشعار؟
13. كيف يمكنك الاتصال بنا بخصوص هذا الإشعار؟
14. كيف يمكنك مراجعة أو تحديث أو حذف البيانات التي نجمعها منك؟

1. ما هي المعلومات التي نجمعها؟

باختصار: نحن نجمع المعلومات الشخصية التي تزودنا بها.
نقوم بجمع المعلومات الشخصية التي تقدمها لنا طواعية عندما تقوم بالتسجيل في التطبيق ، أو تعبر عن اهتمامك بالحصول على معلومات عنا أو عن منتجاتنا وخدماتنا ، عندما تشارك في الأنشطة على التطبيق (مثل نشر الرسائل في منتدياتنا عبر الإنترنت أو الدخول في مسابقات أو مسابقات أو هدايا) أو غير ذلك عند الاتصال بنا.

تعتمد المعلومات الشخصية التي نجمعها على سياق تفاعلاتك معنا ومع التطبيق ، والاختيارات التي تقوم بها والمنتجات والميزات التي تستخدمها. قد تتضمن المعلومات الشخصية التي نجمعها ما يلي:

المعلومات الشخصية التي قدمتها.
نقوم بجمع الأسماء ؛
أرقام الهواتف؛
عناوين البريد الإلكتروني؛
أسماء المستخدمين
كلمات السر
وغيرها من المعلومات المماثلة.

بيانات تسجيل الدخول إلى وسائل التواصل الاجتماعي
قد نوفر لك خيار التسجيل معنا باستخدام تفاصيل حساب الوسائط الاجتماعية الحالي الخاص بك ، مثل Facebook أو Twitter أو أي حساب آخر على وسائل التواصل الاجتماعي. إذا اخترت التسجيل بهذه الطريقة ، فسنجمع المعلومات الموضحة في القسم المسمى "كيف نتعامل مع تسجيلاتك الاجتماعية؟" أدناه.
يجب أن تكون جميع المعلومات الشخصية التي تقدمها لنا صحيحة وكاملة ودقيقة ، ويجب عليك إخطارنا بأي تغييرات تطرأ على هذه المعلومات الشخصية.

يتم جمع المعلومات تلقائيًا
باختصار: يتم جمع بعض المعلومات - مثل عنوان بروتوكول الإنترنت (IP) و / أو خصائص المتصفح والجهاز - تلقائيًا عندما تزور تطبيقنا.
نقوم تلقائيًا بجمع معلومات معينة عند زيارة التطبيق أو استخدامه أو التنقل فيه. لا تكشف هذه المعلومات عن هويتك المحددة (مثل اسمك أو معلومات الاتصال) ولكنها قد تتضمن معلومات الجهاز والاستخدام ، مثل عنوان IP الخاص بك وخصائص المتصفح والجهاز ونظام التشغيل وتفضيلات اللغة وعناوين URL المرجعية واسم الجهاز والبلد والموقع ، معلومات حول كيفية ووقت استخدامك للتطبيق والمعلومات التقنية الأخرى. هذه المعلومات ضرورية بشكل أساسي للحفاظ على أمان وتشغيل تطبيقنا ولأغراض التحليلات الداخلية وإعداد التقارير.

تتضمن المعلومات التي نجمعها ما يلي:

بيانات السجل والاستخدام.
بيانات السجل والاستخدام هي معلومات متعلقة بالخدمة والتشخيص والاستخدام والأداء تجمعها خوادمنا تلقائيًا عند الوصول إلى تطبيقنا أو استخدامه والذي نسجله في ملفات السجل. بناءً على كيفية تفاعلك معنا ، قد تتضمن بيانات السجل هذه عنوان IP الخاص بك ومعلومات الجهاز ونوع المتصفح والإعدادات ومعلومات حول نشاطك في التطبيق (مثل طوابع التاريخ / الوقت المرتبطة باستخدامك والصفحات والملفات التي تم عرضها ، عمليات البحث والإجراءات الأخرى التي تتخذها مثل الميزات التي تستخدمها) ومعلومات أحداث الجهاز (مثل نشاط النظام وتقارير الأخطاء (تسمى أحيانًا "تفريغ الأعطال") وإعدادات الأجهزة).

بيانات الجهاز.
نقوم بجمع بيانات الجهاز مثل معلومات حول جهاز الكمبيوتر أو الهاتف أو الجهاز اللوحي أو أي جهاز آخر تستخدمه للوصول إلى التطبيق. اعتمادًا على الجهاز المستخدم ، قد تتضمن بيانات هذا الجهاز معلومات مثل عنوان IP الخاص بك (أو الخادم الوكيل) ، وأرقام تعريف الجهاز والتطبيق ، والموقع ، ونوع المستعرض ، ومزود خدمة الإنترنت لطراز الجهاز و / أو مشغل الهاتف المحمول ، ونظام التشغيل وتكوين النظام معلومة.

بيانات الموقع.
نقوم بجمع بيانات الموقع مثل معلومات حول موقع جهازك ، والتي يمكن أن تكون دقيقة أو غير دقيقة. يعتمد مقدار المعلومات التي نجمعها على نوع وإعدادات الجهاز الذي تستخدمه للوصول إلى التطبيق. على سبيل المثال ، قد نستخدم GPS وتقنيات أخرى لجمع بيانات تحديد الموقع الجغرافي التي تخبرنا عن موقعك الحالي (بناءً على عنوان IP الخاص بك). يمكنك إلغاء الاشتراك في السماح لنا بجمع هذه المعلومات إما عن طريق رفض الوصول إلى المعلومات أو عن طريق تعطيل إعداد الموقع الخاص بك على جهازك. ومع ذلك ، لاحظ أنه إذا اخترت إلغاء الاشتراك ، فقد لا تتمكن من استخدام جوانب معينة من الخدمات.

المعلومات التي تم جمعها من خلال تطبيقنا
باختصار: نقوم بجمع المعلومات المتعلقة بموقعك الجغرافي وبيانات جهازك المحمول وإشعارات الدفع عند استخدام تطبيقنا.

إذا كنت تستخدم تطبيقنا ، فإننا نجمع أيضًا المعلومات التالية:
معلومات تحديد الموقع الجغرافي.
قد نطلب الوصول أو الإذن إلى وتتبع المعلومات المستندة إلى الموقع من جهازك المحمول ، إما بشكل مستمر أو أثناء استخدام تطبيقنا ، لتقديم خدمات معينة قائمة على الموقع. إذا كنت ترغب في تغيير وصولنا أو أذوناتنا ، فيمكنك القيام بذلك في إعدادات جهازك.

الوصول إلى الجهاز المحمول.
قد نطلب الوصول أو الإذن إلى ميزات معينة من جهازك المحمول ، بما في ذلك ميكروفون جهازك المحمول والكاميرا وأجهزة الاستشعار وحسابات الوسائط الاجتماعية والتخزين والتقويم وميزات أخرى. إذا كنت ترغب في تغيير وصولنا أو أذوناتنا ، فيمكنك القيام بذلك في إعدادات جهازك.

بيانات الجهاز المحمول.
نقوم تلقائيًا بجمع معلومات الجهاز (مثل معرف جهازك المحمول والطراز والشركة المصنعة) ونظام التشغيل ومعلومات الإصدار ومعلومات تكوين النظام وأرقام تعريف الجهاز والتطبيق ونوع المتصفح وإصداره ومزود خدمة الإنترنت لطراز الجهاز و / أو شركة الجوال ، وعنوان بروتوكول الإنترنت (IP) (أو الخادم الوكيل). إذا كنت تستخدم تطبيقنا ، فقد نقوم أيضًا بجمع معلومات حول شبكة الهاتف المرتبطة بجهازك المحمول ، ونظام أو نظام تشغيل جهازك المحمول ، ونوع الجهاز المحمول الذي تستخدمه ، ومعرف الجهاز الفريد لجهازك المحمول ، ومعلومات حول ميزات تطبيقنا الذي قمت بالوصول إليه.

دفع الإخطارات.
قد نطلب إرسال إشعارات فورية إليك بخصوص حسابك أو بعض ميزات التطبيق. إذا كنت ترغب في إلغاء الاشتراك من تلقي هذه الأنواع من الاتصالات ، فيمكنك إيقاف تشغيلها في إعدادات جهازك.
هذه المعلومات ضرورية في المقام الأول للحفاظ على أمان وتشغيل تطبيقنا ، لاستكشاف الأخطاء وإصلاحها ولأغراض التحليلات الداخلية وإعداد التقارير.

2. كيف نستخدم معلوماتك؟

باختصار: نقوم بمعالجة معلوماتك لأغراض تستند إلى المصالح التجارية المشروعة ، والوفاء بعقدنا معك ، والامتثال لالتزاماتنا القانونية ، و / أو موافقتك.
نحن نستخدم المعلومات الشخصية التي تم جمعها عبر تطبيقنا لمجموعة متنوعة من الأغراض التجارية الموضحة أدناه. نقوم بمعالجة معلوماتك الشخصية لهذه الأغراض اعتمادًا على مصالحنا التجارية المشروعة ، من أجل إبرام عقد معك أو تنفيذه ، بموافقتك ، و / أو الامتثال لالتزاماتنا القانونية. نشير إلى أسباب المعالجة المحددة التي نعتمد عليها بجانب كل غرض مدرج أدناه.

نستخدم المعلومات التي نجمعها أو نتلقاها:
لتسهيل إنشاء الحساب وعملية تسجيل الدخول.
إذا اخترت ربط حسابك معنا بحساب طرف ثالث (مثل حساب Google أو Facebook الخاص بك) ، فإننا نستخدم المعلومات التي سمحت لنا بجمعها من تلك الأطراف الثالثة لتسهيل إنشاء الحساب وعملية تسجيل الدخول لأداء عقد. انظر القسم أدناه بعنوان "كيف نتعامل مع تسجيلات الدخول الاجتماعية الخاصة بك؟" لمزيد من المعلومات.

لنشر الشهادات.
ننشر شهادات على تطبيقنا قد تحتوي على معلومات شخصية. قبل نشر الشهادة ، سنحصل على موافقتك على استخدام اسمك ومحتوى الشهادة. إذا كنت ترغب في تحديث شهادتك أو حذفها ، فيرجى الاتصال بنا على linkspeaksupp@gmail.com وتأكد من تضمين اسمك وموقع الشهادة ومعلومات الاتصال الخاصة بك.

طلب ملاحظات.
قد نستخدم معلوماتك لطلب التعليقات وللاتصال بك بشأن استخدامك لتطبيقنا.

لتمكين الاتصالات بين المستخدم.
يجوز لنا استخدام معلوماتك لتمكين الاتصالات بين المستخدم والمستخدم بموافقة كل مستخدم.

لإدارة حسابات المستخدمين.
قد نستخدم معلوماتك لأغراض إدارة حسابنا وإبقائه في حالة جيدة.

لإرسال معلومات إدارية لك.
قد نستخدم معلوماتك الشخصية لنرسل لك معلومات عن المنتج والخدمة والميزات الجديدة و / أو معلومات حول التغييرات التي تطرأ على الشروط والأحكام والسياسات الخاصة بنا.

لحماية خدماتنا.
قد نستخدم معلوماتك كجزء من جهودنا للحفاظ على تطبيقنا آمنًا (على سبيل المثال ، لمراقبة ومنع الاحتيال).

لفرض شروطنا وشروطنا وسياساتنا لأغراض العمل ، للامتثال للمتطلبات القانونية والتنظيمية أو فيما يتعلق بعقدنا.

للرد على الطلبات القانونية ومنع الضرر.
إذا تلقينا أمر استدعاء أو طلبًا قانونيًا آخر ، فقد نحتاج إلى فحص البيانات التي نحتفظ بها لتحديد كيفية الرد.

3. هل سيتم تبادل المعلومات الخاصة بك مع أي شخص؟

باختصار: نحن نشارك المعلومات فقط بموافقتك أو للامتثال للقوانين أو لتزويدك بالخدمات أو لحماية حقوقك أو للوفاء بالتزامات العمل.

قد نعالج أو نشارك بياناتك التي نحتفظ بها بناءً على الأساس القانوني التالي:

موافقة:
قد نعالج بياناتك إذا منحتنا موافقة محددة على استخدام معلوماتك الشخصية لغرض معين.

المصالح المشروعة:
قد نعالج بياناتك عندما تكون ضرورية بشكل معقول لتحقيق مصالحنا التجارية المشروعة.

أداء العقد:
عندما أبرمنا عقدًا معك ، يجوز لنا معالجة معلوماتك الشخصية للوفاء بشروط عقدنا.

الإلتزامات القانونية:
قد نكشف عن معلوماتك عندما يُطلب منا قانونًا القيام بذلك من أجل الامتثال للقانون المعمول به ، أو الطلبات الحكومية ، أو الإجراءات القضائية ، أو أمر المحكمة ، أو الإجراءات القانونية ، مثل الرد على أمر محكمة أو أمر استدعاء (بما في ذلك الرد على ذلك) للسلطات العامة للوفاء بمتطلبات الأمن القومي أو إنفاذ القانون).

الاهتمامات الحيوية:
قد نكشف عن معلوماتك عندما نعتقد أنه من الضروري التحقيق أو منع أو اتخاذ إجراء بشأن الانتهاكات المحتملة لسياساتنا ، أو الاحتيال المشتبه به ، أو المواقف التي تنطوي على تهديدات محتملة لسلامة أي شخص وأنشطة غير قانونية ، أو كدليل في التقاضي الذي نحن متورطون.

وبشكل أكثر تحديدًا ، قد نحتاج إلى معالجة بياناتك أو مشاركة معلوماتك الشخصية في المواقف التالية:

تحويلات الأعمال.
يجوز لنا مشاركة معلوماتك أو نقلها فيما يتعلق أو أثناء المفاوضات بشأن أي اندماج أو بيع أصول الشركة أو تمويل أو الاستحواذ على كل أو جزء من أعمالنا إلى شركة أخرى.

4. كيف نتعامل مع تسجيلات الدخول الاجتماعية الخاصة بك؟

باختصار: إذا اخترت التسجيل أو تسجيل الدخول إلى خدماتنا باستخدام حساب وسائل التواصل الاجتماعي ، فقد نتمكن من الوصول إلى معلومات معينة عنك.
يوفر لك تطبيقنا القدرة على التسجيل وتسجيل الدخول باستخدام تفاصيل حساب وسائل التواصل الاجتماعي الخاصة بطرف ثالث (مثل تسجيلات الدخول على Facebook أو Twitter). عندما تختار القيام بذلك ، سوف نتلقى معلومات ملف تعريف معينة عنك من مزود الوسائط الاجتماعية الخاص بك. قد تختلف معلومات الملف الشخصي التي نتلقاها اعتمادًا على مزود وسائل التواصل الاجتماعي المعني ، ولكنها غالبًا ما تتضمن اسمك وعنوان بريدك الإلكتروني وقائمة أصدقائك وصورة ملفك الشخصي بالإضافة إلى المعلومات الأخرى التي تختار نشرها على منصة التواصل الاجتماعي هذه. سنستخدم المعلومات التي نتلقاها فقط للأغراض الموضحة في إشعار الخصوصية هذا أو التي تم توضيحها لك بطريقة أخرى في التطبيق ذي الصلة. يرجى ملاحظة أننا لا نتحكم ، ولسنا مسؤولين عن ، الاستخدامات الأخرى لمعلوماتك الشخصية بواسطة موفر الوسائط الاجتماعية التابع لجهة خارجية. نوصي بمراجعة إشعار الخصوصية الخاص بهم لفهم كيفية جمعهم لمعلوماتك الشخصية واستخدامها ومشاركتها ، وكيف يمكنك تعيين تفضيلات الخصوصية الخاصة بك على مواقعهم وتطبيقاتهم.

5. ما هو موقفنا من المواقع الإلكترونية للأطراف الثالثة؟

باختصار: نحن لسنا مسؤولين عن سلامة أي معلومات تشاركها مع مزودي الطرف الثالث الذين يعلنون ، ولكن ليسوا تابعين لموقعنا.
قد يحتوي التطبيق على إعلانات من أطراف ثالثة غير تابعة لنا والتي قد ترتبط بمواقع أخرى أو خدمات عبر الإنترنت أو تطبيقات الهاتف المحمول. لا يمكننا ضمان سلامة وخصوصية البيانات التي تقدمها لأي طرف ثالث. لا يغطي إشعار الخصوصية هذا أي بيانات يتم جمعها من قبل جهات خارجية. نحن لسنا مسؤولين عن المحتوى أو ممارسات وسياسات الخصوصية والأمان الخاصة بأي طرف ثالث ، بما في ذلك مواقع الويب أو الخدمات أو التطبيقات الأخرى التي قد تكون مرتبطة بالتطبيق أو منه. يجب عليك مراجعة سياسات هذه الجهات الخارجية والاتصال بها مباشرة للرد على أسئلتك.

6. ما هي مدة احتفاظنا بمعلوماتك؟

باختصار: نحتفظ بمعلوماتك طالما كان ذلك ضروريًا لتحقيق الأغراض الموضحة في إشعار الخصوصية هذا ما لم يقتض القانون خلاف ذلك.
سنحتفظ فقط بمعلوماتك الشخصية طالما كانت ضرورية للأغراض المنصوص عليها في إشعار الخصوصية هذا ، ما لم يكن هناك حاجة إلى فترة احتفاظ أطول أو مسموح بها بموجب القانون (مثل الضرائب أو المحاسبة أو المتطلبات القانونية الأخرى). لن يتطلب أي غرض في هذا الإشعار الاحتفاظ بمعلوماتك الشخصية لمدة تزيد عن ستة (6) أشهر بعد إنهاء حساب المستخدم.
عندما لا يكون لدينا عمل شرعي مستمر لمعالجة معلوماتك الشخصية ، فسنقوم إما بحذف هذه المعلومات أو إخفاء هويتها ، أو إذا لم يكن ذلك ممكنًا (على سبيل المثال ، لأن معلوماتك الشخصية قد تم تخزينها في أرشيفات النسخ الاحتياطي) ، فسنقوم بذلك بأمان قم بتخزين معلوماتك الشخصية وعزلها عن أي معالجة أخرى حتى يصبح الحذف ممكنًا.

7. كيف نحافظ على أمان معلوماتك؟

باختصار: نحن نهدف إلى حماية معلوماتك الشخصية من خلال نظام من التدابير الأمنية التنظيمية والفنية.
لقد قمنا بتنفيذ تدابير أمنية تقنية وتنظيمية مناسبة مصممة لحماية أمن أي معلومات شخصية نقوم بمعالجتها. ومع ذلك ، على الرغم من الضمانات والجهود التي نبذلها لتأمين معلوماتك ، لا يمكن ضمان أن يكون النقل الإلكتروني عبر الإنترنت أو تقنية تخزين المعلومات آمنًا بنسبة 100٪ ، لذلك لا يمكننا أن نعد أو نضمن أن المتسللين أو مجرمي الإنترنت أو غيرهم من الأطراف الثالثة غير المصرح لهم لن يكونوا قادرًا على هزيمة أمننا وجمع معلوماتك أو الوصول إليها أو سرقتها أو تعديلها بشكل غير صحيح. على الرغم من أننا سنبذل قصارى جهدنا لحماية معلوماتك الشخصية ، فإن نقل المعلومات الشخصية من تطبيقنا وإليه يكون على مسؤوليتك الخاصة. يجب عليك الوصول إلى التطبيق فقط في بيئة آمنة.

8. هل نجمع المعلومات من القصر؟

باختصار: نحن لا نجمع بيانات عن قصد من الأطفال دون سن 18 عامًا أو نسوقهم لهم.
نحن لا نطلب عن عمد بيانات من الأطفال دون سن 18 عامًا أو نسوقهم لهم. باستخدام التطبيق ، فإنك تقر بأن عمرك لا يقل عن 18 عامًا أو أنك أحد الوالدين أو الوصي على هذا القاصر وتوافق على استخدام هذا القاصر المعال للتطبيق. إذا علمنا أنه قد تم جمع المعلومات الشخصية من المستخدمين الذين تقل أعمارهم عن 18 عامًا ، فسنقوم بإلغاء تنشيط الحساب واتخاذ الإجراءات المعقولة لحذف هذه البيانات من سجلاتنا على الفور. إذا علمت بأي بيانات قد جمعناها من الأطفال دون سن 18 عامًا ، فيرجى الاتصال بنا على linkspeaksupp@gmail.com.

9. ما هي حقوق الخصوصية الخاصة بك؟

باختصار: في بعض المناطق ، مثل المنطقة الاقتصادية الأوروبية (EEA) والمملكة المتحدة (المملكة المتحدة) ، لديك حقوق تتيح لك الوصول بشكل أكبر إلى معلوماتك الشخصية والتحكم فيها. يمكنك مراجعة أو تغيير أو إنهاء حسابك في أي وقت.
في بعض المناطق (مثل المنطقة الاقتصادية الأوروبية والمملكة المتحدة) ، لديك حقوق معينة بموجب قوانين حماية البيانات المعمول بها. قد تشمل هذه الحق
  (1) لطلب الوصول والحصول على نسخة من معلوماتك الشخصية ،
  (2) لطلب التصحيح أو الحذف ؛
  (3) لتقييد معالجة معلوماتك الشخصية ؛ و
  (4) إن أمكن ، لإمكانية نقل البيانات. في ظروف معينة ، قد يكون لك أيضًا الحق في الاعتراض على معالجة معلوماتك الشخصية.
لتقديم مثل هذا الطلب ، يرجى استخدام تفاصيل الاتصال الواردة أدناه. سننظر في أي طلب ونتصرف بناءً عليه وفقًا لقوانين حماية البيانات المعمول بها.
إذا كنا نعتمد على موافقتك لمعالجة معلوماتك الشخصية ، فيحق لك سحب موافقتك في أي وقت. يرجى ملاحظة أن هذا لن يؤثر على قانونية المعالجة قبل سحبها ، ولن يؤثر على معالجة معلوماتك الشخصية التي تتم بالاعتماد على أسس معالجة قانونية بخلاف الموافقة. إذا كنت مقيمًا في المنطقة الاقتصادية الأوروبية أو المملكة المتحدة وتعتقد أننا نعالج معلوماتك الشخصية بشكل غير قانوني ، فيحق لك أيضًا تقديم شكوى إلى السلطة الإشرافية المحلية لحماية البيانات.

يمكنك العثور على تفاصيل الاتصال الخاصة بهم هنا:
http://ec.europa.eu/justice/data-protection/bodies/authorities/index_en.html.

إذا كنت مقيماً في سويسرا ، فإن تفاصيل الاتصال بهيئات حماية البيانات متاحة هنا:
https://www.edoeb.admin.ch/edoeb/en/home.html.

معلومات الحساب
إذا كنت ترغب في أي وقت في مراجعة أو تغيير المعلومات الموجودة في حسابك أو إنهاء حسابك ، فيمكنك:
قم بتسجيل الدخول إلى إعدادات حسابك وقم بتحديث حساب المستخدم الخاص بك.
اتصل بنا باستخدام معلومات الاتصال المقدمة.
بناءً على طلبك لإنهاء حسابك ، سنقوم بإلغاء تنشيط أو حذف حسابك ومعلوماتك من قواعد البيانات النشطة لدينا. ومع ذلك ، قد نحتفظ ببعض المعلومات في ملفاتنا لمنع الاحتيال واستكشاف المشكلات وإصلاحها والمساعدة في أي تحقيقات وفرض شروط الاستخدام و / أو الامتثال للمتطلبات القانونية المعمول بها.

الانسحاب من التسويق عبر البريد الإلكتروني:
يمكنك إلغاء الاشتراك من قائمة البريد الإلكتروني التسويقي الخاصة بنا في أي وقت من خلال النقر على رابط إلغاء الاشتراك في رسائل البريد الإلكتروني التي نرسلها أو عن طريق الاتصال بنا باستخدام التفاصيل الواردة أدناه. ستتم إزالتك بعد ذلك من قائمة البريد الإلكتروني التسويقي - ومع ذلك ، قد لا نزال نتواصل معك ، على سبيل المثال لإرسال رسائل البريد الإلكتروني المتعلقة بالخدمة والضرورية لإدارة حسابك واستخدامه ، أو للرد على طلبات الخدمة ، أو لأغراض أخرى أغراض غير تسويقية. لإلغاء الاشتراك بطريقة أخرى ، يمكنك:
الوصول إلى إعدادات حسابك وتحديث تفضيلاتك.

10. ضوابط ميزات "عدم التعقب"

تتضمن معظم متصفحات الويب وبعض أنظمة تشغيل الأجهزة المحمولة وتطبيقات الهاتف المحمول ميزة Do-Not-Track ("DNT") أو الإعداد الذي يمكنك تنشيطه للإشارة إلى تفضيل الخصوصية لديك بحيث لا تتم مراقبة وجمع بيانات حول أنشطة التصفح عبر الإنترنت الخاصة بك. في هذه المرحلة ، لم يتم الانتهاء من أي معيار تقني موحد للتعرف على إشارات DNT وتنفيذها. على هذا النحو ، نحن لا نستجيب حاليًا لإشارات مستعرض DNT أو أي آلية أخرى تقوم تلقائيًا بإبلاغ اختيارك بعدم التعقب عبر الإنترنت.
إذا تم اعتماد معيار للتتبع عبر الإنترنت يجب علينا اتباعه في المستقبل ، فسنبلغك بهذه الممارسة في نسخة منقحة من إشعار الخصوصية هذا.

11. هل يتمتع سكان كاليفورنيا بحقوق خصوصية محددة؟

باختصار: نعم ، إذا كنت مقيمًا في كاليفورنيا ، يتم منحك حقوقًا محددة فيما يتعلق بالوصول إلى معلوماتك الشخصية.
يسمح القسم 1798.83 من القانون المدني لولاية كاليفورنيا ، والمعروف أيضًا باسم قانون "Shine The Light" ، لمستخدمينا المقيمين في كاليفورنيا بطلب معلومات منا والحصول عليها ، مرة واحدة سنويًا مجانًا ، حول فئات المعلومات الشخصية (إن وجدت). تم الكشف عنها لأطراف ثالثة لأغراض التسويق المباشر وأسماء وعناوين جميع الأطراف الثالثة التي شاركنا معها المعلومات الشخصية في السنة التقويمية السابقة مباشرة. إذا كنت مقيمًا في كاليفورنيا وترغب في تقديم مثل هذا الطلب ، فيرجى إرسال طلبك كتابيًا إلينا باستخدام معلومات الاتصال الواردة أدناه.
إذا كان عمرك أقل من 18 عامًا ، وتقيم في كاليفورنيا ، ولديك حساب مسجل في التطبيق ، فيحق لك طلب إزالة البيانات غير المرغوب فيها التي تنشرها علنًا على التطبيق. لطلب إزالة هذه البيانات ، يرجى الاتصال بنا باستخدام معلومات الاتصال الواردة أدناه ، وتضمين عنوان البريد الإلكتروني المرتبط بحسابك وبيان أنك تقيم في كاليفورنيا. سوف نتأكد من عدم عرض البيانات علنًا على التطبيق ، ولكن يرجى الانتباه إلى أنه قد لا تتم إزالة البيانات بشكل كامل أو شامل من جميع أنظمتنا (مثل النسخ الاحتياطية ، وما إلى ذلك). مقيم "بصفته:
(1) كل فرد موجود في ولاية كاليفورنيا لغير الأغراض المؤقتة أو المؤقتة و
(2) كل فرد مقيم في ولاية كاليفورنيا وموجود خارج ولاية كاليفورنيا لغرض مؤقت أو مؤقت.
يتم تعريف جميع الأفراد الآخرين على أنهم "غير مقيمين". إذا كان تعريف "مقيم" ينطبق عليك ، فيجب علينا الالتزام بحقوق والتزامات معينة فيما يتعلق بمعلوماتك الشخصية.

ما هي فئات المعلومات الشخصية التي نجمعها؟

لقد جمعنا الفئات التالية من المعلومات الشخصية في الاثني عشر (12) شهرًا الماضية:

تم تجميع أمثلة الفئات

أ. المعرفات
تفاصيل الاتصال ، مثل الاسم الحقيقي والاسم المستعار والعنوان البريدي ورقم الهاتف أو الهاتف المحمول والمعرف الشخصي الفريد والمعرف عبر الإنترنت وعنوان بروتوكول الإنترنت وعنوان البريد الإلكتروني واسم الحساب

ب. فئات المعلومات الشخصية المدرجة في قانون سجلات العملاء في كاليفورنيا
الاسم ومعلومات الاتصال والتعليم والعمل والتاريخ الوظيفي والمعلومات المالية

ج- خصائص التصنيف المحمية بموجب قانون كاليفورنيا أو القانون الفيدرالي
الجنس وتاريخ الميلاد

د- المعلومات التجارية
معلومات المعاملات وسجل الشراء والتفاصيل المالية ومعلومات الدفع

هاء المعلومات البيومترية
بصمات الأصابع والبصمات الصوتية

و. الإنترنت أو نشاط شبكة آخر مشابه
محفوظات الاستعراض وسجل البحث والسلوك عبر الإنترنت وبيانات الاهتمام والتفاعلات مع مواقع الويب والتطبيقات والأنظمة والإعلانات الخاصة بنا وغيرها

بيانات تحديد الموقع الجغرافي
موقع الجهاز

ح. معلومات صوتية أو إلكترونية أو بصرية أو حرارية أو شمية أو ما شابه ذلك
الصور وتسجيلات الصوت والفيديو أو المكالمات التي تم إنشاؤها فيما يتعلق بأنشطة أعمالنا

1. المعلومات المهنية أو المتعلقة بالعمل
تفاصيل الاتصال بالعمل من أجل تقديم خدماتنا لك على مستوى الأعمال والمسمى الوظيفي وكذلك تاريخ العمل والمؤهلات المهنية إذا تقدمت بطلب للحصول على وظيفة معنا

J. معلومات التعليم
سجلات الطلاب ومعلومات الدليل

K. الاستنتاجات المستمدة من المعلومات الشخصية الأخرى
الاستنتاجات المستمدة من أي من المعلومات الشخصية المجمعة المدرجة أعلاه لإنشاء ملف شخصي أو ملخص حول ، على سبيل المثال ، تفضيلات الفرد وخصائصه

قد نقوم أيضًا بجمع معلومات شخصية أخرى خارج حالات هذه الفئات حيث تتفاعل معنا شخصيًا أو عبر الإنترنت أو عبر الهاتف أو البريد في سياق:
تلقي المساعدة من خلال قنوات دعم العملاء لدينا ؛
المشاركة في استبيانات العملاء أو المسابقات ؛ و
تسهيل تقديم خدماتنا والرد على استفساراتك.

كيف نستخدم معلوماتك الشخصية ونشاركها؟

يمكن العثور على مزيد من المعلومات حول ممارسات جمع البيانات ومشاركتها في إشعار الخصوصية هذا.
يمكنك الاتصال بنا عبر البريد الإلكتروني على linkspeaksupp@gmail.com ، أو بالرجوع إلى تفاصيل الاتصال في أسفل هذا المستند.
إذا كنت تستخدم وكيلًا معتمدًا لممارسة حقك في إلغاء الاشتراك ، فقد نرفض طلبًا إذا لم يقدم الوكيل المعتمد دليلًا على أنه قد تم تفويضه بشكل صحيح للتصرف نيابة عنك.

هل سيتم مشاركة معلوماتك مع أي شخص آخر؟

يجوز لنا الكشف عن معلوماتك الشخصية مع مزودي الخدمة لدينا بموجب عقد مكتوب بيننا وبين كل مقدم خدمة. كل مقدم خدمة هو كيان ربحي يعالج المعلومات نيابة عنا.
قد نستخدم معلوماتك الشخصية لأغراض تجارية خاصة بنا ، مثل إجراء بحث داخلي للتطوير التكنولوجي والعرض. لا يعتبر هذا بمثابة "بيع" لبياناتك الشخصية.
لم تكشف Linkspeak أو تبيع أي معلومات شخصية لأطراف ثالثة لغرض تجاري أو تجاري في الأشهر الـ 12 السابقة. لن تبيع Linkspeak معلومات شخصية في المستقبل تخص زوار الموقع والمستخدمين والمستهلكين الآخرين.

حقوقك فيما يتعلق ببياناتك الشخصية

الحق في طلب حذف البيانات - طلب الحذف
يمكنك طلب حذف معلوماتك الشخصية. إذا طلبت منا حذف معلوماتك الشخصية ، فسنحترم طلبك ونحذف معلوماتك الشخصية ، مع مراعاة بعض الاستثناءات التي ينص عليها القانون ، مثل (على سبيل المثال لا الحصر) ممارسة مستهلك آخر لحقه في حرية التعبير. ، متطلبات الامتثال الخاصة بنا الناتجة عن التزام قانوني أو أي معالجة قد تكون مطلوبة للحماية من الأنشطة غير القانونية.

الحق في الحصول على المعلومات - طلب المعرفة
حسب الظروف ، لديك الحق في معرفة:
ما إذا كنا نجمع معلوماتك الشخصية ونستخدمها ؛
فئات المعلومات الشخصية التي نجمعها ؛
الأغراض التي من أجلها يتم استخدام المعلومات الشخصية التي تم جمعها ؛
ما إذا كنا نبيع معلوماتك الشخصية لأطراف ثالثة ؛
فئات المعلومات الشخصية التي قمنا ببيعها أو الكشف عنها لغرض تجاري ؛
فئات الأطراف الثالثة التي تم بيع المعلومات الشخصية لها أو الكشف عنها لغرض تجاري ؛ و
الغرض التجاري أو التجاري لجمع المعلومات الشخصية أو بيعها.
وفقًا للقانون المعمول به ، لسنا ملزمين بتقديم أو حذف معلومات المستهلك التي تم إلغاء تحديد هويتها استجابة لطلب المستهلك أو إعادة تحديد البيانات الفردية للتحقق من طلب المستهلك.

الحق في عدم التمييز لممارسة حقوق الخصوصية للمستهلك
لن نميز ضدك إذا مارست حقوق الخصوصية الخاصة بك.

عملية التحقق
عند تلقي طلبك ، سنحتاج إلى التحقق من هويتك لتحديد أنك نفس الشخص الذي لدينا معلومات عنه في نظامنا. تتطلب منا جهود التحقق هذه أن نطلب منك تقديم معلومات حتى نتمكن من مطابقتها مع المعلومات التي قدمتها لنا مسبقًا. على سبيل المثال ، بناءً على نوع الطلب الذي ترسله ، قد نطلب منك تقديم معلومات معينة حتى نتمكن من مطابقة المعلومات التي تقدمها مع المعلومات الموجودة لدينا بالفعل في الملف ، أو قد نتصل بك من خلال وسيلة اتصال (مثل الهاتف أو البريد الإلكتروني) الذي قدمته إلينا مسبقًا. يجوز لنا أيضًا استخدام طرق تحقق أخرى حسب ما تمليه الظروف.
سنستخدم فقط المعلومات الشخصية المقدمة في طلبك للتحقق من هويتك أو سلطتك لتقديم الطلب. إلى أقصى حد ممكن ، سوف نتجنب طلب معلومات إضافية منك لأغراض التحقق. ومع ذلك ، إذا لم نتمكن من التحقق من هويتك من المعلومات التي نحتفظ بها بالفعل ، فقد نطلب منك تقديم معلومات إضافية لأغراض التحقق من هويتك ولأغراض الأمان أو منع الاحتيال.
سنحذف هذه المعلومات المقدمة بالإضافة إلى ذلك بمجرد أن ننتهي من التحقق منك.

حقوق الخصوصية الأخرى
قد تعترض على معالجة بياناتك الشخصية
يمكنك طلب تصحيح بياناتك الشخصية إذا كانت غير صحيحة أو لم تعد ذات صلة ، أو تطلب تقييد معالجة البيانات
يمكنك تعيين وكيل معتمد لتقديم طلب بموجب قانون خصوصية المستهلك في كاليفورنيا (CCPA) نيابة عنك. قد نرفض طلبًا من وكيل معتمد لا يقدم دليلاً على أنه قد تم تفويضه بشكل صحيح للتصرف نيابةً عنك وفقًا لقانون حماية خصوصية المستهلك (CCPA).
يمكنك طلب الانسحاب من البيع المستقبلي لمعلوماتك الشخصية لأطراف ثالثة. عند تلقي طلب الانسحاب ، سنتصرف بناءً على الطلب في أقرب وقت ممكن ، ولكن في موعد لا يتجاوز 15 يومًا من تاريخ تقديم الطلب.
لممارسة هذه الحقوق ، يمكنك الاتصال بنا عبر البريد الإلكتروني على linkspeaksupp@gmail.com ، أو بالرجوع إلى تفاصيل الاتصال في أسفل هذا المستند.
إذا كانت لديك شكوى حول كيفية تعاملنا مع بياناتك ، فنحن نود أن نسمع منك.

12. هل نجري تحديثات على هذا الإشعار؟

باختصار: نعم ، سنقوم بتحديث هذا الإشعار حسب الضرورة للبقاء ملتزمًا بالقوانين ذات الصلة.
قد نقوم بتحديث إشعار الخصوصية هذا من وقت لآخر.
ستتم الإشارة إلى الإصدار المحدّث من خلال تاريخ محدّث "منقّح" وستصبح النسخة المحدّثة سارية حالما يمكن الوصول إليها.
إذا أجرينا تغييرات جوهرية على إشعار الخصوصية هذا ، فقد نخطرك إما عن طريق نشر إشعار واضح بهذه التغييرات أو بإرسال إشعار إليك مباشرةً.
نحن نشجعك على مراجعة إشعار الخصوصية هذا بشكل متكرر لتكون على علم بكيفية حماية معلوماتك.

13. كيف يمكنك الاتصال بنا بخصوص هذا الإشعار؟

إذا كان لديك أي أسئلة أو تعليقات أخرى ، يمكنك الاتصال بنا على عنوان البريد الإلكتروني التالي linkspeaksupp@gmail.com.

14. كيف يمكنك مراجعة أو تحديث أو حذف البيانات التي نجمعها منك؟

استنادًا إلى القوانين المعمول بها في بلدك ، قد يكون لك الحق في طلب الوصول إلى المعلومات الشخصية التي نجمعها منك أو تغيير تلك المعلومات أو حذفها في بعض الظروف.
''';
  final String terms = '''
تعليمات الاستخدام

تم التحديث الأخير في 01 سبتمبر 2021

الموافقة على الشروط

تشكل شروط الاستخدام هذه اتفاقية ملزمة قانونًا بينك ، سواء شخصيًا أو نيابة عن كيان ("أنت") و Linkspeak ("الشركة" أو "نحن" أو "نحن" أو "خاصتنا") ، فيما يتعلق بوصولك إلى موقع Linkspeak الإلكتروني واستخدامه بالإضافة إلى أي نموذج وسائط آخر أو قناة وسائط أو موقع ويب للجوال أو تطبيق جوال مرتبط به أو مرتبط به أو متصل به بطريقة أخرى (يُشار إليها إجمالاً باسم "Linkspeak").
أنت توافق على أنه من خلال الوصول إلى Linkspeak ، تكون قد قرأت وفهمت ووافقت على الالتزام بجميع شروط الاستخدام هذه.

إذا كنت لا توافق على جميع شروط الاستخدام هذه ، فأنت ممنوع صراحةً من استخدام Linkspeak ويجب عليك التوقف عن استخدامه فورًا.

الشروط والأحكام التكميلية أو المستندات التي قد يتم نشرها على Linkspeak من وقت لآخر مدرجة بموجب هذا صراحةً هنا بالإشارة إليها.
نحتفظ بالحق ، وفقًا لتقديرنا الخاص ، في إجراء تغييرات أو تعديلات على شروط الاستخدام هذه في أي وقت ولأي سبب.
سننبهك بأي تغييرات عن طريق تحديث تاريخ "آخر تحديث" لشروط الاستخدام هذه ، وأنت تتنازل عن أي حق في تلقي إشعار محدد لكل تغيير من هذا القبيل.
تقع على عاتقك مسؤولية مراجعة شروط الاستخدام هذه بشكل دوري للبقاء على اطلاع على التحديثات.
ستخضع ، وسيتم اعتبار أنك قد علمت وقبلت ، التغييرات في أي شروط استخدام معدلة من خلال استمرار استخدامك لـ Linkspeak بعد تاريخ نشر شروط الاستخدام المعدلة هذه.
المعلومات المقدمة على Linkspeak ليست مخصصة للتوزيع أو الاستخدام من قبل أي شخص أو كيان في أي ولاية قضائية أو دولة يكون فيها هذا التوزيع أو الاستخدام مخالفًا للقانون أو اللوائح أو من شأنه إخضاعنا لأي شرط تسجيل داخل هذه الولاية القضائية أو الدولة.
وبناءً على ذلك ، فإن هؤلاء الأشخاص الذين يختارون الوصول إلى Linkspeak من مواقع أخرى يفعلون ذلك بمبادرتهم الخاصة وهم وحدهم المسؤولون عن الامتثال للقوانين المحلية ، إذا كانت القوانين المحلية قابلة للتطبيق وإلى الحد الأقصى.
Linkspeak مخصص للمستخدمين الذين لا تقل أعمارهم عن 18 عامًا.
لا يُسمح للأشخاص الذين تقل أعمارهم عن 18 عامًا باستخدام أو التسجيل في Linkspeak.

حقوق الملكية الفكرية

ما لم يُذكر خلاف ذلك ، فإن Linkspeak هي ملكنا
الممتلكات وجميع التعليمات البرمجية المصدر ، وقواعد البيانات ، والوظائف ، والبرمجيات ، والموقع الإلكتروني
التصاميم والصوت والفيديو والنصوص والصور الفوتوغرافية والرسومات على Linkspeak
(يُشار إليها إجمالاً باسم "المحتوى") والعلامات التجارية وعلامات الخدمة والشعارات
الواردة فيه ("العلامات") مملوكة أو خاضعة لسيطرتنا أو مرخصة لنا
لنا ، ومحمية بموجب قوانين حقوق النشر والعلامات التجارية ومختلف أنواع أخرى
حقوق الملكية الفكرية وقوانين المنافسة غير العادلة للولايات المتحدة ، وقوانين حقوق النشر الدولية ، والاتفاقيات الدولية.
يتم توفير المحتوى والعلامات على Linkspeak "كما هي" لمعلوماتك واستخدامك الشخصي فقط.
باستثناء ما هو منصوص عليه صراحةً في شروط الاستخدام هذه ، لا يجوز نسخ أي جزء من Linkspeak ولا محتوى أو علامات أو إعادة إنتاجها أو
مجمعة ، معاد نشرها ، محملة ، منشورة ، معروضة علانية ، مشفرة ،
مترجمة أو نقلها أو توزيعها أو بيعها أو ترخيصها أو استغلالها بأي شكل آخر
لأي غرض تجاري على الإطلاق ، دون كتابة صريحة مسبقة منا
الإذن.
شريطة أن تكون مؤهلاً لاستخدام Linkspeak ، يتم منحك ترخيصًا محدودًا للوصول إلى Linkspeak واستخدامه وتنزيل أو طباعة ملف
نسخة من أي جزء من المحتوى حصلت عليه بشكل صحيح
فقط لاستخدامك الشخصي غير التجاري. نحن نحتفظ بجميع الحقوق لا
الممنوحة لك صراحةً في و Linkspeak والمحتوى والعلامات.

إقرارات المستخدم

باستخدام Linkspeak ، فإنك تقر وتضمن ما يلي:
(1) ستكون جميع معلومات التسجيل التي ترسلها صحيحة ودقيقة وحديثة وكاملة ؛
(2) ستحافظ على دقة هذه المعلومات وتقوم بتحديث معلومات التسجيل على الفور حسب الضرورة ؛
(3) لديك الأهلية القانونية وتوافق على الامتثال لشروط الاستخدام هذه ؛
(4) لست قاصرًا في الولاية القضائية التي تقيم فيها ؛
(5) لن تتمكن من الوصول إلى Linkspeak من خلال وسائل آلية أو غير بشرية ، سواء من خلال روبوت أو برنامج نصي أو غير ذلك ؛
(6) لن تستخدم Linkspeak لأي غرض غير قانوني أو غير مصرح به ؛ و
(7) لن ينتهك استخدامك لـ Linkspeak أي قانون أو لائحة معمول بها ، إذا قدمت أي معلومات غير صحيحة أو غير دقيقة أو غير حديثة أو غير كاملة ، فيحق لنا تعليق حسابك أو إنهائه ورفض أي وجميع المعلومات الحالية أو الحالية الاستخدام المستقبلي لـ Linkspeak (أو أي جزء منه). 

تسجيل المستخدم

قد يُطلب منك التسجيل في Linkspeak.
أنت توافق على الحفاظ على سرية كلمة المرور الخاصة بك وستكون مسؤولاً عن جميع استخدامات حسابك وكلمة المرور الخاصة بك.
نحتفظ بالحق في إزالة أو استرداد أو تغيير اسم المستخدم الذي تحدده إذا قررنا ، وفقًا لتقديرنا الخاص ، أن اسم المستخدم هذا غير مناسب أو فاحش أو مرفوض بأي شكل آخر.

الأنشطة المحظورة

لا يجوز لك الوصول إلى Linkspeak أو استخدامه لأي غرض بخلاف ذلك الذي نوفر Linkspeak من أجله.
لا يجوز استخدام Linkspeak فيما يتعلق بأي مساع تجارية باستثناء تلك التي تم اعتمادها أو الموافقة عليها بشكل خاص من قبلنا.
بصفتك مستخدمًا لبرنامج Linkspeak ، فإنك توافق على عدم القيام بما يلي:
1. استرداد البيانات أو المحتوى الآخر بشكل منهجي من Linkspeak لإنشاء أو تجميع ، بشكل مباشر أو غير مباشر ، مجموعة أو تجميع أو قاعدة بيانات أو دليل دون إذن كتابي منا.
2. خداع أو خداع أو تضليلنا نحن والمستخدمين الآخرين ، خاصة في أي محاولة لمعرفة معلومات الحساب الحساسة مثل كلمات مرور المستخدم.
3. التحايل على ميزات Linkspeak المتعلقة بالأمان أو تعطيلها أو التدخل فيها بطريقة أخرى ، بما في ذلك الميزات التي تمنع أو تقيد استخدام أو نسخ أي محتوى أو تفرض قيودًا على استخدام Linkspeak و / أو المحتوى المتضمن فيه.
4. الاستخفاف أو التشويه أو الإضرار بطريقة أخرى ، في رأينا ، نحن و / أو Linkspeak.
5. استخدام أي معلومات تم الحصول عليها من Linkspeak من أجل مضايقة شخص آخر أو الإساءة إليه أو إلحاق الضرر به.
6. استخدام غير لائق لخدمات الدعم الخاصة بنا أو إرسال تقارير كاذبة عن سوء السلوك أو سوء السلوك.
7. استخدم Linkspeak بطريقة لا تتوافق مع أي قوانين أو لوائح معمول بها.
8. تحميل أو نقل (أو محاولة تحميل أو نقل) فيروسات أو أحصنة طروادة أو مواد أخرى ، بما في ذلك الاستخدام المفرط للأحرف الكبيرة والبريد العشوائي (النشر المستمر للنص المتكرر) ، والذي يتعارض مع استخدام أي طرف وتمتعه بلا انقطاع بـ Linkspeak أو يعدل أو يضعف أو يعطل أو يغير أو يتداخل مع استخدام أو ميزات أو وظائف أو تشغيل أو صيانة Linkspeak.
9. الانخراط في أي استخدام آلي للنظام ، مثل استخدام البرامج النصية لإرسال التعليقات أو الرسائل ، أو استخدام أي استخراج للبيانات ، أو الروبوتات ، أو أدوات مماثلة لجمع البيانات واستخراجها.
10. حذف حقوق الطبع والنشر أو إشعار حقوق الملكية الأخرى من أي محتوى.
11. تحميل أو إرسال (أو محاولة تحميل أو نقل) أي مادة تعمل كآلية لجمع أو نقل المعلومات السلبية أو النشطة ، بما في ذلك على سبيل المثال لا الحصر ، تنسيقات تبادل الرسومات الواضحة ("gifs") ، 1 × 1 بكسل ، أخطاء الويب أو ملفات تعريف الارتباط أو غيرها من الأجهزة المماثلة (يشار إليها أحيانًا باسم "برامج التجسس" أو "آليات التجميع السلبي" أو "pcms").
12. التدخل في أو تعطيل أو إنشاء عبء لا داعي له على Linkspeak أو الشبكات أو الخدمات المتصلة بـ Linkspeak.
13. مضايقة أو مضايقة أو تخويف أو تهديد أي من موظفينا أو وكلائنا المشاركين في تقديم أي جزء من Linkspeak إليك.
14. محاولة تجاوز أي إجراءات خاصة بـ Linkspeak مصممة لمنع أو تقييد الوصول إلى Linkspeak أو أي جزء من Linkspeak.
15. انسخ أو عدِّل برنامج Linkspeak ، بما في ذلك على سبيل المثال لا الحصر Flash أو PHP أو HTML أو JavaScript أو أي تعليمات برمجية أخرى.
16. فك أو فك أو فك أو عكس هندسة أي من البرامج المكونة أو التي تشكل جزءًا من Linkspeak بأي شكل من الأشكال.
17. باستثناء ما قد يكون نتيجة استخدام محرك البحث القياسي أو مستعرض الإنترنت ، استخدم أو تشغيل أو تطوير أو توزيع أي نظام آلي ، بما في ذلك على سبيل المثال لا الحصر ، أي عنكبوت ، أو روبوت ، أو أداة الغش ، أو مكشطة ، أو قارئ غير متصل بالإنترنت يصل إلى Linkspeak ، أو استخدام أو تشغيل أي برنامج نصي أو برنامج آخر غير مصرح به.
18. استخدم وكيل شراء أو وكيل شراء لإجراء عمليات شراء على Linkspeak.
19. قم بأي استخدام غير مصرح به لـ Linkspeak ، بما في ذلك جمع أسماء المستخدمين و / أو عناوين البريد الإلكتروني للمستخدمين بالوسائل الإلكترونية أو غيرها من الوسائل لغرض إرسال بريد إلكتروني غير مرغوب فيه ، أو إنشاء حسابات مستخدمين بوسائل آلية أو تحت ذرائع كاذبة.
20. استخدم Linkspeak كجزء من أي جهد للتنافس معنا أو استخدام Linkspeak و / أو المحتوى لأي مسعى مدر للدخل أو مؤسسة تجارية.

المساهمات التي يولدها المستخدم

قد يدعوك Linkspeak للدردشة أو المساهمة في أو المشاركة في المدونات ولوحات الرسائل والمنتديات عبر الإنترنت وغيرها من الوظائف ، وقد يوفر لك الفرصة لإنشاء أو إرسال أو نشر أو عرض أو نقل أو أداء أو نشر أو توزيع أو بث المحتوى والمواد إلينا أو على Linkspeak ، بما في ذلك على سبيل المثال لا الحصر النصوص أو الكتابات أو الفيديو أو الصوت أو الصور الفوتوغرافية أو الرسومات أو التعليقات أو الاقتراحات أو المعلومات الشخصية أو المواد الأخرى (يشار إليها مجتمعة باسم "المساهمات").
قد تكون المساهمات قابلة للعرض من قبل مستخدمي Linkspeak الآخرين ومن خلال مواقع الويب الخاصة بالأطراف الثالثة.
على هذا النحو ، قد يتم التعامل مع أي مساهمات ترسلها على أنها غير سرية وغير مملوكة.
عندما تنشئ أي مساهمات أو تتيحها ، فإنك بذلك تقر وتضمن ما يلي:
1. لا ينتهك إنشاء مساهماتك أو توزيعها أو نقلها أو عرضها للجمهور أو أدائها والوصول إليها أو تنزيلها أو نسخها حقوق الملكية ، بما في ذلك على سبيل المثال لا الحصر حقوق الطبع والنشر أو براءات الاختراع أو العلامة التجارية أو الأسرار التجارية ، أو الحقوق المعنوية لأي طرف ثالث.
2. أنت منشئ ومالك أو لديك التراخيص والحقوق والموافقات والإصدارات والأذونات اللازمة لاستخدامها وتفويضها لنا و Linkspeak والمستخدمين الآخرين لـ Linkspeak باستخدام مساهماتك بأي طريقة تتوخاها Linkspeak وهذه الشروط من الاستخدام.
3. لديك موافقة كتابية و / أو تصريح و / أو إذن من كل فرد يمكن التعرف عليه في مساهماتك لاستخدام اسم أو شكل كل فرد يمكن التعرف عليه لتمكين إدراج واستخدام مساهماتك بأي طريقة متوقعة بواسطة Linkspeak وشروط الاستخدام هذه.
4. مساهماتك ليست خاطئة أو غير دقيقة أو مضللة.
5. مساهماتك ليست إعلانات غير مرغوب فيها أو غير مصرح بها ، أو مواد ترويجية ، أو مخططات هرمية ، أو رسائل متسلسلة ، أو بريد عشوائي ، أو رسائل بريدية جماعية ، أو أشكال أخرى من الالتماس.
6. مساهماتك ليست فاحشة ، بذيئة ، فاسقة ، قذرة ، عنيفة ، مضايقة ، تشهيرية ، افترائية ، أو مرفوضة بأي شكل آخر (على النحو الذي حددناه).
7. مساهماتك لا تسخر أو تسخر أو تحط من قدر أو تخيف أو تسيء إلى أي شخص.
8. لا تُستخدم مساهماتك لمضايقة أو تهديد (بالمعنى القانوني لتلك المصطلحات) أي شخص آخر وللترويج للعنف ضد شخص معين أو فئة معينة من الناس.
9. لا تنتهك مساهماتك أي قانون أو لائحة أو قاعدة معمول بها.
10. لا تنتهك مساهماتك الخصوصية أو حقوق الدعاية لأي طرف ثالث.
11. لا تحتوي مساهماتك على أي مواد تطلب معلومات شخصية من أي شخص يقل عمره عن 18 عامًا أو تستغل الأشخاص الذين تقل أعمارهم عن 18 عامًا بطريقة جنسية أو عنيفة.
12. لا تنتهك مساهماتك أي قانون معمول به يتعلق باستغلال الأطفال في المواد الإباحية ، أو يقصد بها حماية صحة أو رفاهية القاصرين.
13. لا تتضمن مساهماتك أي تعليقات مسيئة مرتبطة بالعرق أو الأصل القومي أو الجنس أو الميول الجنسية أو الإعاقة الجسدية.
14. لا تنتهك مساهماتك أو ترتبط بمواد تنتهك أي حكم من شروط الاستخدام هذه أو أي قانون أو لائحة معمول بها. أي استخدام لـ Linkspeak ينتهك ما سبق ينتهك شروط الاستخدام هذه وقد يؤدي إلى من بين أمور أخرى ، إنهاء أو تعليق حقوقك في استخدام Linkspeak.

رخصة المساهمة

من خلال نشر مساهماتك في أي جزء من Linkspeak أو إتاحة الوصول إلى المساهمات إلى Linkspeak من خلال ربط حسابك من Linkspeak بأي من حسابات الشبكات الاجتماعية الخاصة بك ، فإنك تمنح تلقائيًا وتقر وتضمن أن لديك الحق في منحنا حقًا غير مقيد. ، غير محدود ، غير قابل للإلغاء ، دائم ، غير حصري ، قابل للتحويل ، بدون حقوق ملكية ، مدفوع بالكامل ، حق عالمي ، وترخيص لاستضافة ، استخدام ، نسخ ، إعادة إنتاج ، إفشاء ، بيع ، إعادة بيع ، نشر ، بث ، إعادة تسمية ، أرشيف ، تخزين ، وذاكرة التخزين المؤقت ، والأداء العام ، والعرض العام ، وإعادة التهيئة ، والترجمة ، والإرسال ، والمقتطفات (كليًا أو جزئيًا) ، وتوزيع هذه المساهمات (بما في ذلك ، على سبيل المثال لا الحصر ، صورتك وصوتك) لأي غرض ، تجاري ، إعلاني ، أو غير ذلك ، ولإعداد أعمال مشتقة من هذه المساهمات أو دمجها في أعمال أخرى ، ومنح التراخيص الفرعية السابقة والتصريح بها.
قد يتم الاستخدام والتوزيع بأي تنسيقات وسائط وعبر أي قنوات وسائط.
سينطبق هذا الترخيص على أي شكل أو وسائط أو تقنية معروفة الآن أو مطورة فيما بعد ، ويتضمن استخدامنا لاسمك واسم الشركة واسم الامتياز ، حسب الاقتضاء ، وأي من العلامات التجارية وعلامات الخدمة والأسماء التجارية والشعارات ، والصور الشخصية والتجارية التي تقدمها.
أنت تتنازل عن جميع الحقوق المعنوية في مساهماتك ، وتضمن أن الحقوق المعنوية لم يتم التأكيد عليها بطريقة أخرى في مساهماتك.
نحن لا نؤكد أي ملكية على مساهماتك.
تحتفظ بالملكية الكاملة لجميع مساهماتك وأي حقوق ملكية فكرية أو حقوق ملكية أخرى مرتبطة بمساهماتك.
نحن لسنا مسؤولين عن أي بيانات أو إقرارات في مساهماتك التي قدمتها في أي منطقة على Linkspeak.
أنت وحدك المسؤول عن مساهماتك في Linkspeak وتوافق صراحة على إعفائنا من أي وجميع المسؤولية والامتناع عن أي إجراء قانوني ضدنا فيما يتعلق بمساهماتك.
لدينا الحق ، وفقًا لتقديرنا المطلق ،
(1) لتحرير أو تنقيح أو تغيير أي مساهمات ؛
(2) لإعادة تصنيف أي مساهمات لوضعها في مواقع أكثر ملاءمة على Linkspeak ؛ و
(3) للفرز المسبق أو حذف أي مساهمات في أي وقت ولأي سبب ، دون سابق إنذار. ليس لدينا أي التزام بمراقبة مساهماتك. 

ترخيص تطبيقات الهاتف المتحرك

ترخيص الاستخدام

إذا قمت بالوصول إلى ملف
الموقع عبر تطبيق الهاتف المحمول ، فنحن نمنحك إذنًا قابلاً للإلغاء وغير حصري ،
حق محدود وغير قابل للتحويل لتثبيت واستخدام تطبيق الهاتف المحمول على
الأجهزة الإلكترونية اللاسلكية التي تملكها أو تتحكم فيها ، والوصول إليها واستخدامها
تطبيق الهاتف المحمول على هذه الأجهزة بدقة وفقًا للشروط
وشروط ترخيص تطبيق الهاتف المحمول هذا الواردة في شروط الاستخدام هذه.
لا يجب عليك:
(1) فك ، هندسة عكسية ، تفكيك ، محاولة اشتقاق
الكود المصدري للتطبيق أو فك تشفيره ؛
(2) إجراء أي تعديل ،
التكيف أو التحسين أو التحسين أو الترجمة أو العمل المشتق من
تطبيق؛
(3) تنتهك أي قوانين أو قواعد أو لوائح معمول بها في
الاتصال بوصولك إلى التطبيق أو استخدامه ؛
(4) إزالة أو تغيير أو
إخفاء أي إشعار ملكية (بما في ذلك أي إشعار بحقوق النشر أو العلامة التجارية)
تم نشره من قبلنا أو من قبل المرخصين للتطبيق ؛
(5) استخدام التطبيق ل
أي مسعى مدر للدخل أو مؤسسة تجارية أو أي غرض آخر
التي لم يتم تصميمها أو النية ؛
(6) اجعل التطبيق متاحًا عبر أ
شبكة أو بيئة أخرى تسمح بالوصول أو الاستخدام بواسطة أجهزة متعددة أو
المستخدمين في نفس الوقت ؛
(7) استخدم التطبيق لإنشاء منتج ،
الخدمة أو البرامج المنافسة بشكل مباشر أو غير مباشر معها أو فيها
بأي شكل من الأشكال بديلا للتطبيق ؛
(8) استخدام التطبيق للإرسال
استعلامات آلية إلى أي موقع ويب أو لإرسال أي بريد إلكتروني تجاري غير مرغوب فيه ؛
أو
(9) استخدام أي معلومات ملكية أو أي من واجهاتنا أو واجهاتنا الأخرى
الملكية الفكرية في التصميم أو التطوير أو التصنيع أو الترخيص أو
توزيع أي تطبيقات أو ملحقات أو أجهزة للاستخدام مع
تطبيق.

أجهزة آبل وأندرويد
تنطبق الشروط التالية عند استخدام تطبيق الهاتف المحمول الذي تم الحصول عليه من متجر Apple أو Google Play (يُشار إلى كل منهما باسم "موزع تطبيقات") للوصول إلى Linkspeak:
(1) يقتصر الترخيص الممنوح لك لتطبيق الهاتف المحمول الخاص بنا على ترخيص غير قابل للتحويل لاستخدام التطبيق على جهاز يستخدم أنظمة تشغيل Apple iOS أو Android ، حسب الاقتضاء ، ووفقًا لقواعد الاستخدام المنصوص عليها في شروط خدمة موزع التطبيق المعمول بها ؛
(2) نحن مسؤولون عن تقديم أي خدمات صيانة ودعم فيما يتعلق بتطبيق الهاتف المحمول كما هو محدد في شروط وأحكام ترخيص تطبيق الهاتف المحمول هذا الوارد في شروط الاستخدام هذه أو كما هو مطلوب بموجب القانون المعمول به ، وأنت تقر بأن كل لا يلتزم موزع التطبيقات على الإطلاق بتقديم أي خدمات صيانة ودعم فيما يتعلق بتطبيق الهاتف المحمول ؛
(3) في حالة فشل تطبيق الهاتف المحمول في الامتثال لأي ضمان معمول به ، يجوز لك إخطار موزع التطبيقات المعمول به ، ويجوز لموزع التطبيقات ، وفقًا لشروطه وسياساته ، إعادة سعر الشراء ، إن وجد ، مدفوعة مقابل تطبيق الهاتف المحمول ، وإلى أقصى حد يسمح به القانون المعمول به ، لن يكون لدى موزع التطبيقات أي التزام ضمان آخر على الإطلاق فيما يتعلق بتطبيق الهاتف المحمول ؛
(4) أنت تقر وتضمن ذلك
  (1) لم تكن مقيمًا في بلد خاضع لحظر حكومي أمريكي ، أو بلد صنفته حكومة الولايات المتحدة على أنه بلد "داعم للإرهاب" و
  (2) أنك غير مدرج في أي قائمة حكومية أمريكية للأطراف المحظورة أو المحظورة ؛
(5) يجب عليك الامتثال لشروط اتفاقية الطرف الثالث السارية عند استخدام تطبيق الهاتف المحمول ، على سبيل المثال ، إذا كان لديك تطبيق VoIP ، فيجب ألا تنتهك اتفاقية خدمة البيانات اللاسلكية الخاصة بهم عند استخدام تطبيق الهاتف المحمول ؛ و
(6) أنت تقر وتوافق على أن موزعي التطبيقات هم طرف ثالث مستفيد من البنود والشروط الواردة في ترخيص تطبيق الهاتف المحمول هذا الوارد في شروط الاستخدام هذه ، وأن كل موزع تطبيقات سيكون له الحق (وسيعتبر أنه قد تم قبوله) الحق) في فرض الشروط والأحكام الواردة في ترخيص تطبيق الهاتف المحمول هذا الوارد في شروط الاستخدام هذه ضدك بصفتك طرفًا ثالثًا مستفيدًا منها.

وسائل الاعلام الاجتماعية
كجزء من وظيفة Linkspeak ، يمكنك ربط حسابك بحسابات عبر الإنترنت لديك مع مزودي خدمة تابعين لجهات خارجية (كل حساب من هذا القبيل ، "حساب طرف ثالث") إما عن طريق:
(1) تقديم معلومات تسجيل الدخول إلى حساب الطرف الثالث الخاص بك من خلال Linkspeak ؛ أو
(2) السماح لنا بالوصول إلى حساب الطرف الثالث الخاص بك ، كما هو مسموح به بموجب الشروط والأحكام السارية التي تحكم استخدامك لكل حساب طرف ثالث.

أنت تقر وتضمن أنه يحق لك الكشف عن معلومات تسجيل الدخول إلى حساب الطرف الثالث الخاص بك إلينا و / أو منحنا حق الوصول إلى حساب الطرف الثالث الخاص بك ، دون خرقك لأي من الشروط والأحكام التي تحكم استخدامك لما هو معمول به. حساب الطرف الثالث ، وبدون إلزامنا بدفع أي رسوم أو جعلنا خاضعين لأي قيود استخدام يفرضها موفر خدمة الطرف الثالث لحساب الطرف الثالث.
بمنحنا حق الوصول إلى أي حسابات طرف ثالث ، فإنك تدرك ذلك
(1) يجوز لنا الوصول إلى أي محتوى قدمته وتخزينه في حساب الطرف الثالث الخاص بك ("محتوى الشبكة الاجتماعية") ("محتوى الشبكة الاجتماعية") (إن أمكن) بحيث يكون متاحًا على Linkspeak ومن خلاله عبر حساب ، بما في ذلك على سبيل المثال لا الحصر أي قوائم أصدقاء و
(2) يجوز لنا تقديم معلومات إضافية إلى حساب الطرف الثالث الخاص بك واستلامها منه إلى الحد الذي يتم إعلامك فيه عند ربط حسابك بحساب الطرف الثالث.
اعتمادًا على حسابات الطرف الثالث التي تختارها وتخضع لإعدادات الخصوصية التي قمت بتعيينها في حسابات الطرف الثالث ، قد تكون معلومات التعريف الشخصية التي تنشرها على حسابات الأطراف الثالثة الخاصة بك متاحة على حسابك على Linkspeak ومن خلاله.
يرجى ملاحظة أنه في حالة عدم توفر حساب جهة خارجية أو خدمة مرتبطة به أو تم إنهاء وصولنا إلى حساب الطرف الثالث هذا بواسطة مزود خدمة الطرف الثالث ، فقد لا يكون محتوى الشبكة الاجتماعية متاحًا على Linkspeak ومن خلاله.
سيكون لديك القدرة على تعطيل الاتصال بين حسابك على Linkspeak وحسابات الطرف الثالث الخاصة بك في أي وقت. 

يرجى ملاحظة أن علاقتك بمقدمي خدمات الطرف الثالث المرتبطين بحسابات الطرف الثالث الخاصة بك تحكمها فقط الاتفاقية (الاتفاقيات) الخاصة بك مع مقدمي الخدمات من هذا الطرف الثالث.

نحن لا نبذل أي جهد لمراجعة أي محتوى على الشبكة الاجتماعية لأي غرض ، بما في ذلك على سبيل المثال لا الحصر ، الدقة أو الشرعية أو عدم الانتهاك ، ونحن لسنا مسؤولين عن أي محتوى على الشبكة الاجتماعية.
أنت تقر وتوافق على أنه يجوز لنا الوصول إلى دفتر عناوين بريدك الإلكتروني المرتبط بحساب طرف ثالث وقائمة جهات الاتصال الخاصة بك المخزنة على جهازك المحمول أو الكمبيوتر اللوحي الخاص بك فقط لأغراض تحديد وإبلاغك بجهات الاتصال التي سجلت أيضًا لاستخدام Linkspeak.
يمكنك إلغاء تنشيط الاتصال بين Linkspeak وحساب الطرف الثالث الخاص بك عن طريق الاتصال بنا باستخدام معلومات الاتصال أدناه أو من خلال إعدادات حسابك (إن أمكن).
سنحاول حذف أي معلومات مخزنة على خوادمنا تم الحصول عليها من خلال حساب الطرف الثالث هذا ، باستثناء اسم المستخدم وصورة الملف الشخصي التي أصبحت مرتبطة بحسابك.

التقديمات

أنت تقر وتوافق على أن أي أسئلة أو تعليقات أو اقتراحات أو أفكار أو ملاحظات أو غيرها من المعلومات المتعلقة بـ Linkspeak ("عمليات الإرسال") التي تقدمها لنا غير سرية وستصبح ملكنا الوحيد.
سنمتلك الحقوق الحصرية ، بما في ذلك جميع حقوق الملكية الفكرية ، ويحق لنا استخدام ونشر هذه المواد المقدمة لأي غرض قانوني ، تجاري أو غير ذلك ، دون إقرار أو تعويض لك.
أنت تتنازل بموجب هذا عن جميع الحقوق المعنوية لأي من هذه التقديمات ، وتتعهد بموجب هذا بأن أي من هذه التقديمات أصلية معك أو أن لديك الحق في إرسال مثل هذه التقديمات.
أنت توافق على أنه لن يكون هناك أي طعن ضدنا بسبب أي انتهاك مزعوم أو فعلي أو اختلاس لأي حق ملكية في عمليات الإرسال الخاصة بك.

موقع ويب ومحتوى الطرف الثالث

قد يحتوي Linkspeak (أو قد يتم إرسالك عبر Linkspeak) على روابط لمواقع ويب أخرى ("مواقع الطرف الثالث") بالإضافة إلى مقالات وصور فوتوغرافية ونصوص ورسومات وصور وتصميمات وموسيقى وصوت وفيديو ومعلومات وتطبيقات وبرامج ، والمحتويات أو العناصر الأخرى التي تنتمي إلى أطراف ثالثة أو تنشأ منها ("محتوى الطرف الثالث").
لا يتم التحقيق في مواقع الويب الخاصة بالجهات الخارجية ومحتويات الجهات الخارجية أو مراقبتها أو التحقق من دقتها أو ملاءمتها أو اكتمالها من قبلنا ، ونحن لسنا مسؤولين عن أي مواقع ويب لأطراف أخرى يتم الوصول إليها من خلال Linkspeak أو أي محتوى تابع لجهة خارجية يتم نشره على ، متاحة من خلال أو مثبتة من Linkspeak ، بما في ذلك المحتوى أو الدقة أو الإساءة أو الآراء أو الموثوقية أو ممارسات الخصوصية أو السياسات الأخرى الخاصة بمواقع الأطراف الثالثة أو محتوى الطرف الثالث أو المضمنة فيها.
إن تضمين أو ربط أو السماح باستخدام أو تثبيت أي مواقع ويب خاصة بطرف ثالث أو أي محتوى خاص بطرف ثالث لا يعني الموافقة أو المصادقة عليها من قبلنا.
إذا قررت ترك Linkspeak والوصول إلى مواقع الويب الخاصة بالجهات الخارجية أو استخدام أو تثبيت أي محتوى تابع لجهة خارجية ، فإنك تقوم بذلك على مسؤوليتك الخاصة ، ويجب أن تدرك أن شروط الاستخدام هذه لم تعد تحكم.
يجب عليك مراجعة الشروط والسياسات المعمول بها ، بما في ذلك ممارسات الخصوصية وجمع البيانات ، لأي موقع تنتقل إليه من Linkspeak أو فيما يتعلق بأي تطبيقات تستخدمها أو تثبتها من Linkspeak.
ستكون أي عمليات شراء تقوم بها عبر مواقع ويب الأطراف الثالثة من خلال مواقع ويب أخرى ومن شركات أخرى ، ولا نتحمل أي مسؤولية من أي نوع فيما يتعلق بهذه المشتريات التي تكون حصريًا بينك وبين الطرف الثالث المعني.
أنت توافق وتقر بأننا لا نصادق على المنتجات أو الخدمات المقدمة على مواقع الويب الخاصة بأطراف ثالثة ويجب أن تحمينا من أي ضرر ناتج عن شرائك لهذه المنتجات أو الخدمات.
بالإضافة إلى ذلك ، يجب أن تحمينا من أي خسائر تتكبدها أو ضرر يلحق بك فيما يتعلق أو ينتج بأي شكل من الأشكال عن أي محتوى تابع لجهة خارجية أو أي اتصال بمواقع ويب تابعة لجهات خارجية.

المعلنون
نسمح للمعلنين بعرض إعلاناتهم ومعلومات أخرى في مناطق معينة من Linkspeak ، مثل إعلانات الشريط الجانبي أو إعلانات الشعارات.
إذا كنت معلنًا ، فستتحمل المسؤولية الكاملة عن أي إعلانات تضعها على Linkspeak وأي خدمات مقدمة على Linkspeak أو المنتجات المباعة من خلال تلك الإعلانات.
علاوة على ذلك ، بصفتك معلنًا ، فإنك تضمن وتقر بأنك تمتلك جميع الحقوق والسلطات لوضع الإعلانات على Linkspeak ، بما في ذلك ، على سبيل المثال لا الحصر ، حقوق الملكية الفكرية وحقوق الدعاية والحقوق التعاقدية.
نحن ببساطة نوفر مساحة لوضع مثل هذه الإعلانات ، وليس لدينا علاقة أخرى مع المعلنين.

إدارة الموقع

نحن نحتفظ بالحق ، ولكن ليس الالتزام ، في:
(1) مراقبة Linkspeak لانتهاكات
شروط الاستخدام هذه ؛
(2) اتخاذ الإجراءات القانونية المناسبة ضد أي شخص ، في
وفقًا لتقديرنا الخاص ، ينتهك القانون أو شروط الاستخدام هذه ، بما في ذلك بدون
التقييد ، إبلاغ سلطات إنفاذ القانون بهذا المستخدم ؛
(3) في وحيدنا
تقديرية ودون حصر ، رفض ، تقييد الوصول ، تقييد
توفر أو تعطيل (إلى الحد الممكن تقنيًا) أيًا من
مساهماتك أو أي جزء منها ؛
(4) حسب تقديرنا الخاص و
على سبيل المثال لا الحصر ، إشعار ، أو مسؤولية ، لإزالة من Linkspeak أو غير ذلك
تعطيل جميع الملفات والمحتويات الزائدة في الحجم أو بأي شكل من الأشكال
عبئًا على أنظمتنا ؛ و
(5) إدارة Linkspeak بطريقة أخرى
مصممة لحماية حقوقنا وممتلكاتنا وتسهيل المناسب
تشغيل Linkspeak.

المدة والإنهاء

تظل شروط الاستخدام هذه سارية المفعول والتأثير الكامل أثناء استخدام Linkspeak.

بدون تحديد أي حكم آخر من شروط الاستخدام هذه ، نحتفظ بالحق في ، وفقًا لتقديرنا الخاص ودون إشعار أو مسؤولية ،
رفض الوصول إلى Linkspeak واستخدامه (بما في ذلك حظر بعض عناوين IP) ، لأي شخص لأي سبب أو بدون سبب ،
بما في ذلك على سبيل المثال لا الحصر انتهاك أي تمثيل أو ضمان أو تعهد وارد في شروط الاستخدام هذه أو أي قانون أو لائحة معمول بها.
يجوز لنا إنهاء استخدامك أو مشاركتك في Linkspeak أو حذف حسابك وأي محتوى أو معلومات نشرتها في أي وقت ،
دون سابق إنذار ، وفقًا لتقديرنا الخاص.

إذا قمنا بإنهاء حسابك أو تعليقه لأي سبب ، فيُحظر عليك التسجيل و
إنشاء حساب جديد باسمك أو اسم مزيف أو مستعار أو باسم
أي طرف ثالث ، حتى لو كنت تتصرف نيابة عن الطرف الثالث. في
بالإضافة إلى إنهاء حسابك أو تعليقه ، نحتفظ بالحق في
اتخاذ الإجراءات القانونية المناسبة ، بما في ذلك على سبيل المثال لا الحصر الملاحقة المدنية ،
جنائي وزجري.

التعديلات والانقطاعات

نحتفظ بالحق في تغيير أو تعديل أو إزالة محتويات Linkspeak في أي وقت أو لأي سبب وفقًا لتقديرنا الخاص دون إشعار.
ومع ذلك ، فإننا لسنا ملزمين بتحديث أي معلومات على موقعنا.
نحتفظ أيضًا بالحق في تعديل أو إيقاف كل أو جزء من Linkspeak دون إشعار في أي وقت.
لن نكون مسؤولين تجاهك أو تجاه أي طرف ثالث عن أي تعديل أو تغيير في الأسعار أو تعليق أو وقف لـ Linkspeak.
لا يمكننا ضمان توفر Linkspeak في جميع الأوقات. قد نواجه الأجهزة والبرامج
أو مشاكل أخرى أو تحتاج إلى إجراء الصيانة المتعلقة بـ Linkspeak ، الناتجة
في حالات الانقطاع أو التأخير أو الأخطاء. نحن
نحتفظ بالحق في التغيير أو المراجعة أو التحديث أو التعليق أو التوقف أو غير ذلك
تعديل Linkspeak في أي وقت أو لأي سبب دون إخطارك. أنت توافق على أننا لا نتحمل أي مسؤولية
على الإطلاق عن أي خسارة أو ضرر أو إزعاج ناتج عن عدم قدرتك على
الوصول إلى أو استخدام Linkspeak أثناء أي توقف أو توقف لـ Linkspeak. لن يكون أي شيء في شروط الاستخدام هذه
تُفسر على أنها تُلزمنا بالحفاظ على Linkspeak ودعمها أو توفير أي منها
التصحيحات أو التحديثات أو الإصدارات المتعلقة بذلك.

القانون الذي يحكم

تخضع هذه الشروط ويتم تحديدها وفقًا لقوانين المملكة المتحدة.
توافق أنت و Linkspeak بشكل نهائي على أن يكون لمحاكم المملكة المتحدة الاختصاص الحصري لحل أي نزاع قد ينشأ فيما يتعلق بهذه الشروط.

حل النزاع

التحكيم الملزم
يتم تحديد أي نزاع ينشأ عن العلاقات بين طرفي هذا العقد من قبل محكم واحد يتم اختياره وفقًا لقواعد التحكيم والداخلية لمحكمة التحكيم الأوروبية باعتبارها جزءًا من المركز الأوروبي للتحكيم الذي يقع مقره في ستراسبورغ ، والتي كانت سارية وقت تقديم طلب التحكيم ، والتي يعتبر اعتماد هذا البند قبولًا لها.
يجب أن يكون مقر التحكيم لندن ، المملكة المتحدة.
يجب أن تكون لغة الإجراءات هي اللغة الإنجليزية ، أو أي لغة أخرى متفق عليها.
يجب أن تكون قواعد القانون الموضوعي المعمول بها هي قانون المملكة المتحدة.

قيود
يتفق الطرفان على أن أي تحكيم يجب أن يقتصر على النزاع بين الطرفين بشكل فردي.
إلى أقصى حد يسمح به القانون ،
(أ) لا يجوز ضم أي تحكيم إلى أي إجراء آخر ؛
(ب) لا يوجد حق أو سلطة لأي نزاع يتم التحكيم فيه على أساس الدعوى الجماعية أو لاستخدام إجراءات الدعوى الجماعية ؛ و
(ج) لا يوجد حق أو سلطة لأي نزاع يتم تقديمه بصفة تمثيلية مزعومة نيابة عن عامة الناس أو أي أشخاص آخرين.

استثناءات من التحكيم
يتفق الطرفان على أن النزاعات التالية لا تخضع للأحكام المذكورة أعلاه المتعلقة بالتحكيم الملزم:
(أ) أي نزاعات تسعى إلى إنفاذ أو حماية ، أو فيما يتعلق بصلاحية أي من حقوق الملكية الفكرية لأحد الأطراف ؛
(ب) أي نزاع يتعلق أو ينشأ عن مزاعم السرقة أو القرصنة أو التعدي على الخصوصية أو الاستخدام غير المصرح به ؛ و
(ج) أي مطالبة بأمر زجري.
إذا تبين أن هذا البند غير قانوني أو غير قابل للتنفيذ ، فلن يختار أي طرف التحكيم في أي نزاع يقع ضمن هذا الجزء من هذا الحكم الذي يتبين أنه غير قانوني أو غير قابل للتنفيذ ويتم الفصل في هذا النزاع من قبل محكمة ذات اختصاص قضائي داخل المحاكم المدرجة لـ الاختصاص القضائي أعلاه ، ويوافق الطرفان على الخضوع للاختصاص القضائي الشخصي لتلك المحكمة.

التصحيحات

قد يكون هناك
معلومات حول Linkspeak تحتوي على أخطاء مطبعية أو عدم دقة أو
السهو ، بما في ذلك الأوصاف والتسعير والتوافر ومختلف أنواع أخرى
معلومة. نحن نحتفظ بالحق في
تصحيح أي أخطاء أو عدم دقة أو سهو وتغيير أو تحديث
معلومات على Linkspeak في أي وقت ، دون إشعار مسبق.

تنصل

يتم توفير Linkspeak على أساس كما هو ومتوفر. أنت
توافق على أن استخدامك لـ Linkspeak وخدماتنا سيكون على مسؤوليتك وحدك. الى ال
بأقصى حد يسمح به القانون ، نحن نخلي مسؤوليتنا من جميع الضمانات ، الصريحة أو
ضمنيًا ، فيما يتعلق بـ Linkspeak واستخدامك له ، بما في ذلك ، بدون
التقييد والضمانات الضمنية لقابلية التسويق والملاءمة بشكل خاص
الغرض وعدم الانتهاك. نحن لا نقدم أي ضمانات أو إقرارات حول
دقة أو اكتمال محتوى Linkspeak أو محتوى أي
المواقع الإلكترونية المرتبطة بـ Linkspeak ولن نتحمل أي مسؤولية أو مسؤولية
لأي
(1) الأخطاء أو الأخطاء أو عدم دقة المحتوى والمواد ،
(2)
الإصابة الشخصية أو الأضرار بالممتلكات ، من أي طبيعة كانت ، والناجمة عن
وصولك إلى Linkspeak واستخدامه ،
(3) أي وصول أو استخدام غير مصرح به
خوادمنا الآمنة و / أو أي وجميع المعلومات الشخصية و / أو المالية
المعلومات المخزنة فيه ،
(4) أي انقطاع أو توقف للإرسال
إلى أو من Linkspeak ،
(5) أي بق ، فيروسات ، حصان طروادة ، أو ما شابه
قد يتم نقلها إلى أو من خلال Linkspeak من قبل أي طرف ثالث ، و / أو
(6) أي أخطاء أو سهو في أي محتوى أو مواد أو عن أي فقد أو تلف
أي نوع يتم تكبده نتيجة لاستخدام أي محتوى تم نشره أو نقله أو
متاح بخلاف ذلك عبر Linkspeak. نحن لا نضمن ، نصادق ، نضمن ،
أو تحمل المسؤولية عن أي منتج أو خدمة يتم الإعلان عنها أو تقديمها من قبل أ
الطرف الثالث من خلال Linkspeak أو أي موقع ويب متشابك أو أي موقع ويب أو جوال
تطبيق مميز في أي إعلان بانر أو إعلان آخر ، ولن نكون
طرفًا أو بأي شكل من الأشكال يكون مسؤولاً عن مراقبة أي معاملة بينكما
وأي طرف ثالث من مزودي المنتجات أو الخدمات. كما هو الحال مع
شراء منتج أو خدمة من خلال أي وسيط أو في أي بيئة ، أنت
يجب أن تستخدم أفضل حكم لديك وتوخي الحذر حيثما كان ذلك مناسبًا.

حدود المسؤولية
لن نتحمل نحن أو مديرينا أو موظفونا أو وكلائنا بأي حال من الأحوال المسؤولية تجاهك أو تجاه أي طرف ثالث عن أي
الأضرار المباشرة أو غير المباشرة أو التبعية أو النموذجية أو العرضية أو الخاصة أو التأديبية ، بما في ذلك الأرباح المفقودة أو الإيرادات المفقودة أو فقدان البيانات ،
أو أضرار أخرى تنشأ عن استخدامك لـ Linkspeak ،
حتى لو تم إخطارنا بإمكانية حدوث مثل هذه الأضرار.

التعويض

أنت توافق على الدفاع عنا وتعويضنا وحمايتنا من الضرر ، بما في ذلك الشركات التابعة لنا ،
التابعة ، وجميع مسؤولينا ووكلائنا وشركائنا و
الموظفين ، من وضد أي خسارة أو ضرر أو مسؤولية أو مطالبة أو طلب ، بما في ذلك
أتعاب ومصاريف المحاماة المعقولة التي يتحملها أي طرف ثالث بسبب أو
ينبع من:
(1) مساهماتك ؛
(2) استخدام Linkspeak ؛
(3) خرق شروط الاستخدام هذه ؛
(4) أي خرق لإقراراتك وضماناتك المنصوص عليها في شروط الاستخدام هذه ؛
(5) انتهاكك لحقوق طرف ثالث ، بما في ذلك على سبيل المثال لا الحصر حقوق الملكية الفكرية ؛ أو
(6) أي عمل ضار صريح تجاه أي مستخدم آخر لـ Linkspeak اتصلت به عبر Linkspeak. على الرغم مما سبق ذكره ، فإننا نحتفظ بالحق ، على نفقتك الخاصة ، في تولي الدفاع الحصري والتحكم في أي مسألة يُطلب منك تعويضنا عنها ، وتوافق على التعاون ، على نفقتك الخاصة ، مع دفاعنا عن هذه المطالبات.
سنبذل جهودًا معقولة لإعلامك بأي مطالبة أو إجراء أو إجراء يخضع لهذا التعويض بمجرد علمك به.

بيانات المستخدم

سوف نحافظ عليه
بعض البيانات التي ترسلها إلى Linkspeak بغرض إدارة
أداء Linkspeak ، وكذلك البيانات المتعلقة باستخدامك لـ Linkspeak.
على الرغم من أننا نقوم بإجراء نسخ احتياطي روتيني منتظم
من البيانات ، فأنت وحدك المسؤول عن جميع البيانات التي ترسلها أو تلك التي ترسلها
يتعلق بأي نشاط قمت به باستخدام Linkspeak. أنت توافق
أننا لن نتحمل أي مسؤولية تجاهك عن أي خسارة أو فساد من هذا القبيل
البيانات ، وأنت تتنازل بموجب هذا عن أي حق في اتخاذ إجراء ضدنا ناشئ عن أي من هذا القبيل
فقدان أو تلف هذه البيانات.

الاتصالات والمعاملات والتوقيعات الإلكترونية

تشكل زيارة Linkspeak وإرسال رسائل البريد الإلكتروني إلينا واستكمال النماذج عبر الإنترنت اتصالات إلكترونية.
أنت توافق على تلقي الاتصالات الإلكترونية ، وتوافق على أن جميع الاتفاقيات والإشعارات والإفصاحات وغيرها من الاتصالات التي نقدمها لك إلكترونيًا ، عبر البريد الإلكتروني وعلى Linkspeak ، تفي بأي شرط قانوني بأن يكون هذا الاتصال كتابيًا.
أنت توافق بموجب هذا على استخدام التوقيعات الإلكترونية والعقود والأوامر والسجلات الأخرى ، وعلى التسليم الإلكتروني للإشعارات والسياسات وسجلات المعاملات التي بدأناها أو أكملتها الولايات المتحدة أو عبر Linkspeak.
أنت تتنازل بموجب هذا عن أي حقوق أو متطلبات بموجب أي قوانين أو لوائح أو قواعد أو مراسيم أو قوانين أخرى في أي ولاية قضائية تتطلب توقيعًا أصليًا أو تسليم أو الاحتفاظ بسجلات غير إلكترونية ، أو عن المدفوعات أو منح ائتمانات بأي وسيلة أخرى من الوسائل الإلكترونية.

متفرقات

تشكل شروط الاستخدام هذه وأي سياسات أو قواعد تشغيل نشرناها على Linkspeak أو فيما يتعلق بـ Linkspeak الاتفاقية الكاملة والتفاهم بينك وبيننا.
إن إخفاقنا في ممارسة أو إنفاذ أي حق أو حكم من شروط الاستخدام هذه لا يعتبر بمثابة تنازل عن هذا الحق أو الحكم.
تعمل شروط الاستخدام هذه إلى أقصى حد يسمح به القانون.
يجوز لنا التنازل عن أي من حقوقنا والتزاماتنا أو جميعها للآخرين في أي وقت.
لن نكون مسؤولين أو مسؤولين عن أي خسارة أو ضرر أو تأخير أو فشل في التصرف بسبب أي سبب خارج عن سيطرتنا المعقولة.
إذا تم تحديد أي بند أو جزء من شرط من شروط الاستخدام هذه على أنه غير قانوني أو باطل أو غير قابل للتنفيذ ، فإن هذا الحكم أو جزء من الحكم يعتبر قابلاً للفصل عن شروط الاستخدام هذه ولا يؤثر على صلاحية وإمكانية إنفاذ أي بند متبقي الأحكام.
لا يوجد مشروع مشترك أو شراكة أو توظيف أو علاقة وكالة تم إنشاؤها بينك وبيننا نتيجة لشروط الاستخدام هذه أو استخدام Linkspeak.
أنت توافق على أن شروط الاستخدام هذه لن يتم تفسيرها ضدنا بحكم صياغتها.
أنت تتنازل بموجبه عن أي وجميع الدفاعات التي قد تكون لديك بناءً على الشكل الإلكتروني لشروط الاستخدام هذه وعدم توقيع الأطراف بهذه الاتفاقية لتنفيذ شروط الاستخدام هذه.

اتصل بنا
لحل شكوى بخصوص Linkspeak أو لتلقي مزيد من المعلومات بخصوص استخدام Linkspeak ،
يرجى الاتصال بنا على:
linkspeaksupp@gmail.com
''';
}

class ArabicCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const ArabicCameraPickerTextDelegate();

  @override
  String get languageCode => 'ar';

  @override
  String get confirm => 'تأكيد';

  @override
  String get shootingTips => 'اضغط لأخذ صورة';

  @override
  String get shootingWithRecordingTips =>
      'اضغط لأخذ صورة. استمر بالضغط لتسجيل مقطع.';

  @override
  String get shootingOnlyRecordingTips => 'اسنمر بالضغط لتسجيل مقطع.';

  @override
  String get shootingTapRecordingTips => 'اضغط لتسجيل مقطع';

  @override
  String get loadFailed => 'فشل التنزيل';

  @override
  String get loading => 'جاري التنزيل';

  @override
  String get saving => 'جاري التحفيظ...';

  @override
  String get sActionManuallyFocusHint => 'تركيز يدوي';

  @override
  String get sActionPreviewHint => 'لمحة';

  @override
  String get sActionRecordHint => 'سجّل';

  @override
  String get sActionShootHint => 'خذ صورة';

  @override
  String get sActionShootingButtonTooltip => 'زرّ الالتقاط';

  @override
  String get sActionStopRecordingHint => 'وقف التسجيل';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) => value.name;

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return '${sCameraLensDirectionLabel(value)} لمحة الكاميرا';
  }

  @override
  String sFlashModeLabel(FlashMode mode) => 'وضع الفلاش: ${mode.name}';

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) =>
      'تبديل الكاميرا';
}
