import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/channel_type.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/web/constants/constants.dart';

String getAppUrl(ChannelType channel) {
  switch (channel) {
    case ChannelType.app:
      return 'https://app.tuii.io';
    case ChannelType.beta:
      return 'https://beta.tuii.io';
    case ChannelType.alpha:
      return 'https://alpha.tuii.io';
    default:
      return 'https://dev.tuii.io';
  }
}

void manageLoginScreenRoute(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  if (authBloc.state.status != AuthStatus.unauthenticated) {
    authBloc.add(AuthLogoutRequested());
  }

  Navigator.of(context)
      .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
}

Text getOrText() {
  return Text('---- Or ----'.i18n,
      style: const TextStyle(
        fontSize: 16.0,
        color: TuiiColors.inactiveTool,
      ));
}

List<String> getPlatformCountries(BuildContext context) {
  final platformCountries = BlocProvider.of<TuiiAppBloc>(context)
      .state
      .systemConfig
      ?.platformCountries;
  return platformCountries ?? ['AU', 'CA'];
}

Future<bool> validatePhoneNumber(String phoneNumber,
    {String? isoCode = 'AU'}) async {
  try {
    await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, isoCode!);

    return true;
  } catch (err) {
    return false;
  }
}

String? getImageCdnUrl(BuildContext context, String? imageUrl,
    {int? width, int? height}) {
  // Uncomment for locahost testing
  // return imageUrl;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    String projectId = SystemConstantsProvider.of(context).googleProjectId;
    String firebaseStorageRoot =
        'https://firebasestorage.googleapis.com/v0/b/$projectId.appspot.com/o/';
    String storageRoot =
        'https://storage.googleapis.com/$projectId.appspot.com/';
    if (imageUrl.startsWith(firebaseStorageRoot)) {
      String cdnUrl = '/cdn/image/';
      cdnUrl += (width != null && width > 0) ? 'width=$width' : 'width=x';
      cdnUrl +=
          (height != null && height > 0) ? ',height=$height/' : ',height=y/';
      cdnUrl += imageUrl.substring(firebaseStorageRoot.length);

      debugPrint('Converted CDN Url: $cdnUrl');
      return cdnUrl;
    } else if (imageUrl.startsWith(storageRoot)) {
      String cdnUrl = '/cdn/image/';
      cdnUrl += (width != null && width > 0) ? 'width=$width' : 'width=x';
      cdnUrl +=
          (height != null && height > 0) ? ',height=$height/' : ',height=y/';
      cdnUrl += imageUrl.substring(storageRoot.length);

      debugPrint('Converted CDN Url: $cdnUrl');
      return cdnUrl;
    }
  }
  return imageUrl;
}

String getHashFromByteArray(Uint8List fileBytes) {
  // Digest result = sha1.convert(fileBytes);
  Digest result = sha256.convert(fileBytes);
  return result.toString();
}
