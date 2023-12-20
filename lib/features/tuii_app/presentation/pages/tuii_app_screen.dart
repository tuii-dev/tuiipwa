// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuiicore/core/config/theme/tuii_colors.dart';
import 'package:tuiipwa/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tuiipwa/features/auth/presentation/pages/login_screen.dart';
import 'package:tuiipwa/features/tuii_app/presentation/bloc/tuii_beacon/tuii_beacon_bloc.dart';
import 'package:tuiipwa/utils/pwa_i18n.dart';

class TuiiAppScreen extends StatefulWidget {
  static const String routeName = '/app';

  const TuiiAppScreen({super.key});

  @override
  State<TuiiAppScreen> createState() => _TuiiAppScreenState();
}

class _TuiiAppScreenState extends State<TuiiAppScreen> {
  int selectedPos = 0;
  Color tabItemColor = TuiiColors.primary;
  Color tabItemLabelColor = TuiiColors.defaultText;

  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(selectedPos);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
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
                                BlocProvider.of<TuiiBeaconBloc>(context).add(
                                    const ShowBeaconCommandEvent(
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
          body: Container(),
          bottomNavigationBar: CircularBottomNavigation(
            [
              TabItem(Icons.home, "Home".i18n, tabItemColor,
                  circleStrokeColor: TuiiColors.white,
                  labelStyle: TextStyle(
                      color: tabItemLabelColor, fontWeight: FontWeight.bold)),
              // TODO: Fix this
              TabItem(Icons.account_circle, "Educators".i18n, tabItemColor,
                  circleStrokeColor: TuiiColors.white,
                  labelStyle: TextStyle(
                      color: tabItemLabelColor, fontWeight: FontWeight.bold)),
              TabItem(Icons.attach_money, "Bookings".i18n, tabItemColor,
                  circleStrokeColor: TuiiColors.white,
                  labelStyle: TextStyle(
                      color: tabItemLabelColor, fontWeight: FontWeight.bold)),
              TabItem(Icons.notifications, "Notifications".i18n, tabItemColor,
                  circleStrokeColor: TuiiColors.white,
                  labelStyle: TextStyle(
                      color: tabItemLabelColor, fontWeight: FontWeight.bold)),
              TabItem(MdiIcons.chatProcessing, "Chats".i18n, tabItemColor,
                  circleStrokeColor: TuiiColors.white,
                  labelStyle: TextStyle(
                      color: tabItemLabelColor, fontWeight: FontWeight.bold)),
            ],
            controller: _navigationController,
            barHeight: 60,
            animationDuration: const Duration(milliseconds: 300),
            selectedPos: selectedPos,
            selectedCallback: (int? selectedPos) {
              debugPrint("clicked on $selectedPos");
              setState(() => selectedPos = selectedPos ?? 0);
            },
          )

          // CurvedNavigationBar(
          //   animationDuration: const Duration(milliseconds: 150),
          //   color: TuiiColors.defaultColor,
          //   backgroundColor: TuiiColors.bgColorScreen,
          //   buttonBackgroundColor: TuiiColors.defaultColor,
          //   height: 60,
          //   items: const [
          //     Icon(
          //       Icons.home,
          //       size: 30,
          //       color: TuiiColors.white,
          //     ),
          //     Icon(
          //       Icons.account_circle,
          //       size: 30,
          //       color: TuiiColors.white,
          //     ),
          //     Icon(
          //       Icons.attach_money,
          //       size: 30,
          //       color: TuiiColors.white,
          //     ),
          //     Icon(
          //       Icons.message,
          //       size: 30,
          //       color: TuiiColors.white,
          //     ),
          //     Icon(
          //       Icons.notifications,
          //       size: 30,
          //       color: TuiiColors.white,
          //     ),
          //   ],
          //   onTap: (index) {
          //     //Handle button tap
          //   },
          // ),
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}
