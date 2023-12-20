import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/common/common.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/user_agent_type.dart';
import 'package:tuiicore/core/widgets/formatters/tuii_date_input_formatter.dart';
import 'package:tuiientitymodels/files/auth/data/models/child_registration_model.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class ParentChildRegistrationWidget extends StatefulWidget {
  const ParentChildRegistrationWidget(
      {Key? key,
      required this.child,
      required this.isLast,
      required this.scrollCallback})
      : super(key: key);

  final ChildRegistrationModel child;
  final bool isLast;
  final void Function() scrollCallback;

  @override
  State<ParentChildRegistrationWidget> createState() =>
      _ParentChildRegistrationWidgetState();
}

class _ParentChildRegistrationWidgetState
    extends State<ParentChildRegistrationWidget> with TickerProviderStateMixin {
  late Widget _collapseButton;
  late double _bodyHeight;
  late bool _showBody;
  late Color _borderColor;

  final double _fullBodyHeight = 220;

  final FocusNode _firstNameNode = FocusNode();
  Color _firstNameColor = TuiiColors.bgColorScreen;

  final FocusNode _lastNameNode = FocusNode();
  Color _lastNameColor = TuiiColors.bgColorScreen;

  final FocusNode _birthDateNode = FocusNode();
  Color _birthDateColor = TuiiColors.bgColorScreen;
  late TextEditingController _birthDateController;

  final FocusNode _emailNode = FocusNode();
  // Color _emailColor = TuiiColors.bgColorScreen;

  @override
  void initState() {
    _showBody = widget.child.showBody == true;
    _collapseButton = _showBody
        ? _BodyCollapseCloseButton(onPressed: collapseButtonOnPressedHandler)
        : _BodyCollapseOpenButton(onPressed: collapseButtonOnPressedHandler);
    _bodyHeight = _showBody ? _fullBodyHeight : 0;
    _borderColor = _showBody ? TuiiColors.inactiveTool : Colors.transparent;

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

    // _emailNode.addListener(() {
    //   setState(() {
    //     _emailColor =
    //         (_emailNode.hasFocus) ? Colors.white70 : TuiiColors.bgColorScreen;
    //   });
    // });

    if (getUserAgent() == UserAgentType.desktop) {
      Future.delayed(Duration.zero, () {
        _firstNameNode.requestFocus(); //auto focus on second text field.
      });
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    ProfileState state = BlocProvider.of<ProfileCubit>(context).state;
    DateTime? birthDate = widget.child.dateOfBirth;
    _birthDateController =
        TextEditingController(text: state.getDateLabel(birthDate));

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _birthDateNode.dispose();
    _emailNode.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: paddingHorizontal20,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  widget.child.showHeader == true
                      ? Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: TuiiColors.inactiveTool),
                            borderRadius: widget.child.showBody == true
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  )
                                : const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Text(widget.child.label ?? '',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: TuiiColors.defaultText,
                                            fontWeight: FontWeight.w700))),
                                SizedBox(
                                    width: 35,
                                    child: GestureDetector(
                                      onTap: () {
                                        BlocProvider.of<ProfileCubit>(context)
                                            .removeChild(widget.child);
                                      },
                                      child: const Icon(
                                          MdiIcons.closeCircleOutline,
                                          size: 20,
                                          color: TuiiColors.inactiveTool),
                                    )),
                                // AnimatedSwitcher(
                                //     duration: const Duration(milliseconds: 500),
                                //     child: _collapseButton)
                              ]))
                      : const SizedBox.shrink(),
                  Container(
                    decoration: BoxDecoration(
                        border: widget.child.showHeader == true
                            ? Border(
                                left:
                                    BorderSide(color: _borderColor, width: 1.0),
                                right:
                                    BorderSide(color: _borderColor, width: 1.0),
                                bottom:
                                    BorderSide(color: _borderColor, width: 1.0))
                            : Border(
                                top:
                                    BorderSide(color: _borderColor, width: 1.0),
                                left:
                                    BorderSide(color: _borderColor, width: 1.0),
                                right:
                                    BorderSide(color: _borderColor, width: 1.0),
                                bottom:
                                    BorderSide(color: _borderColor, width: 1.0))
                        // borderRadius: BorderRadius.only(
                        //   bottomLeft: Radius.circular(8),
                        //   bottomRight: Radius.circular(8),
                        // ),
                        ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: _bodyHeight,
                      onEnd: () {
                        setState(
                            () => _showBody = _bodyHeight == _fullBodyHeight);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: _showBody == true
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                focusNode: _firstNameNode,
                                                initialValue:
                                                    widget.child.firstName ??
                                                        '',
                                                decoration: InputDecoration(
                                                    suffixIcon: const Icon(MdiIcons.account,
                                                        color: TuiiColors
                                                            .inactiveTool),
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: const BorderSide(color: TuiiColors.inactiveTool, width: 1)),
                                                    filled: true,
                                                    hintStyle: const TextStyle(color: TuiiColors.inactiveTool),
                                                    hintText: 'First Name',
                                                    hoverColor: Colors.white70,
                                                    fillColor: _firstNameColor),
                                                onChanged: (value) {
                                                  context
                                                      .read<ProfileCubit>()
                                                      .childFirstNameChanged(
                                                          widget.child, value);
                                                },
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: space10),
                                  SizedBox(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                focusNode: _lastNameNode,
                                                initialValue:
                                                    widget.child.lastName ?? '',
                                                decoration: InputDecoration(
                                                    suffixIcon: const Icon(MdiIcons.account,
                                                        color: TuiiColors
                                                            .inactiveTool),
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                        borderSide: const BorderSide(color: TuiiColors.inactiveTool, width: 1)),
                                                    filled: true,
                                                    hintStyle: const TextStyle(color: TuiiColors.inactiveTool),
                                                    hintText: 'Last Name',
                                                    hoverColor: Colors.white70,
                                                    fillColor: _lastNameColor),
                                                onChanged: (value) {
                                                  context
                                                      .read<ProfileCubit>()
                                                      .childLastNameChanged(
                                                          widget.child, value);
                                                },
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: space10),
                                  SizedBox(
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                focusNode: _birthDateNode,
                                                // controller:
                                                //     _birthDateController,
                                                initialValue: formatDate(
                                                    widget.child.dateOfBirth),
                                                maxLength: 10,
                                                decoration: InputDecoration(
                                                    counterStyle:
                                                        const TextStyle(
                                                      height:
                                                          double.minPositive,
                                                    ),
                                                    counterText: "",
                                                    suffixIcon: const Icon(
                                                        MdiIcons.cakeVariant,
                                                        color: TuiiColors
                                                            .inactiveTool),
                                                    border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors
                                                                .inactiveTool,
                                                            width: 1)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            5.0),
                                                        borderSide: const BorderSide(
                                                            color: TuiiColors.inactiveTool,
                                                            width: 1)),
                                                    filled: true,
                                                    hintStyle: const TextStyle(color: TuiiColors.inactiveTool),
                                                    hintText: 'DD/MM/YYYY',
                                                    hoverColor: Colors.white70,
                                                    fillColor: _birthDateColor),
                                                keyboardType:
                                                    TextInputType.number,
                                                autovalidateMode:
                                                    AutovalidateMode.always,
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  TuiiDateInputFormatter(),
                                                ], //
                                                onChanged: (value) {
                                                  // int? year = int.tryParse(value);
                                                  // if (year != null) {
                                                  //   context
                                                  //       .read<ParentCubit>()
                                                  //       .childBirthYearChanged(
                                                  //           widget.child, year);
                                                  // } else {
                                                  //   context
                                                  //       .read<ParentCubit>()
                                                  //       .resetChildBirthYear(
                                                  //           widget.child);
                                                  // }
                                                  final currentYear =
                                                      DateTime.now().year;
                                                  final cubit = BlocProvider.of<
                                                      ProfileCubit>(context);
                                                  final components =
                                                      value.split("/");
                                                  if (components.length == 3) {
                                                    final day = int.tryParse(
                                                        components[0]);
                                                    final month = int.tryParse(
                                                        components[1]);
                                                    final year = int.tryParse(
                                                        components[2]);
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
                                                          final date = DateTime(
                                                              year, month, day);

                                                          cubit
                                                              .childBirthDateChanged(
                                                                  widget.child,
                                                                  date);

                                                          return;
                                                        } catch (e) {
                                                          debugPrint(
                                                              'Invalid date format!'
                                                                  .i18n);
                                                        }
                                                      }
                                                    }
                                                  }
                                                  cubit.resetChildBirthDate(
                                                      widget.child);
                                                },
                                                // onTap: () async {
                                                //   var result = await showModal(
                                                //       context: context,
                                                //       configuration:
                                                //           const FadeScaleTransitionConfiguration(
                                                //               barrierDismissible:
                                                //                   false),
                                                //       builder:
                                                //           (BuildContext context) {
                                                //         return TuiiDatePickerDialog(
                                                //           dialogTitle:
                                                //               'Your Child\'s Birthday!'
                                                //                   .i18n,
                                                //           initialDate: widget
                                                //               .child.dateOfBirth,
                                                //           disableFutureDates:
                                                //               true,
                                                //         );
                                                //       });
                                                //   if (result is DateTime) {
                                                //     final bloc = BlocProvider.of<
                                                //         ParentCubit>(context);

                                                //     bloc.childBirthDateChanged(
                                                //         widget.child, result);
                                                //     setState(() {
                                                //       _birthDateController.text =
                                                //           bloc.state.getDateLabel(
                                                //               result);
                                                //     });
                                                //   }
                                                // },
                                              ),
                                            ),

                                            // TextFormField(
                                            //   focusNode: _emailNode,
                                            //   readOnly: true,
                                            //   initialValue: widget.child.email,
                                            //   decoration: InputDecoration(
                                            //       suffixIcon: const Icon(
                                            //           MdiIcons.email,
                                            //           color: TuiiColors
                                            //               .inactiveTool),
                                            //       border: OutlineInputBorder(
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   5.0),
                                            //           borderSide: const BorderSide(
                                            //               color: TuiiColors
                                            //                   .inactiveTool,
                                            //               width: 1)),
                                            //       enabledBorder: OutlineInputBorder(
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   5.0),
                                            //           borderSide:
                                            //               const BorderSide(
                                            //                   color: TuiiColors
                                            //                       .inactiveTool,
                                            //                   width: 1)),
                                            //       focusedBorder: OutlineInputBorder(
                                            //           borderRadius: BorderRadius.circular(5.0),
                                            //           borderSide: const BorderSide(color: TuiiColors.inactiveTool, width: 1)),
                                            //       filled: true,
                                            //       hintStyle: const TextStyle(color: TuiiColors.inactiveTool),
                                            //       hintText: 'Email',
                                            //       hoverColor: Colors.white70,
                                            //       fillColor: _emailColor),
                                            //   onChanged: (value) {},
                                            // ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  widget.isLast
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(
                                    child: SizedBox.shrink(),
                                  ),
                                  _AddChildButton(callback: () {
                                    final cubit =
                                        BlocProvider.of<ProfileCubit>(context);
                                    final state = cubit.state;
                                    cubit.addChild(ChildRegistrationModel(
                                      lastName: state.lastName,
                                      email: state.newEmail ?? state.email,
                                      creationTimestamp: DateTime.now(),
                                      showBody: true,
                                    ));

                                    Future.delayed(
                                        const Duration(milliseconds: 100), () {
                                      widget.scrollCallback();
                                    });
                                  }),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ])
                      : const SizedBox.shrink()
                ])),
          ]),
    );
  }

  void collapseButtonOnPressedHandler(bool fromOpen) {
    final cubit = BlocProvider.of<ProfileCubit>(context);
    if (fromOpen) {
      setState(() {
        _collapseButton =
            _BodyCollapseCloseButton(onPressed: collapseButtonOnPressedHandler);
        _bodyHeight = _fullBodyHeight;
        _borderColor = TuiiColors.inactiveTool;
      });

      cubit.showChildBody(widget.child);
    } else {
      setState(() {
        _collapseButton =
            _BodyCollapseOpenButton(onPressed: collapseButtonOnPressedHandler);
        _bodyHeight = 0;
        _showBody = false;
        _borderColor = Colors.transparent;
      });

      cubit.hideChildBody(widget.child);
    }
  }
}

class _BodyCollapseOpenButton extends StatelessWidget {
  const _BodyCollapseOpenButton({Key? key, required this.onPressed})
      : super(key: key);

  final void Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      splashRadius: 1.0,
      splashColor: Colors.transparent,
      icon: const Icon(MdiIcons.chevronUp,
          color: TuiiColors.inactiveTool, size: 26),
      onPressed: () {
        onPressed(true);
      },
    );
  }
}

class _BodyCollapseCloseButton extends StatelessWidget {
  const _BodyCollapseCloseButton({Key? key, required this.onPressed})
      : super(key: key);

  final void Function(bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      splashRadius: 1.0,
      splashColor: Colors.transparent,
      icon: const Icon(MdiIcons.chevronDown,
          color: TuiiColors.inactiveTool, size: 26),
      onPressed: () {
        onPressed(false);
      },
    );
  }
}

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({Key? key, required this.callback}) : super(key: key);

  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: TuiiColors.primary, borderRadius: BorderRadius.circular(8)),
      child: Material(
        child: InkWell(
          hoverColor: TuiiColors.primary.withOpacity(0.1),
          splashColor: TuiiColors.primary,
          onTap: () {
            callback();
          },
          child: SizedBox(
              width: 200.0,
              height: 36.0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      MdiIcons.plus,
                      size: 16,
                      color: TuiiColors.white,
                    ),
                    const SizedBox(width: 10),
                    Text('Add Another Child'.i18n,
                        style: const TextStyle(
                            fontSize: 16.0, color: TuiiColors.white)),
                  ],
                ),
              )),
        ),
        color: TuiiColors.primaryTransparentBackground,
      ),
    );
  }
}
