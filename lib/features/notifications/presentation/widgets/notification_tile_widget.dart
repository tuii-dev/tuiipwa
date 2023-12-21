import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuiientitymodels/files/tuii_app/data/models/notification_model.dart';
import 'package:tuiicore/core/enums/enums.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_notifications/tuii_notifications_bloc.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({Key? key, required this.notification})
      : super(key: key);

  final NotificationModel notification;
  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  @override
  Widget build(BuildContext context) {
    String? profileImageUrl = getImageCdnUrl(
        context, widget.notification.senderProfileImageUrl,
        width: 40, height: 40);

    return BlocBuilder<TuiiNotificationsBloc, TuiiNotificationsState>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // if (widget.notification.resolved != true) {
            _notificationTapHandler(widget.notification);
            // }
          },
          child: SizedBox(
              height: 60,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.notification.resolved == false
                        ? Row(
                            children: [
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: TuiiColors.redBadge,
                                        borderRadius: BorderRadius.circular(5)),
                                  )),
                              const SizedBox(width: 5),
                            ],
                          )
                        : const SizedBox(width: 10),
                    SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: profileImageUrl != null &&
                                profileImageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: profileImageUrl,
                                ),
                              )
                            : Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                    color: TuiiColors.primary,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Center(
                                    child: Text(
                                        getUserInitialsFromFirstAndLastName(
                                            widget.notification.senderFirstName,
                                            widget.notification.senderLastName),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            color: TuiiColors.white,
                                            fontWeight: FontWeight.w700))))),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${widget.notification.senderFirstName ?? ''} ${widget.notification.senderLastName ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: TuiiColors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                )),
                            Text(widget.notification.notificationPreface ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: TuiiColors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                )),
                          ]),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                          timeago.format(widget.notification.creationDate!),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TuiiColors.inactiveTool,
                            fontSize: 14,
                          )),
                    ),
                  ])),
        );
      },
    );
  }

  void _notificationTapHandler(NotificationModel notification) async {
    switch (notification.notificationType) {
      case NotificationType.connectionRequested:
        // final directive = await _handleConnectionAttempt(notification);
        // if (directive != null && directive['runBookLesson'] == true) {
        //   final currentContext = ContextHolder.currentContext;
        //   await bookLesson(
        //     currentContext,
        //     directive['classroom'],
        //     fontFamily,
        //   );
        // }
        break;
      case NotificationType.parentConnectionRequested:
        // _handleParentConnectionAttempt(notification);
        break;
      case NotificationType.tutorConnectionAccepted:
        // _handleTutorConnectionAccepted(notification);
        break;
      case NotificationType.bookingConfirmationRequested:
      case NotificationType.bookingConfirmationAccepted:
      case NotificationType.bookingConfirmationRejected:
      case NotificationType.bookingConfirmationCanceled:
      case NotificationType.bookingRefundRequested:
      case NotificationType.bookingRefundAccepted:
      case NotificationType.bookingRefundRejected:
      case NotificationType.bookingDisputeRaised:
      case NotificationType.tutorRescheduledLesson:
        // Future.delayed(const Duration(milliseconds: 250), () {
        //   final lessonBooking = LessonBookingModel.fromMap(
        //       notification.payload!['lessonBooking']);
        //   BlocProvider.of<TuiiNotificationsBloc>(context).add(
        //       RefreshLessonBookingEvent(
        //           lessonBookingId: lessonBooking.id!,
        //           notification: notification));

        //   Navigator.of(context).pop();
        // });
        break;
      case NotificationType.connectionAccepted:
        // handleChatChannelRoute(context, 'tutor', notification.senderId,
        //     popNavigator: true);
        break;
      case NotificationType.connectionRejected:
        // handleChatChannelRoute(context, 'tutor', notification.senderId,
        //     popNavigator: true);
        // if (notification.resolveOnView != true &&
        //     notification.resolved != true) {
        //   BlocProvider.of<TuiiNotificationsBloc>(context).add(
        //       UpdateTuiiNotificationEvent(
        //           notification: notification.copyWith(
        //               resolved: true, resolutionDate: DateTime.now())));
        // }
        break;
      // case NotificationType.zoomErrorResetTokenRequired:
      //   final roleType =
      //       BlocProvider.of<AuthBloc>(context).state.user!.roleType;

      //   if (roleType != null) {
      //     Navigator.of(context).pushNamed(TuiiOnboardingScreen.routeName,
      //         arguments: TuiiCompleteProfileRouteArgs(
      //             selectedFormIndex: roleType == TuiiRoleType.tutor
      //                 ? 0
      //                 : roleType == TuiiRoleType.student
      //                     ? 1
      //                     : 2,
      //             isUpdatingProfile: true,
      //             includeRoleSelectionForm: false,
      //             childSelectedFormIndex: 3,
      //             forceAtomicFormAction: true));
      //   }
      //   break;
      // case NotificationType.zoomApiConstraintsExceeded:
      //   _handleZoomApiExceeded();
      //   break;
      default:
        return;
    }
  }

//   Future<Map<String, dynamic>?> _handleConnectionAttempt(
//       NotificationModel notification) async {
//     _safeClosePopOver(context);
//     final payload =
//         ConnectNotificationPayload.fromMap(widget.notification.payload ?? {});

//     final classrooms =
//         BlocProvider.of<TutorHomeBloc>(context).state.serverClassrooms ?? [];

//     final index = classrooms.indexWhere((c) =>
//         c.studentId == widget.notification.senderId &&
//         c.studentEnrollmentStatus != EnrollmentStatusType.pending);

//     if (index == -1) {
//       final user = UserModel(
//           id: widget.notification.senderId,
//           email: widget.notification.senderEmail ?? '',
//           firstName: widget.notification.senderFirstName,
//           lastName: widget.notification.senderLastName,
//           profileImageUrl: widget.notification.senderProfileImageUrl,
//           roleType: payload.senderRoleType,
//           bio: payload.senderBio,
//           address: payload.senderAddress,
//           userSubjects: payload.senderSubjects);
//       await showModal(
//           context: context,
//           configuration:
//               const FadeScaleTransitionConfiguration(barrierDismissible: false),
//           builder: (BuildContext context) {
//             return SystemConstantsProvider(
//               child: MultiBlocProvider(
//                 providers: [
//                   BlocProvider(
//                     create: (context) => sl<ConnectUserBloc>(),
//                   ),
//                   // BlocProvider(
//                   //   create: (context) => sl<TuiiNotificationsBloc>(),
//                   // ),
//                 ],
//                 child: ClassroomConnectWithUserDialog(
//                   isNotificationTrigger: true,
//                   selectedUser: user,
//                   notification: widget.notification,
//                 ),
//               ),
//             );
//           });
//     } else {
//       final classroom = classrooms[index];
//       final runBookLesson = await showModal(
//           context: context,
//           configuration:
//               const FadeScaleTransitionConfiguration(barrierDismissible: false),
//           builder: (BuildContext context) {
//             return SystemConstantsProvider(
//               child: ClassroomPromptForActionDialog(
//                 classroom: classroom,
//                 connection: null,
//                 identityVerificationCubit: null,
//                 actionType: ClassroomPromptForActionType.usersAlreadyConnected,
//               ),
//             );
//           });

//       return {'runBookLesson': runBookLesson, 'classroom': classroom};

//       // if (runBookLesson == true) {
//       //   bookLesson(
//       //       context, classroom, SystemConstantsProvider.of(context).fontFamily);
//       // }
//     }

//     return null;
//   }

//   void _handleParentConnectionAttempt(NotificationModel notification) async {
//     _safeClosePopOver(context);
//     final tutor = BlocProvider.of<AuthBloc>(context).state.user!;
//     final payload = ParentConnectNotificationPayload.fromMap(
//         widget.notification.payload ?? {});

//     final classrooms =
//         BlocProvider.of<TutorHomeBloc>(context).state.serverClassrooms ?? [];

//     final index = classrooms.indexWhere((c) =>
//         c.studentCustodianId == widget.notification.senderId &&
//         c.studentId == payload.children[0].id &&
//         c.studentEnrollmentStatus != EnrollmentStatusType.pending);

//     if (index == -1) {
//       final parent = UserModel(
//           id: widget.notification.senderId,
//           email: widget.notification.senderEmail ?? '',
//           firstName: widget.notification.senderFirstName,
//           lastName: widget.notification.senderLastName,
//           profileImageUrl: widget.notification.senderProfileImageUrl,
//           roleType: payload.senderRoleType,
//           bio: payload.senderBio,
//           address: payload.senderAddress,
//           userSubjects: payload.senderSubjects,
//           custodianConnections: payload.custodianConnections);

//       await showModal(
//           context: context,
//           configuration:
//               const FadeScaleTransitionConfiguration(barrierDismissible: false),
//           builder: (BuildContext context) {
//             return SystemConstantsProvider(
//               child: MultiBlocProvider(
//                 providers: [
//                   BlocProvider(
//                     create: (context) => sl<ConnectUserBloc>()
//                       ..initParent(parent, payload.children),
//                   ),
//                   // BlocProvider(
//                   //   create: (context) => sl<TuiiNotificationsBloc>(),
//                   // ),
//                 ],
//                 child: ParentConnectWithTutorDialog(
//                   isNotificationTrigger: true,
//                   tutor: tutor.toModel(),
//                   parent: parent,
//                   notification: widget.notification,
//                 ),
//               ),
//             );
//           });
//     } else {
//       final classroom = classrooms[index];
//       await showModal(
//           context: context,
//           configuration:
//               const FadeScaleTransitionConfiguration(barrierDismissible: false),
//           builder: (BuildContext context) {
//             return SystemConstantsProvider(
//               child: ClassroomPromptForActionDialog(
//                 classroom: classroom,
//                 connection: null,
//                 identityVerificationCubit: null,
//                 actionType: ClassroomPromptForActionType
//                     .usersAlreadyConnectedMessageOnly,
//               ),
//             );
//           });
//     }

//     return;
//   }

//   void _handleTutorConnectionAccepted(NotificationModel notification) async {
//     final user = BlocProvider.of<AuthBloc>(context).state.user!;
//     if (user.roleType == TuiiRoleType.tutor) {
//       _safeClosePopOver(context);
//       final classroomId = notification.payload!['classroomId'];
//       if (classroomId != null && classroomId.isNotEmpty) {
//         final allClassrooms =
//             BlocProvider.of<TutorHomeBloc>(context).state.studentClassrooms ??
//                 [];
//         final classroom = allClassrooms.firstWhere((c) => c.id == classroomId,
//             orElse: () => ClassroomModel.isEmpty());

//         if (!classroom.isEmpty) {
//           final fontFamily = SystemConstantsProvider.of(context).fontFamily;
//           await bookLesson(context, classroom, fontFamily);
//         }
//       }
//     }
//   }

//   void _safeClosePopOver(BuildContext context) {
//     Navigator.of(context)
//         .popUntil((route) => route.settings.name == TuiiAppScreen.routeName);
//   }
}
