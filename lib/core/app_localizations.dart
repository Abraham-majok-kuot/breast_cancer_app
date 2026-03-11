import 'package:flutter/material.dart';

// ── Provider widget ────────────────────────────────────────────────────────────
/// Wrap the navigator content (via MaterialApp.builder) with this widget.
/// It provides [AppTranslations] to the entire subtree and sets RTL for Arabic.
class AppLocalizationsProvider extends StatelessWidget {
  final String language;
  final Widget child;

  const AppLocalizationsProvider({
    super.key,
    required this.language,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          language == 'Arabic' ? TextDirection.rtl : TextDirection.ltr,
      child: _AppLocalizationsScope(
        translations: AppTranslations.forLanguage(language),
        child: child,
      ),
    );
  }
}

// ── InheritedWidget ────────────────────────────────────────────────────────────
class _AppLocalizationsScope extends InheritedWidget {
  final AppTranslations translations;

  const _AppLocalizationsScope({
    required this.translations,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AppLocalizationsScope old) =>
      translations.language != old.translations.language;
}

// ── Context extension ─────────────────────────────────────────────────────────
extension AppLocalizationsExt on BuildContext {
  /// Access translations from anywhere: `context.l.settings`
  AppTranslations get l =>
      dependOnInheritedWidgetOfExactType<_AppLocalizationsScope>()
          ?.translations ??
      AppTranslations.forLanguage('English');
}

// ── Translations class ─────────────────────────────────────────────────────────
class AppTranslations {
  final String language;
  final Map<String, String> _m;

  AppTranslations._(this.language, this._m);

  factory AppTranslations.forLanguage(String lang) {
    switch (lang) {
      case 'Swahili':
        return AppTranslations._('Swahili', _sw);
      case 'French':
        return AppTranslations._('French', _fr);
      case 'Arabic':
        return AppTranslations._('Arabic', _ar);
      default:
        return AppTranslations._('English', _en);
    }
  }

  String _g(String key) => _m[key] ?? key;

  // ── Settings ───────────────────────────────────────────────────────────────
  String get settings => _g('settings');
  String get profile => _g('profile');
  String get editProfile => _g('editProfile');
  String get updateNamePhoto => _g('updateNamePhoto');
  String get changePassword => _g('changePassword');
  String get updatePassword => _g('updatePassword');
  String get emailAddress => _g('emailAddress');
  String get notifications => _g('notifications');
  String get pushNotifications => _g('pushNotifications');
  String get receiveHealthReminders => _g('receiveHealthReminders');
  String get selfExamReminders => _g('selfExamReminders');
  String get monthlyAlerts => _g('monthlyAlerts');
  String get reminderFrequency => _g('reminderFrequency');
  String get appearance => _g('appearance');
  String get darkMode => _g('darkMode');
  String get switchDarkTheme => _g('switchDarkTheme');
  String get languageLabel => _g('language');
  String get security => _g('security');
  String get biometricLogin => _g('biometricLogin');
  String get useFingerprint => _g('useFingerprint');
  String get loginActivity => _g('loginActivity');
  String get viewRecentSignIn => _g('viewRecentSignIn');
  String get dataPrivacy => _g('dataPrivacy');
  String get cloudBackup => _g('cloudBackup');
  String get autoSaveData => _g('autoSaveData');
  String get exportMyData => _g('exportMyData');
  String get downloadRecordsPdf => _g('downloadRecordsPdf');
  String get clearCache => _g('clearCache');
  String get freeUpStorage => _g('freeUpStorage');
  String get privacyPolicy => _g('privacyPolicy');
  String get howWeHandleData => _g('howWeHandleData');
  String get about => _g('about');
  String get rateApp => _g('rateApp');
  String get shareFeedback => _g('shareFeedback');
  String get helpSupport => _g('helpSupport');
  String get contactFaqs => _g('contactFaqs');
  String get signOut => _g('signOut');
  String get deleteAccount => _g('deleteAccount');
  String get save => _g('save');
  String get cancel => _g('cancel');
  String get update => _g('update');
  String get selectLanguage => _g('selectLanguage');
  String get fullName => _g('fullName');
  String get newEmail => _g('newEmail');
  String get profileUpdated => _g('profileUpdated');
  String get verificationSent => _g('verificationSent');
  String get daily => _g('daily');
  String get weekly => _g('weekly');
  String get monthly => _g('monthly');

  // ── Register ───────────────────────────────────────────────────────────────
  String get createAccount => _g('createAccount');
  String get joinUs => _g('joinUs');
  String get agreeToTerms => _g('agreeToTerms');
  String get mustAgreeTerms => _g('mustAgreeTerms');
  String get termsOfService => _g('termsOfService');
  String get alreadyHaveAccount => _g('alreadyHaveAccount');
  String get signIn => _g('signIn');
  String get gender => _g('gender');
  String get selectGender => _g('selectGender');
  String get password => _g('password');
  String get confirmPassword => _g('confirmPassword');
  String get atLeast6Chars => _g('atLeast6Chars');

  // ── Result Screen ──────────────────────────────────────────────────────────
  String get yourResults => _g('yourResults');
  String get retake => _g('retake');
  String get home => _g('home');
  String get visitEducationHub => _g('visitEducationHub');
  String get learnMore => _g('learnMore');
  String get lowRisk => _g('lowRisk');
  String get moderateRisk => _g('moderateRisk');
  String get highRisk => _g('highRisk');
  String get riskFactorBreakdown => _g('riskFactorBreakdown');
  String get personalisedRecs => _g('personalisedRecs');

  // ── Education ──────────────────────────────────────────────────────────────
  String get readFullArticle => _g('readFullArticle');
  String get searchArticles => _g('searchArticles');
  String get noArticlesFound => _g('noArticlesFound');

  // ── Dashboard ──────────────────────────────────────────────────────────────
  String get hello => _g('hello');
  String get welcomeBack => _g('welcomeBack');
  String get yourHealthJourney => _g('yourHealthJourney');
  String get earlyAwareness => _g('earlyAwareness');
  String get startAssessment => _g('startAssessment');
  String get quickActions => _g('quickActions');
  String get seeAll => _g('seeAll');
  String get newAssessment => _g('newAssessment');
  String get viewHistory => _g('viewHistory');
  String get educationHub => _g('educationHub');
  String get newsletterUpdates => _g('newsletterUpdates');
  String get privacyData => _g('privacyData');
  String get resetPassword => _g('resetPassword');
  String get healthTips => _g('healthTips');
  String get myHistory => _g('myHistory');
  String get newsletter => _g('newsletter');

  // ── English ────────────────────────────────────────────────────────────────
  static const Map<String, String> _en = {
    'settings': 'Settings',
    'profile': 'Profile',
    'editProfile': 'Edit Profile',
    'updateNamePhoto': 'Update your name and photo',
    'changePassword': 'Change Password',
    'updatePassword': 'Update your account password',
    'emailAddress': 'Email Address',
    'notifications': 'Notifications',
    'pushNotifications': 'Push Notifications',
    'receiveHealthReminders': 'Receive health reminders',
    'selfExamReminders': 'Self-Exam Reminders',
    'monthlyAlerts': 'Monthly check-up alerts',
    'reminderFrequency': 'Reminder Frequency',
    'appearance': 'Appearance',
    'darkMode': 'Dark Mode',
    'switchDarkTheme': 'Switch to dark theme',
    'language': 'Language',
    'security': 'Security',
    'biometricLogin': 'Biometric Login',
    'useFingerprint': 'Use fingerprint to sign in',
    'loginActivity': 'Login Activity',
    'viewRecentSignIn': 'View recent sign-in history',
    'dataPrivacy': 'Data & Privacy',
    'cloudBackup': 'Cloud Backup',
    'autoSaveData': 'Auto-save your assessment data',
    'exportMyData': 'Export My Data',
    'downloadRecordsPdf': 'Download all your records as PDF',
    'clearCache': 'Clear Cache',
    'freeUpStorage': 'Free up storage space',
    'privacyPolicy': 'Privacy Policy',
    'howWeHandleData': 'How we handle your data',
    'about': 'About',
    'rateApp': 'Rate the App',
    'shareFeedback': 'Share your feedback',
    'helpSupport': 'Help & Support',
    'contactFaqs': 'Contact us or read FAQs',
    'signOut': 'Sign Out',
    'deleteAccount': 'Delete Account',
    'save': 'Save',
    'cancel': 'Cancel',
    'update': 'Update',
    'selectLanguage': 'Select Language',
    'fullName': 'Full Name',
    'newEmail': 'New Email',
    'profileUpdated': 'Profile updated!',
    'verificationSent': 'Verification sent to new email',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'hello': 'Hello',
    'welcomeBack': 'Welcome Back!',
    'yourHealthJourney': 'Your Health Journey',
    'earlyAwareness':
        'Early awareness saves lives.\nTake your breast cancer risk assessment today.',
    'startAssessment': 'Start Assessment',
    'quickActions': 'Quick Actions',
    'seeAll': 'See all →',
    'newAssessment': 'New\nAssessment',
    'viewHistory': 'View\nHistory',
    'educationHub': 'Education\nHub',
    'newsletterUpdates': 'Newsletter\n& Updates',
    'privacyData': 'Privacy\n& Data',
    'resetPassword': 'Reset\nPassword',
    'healthTips': 'Health Tips',
    'myHistory': 'My History',
    'newsletter': 'Newsletter',
    // Register
    'createAccount': 'Create Account',
    'joinUs': 'Join us for better health insights',
    'agreeToTerms': 'I agree to the Terms of Service and Privacy Policy',
    'mustAgreeTerms': 'You must agree to the Terms of Service to register',
    'termsOfService': 'Terms of Service',
    'alreadyHaveAccount': 'Already have an account?',
    'signIn': 'Sign In',
    'gender': 'Gender',
    'selectGender': 'Select gender',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'atLeast6Chars': 'At least 6 characters',
    // Result
    'yourResults': 'Your Results',
    'retake': 'Retake',
    'home': 'Home',
    'visitEducationHub': 'Education Hub',
    'learnMore': 'Learn More',
    'lowRisk': 'Low Risk',
    'moderateRisk': 'Moderate Risk',
    'highRisk': 'High Risk',
    'riskFactorBreakdown': 'Risk Factor Breakdown',
    'personalisedRecs': 'Personalised Recommendations',
    // Education
    'readFullArticle': 'Read Full Article',
    'searchArticles': 'Search articles...',
    'noArticlesFound': 'No articles found',
  };

  // ── Swahili ────────────────────────────────────────────────────────────────
  static const Map<String, String> _sw = {
    'settings': 'Mipangilio',
    'profile': 'Wasifu',
    'editProfile': 'Hariri Wasifu',
    'updateNamePhoto': 'Sasisha jina na picha yako',
    'changePassword': 'Badilisha Nywila',
    'updatePassword': 'Sasisha nywila ya akaunti yako',
    'emailAddress': 'Anwani ya Barua Pepe',
    'notifications': 'Arifa',
    'pushNotifications': 'Arifa za Kusukuma',
    'receiveHealthReminders': 'Pokea vikumbusho vya afya',
    'selfExamReminders': 'Vikumbusho vya Kujichunguza',
    'monthlyAlerts': 'Arifa za uchunguzi wa kila mwezi',
    'reminderFrequency': 'Mara kwa mara ya Kikumbusho',
    'appearance': 'Mwonekano',
    'darkMode': 'Hali ya Giza',
    'switchDarkTheme': 'Badili kwenye mandhari ya giza',
    'language': 'Lugha',
    'security': 'Usalama',
    'biometricLogin': 'Kuingia kwa Biometric',
    'useFingerprint': 'Tumia alama ya vidole kuingia',
    'loginActivity': 'Shughuli ya Kuingia',
    'viewRecentSignIn': 'Tazama historia ya kuingia',
    'dataPrivacy': 'Data na Faragha',
    'cloudBackup': 'Hifadhi ya Wingu',
    'autoSaveData': 'Hifadhi kiotomatiki data ya tathmini',
    'exportMyData': 'Hamisha Data Yangu',
    'downloadRecordsPdf': 'Pakua rekodi zako kama PDF',
    'clearCache': 'Futa Cache',
    'freeUpStorage': 'Fungua nafasi ya kuhifadhi',
    'privacyPolicy': 'Sera ya Faragha',
    'howWeHandleData': 'Jinsi tunavyoshughulikia data yako',
    'about': 'Kuhusu',
    'rateApp': 'Kadiria Programu',
    'shareFeedback': 'Shiriki maoni yako',
    'helpSupport': 'Msaada na Usaidizi',
    'contactFaqs': 'Wasiliana nasi au soma Maswali',
    'signOut': 'Toka',
    'deleteAccount': 'Futa Akaunti',
    'save': 'Hifadhi',
    'cancel': 'Ghairi',
    'update': 'Sasisha',
    'selectLanguage': 'Chagua Lugha',
    'fullName': 'Jina Kamili',
    'newEmail': 'Barua Pepe Mpya',
    'profileUpdated': 'Wasifu umesasishwa!',
    'verificationSent': 'Uthibitisho umetumwa kwa barua pepe mpya',
    'daily': 'Kila siku',
    'weekly': 'Kila wiki',
    'monthly': 'Kila mwezi',
    'hello': 'Habari',
    'welcomeBack': 'Karibu Tena!',
    'yourHealthJourney': 'Safari Yako ya Afya',
    'earlyAwareness':
        'Ufahamu wa mapema huokoa maisha.\nFanya tathmini ya hatari ya saratani leo.',
    'startAssessment': 'Anza Tathmini',
    'quickActions': 'Vitendo vya Haraka',
    'seeAll': 'Ona yote →',
    'newAssessment': 'Tathmini\nMpya',
    'viewHistory': 'Tazama\nHistoria',
    'educationHub': 'Kituo cha\nElimu',
    'newsletterUpdates': 'Jarida\n& Taarifa',
    'privacyData': 'Faragha\n& Data',
    'resetPassword': 'Weka Upya\nNywila',
    'healthTips': 'Vidokezo vya Afya',
    'myHistory': 'Historia Yangu',
    'newsletter': 'Jarida',
    'createAccount': 'Fungua Akaunti',
    'joinUs': 'Jiunge nasi kwa maarifa bora ya afya',
    'agreeToTerms': 'Nakubali Masharti ya Huduma na Sera ya Faragha',
    'mustAgreeTerms': 'Lazima ukubali Masharti ya Huduma ili kusajili',
    'termsOfService': 'Masharti ya Huduma',
    'alreadyHaveAccount': 'Una akaunti tayari?',
    'signIn': 'Ingia',
    'gender': 'Jinsia',
    'selectGender': 'Chagua jinsia',
    'password': 'Nywila',
    'confirmPassword': 'Thibitisha Nywila',
    'atLeast6Chars': 'Angalau herufi 6',
    'yourResults': 'Matokeo Yako',
    'retake': 'Rudia',
    'home': 'Nyumbani',
    'visitEducationHub': 'Kituo cha Elimu',
    'learnMore': 'Jifunza Zaidi',
    'lowRisk': 'Hatari Ndogo',
    'moderateRisk': 'Hatari ya Wastani',
    'highRisk': 'Hatari Kubwa',
    'riskFactorBreakdown': 'Uchambuzi wa Mambo ya Hatari',
    'personalisedRecs': 'Mapendekezo Maalum',
    'readFullArticle': 'Soma Makala Kamili',
    'searchArticles': 'Tafuta makala...',
    'noArticlesFound': 'Hakuna makala zilizopatikana',
  };

  // ── French ─────────────────────────────────────────────────────────────────
  static const Map<String, String> _fr = {
    'settings': 'Paramètres',
    'profile': 'Profil',
    'editProfile': 'Modifier le Profil',
    'updateNamePhoto': 'Mettre à jour votre nom et photo',
    'changePassword': 'Changer le Mot de Passe',
    'updatePassword': 'Mettre à jour votre mot de passe',
    'emailAddress': 'Adresse E-mail',
    'notifications': 'Notifications',
    'pushNotifications': 'Notifications Push',
    'receiveHealthReminders': 'Recevoir des rappels de santé',
    'selfExamReminders': 'Rappels d\'Auto-examen',
    'monthlyAlerts': 'Alertes mensuelles de contrôle',
    'reminderFrequency': 'Fréquence de Rappel',
    'appearance': 'Apparence',
    'darkMode': 'Mode Sombre',
    'switchDarkTheme': 'Passer au thème sombre',
    'language': 'Langue',
    'security': 'Sécurité',
    'biometricLogin': 'Connexion Biométrique',
    'useFingerprint': 'Utiliser l\'empreinte digitale',
    'loginActivity': 'Activité de Connexion',
    'viewRecentSignIn': 'Voir l\'historique récent',
    'dataPrivacy': 'Données et Confidentialité',
    'cloudBackup': 'Sauvegarde Cloud',
    'autoSaveData': 'Sauvegarde automatique des données',
    'exportMyData': 'Exporter Mes Données',
    'downloadRecordsPdf': 'Télécharger les enregistrements en PDF',
    'clearCache': 'Vider le Cache',
    'freeUpStorage': 'Libérer de l\'espace',
    'privacyPolicy': 'Politique de Confidentialité',
    'howWeHandleData': 'Comment nous gérons vos données',
    'about': 'À Propos',
    'rateApp': 'Noter l\'Application',
    'shareFeedback': 'Partagez vos commentaires',
    'helpSupport': 'Aide et Support',
    'contactFaqs': 'Contactez-nous ou lisez les FAQ',
    'signOut': 'Se Déconnecter',
    'deleteAccount': 'Supprimer le Compte',
    'save': 'Enregistrer',
    'cancel': 'Annuler',
    'update': 'Mettre à jour',
    'selectLanguage': 'Sélectionner la Langue',
    'fullName': 'Nom Complet',
    'newEmail': 'Nouvel E-mail',
    'profileUpdated': 'Profil mis à jour!',
    'verificationSent': 'Vérification envoyée au nouvel e-mail',
    'daily': 'Quotidien',
    'weekly': 'Hebdomadaire',
    'monthly': 'Mensuel',
    'hello': 'Bonjour',
    'welcomeBack': 'Content de vous revoir!',
    'yourHealthJourney': 'Votre Parcours de Santé',
    'earlyAwareness':
        'La sensibilisation précoce sauve des vies.\nFaites votre évaluation du cancer du sein aujourd\'hui.',
    'startAssessment': 'Commencer l\'Évaluation',
    'quickActions': 'Actions Rapides',
    'seeAll': 'Voir tout →',
    'newAssessment': 'Nouvelle\nÉvaluation',
    'viewHistory': 'Voir\nL\'historique',
    'educationHub': 'Centre\nd\'Éducation',
    'newsletterUpdates': 'Bulletin\n& Mises à jour',
    'privacyData': 'Confidentialité\n& Données',
    'resetPassword': 'Réinitialiser\nMot de Passe',
    'healthTips': 'Conseils Santé',
    'myHistory': 'Mon Historique',
    'newsletter': 'Bulletin',
    'createAccount': 'Créer un Compte',
    'joinUs': 'Rejoignez-nous pour de meilleures informations sur la santé',
    'agreeToTerms': 'J\'accepte les Conditions d\'Utilisation et la Politique de Confidentialité',
    'mustAgreeTerms': 'Vous devez accepter les Conditions d\'Utilisation pour vous inscrire',
    'termsOfService': 'Conditions d\'Utilisation',
    'alreadyHaveAccount': 'Vous avez déjà un compte?',
    'signIn': 'Se Connecter',
    'gender': 'Genre',
    'selectGender': 'Sélectionner le genre',
    'password': 'Mot de Passe',
    'confirmPassword': 'Confirmer le Mot de Passe',
    'atLeast6Chars': 'Au moins 6 caractères',
    'yourResults': 'Vos Résultats',
    'retake': 'Reprendre',
    'home': 'Accueil',
    'visitEducationHub': 'Centre d\'Éducation',
    'learnMore': 'En Savoir Plus',
    'lowRisk': 'Risque Faible',
    'moderateRisk': 'Risque Modéré',
    'highRisk': 'Risque Élevé',
    'riskFactorBreakdown': 'Analyse des Facteurs de Risque',
    'personalisedRecs': 'Recommandations Personnalisées',
    'readFullArticle': 'Lire l\'Article Complet',
    'searchArticles': 'Rechercher des articles...',
    'noArticlesFound': 'Aucun article trouvé',
  };

  // ── Arabic ─────────────────────────────────────────────────────────────────
  static const Map<String, String> _ar = {
    'settings': 'الإعدادات',
    'profile': 'الملف الشخصي',
    'editProfile': 'تعديل الملف الشخصي',
    'updateNamePhoto': 'تحديث اسمك وصورتك',
    'changePassword': 'تغيير كلمة المرور',
    'updatePassword': 'تحديث كلمة مرور حسابك',
    'emailAddress': 'عنوان البريد الإلكتروني',
    'notifications': 'الإشعارات',
    'pushNotifications': 'الإشعارات الفورية',
    'receiveHealthReminders': 'تلقي تذكيرات صحية',
    'selfExamReminders': 'تذكيرات الفحص الذاتي',
    'monthlyAlerts': 'تنبيهات الفحص الشهري',
    'reminderFrequency': 'تكرار التذكير',
    'appearance': 'المظهر',
    'darkMode': 'الوضع الداكن',
    'switchDarkTheme': 'التبديل إلى الوضع الداكن',
    'language': 'اللغة',
    'security': 'الأمان',
    'biometricLogin': 'تسجيل الدخول البيومتري',
    'useFingerprint': 'استخدم بصمة الإصبع للدخول',
    'loginActivity': 'نشاط تسجيل الدخول',
    'viewRecentSignIn': 'عرض سجل تسجيل الدخول',
    'dataPrivacy': 'البيانات والخصوصية',
    'cloudBackup': 'النسخ الاحتياطي السحابي',
    'autoSaveData': 'حفظ بيانات التقييم تلقائياً',
    'exportMyData': 'تصدير بياناتي',
    'downloadRecordsPdf': 'تحميل جميع سجلاتك بصيغة PDF',
    'clearCache': 'مسح ذاكرة التخزين المؤقت',
    'freeUpStorage': 'تحرير مساحة التخزين',
    'privacyPolicy': 'سياسة الخصوصية',
    'howWeHandleData': 'كيف نتعامل مع بياناتك',
    'about': 'حول',
    'rateApp': 'تقييم التطبيق',
    'shareFeedback': 'شارك ملاحظاتك',
    'helpSupport': 'المساعدة والدعم',
    'contactFaqs': 'تواصل معنا أو اقرأ الأسئلة الشائعة',
    'signOut': 'تسجيل الخروج',
    'deleteAccount': 'حذف الحساب',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'update': 'تحديث',
    'selectLanguage': 'اختر اللغة',
    'fullName': 'الاسم الكامل',
    'newEmail': 'البريد الإلكتروني الجديد',
    'profileUpdated': 'تم تحديث الملف الشخصي!',
    'verificationSent': 'تم إرسال التحقق إلى البريد الإلكتروني الجديد',
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
    'hello': 'مرحباً',
    'welcomeBack': 'مرحباً بعودتك!',
    'yourHealthJourney': 'رحلتك الصحية',
    'earlyAwareness':
        'الوعي المبكر ينقذ الأرواح.\nقومي بتقييم مخاطر سرطان الثدي اليوم.',
    'startAssessment': 'ابدأ التقييم',
    'quickActions': 'إجراءات سريعة',
    'seeAll': 'عرض الكل ←',
    'newAssessment': 'تقييم\nجديد',
    'viewHistory': 'عرض\nالسجل',
    'educationHub': 'مركز\nالتعليم',
    'newsletterUpdates': 'النشرة\nوالتحديثات',
    'privacyData': 'الخصوصية\nوالبيانات',
    'resetPassword': 'إعادة تعيين\nكلمة المرور',
    'healthTips': 'نصائح صحية',
    'myHistory': 'سجلاتي',
    'newsletter': 'النشرة الإخبارية',
    'createAccount': 'إنشاء حساب',
    'joinUs': 'انضم إلينا لرؤى صحية أفضل',
    'agreeToTerms': 'أوافق على شروط الخدمة وسياسة الخصوصية',
    'mustAgreeTerms': 'يجب الموافقة على شروط الخدمة للتسجيل',
    'termsOfService': 'شروط الخدمة',
    'alreadyHaveAccount': 'هل لديك حساب بالفعل؟',
    'signIn': 'تسجيل الدخول',
    'gender': 'الجنس',
    'selectGender': 'اختر الجنس',
    'password': 'كلمة المرور',
    'confirmPassword': 'تأكيد كلمة المرور',
    'atLeast6Chars': 'على الأقل 6 أحرف',
    'yourResults': 'نتائجك',
    'retake': 'إعادة',
    'home': 'الرئيسية',
    'visitEducationHub': 'مركز التعليم',
    'learnMore': 'اعرف أكثر',
    'lowRisk': 'خطر منخفض',
    'moderateRisk': 'خطر معتدل',
    'highRisk': 'خطر مرتفع',
    'riskFactorBreakdown': 'تحليل عوامل الخطر',
    'personalisedRecs': 'توصيات مخصصة',
    'readFullArticle': 'اقرأ المقال الكامل',
    'searchArticles': 'البحث في المقالات...',
    'noArticlesFound': 'لم يتم العثور على مقالات',
  };
}
