import 'package:get_it/get_it.dart';
import 'package:vibyuk/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:vibyuk/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:vibyuk/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:vibyuk/features/profile/domain/repositories/profile_repository.dart';
import 'package:vibyuk/features/profile/domain/usecases/change_password_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/delete_account_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/get_my_profile_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/get_notification_settings_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/update_notification_settings_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:vibyuk/features/profile/domain/usecases/upload_avatar_use_case.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';

void registerProfileModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNotificationSettingsUseCase(sl()));

  // BLoC — factory so each app-level provider gets a fresh instance
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getMyProfile: sl(),
      updateProfile: sl(),
      uploadAvatar: sl(),
      changePassword: sl(),
      deleteAccount: sl(),
      getNotificationSettings: sl(),
      updateNotificationSettings: sl(),
    ),
  );
}
