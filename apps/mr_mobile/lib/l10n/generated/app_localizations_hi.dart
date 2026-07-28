import 'app_localizations.dart';

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'MediVisit Pro';

  @override
  String get loginTitle => 'वापसी पर स्वागत है';

  @override
  String get loginSubtitle => 'MediVisit Pro में जारी रखने के लिए साइन इन करें';

  @override
  String get emailLabel => 'ईमेल पता';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get loginButton => 'साइन इन करें';

  @override
  String get registerHere => 'खाता नहीं है? यहाँ रजिस्टर करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get registerTitle => 'खाता बनाएं';

  @override
  String get registerSubtitle => 'अपनी विज़िट प्रबंधित करने के लिए MediVisit Pro से जुड़ें';

  @override
  String get nameLabel => 'पूरा नाम';

  @override
  String get phoneLabel => 'फ़ोन नंबर';

  @override
  String get territoryLabel => 'क्षेत्र चुनें';

  @override
  String get registerButton => 'रजिस्टर करें';

  @override
  String get backToLogin => 'पहले से खाता है? साइन इन करें';

  @override
  String get pendingVerificationTitle => 'खाता समीक्षा के अधीन';

  @override
  String get pendingVerificationMessage => 'आपका खाता क्षेत्रीय प्रशासक द्वारा सत्यापन के लिए लंबित है। कृपया बाद में जांचें।';

  @override
  String get contactAdmin => 'सहायता के लिए अपने क्षेत्रीय व्यवस्थापक से संपर्क करें।';

  @override
  String dashboardGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get visitsToday => 'आज की विज़िट';

  @override
  String get attendance => 'उपस्थिति';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get doctorVisits => 'डॉक्टर विज़िट';

  @override
  String get products => 'उत्पाद';

  @override
  String get leaveRequest => 'छुट्टी का अनुरोध';

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get quickLog => 'त्वरित लॉग';

  @override
  String get markDoctorVisit => 'डॉक्टर विज़िट दर्ज करें';

  @override
  String get markAttendance => 'उपस्थिति दर्ज करें';

  @override
  String get requestLeave => 'छुट्टी का अनुरोध करें';

  @override
  String get daySelector => 'दिन चुनें';

  @override
  String get all => 'सभी';

  @override
  String get pending => 'लंबित';

  @override
  String get visited => 'देखा गया';

  @override
  String get markAsVisited => 'विज़िट के रूप में चिह्नित करें';

  @override
  String get confirmVisitLocation => 'विज़िट स्थान की पुष्टि करें';

  @override
  String get confirmVisit => 'विज़िट की पुष्टि करें';

  @override
  String get outOfGeofenceReason => 'जियोफेंस के बाहर होने का कारण';

  @override
  String get visitConfirmed => 'विज़िट की पुष्टि हुई!';

  @override
  String get rateVisit => 'विज़िट को रेट करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get visitHistory => 'विज़िट इतिहास';

  @override
  String get catalog => 'कैटलॉग';

  @override
  String get searchProducts => 'उत्पाद खोजें...';

  @override
  String get inStock => 'स्टॉक में';

  @override
  String get lowStock => 'कम स्टॉक';

  @override
  String get outOfStock => 'स्टॉक से बाहर';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get totalVisits => 'कुल विज़िट';

  @override
  String get avgRating => 'औसत रेटिंग';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get language => 'भाषा';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get save => 'सहेजें';
}
