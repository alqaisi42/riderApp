import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_navigation_icon.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'banner_widget.dart';
import 'home_on_going_rides.dart';
import 'recent_search_places_widget.dart';
import 'services_module_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final BuildContext cont;

  const BottomSheetWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<HomeBloc>(),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;
            final baseSurface = theme.scaffoldBackgroundColor;
            final haloColor = colorScheme.primary.withOpacity(isDark ? 0.25 : 0.12);
            final cardBorder = theme.dividerColor.withOpacity(isDark ? 0.45 : 0.22);
            final cardShadow = colorScheme.primary.withOpacity(isDark ? 0.18 : 0.24);
            final overlayTint = colorScheme.secondary
                .withOpacity(isDark ? 0.12 : 0.06);
            return Container(
              height: size.height,
              margin: const EdgeInsets.only(top: 1),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              baseSurface.withOpacity(isDark ? 0.9 : 0.95),
                              baseSurface.withOpacity(isDark ? 0.92 : 1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          color:
                              baseSurface.withOpacity(isDark ? 0.78 : 0.82),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              overlayTint,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!context.read<HomeBloc>().isSheetAtTop) ...[
                          SizedBox(height: size.width * 0.03),
                          Center(
                            child: Container(
                              height: 6,
                              width: size.width * 0.22,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [
                                    haloColor,
                                    haloColor.withOpacity(isDark ? 0.45 : 0.25),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * 0.035),
                        ],
                        if (context.read<HomeBloc>().isSheetAtTop)
                          SizedBox(height: size.width * 0.15),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.045),
                          child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        final homeBloc = context.read<HomeBloc>();
                        if (homeBloc.userData == null) {
                          return const SizedBox.shrink(); // Or a loading indicator
                        }
                        // Access the current sheetSize directly from HomeBloc
                        double sheetSize = context.read<HomeBloc>().sheetSize;
                        double maxSheetSize =
                            context.read<HomeBloc>().maxChildSize;
                        double recentSearchWidth = sheetSize == maxSheetSize
                            ? size.width * 0.9
                            : size.width * 0.9;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: cardBorder, width: 1.1),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface.withOpacity(
                                    isDark ? 0.55 : 0.82),
                                theme.colorScheme.surfaceVariant.withOpacity(
                                    isDark ? 0.35 : 0.45),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.035,
                              vertical: size.width * 0.04,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: size.width * 0.02),
                                    if (context.read<HomeBloc>().isSheetAtTop ==
                                            true &&
                                        context.read<HomeBloc>().userData !=
                                            null)
                                      Flexible(
                                        child: NavigationIconWidget(
                                          icon: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                      AccountPage.routeName,
                                                      arguments:
                                                          AccountPageArguments(
                                                              userData: context
                                                                  .read<
                                                                      HomeBloc>()
                                                                  .userData!))
                                                  .then((value) {
                                                if (!context.mounted) return;
                                                context
                                                    .read<HomeBloc>()
                                                    .add(GetDirectionEvent());
                                                if (value != null) {
                                                  context
                                                          .read<HomeBloc>()
                                                          .userData =
                                                      value as UserDetail;
                                                  context
                                                      .read<HomeBloc>()
                                                      .add(UpdateEvent());
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.menu,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                          ),
                                          isShadowWidget: true,
                                        ),
                                      ),
                                    if (context.read<HomeBloc>().isSheetAtTop)
                                      SizedBox(width: size.width * 0.02),
                                    Flexible(
                                      flex: context
                                          .read<HomeBloc>()
                                          .calculateResponsiveFlex(size.width),
                                        child: InkWell(
                                          onTap: () {
                                            final homeBloc = context.read<HomeBloc>();
                                            if (homeBloc.userData != null) {
                                              if (homeBloc.userData!.enableModulesForApplications ==
                                                'both' ||
                                                homeBloc.userData!.enableModulesForApplications ==
                                                    'taxi') {
                                              homeBloc.add(DestinationSelectEvent(
                                                  isPickupChange: false));
                                            } else {
                                              homeBloc.add(ServiceTypeChangeEvent(
                                                  serviceTypeIndex: 1));
                                            }
                                          }
                                        },
                                        child: AnimatedContainer(
                                          transformAlignment:
                                              Alignment.centerRight,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          width: recentSearchWidth,
                                          padding:
                                              EdgeInsets.all(size.width * 0.022),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            border: Border.all(
                                              color: cardBorder,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                theme.colorScheme.surface
                                                    .withOpacity(isDark ? 0.6 : 0.85),
                                                theme.colorScheme.surface
                                                    .withOpacity(isDark ? 0.4 : 0.65),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: cardShadow,
                                                blurRadius: 22,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: size.width * 0.085,
                                                height: size.width * 0.085,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      colorScheme.primary
                                                          .withOpacity(isDark ? 0.55 : 0.9),
                                                      colorScheme.secondary
                                                          .withOpacity(isDark ? 0.5 : 0.7),
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: colorScheme.primary
                                                          .withOpacity(isDark ? 0.35 : 0.25),
                                                      blurRadius: 18,
                                                      offset: const Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.search,
                                                  size: 20,
                                                  color: colorScheme.onPrimary,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              Expanded(
                                                // Place Expanded inside Row to prevent overflow here
                                                child: MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .whereAreYouGoing,
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          color: theme
                                                              .primaryColorDark
                                                              .withAlpha((0.75 * 255).toInt()),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16),
                                                ),
                                              ),
                                              if (context
                                                          .read<HomeBloc>()
                                                          .userData !=
                                                      null &&
                                                  (context
                                                          .read<HomeBloc>()
                                                          .userData!
                                                          .showRideWithoutDestination ==
                                                      "1") &&
                                                  (context
                                                              .read<HomeBloc>()
                                                              .userData!
                                                              .enableModulesForApplications ==
                                                          'taxi' ||
                                                      context
                                                              .read<HomeBloc>()
                                                              .userData!
                                                              .enableModulesForApplications ==
                                                          'both'))
                                                InkWell(
                                                  onTap: () {
                                                    final homeBloc = context.read<HomeBloc>();
                                                    if (homeBloc.userData != null) {
                                                      homeBloc.add(
                                                          RideWithoutDestinationEvent());
                                                    }
                                                  },
                                                  child: Container(
                                                    height: size.width * 0.078,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(20),
                                                      color: theme.disabledColor
                                                          .withOpacity(isDark ? 0.08 : 0.15),
                                                    ),
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .skip,
                                                      textStyle: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: theme
                                                                .primaryColorDark
                                                                .withAlpha(
                                                                    (0.55 * 255)
                                                                        .toInt()),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Banner
                                if (context.read<HomeBloc>().isSheetAtTop ==
                                        false &&
                                    context.read<HomeBloc>().userData != null &&
                                    homeBloc.userData!.bannerImage != null &&
                                    context
                                        .read<HomeBloc>()
                                        .userData!
                                        .bannerImage
                                        .data
                                        .isNotEmpty) ...[
                                  SizedBox(height: size.width * 0.025),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BannerWidget(cont: context),
                                  ),
                                ],
                                // Service Modules
                                if (context.read<HomeBloc>().userData != null &&
                                    ((context
                                                .read<HomeBloc>()
                                                .userData!
                                                .enableModulesForApplications ==
                                            'both') ||
                                        (context
                                                    .read<HomeBloc>()
                                                    .userData!
                                                    .enableModulesForApplications ==
                                                'taxi' &&
                                            context
                                                .read<HomeBloc>()
                                                .userData!
                                                .showRentalRide) ||
                                        (context
                                                    .read<HomeBloc>()
                                                    .userData!
                                                    .enableModulesForApplications ==
                                                'delivery' &&
                                            context
                                                .read<HomeBloc>()
                                                .userData!
                                                .showRentalRide)))
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * 0.01),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: cardBorder),
                                        color: theme.colorScheme.surface
                                            .withOpacity(isDark ? 0.45 : 0.7),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.035,
                                          vertical: size.width * 0.035,
                                        ),
                                        child: ServicesModuleWidget(cont: cont),
                                      ),
                                    ),
                                  ),

                                // ON GOING RIDES
                                if (context
                                    .read<HomeBloc>()
                                    .isMultipleRide) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText(
                                            text: AppLocalizations.of(context)!
                                                .onGoingRides,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColorDark)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.01),
                                  HomeOnGoingRidesWidget(cont: context),
                                ],
                                // Recent search places
                                if (context
                                    .read<HomeBloc>()
                                    .recentSearchPlaces
                                    .isNotEmpty) ...[
                                  SizedBox(
                                      height: context
                                                  .read<HomeBloc>()
                                                  .isSheetAtTop ==
                                              false
                                          ? size.width * 0.01
                                          : size.width * 0.02),
                                  RecentSearchPlacesWidget(cont: context)
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: size.width * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (context.read<HomeBloc>().isSheetAtTop == true &&
                          context.read<HomeBloc>().userData != null &&
                          context
                              .read<HomeBloc>()
                              .userData!
                              .bannerImage != null &&
                          context
                              .read<HomeBloc>()
                              .userData!
                              .bannerImage
                              .data
                              .isNotEmpty) ...[
                        SizedBox(height: size.width * 0.025),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.045),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BannerWidget(cont: context),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: size.width * 0.1),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          AppImages.bottomBackground,
                          fit: BoxFit.cover,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                baseSurface.withOpacity(isDark ? 0.65 : 0.55),
                                baseSurface.withOpacity(isDark ? 0.92 : 0.85),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ));
  }
}
