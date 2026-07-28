import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MediVisit Pro';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue to MediVisit Pro';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerHere => 'Don\'t have an account? Register here';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Join MediVisit Pro to manage your visits';

  @override
  String get nameLabel => 'Full Name';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get territoryLabel => 'Select Territory';

  @override
  String get registerButton => 'Register';

  @override
  String get backToLogin => 'Already have an account? Sign in';

  @override
  String get pendingVerificationTitle => 'Account Under Review';

  @override
  String get pendingVerificationMessage => 'Your account is pending verification by a regional administrator. Please check back later.';

  @override
  String get contactAdmin => 'Contact your regional admin for assistance.';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get visitsToday => 'Visits Today';

  @override
  String get attendance => 'Attendance';

  @override
  String get thisWeek => 'This Week';

  @override
  String get doctorVisits => 'Doctor Visits';

  @override
  String get products => 'Products';

  @override
  String get leaveRequest => 'Leave Request';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get quickLog => 'Quick Log';

  @override
  String get markDoctorVisit => 'Mark Doctor Visit';

  @override
  String get markAttendance => 'Mark Attendance';

  @override
  String get requestLeave => 'Request Leave';

  @override
  String get daySelector => 'Select Day';

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String get visited => 'Visited';

  @override
  String get markAsVisited => 'Mark as Visited';

  @override
  String get confirmVisitLocation => 'Confirm Visit Location';

  @override
  String get confirmVisit => 'Confirm Visit';

  @override
  String get outOfGeofenceReason => 'Reason for being outside geofence';

  @override
  String get visitConfirmed => 'Visit Confirmed!';

  @override
  String get rateVisit => 'Rate Visit';

  @override
  String get submit => 'Submit';

  @override
  String get visitHistory => 'Visit History';

  @override
  String get catalog => 'Catalog';

  @override
  String get searchProducts => 'Search Products...';

  @override
  String get inStock => 'In Stock';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String get profile => 'Profile';

  @override
  String get totalVisits => 'Total Visits';

  @override
  String get avgRating => 'Avg Rating';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get logout => 'Logout';

  @override
  String get save => 'Save';
}
