import 'package:flutter/material.dart';
import 'package:tuiicore/core/enums/channel_type.dart';

class SystemConstantsProvider extends InheritedWidget {
  // CONFIGURE DEV SETTINGS HERE
  static const ChannelType channel = ChannelType.dev;
  static const bool channelSignUpIsSecured = true;
  static const bool runIdentityVerification = false;

  static String projectId =
      (channel == ChannelType.dev || channel == ChannelType.alpha)
          ? 'tutorbase-336701'
          : 'tuii-380018';

  static String apiRootUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/';

  static String streamCreateTokenUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/stream/token/create/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/stream/token/create/';

  static String streamRevokeTokenUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/stream/token/revoke/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/stream/token/revoke/';

  static String streamMessageUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/stream/messages/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/stream/messages/';

  static String createAppLinkUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/appLinks/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/appLinks/';

  static String helpScoutBeaconId =
      (channel == ChannelType.dev || channel == ChannelType.alpha)
          ? '3e10733b-5420-4aee-b906-a14034aa0ff2'
          : '';

  // SMS And Phone Verification
  static String smsSendUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/sms/send/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/sms/send/';

  static String smsSendPhoneVerificationCodeUrl = (channel == ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/sms/phoneVerification/send/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/sms/phoneVerification/send/';

  static String smsVerifyPhoneVerificationCodeUrl = (channel ==
              ChannelType.dev ||
          channel == ChannelType.alpha)
      ? 'https://australia-southeast1-tutorbase-336701.cloudfunctions.net/app/sms/phoneVerification/verify/'
      : 'https://australia-southeast1-tuii-380018.cloudfunctions.net/app/sms/phoneVerification/verify/';

  static SystemConstantsProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SystemConstantsProvider>()!;

  // ignore: annotate_overrides, overridden_fields
  final Widget child;

  SystemConstantsProvider({Key? key, required this.child})
      : super(key: key, child: child);

  final String fontFamily = 'SF Pro Display';

  // KEEP TRAILING /

  final String corsAnywhereUrl =
      '${SystemConstantsProvider.apiRootUrl}cors/image/anywhere/';

  // SignUp
  final String signUpValidationUrl =
      '${SystemConstantsProvider.apiRootUrl}signUpControl/';

  // Zoom
  final String zoomCreateTokenUrl =
      '${SystemConstantsProvider.apiRootUrl}zoom/token/create/';

  final String zoomRevokeTokenUrl =
      '${SystemConstantsProvider.apiRootUrl}zoom/token/revoke/';

  final String zoomAccountUrl =
      '${SystemConstantsProvider.apiRootUrl}zoom/account/';

  final String zoomMeetingUrl =
      '${SystemConstantsProvider.apiRootUrl}zoom/meeting/';

  final String zoomAuthorizationUrl =
      'https://zoom.us/oauth/authorize?response_type=code&client_id=w7hV1c4TS9qnyZ963Ap3KA&redirect_uri=https%3A%2F%2Fapp.tuii.io%2Fauth.html';

  // Stripe
  final String stripeCreateSessionUrl =
      '${SystemConstantsProvider.apiRootUrl}stripe/checkout/';

  final String stripeCreateRefundUrl =
      '${SystemConstantsProvider.apiRootUrl}stripe/refunds/';

  final String stripeCreateAccountUrl =
      '${SystemConstantsProvider.apiRootUrl}stripe/express/';

  final String stripeAccountDetailsUrl =
      '${SystemConstantsProvider.apiRootUrl}stripe/express/account/';

  // Stream
  // final String streamCreateTokenUrl =
  //     SystemConstantsProvider.apiRootUrl + 'stream/token/create/';

  // final String streamRevokeTokenUrl =
  //     SystemConstantsProvider.apiRootUrl + 'stream/token/revoke/';

  final String googleProjectId =
      (channel == ChannelType.dev || channel == ChannelType.alpha)
          ? 'tutorbase-336701'
          : 'tuii-380018';

  @override
  bool updateShouldNotify(SystemConstantsProvider oldWidget) => false;
}
