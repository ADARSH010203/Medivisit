library core;

// Models
export 'models/mr_user.dart';
export 'models/doctor.dart';
export 'models/visit.dart';
export 'models/product.dart';
export 'models/attendance.dart';
export 'models/leave_request.dart';
export 'models/sample.dart';
export 'models/expense.dart';
export 'models/notification_model.dart';
export 'models/territory.dart';
export 'models/badge_definition.dart';
export 'models/leaderboard_entry.dart';
export 'models/filter_model.dart';

// Repositories (Abstract)
export 'repositories/auth_repository.dart';
export 'repositories/user_repository.dart';
export 'repositories/doctor_repository.dart';
export 'repositories/visit_repository.dart';
export 'repositories/product_repository.dart';
export 'repositories/attendance_repository.dart';
export 'repositories/leave_repository.dart';
export 'repositories/notification_repository.dart';
export 'repositories/leaderboard_repository.dart';
export 'repositories/badge_repository.dart';
export 'repositories/tracking_repository.dart';
export 'repositories/expense_repository.dart';

// Repositories (Firebase Concrete)
export 'repositories/firebase/firebase_auth_repository.dart';
export 'repositories/firebase/firebase_user_repository.dart';
export 'repositories/firebase/firebase_doctor_repository.dart';
export 'repositories/firebase/firebase_visit_repository.dart';
export 'repositories/firebase/firebase_product_repository.dart';
export 'repositories/firebase/firebase_notification_repository.dart';
export 'repositories/firebase/firebase_tracking_repository.dart';
export 'repositories/firebase/firebase_attendance_repository.dart';
export 'repositories/firebase/firebase_leave_repository.dart';
export 'repositories/firebase/firebase_leaderboard_repository.dart';
export 'repositories/firebase/firebase_badge_repository.dart';
export 'repositories/firebase/firebase_expense_repository.dart';

// Services
export 'services/auth_service.dart';
export 'services/route_optimizer.dart';
export 'services/offline_sync_service.dart';
export 'services/background_sync_service.dart';
export 'services/geofence_service.dart';
export 'services/location_service.dart';
export 'services/supabase_function_service.dart';
export 'services/workmanager_stub.dart';
export 'services/cloudinary_service.dart';
export 'services/ocr_service.dart';
export 'services/seed_data_service.dart';
export 'services/csv_export_service.dart';
export 'services/pdf_export_service.dart';

// Theme & Widgets
export 'theme/app_colors.dart';
export 'theme/app_typography.dart';
export 'theme/mobile_theme.dart';
export 'theme/admin_theme.dart';

// Widgets
export 'widgets/glass_card.dart';
export 'widgets/gradient_button.dart';
export 'widgets/secondary_button.dart';
export 'widgets/pill_bottom_nav.dart';
export 'widgets/shimmer_loader.dart';
export 'widgets/mesh_gradient_background.dart';
export 'widgets/app_text_field.dart';
export 'widgets/status_pill.dart';
export 'widgets/admin_sidebar.dart';
export 'widgets/admin_glass_card.dart';
export 'widgets/kpi_tile.dart';

