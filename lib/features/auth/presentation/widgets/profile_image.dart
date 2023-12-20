// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/models/selected_file.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/common/common.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({
    Key? key,
    required this.roleType,
    required this.profileImage,
    required this.profileImageUrl,
    required this.snackbarService,
    this.hideChangeControl = false,
    this.reduceSize = false,
    this.addCustodianIcon = false,
  }) : super(key: key);

  final TuiiRoleType roleType;
  final SelectedFile? profileImage;
  final String? profileImageUrl;
  final SnackbarService snackbarService;
  final bool? hideChangeControl;
  final bool? reduceSize;
  final bool? addCustodianIcon;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool isAwaiting = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.reduceSize == true ? 70.0 : 100.0,
        height: widget.reduceSize == true ? 70.0 : 100.0,
        child: GestureDetector(
          onTap: () {
            if (widget.hideChangeControl != true) {
              _browseForFile(context);
            }
          },
          child: Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              clipBehavior: Clip.none,
              children: [
                widget.profileImage != null
                    ? CircleAvatar(
                        radius: widget.reduceSize == true ? 35.0 : 40.0,
                        backgroundColor: TuiiColors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.memory(
                            widget.profileImage!.fileBytes,
                            width: widget.reduceSize == true ? 70 : 80,
                            height: widget.reduceSize == true ? 70 : 80,
                            fit: BoxFit.cover,
                          ),
                        ))
                    : widget.profileImageUrl != null &&
                            widget.profileImageUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: widget.reduceSize == true ? 35.0 : 40.0,
                            backgroundColor: TuiiColors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: CachedNetworkImage(
                                imageUrl: getImageCdnUrl(
                                  context,
                                  widget.profileImageUrl!,
                                  width: widget.reduceSize == true ? 70 : 80,
                                  height: widget.reduceSize == true ? 70 : 80,
                                )!,
                                width: widget.reduceSize == true ? 70 : 80,
                                height: widget.reduceSize == true ? 70 : 80,
                                fit: BoxFit.cover,
                              ),
                            ))
                        : widget.hideChangeControl == true
                            ? const Icon(MdiIcons.school,
                                color: TuiiColors.white, size: 70)
                            : const Icon(Icons.account_circle,
                                color: TuiiColors.inactiveTool, size: 80),
                widget.hideChangeControl != true
                    ? Positioned(
                        top: widget.reduceSize == true ? 52 : 62,
                        left: widget.reduceSize == true ? 54 : 64,
                        child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: TuiiColors.primary,
                              borderRadius: BorderRadius.circular(13.0),
                            ),
                            child: const Center(
                              child: Text('+',
                                  style: TextStyle(
                                      color: TuiiColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18)),
                            )))
                    : const SizedBox.shrink(),
                widget.addCustodianIcon == true
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                              color: TuiiColors.inactiveBackground,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(11))),
                          child: const Center(
                            child: Icon(MdiIcons.accountChildCircle,
                                color: TuiiColors.defaultDarkColor, size: 20),
                          ),
                        ))
                    : const SizedBox.shrink(),
              ]),
        ));
  }

  void _browseForFile(BuildContext context) async {
    if (!isAwaiting) {
      setState(() => isAwaiting = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.first.size < (25 * 1048576)) {
          final file = result.files.first;
          final fileBytes = file.bytes!;
          final hash = getHashFromByteArray(fileBytes);
          final selectedFile = SelectedFile(
              fileBytes: fileBytes, fileName: file.name, hash: hash);
          BlocProvider.of<ProfileCubit>(context)
              .profileImageChanged(selectedFile);
        } else {
          widget.snackbarService.showSnackbar(
              context, true, 'File size must no exceed 25 MB!'.i18n, 500);
        }
      }
      setState(() => isAwaiting = false);
    }
  }
}
