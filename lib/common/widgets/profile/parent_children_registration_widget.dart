import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiientitymodels/files/auth/data/models/child_registration_model.dart';
import 'package:tuiipwa/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:tuiipwa/features/auth/presentation/widgets/parent_child_registration_widget.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/utils/spacing.dart';

class ParentChildrenRegistrationWidget extends StatefulWidget {
  const ParentChildrenRegistrationWidget(
      {super.key,
      required this.isInstantiatedInSettings,
      required this.containerHeight});

  final bool isInstantiatedInSettings;
  final double containerHeight;

  @override
  State<ParentChildrenRegistrationWidget> createState() =>
      _ParentChildrenRegistrationWidgetState();
}

class _ParentChildrenRegistrationWidgetState
    extends State<ParentChildrenRegistrationWidget> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () => _scrollDown());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        List<ChildRegistrationModel> children = List.from(state.children ?? []);

        return LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _controller,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  color: TuiiColors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Child Profile Setup'.i18n,
                          style: const TextStyle(
                            fontSize: 18,
                            color: TuiiColors.defaultText,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: space10),
                      Flexible(
                        child: Padding(
                          padding: paddingHorizontal20,
                          child: Text(
                              'As a parent, each of your children who use Tuii will need a learning profile.'
                                  .i18n,
                              style: const TextStyle(
                                fontSize: 14,
                                color: TuiiColors.defaultText,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                      const SizedBox(height: space10),
                      Flexible(
                        child: Padding(
                          padding: paddingHorizontal20,
                          child: Text(
                              'Add your children\'s profiles below. You can add more profiles later in the settings menu.'
                                  .i18n,
                              style: const TextStyle(
                                fontSize: 14,
                                color: TuiiColors.defaultText,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                      const SizedBox(height: space20),
                      Flexible(
                        child: Padding(
                          padding: paddingHorizontal20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('For more information refer to this '.i18n,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: TuiiColors.defaultText,
                                    fontWeight: FontWeight.w700,
                                  )),
                              GestureDetector(
                                onTap: () {},
                                child: Text('KB Article.'.i18n,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      color: TuiiColors.linkTextColor,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: space20),
                      ..._getChildWidgets(children)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  List<Widget> _getChildWidgets(List<ChildRegistrationModel> children) {
    List<Widget> widgets = [];
    final ln = children.length - 1;
    for (int i = 0; i <= ln; i++) {
      final isLast = i == ln;
      final child = children[i];
      widgets.add(ParentChildRegistrationWidget(
        child: child,
        isLast: isLast,
        scrollCallback: _scrollDown,
      ));

      if (!isLast) {
        widgets.add(const SizedBox(
          height: 20,
        ));
      }
    }

    return widgets;
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}
