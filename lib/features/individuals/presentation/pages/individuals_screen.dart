import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/tuii_role_type.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class IndividualsScreen extends StatefulWidget {
  const IndividualsScreen({super.key});

  @override
  State<IndividualsScreen> createState() => _IndividualsScreenState();
}

class _IndividualsScreenState extends State<IndividualsScreen> {
  late FocusNode _focus;
  late TextEditingController _controller;

  @override
  void initState() {
    _focus = FocusNode();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleType = BlocProvider.of<AuthBloc>(context).state.user!.roleType;
    return Padding(
      padding: paddingAll20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 70,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    roleType == TuiiRoleType.tutor
                        ? 'Students'.i18n
                        : 'Educators'.i18n,
                    style: const TextStyle(
                      color: TuiiColors.defaultText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Container(
                      height: 38,
                      padding: EdgeInsets.zero,
                      child: TextFormField(
                        focusNode: _focus,
                        autofocus: false, // _autoFocus,
                        controller: _controller,
                        textAlignVertical: TextAlignVertical.center,
                        onFieldSubmitted: (value) => _runSearch(null, value),
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _runSearch(null, _controller.text),
                              child: const SizedBox(
                                width: 18,
                                height: 38,
                                child: Icon(MdiIcons.magnify,
                                    color: TuiiColors.black, size: 24),
                              ),
                            ),
                            suffixIcon: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _runSearch(null, _controller.text),
                              child: const SizedBox(
                                width: 18,
                                height: 38,
                                child: Icon(MdiIcons.filterVariant,
                                    color: TuiiColors.black, size: 24),
                              ),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(19.0),
                                borderSide: const BorderSide(
                                    color: TuiiColors.inactiveBackground,
                                    width: 1)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(19.0),
                                borderSide: const BorderSide(
                                    color: TuiiColors.inactiveBackground,
                                    width: 1)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(19.0),
                                borderSide: const BorderSide(
                                    color: TuiiColors.inactiveBackground,
                                    width: 1)),
                            filled: true,
                            hintStyle: const TextStyle(color: TuiiColors.muted),
                            hintText: "Search...".i18n,
                            hoverColor: TuiiColors.inactiveBackground,
                            fillColor: TuiiColors.inactiveBackground),
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _runSearch(dynamic state, String value) {}
}
