import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiicore/core/services/snackbar_service.dart';
import 'package:tuiicore/core/widgets/formatters/tuii_date_input_formatter.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/profile_image.dart';
import 'package:tuiipwa/injection_container.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class PersonalInfoWidget extends StatefulWidget {
  const PersonalInfoWidget(
      {super.key,
      required this.isInstantiatedInSettings,
      required this.containerHeight});

  final bool isInstantiatedInSettings;
  final double containerHeight;

  @override
  State<PersonalInfoWidget> createState() => _PersonalInfoWidgetState();
}

class _PersonalInfoWidgetState extends State<PersonalInfoWidget> {
  final FocusNode _firstNameNode = FocusNode();
  Color _firstNameColor = TuiiColors.bgColorScreen;

  final FocusNode _lastNameNode = FocusNode();
  Color _lastNameColor = TuiiColors.bgColorScreen;

  final FocusNode _birthDateNode = FocusNode();
  Color _birthDateColor = TuiiColors.bgColorScreen;
  late TextEditingController _birthDateController;

  final FocusNode _emailNode = FocusNode();
  Color _emailColor = TuiiColors.bgColorScreen;

  final FocusNode _bioNode = FocusNode();
  // Color _bioColor = TuiiColors.bgColorScreen;

  final FocusNode _addressNode = FocusNode();
  Color _addressColor = TuiiColors.bgColorScreen;

  late bool isFirebase;
  late SnackbarService _snackbarService;

  @override
  void initState() {
    _firstNameNode.addListener(() {
      setState(() {
        _firstNameColor = (_firstNameNode.hasFocus)
            ? Colors.white70
            : TuiiColors.bgColorScreen;
      });
    });

    _lastNameNode.addListener(() {
      setState(() {
        _lastNameColor = (_lastNameNode.hasFocus)
            ? Colors.white70
            : TuiiColors.bgColorScreen;
      });
    });

    _birthDateNode.addListener(() {
      setState(() {
        _birthDateColor = (_birthDateNode.hasFocus)
            ? Colors.white70
            : TuiiColors.bgColorScreen;
      });
    });

    _emailNode.addListener(() {
      setState(() {
        _emailColor =
            (_emailNode.hasFocus) ? Colors.white70 : TuiiColors.bgColorScreen;
      });
    });

    _addressNode.addListener(() {
      setState(() {
        _addressColor =
            (_addressNode.hasFocus) ? Colors.white70 : TuiiColors.bgColorScreen;
      });
    });

    // _bioNode.addListener(() {
    //   setState(() {
    //     _bioColor =
    //         (_bioNode.hasFocus) ? Colors.white70 : TuiiColors.bgColorScreen;
    //   });
    // });

    _snackbarService = sl<SnackbarService>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    ProfileState state = BlocProvider.of<ProfileCubit>(context).state;
    DateTime? birthDate = state.birthDate;
    _birthDateController =
        TextEditingController(text: state.getDateLabel(birthDate));

    isFirebase = providerIsFirebase(state.provider);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _birthDateNode.dispose();
    _emailNode.dispose();
    _addressNode.dispose();
    _bioNode.dispose();
    _birthDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  color: TuiiColors.white,
                  child: Padding(
                    padding: paddingHorizontal20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Personal Information'.i18n,
                            style: const TextStyle(
                              fontSize: 18,
                              color: TuiiColors.black,
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 5),
                        ProfileImage(
                          roleType: state.roleType!,
                          profileImage: state.profileImage,
                          profileImageUrl: state.profileImageUrl,
                          snackbarService: _snackbarService,
                          reduceSize: false,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          focusNode: _firstNameNode,
                          initialValue: state.firstName ?? '',
                          decoration: InputDecoration(
                              suffixIcon: const Icon(MdiIcons.account,
                                  color: TuiiColors.inactiveTool),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              filled: true,
                              hintStyle: const TextStyle(
                                  color: TuiiColors.inactiveTool),
                              hintText: 'First Name',
                              hoverColor: Colors.white70,
                              fillColor: _firstNameColor),
                          onChanged: (value) {
                            context
                                .read<ProfileCubit>()
                                .firstNameChanged(value);
                          },
                        ),
                        const SizedBox(height: space20),
                        TextFormField(
                          focusNode: _lastNameNode,
                          initialValue: state.lastName ?? '',
                          decoration: InputDecoration(
                              suffixIcon: const Icon(MdiIcons.account,
                                  color: TuiiColors.inactiveTool),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              filled: true,
                              hintStyle: const TextStyle(
                                  color: TuiiColors.inactiveTool),
                              hintText: 'Last Name',
                              hoverColor: Colors.white70,
                              fillColor: _lastNameColor),
                          onChanged: (value) {
                            context.read<ProfileCubit>().lastNameChanged(value);
                          },
                        ),
                        const SizedBox(height: space20),
                        TextFormField(
                          focusNode: _birthDateNode,
                          // controller:
                          //     _birthDateController,
                          initialValue: formatDate(state.birthDate),
                          maxLength: 10,
                          decoration: InputDecoration(
                              counterStyle: const TextStyle(
                                height: double.minPositive,
                              ),
                              counterText: "",
                              suffixIcon: const Icon(MdiIcons.cakeVariant,
                                  color: TuiiColors.inactiveTool),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              filled: true,
                              hintStyle: const TextStyle(
                                  color: TuiiColors.inactiveTool),
                              hintText: 'DD/MM/YYYY',
                              hoverColor: Colors.white70,
                              fillColor: _birthDateColor),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.always,
                          inputFormatters: <TextInputFormatter>[
                            TuiiDateInputFormatter(),
                          ], //
                          onChanged: (value) {
                            final currentYear = DateTime.now().year;
                            final cubit =
                                BlocProvider.of<ProfileCubit>(context);
                            final components = value.split("/");
                            if (components.length == 3) {
                              final day = int.tryParse(components[0]);
                              final month = int.tryParse(components[1]);
                              final year = int.tryParse(components[2]);
                              if (day != null &&
                                  month != null &&
                                  year != null) {
                                if (day > 0 &&
                                    day <= 31 &&
                                    month > 0 &&
                                    month <= 12 &&
                                    year > 1900 &&
                                    year <= currentYear) {
                                  try {
                                    final date = DateTime(year, month, day);

                                    cubit.birthDateChanged(date);

                                    return;
                                  } catch (e) {
                                    debugPrint('Invalid date format!'.i18n);
                                  }
                                }
                              }
                            }
                            cubit.resetBirthDate();
                          },
                        ),
                        const SizedBox(
                          height: space20,
                        ),
                        TextFormField(
                          focusNode: _emailNode,
                          readOnly: isFirebase != true ||
                              state.isInstantiatedInSettings != true,
                          initialValue: state.newEmail ?? '',
                          decoration: InputDecoration(
                              suffixIcon: const Icon(MdiIcons.email,
                                  color: TuiiColors.inactiveTool),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                      color: TuiiColors.inactiveTool,
                                      width: 1)),
                              filled: true,
                              hintStyle: const TextStyle(
                                  color: TuiiColors.inactiveTool),
                              hintText: 'Email',
                              hoverColor: Colors.white70,
                              fillColor: isFirebase == true
                                  ? _emailColor
                                  : TuiiColors.bgColorScreen),
                          onChanged: (value) {
                            if (isFirebase == true &&
                                state.isInstantiatedInSettings == true) {
                              context.read<ProfileCubit>().emailChanged(value);
                            }
                          },
                        ),
                        const SizedBox(
                          height: space20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  state.roleType == TuiiRoleType.tutor
                                      ? 'Optional: This is your studio address, where your students will come for in person lessons'
                                          .i18n
                                      : 'Optional: This is your address, where your tutor will come for in person lessons'
                                          .i18n,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: TuiiColors.defaultText,
                                  )),
                              const SizedBox(height: 10),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                focusNode: _addressNode,
                                initialValue: state.address ?? '',
                                decoration: InputDecoration(
                                    suffixIcon: const Icon(MdiIcons.mapMarker,
                                        color: TuiiColors.inactiveTool),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(
                                            color: TuiiColors.inactiveTool,
                                            width: 1)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(
                                            color: TuiiColors.inactiveTool,
                                            width: 1)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: const BorderSide(
                                            color: TuiiColors.inactiveTool,
                                            width: 1)),
                                    filled: true,
                                    hintStyle: const TextStyle(
                                        color: TuiiColors.inactiveTool),
                                    hintText: 'Address'.i18n,
                                    hoverColor: Colors.white70,
                                    fillColor: _addressColor),
                                onChanged: (value) {
                                  context
                                      .read<ProfileCubit>()
                                      .addressChanged(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
