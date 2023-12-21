import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiicore/core/enums/enums.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/bookings/presentation/pages/bookings_screen.dart';
import 'package:tuiipwa/features/communications/presentation/pages/communications_screen.dart';
import 'package:tuiipwa/features/home/presentation/pages/home_screen.dart';
import 'package:tuiipwa/features/individuals/presentation/pages/individuals_screen.dart';
import 'package:tuiipwa/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_app/tuii_app_bloc.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_beacon/tuii_beacon_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';
import 'package:tuiipwa/web/constants/constants.dart';

class TuiiAppScreen extends StatefulWidget {
  static const String routeName = '/app';

  const TuiiAppScreen({super.key});

  @override
  State<TuiiAppScreen> createState() => _TuiiAppScreenState();
}

class _TuiiAppScreenState extends State<TuiiAppScreen> {
  int _selectedIndex = 0;
  Color tabItemColor = TuiiColors.primary;
  Color tabItemLabelColor = TuiiColors.defaultText;
  List<Widget> _forms = [];
  Offset _beginSlideOffset = const Offset(-1.0, 0.0);

  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _forms = _getForms();
    _navigationController = CircularBottomNavigationController(_selectedIndex);
    // _navigationController.addListener(() {
    //   setState(() => _selectedIndex = _navigationController.value ?? 0);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, authState) {
          if (authState.status == AuthStatus.unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                LoginScreen.routeName, (route) => false);
          }
        },
        builder: (context, authState) {
          return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: TuiiColors.white,
              appBar: AppBar(
                  backgroundColor: TuiiColors.defaultDarkColor,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Image.asset(
                      'assets/images/logos/tuii_expanded_logo_1x.png',
                      width: 59,
                      height: 27,
                    ),
                  ),
                  actions: [
                    BlocBuilder<TuiiBeaconBloc, TuiiBeaconState>(
                      builder: (context, state) {
                        return state.beaconVisible == true
                            ? IconButton(
                                icon: const Icon(
                                  MdiIcons.helpCircleOutline,
                                  size: 30,
                                  color: TuiiColors.white,
                                ),
                                onPressed: () =>
                                    BlocProvider.of<TuiiBeaconBloc>(context)
                                        .add(const HideBeaconCommandEvent()),
                              )
                            : IconButton(
                                icon: const Icon(
                                  MdiIcons.helpCircle,
                                  size: 30,
                                  color: TuiiColors.white,
                                ),
                                onPressed: () =>
                                    BlocProvider.of<TuiiBeaconBloc>(context)
                                        .add(const ShowBeaconCommandEvent(
                                            openOnLoad: true)),
                              );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        size: 30,
                        color: TuiiColors.white,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        size: 30,
                        color: TuiiColors.white,
                      ),
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context)
                            .add(AuthLogoutRequested());
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ]),
              body: BlocBuilder<TuiiAppBloc, TuiiAppState>(
                builder: (context, state) {
                  return LayoutBuilder(builder: (context, constraints) {
                    return SystemConstantsProvider(
                      child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: SlideIndexedStack(
                            beginSlideOffset: _beginSlideOffset,
                            endSlideOffset: const Offset(0.0, 0.0),
                            curve: Curves.easeInOut,
                            duration: const Duration(milliseconds: 200),
                            index: _selectedIndex,
                            children: _forms,
                          )),
                    );
                  });
                },
              ),
              bottomNavigationBar: CircularBottomNavigation(
                [
                  TabItem(Icons.home, "Home".i18n, tabItemColor,
                      circleStrokeColor: TuiiColors.white,
                      labelStyle: TextStyle(
                          color: tabItemLabelColor,
                          fontWeight: FontWeight.bold)),
                  TabItem(
                      Icons.account_circle,
                      authState.user!.roleType == TuiiRoleType.tutor
                          ? "Students".i18n
                          : "Educators".i18n,
                      tabItemColor,
                      circleStrokeColor: TuiiColors.white,
                      labelStyle: TextStyle(
                          color: tabItemLabelColor,
                          fontWeight: FontWeight.bold)),
                  TabItem(Icons.attach_money, "Bookings".i18n, tabItemColor,
                      circleStrokeColor: TuiiColors.white,
                      labelStyle: TextStyle(
                          color: tabItemLabelColor,
                          fontWeight: FontWeight.bold)),
                  TabItem(
                      Icons.notifications, "Notifications".i18n, tabItemColor,
                      circleStrokeColor: TuiiColors.white,
                      labelStyle: TextStyle(
                          color: tabItemLabelColor,
                          fontWeight: FontWeight.bold)),
                  TabItem(MdiIcons.chatProcessing, "Chats".i18n, tabItemColor,
                      circleStrokeColor: TuiiColors.white,
                      labelStyle: TextStyle(
                          color: tabItemLabelColor,
                          fontWeight: FontWeight.bold)),
                ],
                controller: _navigationController,
                barHeight: 60,
                animationDuration: const Duration(milliseconds: 200),
                selectedPos: _selectedIndex,
                selectedCallback: (int? selectedIndex) {
                  debugPrint("clicked on $selectedIndex");
                  if ((selectedIndex ?? 0) > _selectedIndex) {
                    setState(() {
                      _beginSlideOffset = const Offset(-1.0, 0.0);
                      _selectedIndex = selectedIndex ?? 0;
                    });
                  } else {
                    setState(() {
                      _beginSlideOffset = const Offset(1.0, 0.0);
                      _selectedIndex = selectedIndex ?? 0;
                    });
                  }
                },
              ));
        });
  }

  List<Widget> _getForms() {
    return const [
      HomeScreen(),
      IndividualsScreen(),
      BookingsScreen(),
      NotificationsScreen(),
      CommunicationsScreen(),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}
