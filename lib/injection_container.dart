import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:localstore/localstore.dart';
import 'package:tuiiapp_domain_data_firestore/tuiiapp_domain_data_firestore.dart';
import 'package:tuiiauth_domain_data_firestore/tuiiauth_domain_data_firestore.dart';
import 'package:tuiibookings_domain_data_firestore/files/data/datasources/lesson_booking_datasource.dart';
import 'package:tuiibookings_domain_data_firestore/files/data/datasources/lesson_booking_datasource_impl.dart';
import 'package:tuiibookings_domain_data_firestore/files/domain/repositories/lesson_booking_repository.dart';
import 'package:tuiibookings_domain_data_firestore/files/data/repositories/lesson_booking_repository_impl.dart';
import 'package:tuiibookings_domain_data_firestore/files/domain/usecases/book_lesson.dart';
import 'package:tuiibookings_domain_data_firestore/files/domain/usecases/get_meeting_url.dart';
import 'package:tuiicalendar_domain_data_firestore/files/data/datasources/lesson_booking_data_source.dart';
import 'package:tuiicalendar_domain_data_firestore/files/data/datasources/lesson_booking_data_source_impl.dart';
import 'package:tuiicalendar_domain_data_firestore/files/data/repositories/lesson_booking_repository_impl.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/repositories/lesson_booking_repository.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/accept_booking_refund.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/accept_lesson_booking.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/add_lesson_booking.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/get_lesson_booking_stream_manager.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/get_payout_stream_manager.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/get_stripe_checkout_url.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/raise_refund_dispute.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/reject_booking_refund.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/update_accepted_lesson_booking.dart';
import 'package:tuiicalendar_domain_data_firestore/files/domain/usecases/update_lesson_booking.dart';
import 'package:tuiicommunications_domain_data_firestore/files/data/datasources/stream_chat_data_source.dart';
import 'package:tuiicommunications_domain_data_firestore/files/data/datasources/stream_chat_data_source_impl.dart';
import 'package:tuiicommunications_domain_data_firestore/files/data/repositories/stream_chat_repository_impl.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/repositories/stream_chat_repository.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/add_channel_message.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/create_stream_token.dart';
import 'package:tuiicommunications_domain_data_firestore/files/domain/usecases/revoke_stream_token.dart';
import 'package:tuiicore/core/models/system_constants.dart';
import 'package:tuiihome_domain_data_firestore/files/data/datasources/tutor_lesson_index_data_source.dart';
import 'package:tuiihome_domain_data_firestore/files/data/datasources/tutor_lesson_index_data_source_impl.dart';
import 'package:tuiihome_domain_data_firestore/files/data/repositories/tutor_lesson_index_repository_impl.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/repositories/tutor_lesson_index_repository.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/add_lesson_index.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/delete_lessons_and_indexes.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_classroom_lessons.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_classroom.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_classroom_resources.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_classroom_tasks.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_index_stream_manager.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_indexes.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lesson_student.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/get_lessons_from_indexes.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/update_lesson_shim.dart';
import 'package:tuiihome_domain_data_firestore/files/domain/usecases/update_pending_subsequent_approval.dart';
import 'package:tuiiparent_domain_data_firestore/files/data/datasources/parents_module_data_source.dart';
import 'package:tuiiparent_domain_data_firestore/files/data/datasources/parents_module_data_source_impl.dart';
import 'package:tuiiparent_domain_data_firestore/files/data/repositories/parents_module_repository_impl.dart';
import 'package:tuiiparent_domain_data_firestore/files/domain/repositories/parents_module_repository.dart';
import 'package:tuiiparent_domain_data_firestore/files/domain/usecases/get_parent_home_stream.dart';
import 'package:tuiicore/core/bloc/system_overlay/system_overlay_bloc.dart';
import 'package:tuiicore/core/services/local_store_service.dart';
import 'package:tuiicore/core/services/local_store_service_impl.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiicore/core/services/snackbar_service_impl.dart';
import 'package:tuiicore/core/services/storage_repository.dart';
import 'package:tuiicore/core/services/storage_repository_impl.dart';
import 'package:tuiicore/core/services/toast_service.dart';
import 'package:tuiicore/core/services/toast_service_impl.dart';
import 'package:tuiicore/core/widgets/tag_manager/bloc/tag_manager_bloc.dart';

final sl = GetIt.instance;

Future<void> init(SystemConstants constants) async {
  //! Auth / Onbaording Feature
  sl.registerLazySingleton<FirebaseAuthDataSource>(() =>
      FirebaseAuthDataSourceImpl(
          firebaseAuth: sl(), firestore: sl(), constants: constants));

  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(authDataSource: sl()));

  sl.registerLazySingleton<ValidateSignUpHashUseCase>(
      () => ValidateSignUpHashUseCase(authRepository: sl()));

  sl.registerLazySingleton<LoginWithEmailAndPasswordUseCase>(
      () => LoginWithEmailAndPasswordUseCase(authRepository: sl()));

  sl.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(authRepository: sl()));

  sl.registerLazySingleton<LoginWithGoogleUseCase>(
      () => LoginWithGoogleUseCase(authRepository: sl()));

  // sl.registerLazySingleton<LoginWithAppleUseCase>(
  //     () => LoginWithAppleUseCase(authRepository: sl()));

  sl.registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(authRepository: sl()));

  sl.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(authRepository: sl()));

  sl.registerLazySingleton<IsEmailUniqueUseCase>(
      () => IsEmailUniqueUseCase(authRepository: sl()));

  sl.registerLazySingleton<UpdateUserUseCase>(
      () => UpdateUserUseCase(authRepository: sl()));

  sl.registerLazySingleton<UpdateUserPartitionUseCase>(
      () => UpdateUserPartitionUseCase(authRepository: sl()));

  sl.registerLazySingleton<GetZoomTokenUseCase>(
      () => GetZoomTokenUseCase(authRepository: sl()));

  sl.registerLazySingleton<GetZoomAccountDetailsUseCase>(
      () => GetZoomAccountDetailsUseCase(authRepository: sl()));

  sl.registerLazySingleton<RevokeZoomTokenUseCase>(
      () => RevokeZoomTokenUseCase(authRepository: sl()));

  sl.registerLazySingleton<ValidateTutorDomainUseCase>(
      () => ValidateTutorDomainUseCase(authRepository: sl()));

  sl.registerLazySingleton<UpdateEmailUseCase>(
      () => UpdateEmailUseCase(authRepository: sl()));

  sl.registerLazySingleton<FinalizeOnboardingUseCase>(
      () => FinalizeOnboardingUseCase(authRepository: sl()));

  sl.registerLazySingleton<ManageUserSubjectsUseCase>(
      () => ManageUserSubjectsUseCase(authRepository: sl()));

  sl.registerLazySingleton<SearchUsersUseCase>(
      () => SearchUsersUseCase(authRepository: sl()));

  sl.registerLazySingleton<EmailVerificationUseCase>(
      () => EmailVerificationUseCase(authRepository: sl()));

  sl.registerLazySingleton<SendPhoneVerificationCodeUseCase>(
      () => SendPhoneVerificationCodeUseCase(authRepository: sl()));

  sl.registerLazySingleton<VerifyPhoneVerificationCodeUseCase>(
      () => VerifyPhoneVerificationCodeUseCase(authRepository: sl()));

  sl.registerLazySingleton<RefreshFirebaseUserUseCase>(
      () => RefreshFirebaseUserUseCase(authRepository: sl()));

  sl.registerLazySingleton<GetIsFirebaseUserEmailVierfiedUseCase>(
    () => GetIsFirebaseUserEmailVierfiedUseCase(authRepository: sl()),
  );

  sl.registerLazySingleton(() => SystemOverlayBloc());

  sl.registerFactory<GetStripeAccountLinkUrlUseCase>(
      () => GetStripeAccountLinkUrlUseCase(repository: sl()));
  sl.registerFactory<GetStripeAccountDetailsUseCase>(
      () => GetStripeAccountDetailsUseCase(repository: sl()));
  sl.registerFactory<SendDirectConnectInvitationsUseCase>(
      () => SendDirectConnectInvitationsUseCase(repository: sl()));

  //! TuiiApp Feature
  sl.registerLazySingleton<TuiiModuleDataSource>(
      () => TuiiModuleDataSourceImpl(firestore: sl()));

  sl.registerLazySingleton<TuiiModuleRepository>(
      () => TuiiModuleRepositoryImpl(dataSource: sl()));

  sl.registerLazySingleton<CreateNotificationUseCase>(
      () => CreateNotificationUseCase(repository: sl()));

  sl.registerLazySingleton<UpdateNotificationUseCase>(
      () => UpdateNotificationUseCase(repository: sl()));

  sl.registerLazySingleton<UpdateNotificationListUseCase>(
      () => UpdateNotificationListUseCase(repository: sl()));

  sl.registerLazySingleton<DeleteNotificationUseCase>(
      () => DeleteNotificationUseCase(repository: sl()));

  sl.registerLazySingleton<RefreshLessonBookingUseCase>(
      () => RefreshLessonBookingUseCase(repository: sl()));

  sl.registerLazySingleton<GetNotificationStreamUseCase>(
      () => GetNotificationStreamUseCase(repository: sl()));

  sl.registerLazySingleton<GetAppLinkCommandUseCase>(
      () => GetAppLinkCommandUseCase(repository: sl()));

  sl.registerLazySingleton<ExpireAppLinkCommandUseCase>(
      () => ExpireAppLinkCommandUseCase(repository: sl()));

  sl.registerLazySingleton<GetSystemConfigurationUseCase>(
      () => GetSystemConfigurationUseCase(repository: sl()));

  sl.registerLazySingleton<AddDispatchJobUseCase>(
      () => AddDispatchJobUseCase(repository: sl()));

  //! Parents Feature
  sl.registerLazySingleton<ParentsModuleDataSource>(
      () => ParentsModuleDataSourceImpl(firestore: sl()));

  sl.registerLazySingleton<ParentsModuleRepository>(
      () => ParentsModuleRepositoryImpl(dataSource: sl()));

  sl.registerLazySingleton<GetParentHomeStreamUseCase>(
      () => GetParentHomeStreamUseCase(repository: sl()));

  //! Home Feature
  sl.registerLazySingleton<TutorLessonIndexDataSource>(
      () => TutorLessonIndexDataSourceImpl(firestore: sl()));

  sl.registerLazySingleton<TutorLessonIndexRepository>(
      () => TutorLessonIndexRepositoryImpl(dataSource: sl()));

  sl.registerLazySingleton<GetLessonIndexesUseCase>(
      () => GetLessonIndexesUseCase(repository: sl()));

  sl.registerLazySingleton<GetLessonsFromIndexesUseCase>(
      () => GetLessonsFromIndexesUseCase(repository: sl()));

  sl.registerFactory<GetClassroomLessonsUseCase>(
      () => GetClassroomLessonsUseCase(repository: sl()));

  sl.registerFactory<GetLessonClassroomUseCase>(
      () => GetLessonClassroomUseCase(repository: sl()));

  sl.registerFactory<GetLessonStudentUseCase>(
      () => GetLessonStudentUseCase(repository: sl()));

  sl.registerFactory<GetLessonClassroomTasksUseCase>(
      () => GetLessonClassroomTasksUseCase(repository: sl()));

  sl.registerFactory<GetLessonClassroomResourcesUseCase>(
      () => GetLessonClassroomResourcesUseCase(repository: sl()));

  sl.registerFactory<AddLessonIndexUseCase>(
      () => AddLessonIndexUseCase(repository: sl()));

  sl.registerFactory<UpdateLessonShimUseCase>(
      () => UpdateLessonShimUseCase(repository: sl()));

  sl.registerFactory<GetLessonIndexStreamManager>(
      () => GetLessonIndexStreamManager(repository: sl()));

  sl.registerFactory(() => TagManagerBloc());

  //! Calendar Feature
  sl.registerLazySingleton<CalendarLessonBookingDataSource>(() =>
      CalendarLessonBookingDataSourceImpl(
          firestore: sl(), constants: constants));

  sl.registerLazySingleton<CalendarLessonBookingRepository>(
      () => CalendarLessonBookingRepositoryImpl(dataSource: sl()));

  sl.registerLazySingleton<AddLessonBookingUseCase>(
      () => AddLessonBookingUseCase(repository: sl()));

  sl.registerLazySingleton<UpdateLessonBookingUseCase>(
      () => UpdateLessonBookingUseCase(repository: sl()));

  sl.registerLazySingleton<AcceptLessonBookingUseCase>(
      () => AcceptLessonBookingUseCase(repository: sl()));

  sl.registerLazySingleton<UpdateAcceptedLessonBookingUseCase>(
      () => UpdateAcceptedLessonBookingUseCase(repository: sl()));

  sl.registerLazySingleton<RejectBookingRefundUseCase>(
      () => RejectBookingRefundUseCase(repository: sl()));

  sl.registerLazySingleton<RaiseRefundDisputeUseCase>(
      () => RaiseRefundDisputeUseCase(repository: sl()));

  sl.registerLazySingleton<AcceptBookingRefundUseCase>(
      () => AcceptBookingRefundUseCase(repository: sl()));

  sl.registerLazySingleton<DeleteLessonsAndIndexesUseCase>(
      () => DeleteLessonsAndIndexesUseCase(repository: sl()));

  sl.registerLazySingleton<UpdateLessonIndexesSubsequentApprovalUseCase>(
      () => UpdateLessonIndexesSubsequentApprovalUseCase(repository: sl()));

  sl.registerFactory<GetLessonBookingsStreamManager>(
      () => GetLessonBookingsStreamManager(repository: sl()));

  sl.registerFactory<GetPayoutManifestsStreamManager>(
      () => GetPayoutManifestsStreamManager(repository: sl()));

  // sl.registerLazySingleton(() => CalendarBloc(
  //     addLessonBooking: sl(),
  //     acceptLessonBooking: sl(),
  //     updateLessonBooking: sl(),
  //     updateAcceptedLessonBooking: sl(),
  //     rejectBookingRefund: sl(),
  //     acceptBookingRefund: sl(),
  //     refreshLessonBooking: sl(),
  //     tuiiAppBloc: sl(),
  //     tuiiNotificationsBloc: sl(),
  //     authBloc: sl(),
  //     homeBloc: sl(),
  //     overlayBloc: sl(),
  //     bookingsBloc: sl(),
  //     dataSource: sl()));

  //! Bookings Feature
  sl.registerLazySingleton<LessonBookingDataSource>(
      () => LessonBookingDataSourceImpl(firestore: sl()));

  sl.registerLazySingleton<LessonBookingRepository>(
      () => LessonBookingRepositoryImpl(dataSource: sl()));

  sl.registerLazySingleton<BookLesson>(() => BookLesson(repository: sl()));
  sl.registerLazySingleton<GetMeetingUrl>(
      () => GetMeetingUrl(repository: sl()));

  sl.registerFactory<GetStripeCheckoutUrlUseCase>(
      () => GetStripeCheckoutUrlUseCase(repository: sl()));

  //! Communications Feature
  sl.registerLazySingleton<StreamChatDataSource>(
      () => StreamChatDataSourceImpl());

  sl.registerLazySingleton<StreamChatRepository>(
      () => StreamChatRepositoryImpl(dataSource: sl()));

  sl.registerFactory<CreateStreamTokenUseCase>(
      () => CreateStreamTokenUseCase(repository: sl()));

  sl.registerFactory<RevokeStreamTokenUseCase>(
      () => RevokeStreamTokenUseCase(repository: sl()));

  sl.registerFactory<AddChannelMessageUseCase>(
      () => AddChannelMessageUseCase(repository: sl()));

  //! Enrollments Feature
  // sl.registerFactory(() => EnrollmentsBloc(numberOfForms: 6));

  //! Common
  sl.registerLazySingleton<StorageRepository>(
      () => StorageRepositoryImpl(storage: sl()));

  sl.registerLazySingleton<LocalStoreService>(
      () => LocalStoreServiceImpl(db: sl()));
  sl.registerLazySingleton<ToastService>(() => ToastServiceImpl());
  sl.registerLazySingleton<SnackbarService>(() => SnackbarServiceImpl());

  //!External
  final firestore = FirebaseFirestore.instance;
  // await firestore.enablePersistence(const PersistenceSettings(synchronizeTabs: false));

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => firestore);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => Localstore.instance);

  //! ALL SINGLETONS HERE
}
