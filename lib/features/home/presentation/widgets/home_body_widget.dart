import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../common/common.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'bottom_sheet_widget.dart';

class HomeBodyWidget extends StatelessWidget {
  final BuildContext cont;

  const HomeBodyWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color primary = theme.colorScheme.primary;
    final Color secondary = theme.colorScheme.secondary;
    final Color scaffold = theme.scaffoldBackgroundColor;
    final Color accentBlend = Color.lerp(primary, secondary, 0.35) ?? primary;
    final Color glassBackground =
        scaffold.withOpacity(isDark ? 0.55 : 0.9);
    final Color borderColor = primary.withOpacity(isDark ? 0.4 : 0.12);
    final Color topOverlayStart = primary.withOpacity(isDark ? 0.28 : 0.22);
    final Color topOverlayEnd = scaffold.withOpacity(0.0);
    final Color bottomOverlayBase =
        Color.lerp(scaffold, accentBlend, isDark ? 0.2 : 0.12) ?? scaffold;
    final Color bottomOverlayStart =
        bottomOverlayBase.withOpacity(isDark ? 0.82 : 0.68);
    final Color bottomOverlayEnd = scaffold.withOpacity(0.0);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Stack(
            children: [
              // The map and other widgets
              SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    (context.read<HomeBloc>().mapType == 'google_map')
                        // GOOGLE MAP
                        ? SizedBox(
                            height: size.height,
                            width: size.width,
                            child: GoogleMap(
                              mapType: context.read<HomeBloc>().selectedMapType,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                if (context
                                        .read<HomeBloc>()
                                        .googleMapController ==
                                    null) {
                                  context.read<HomeBloc>().add(
                                      GoogleControllAssignEvent(
                                          controller: controller,
                                          isFromHomePage: true,
                                          isEditAddress: false,
                                          latlng: context
                                              .read<HomeBloc>()
                                              .currentLatLng));
                                } else {
                                  context.read<HomeBloc>().add(LocateMeEvent(
                                      mapType:
                                          context.read<HomeBloc>().mapType));
                                }
                              },
                              padding: EdgeInsets.only(
                                  bottom: screenWidth + size.width * 0.01),
                              initialCameraPosition: CameraPosition(
                                target: context.read<HomeBloc>().currentLatLng,
                                zoom: 15.0,
                              ),
                              onTap: (argument) {
                                context.read<HomeBloc>().currentLatLng =
                                    argument;
                                if (context
                                        .read<HomeBloc>()
                                        .googleMapController !=
                                    null) {
                                  context
                                      .read<HomeBloc>()
                                      .googleMapController!
                                      .animateCamera(
                                          CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: argument, zoom: 15)));
                                }
                              },
                              onCameraMoveStarted: () {
                                context.read<HomeBloc>().setDragging(true);

                                context.read<HomeBloc>().isCameraMoveComplete =
                                    true;
                              },
                              onCameraMove: (CameraPosition? position) {
                                if (position != null) {
                                  if (!context.mounted) return;
                                  context.read<HomeBloc>().currentLatLng =
                                      position.target;
                                }
                              },
                              onCameraIdle: () {
                                context.read<HomeBloc>().setDragging(false);
                                if (context
                                    .read<HomeBloc>()
                                    .isCameraMoveComplete) {
                                  if (context
                                      .read<HomeBloc>()
                                      .pickupAddressList
                                      .isEmpty) {
                                    context.read<HomeBloc>().add(
                                        UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: context
                                                .read<HomeBloc>()
                                                .currentLatLng,
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType));
                                  } else {
                                    context.read<HomeBloc>().confirmPinAddress =
                                        true;
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                }
                              },
                              markers:
                                  context.read<HomeBloc>().markerList.isNotEmpty
                                      ? Set.from(
                                          context.read<HomeBloc>().markerList)
                                      : {},
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(13, 20),
                              buildingsEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                            ),
                          ) // OPEN STREET MAP
                        : SizedBox(
                            height: size.height * 0.55,
                            width: size.width,
                            child: fm.FlutterMap(
                              mapController:
                                  context.read<HomeBloc>().fmController,
                              options: fm.MapOptions(
                                onTap: (tapPosition, latLng) {
                                  context.read<HomeBloc>().currentLatLng =
                                      LatLng(latLng.latitude, latLng.longitude);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (context.read<HomeBloc>().fmController !=
                                        null) {
                                      context
                                          .read<HomeBloc>()
                                          .fmController!
                                          .move(latLng, 15);
                                    }
                                  });
                                  context.read<HomeBloc>().add(
                                        UpdateLocationEvent(
                                          isFromHomePage: true,
                                          latLng: context
                                              .read<HomeBloc>()
                                              .currentLatLng,
                                          mapType:
                                              context.read<HomeBloc>().mapType,
                                        ),
                                      );
                                },
                                onMapEvent: (v) async {
                                  if (v.source ==
                                      fm.MapEventSource.nonRotatedSizeChange) {
                                    context.read<HomeBloc>().fmLatLng =
                                        fmlt.LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().add(
                                          UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: context
                                                .read<HomeBloc>()
                                                .currentLatLng,
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType,
                                          ),
                                        );
                                  }
                                  if (v.source == fm.MapEventSource.onDrag) {
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude);
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                  if (v.source == fm.MapEventSource.dragEnd) {
                                    context.read<HomeBloc>().add(
                                          UpdateLocationEvent(
                                            isFromHomePage: true,
                                            latLng: LatLng(
                                                v.camera.center.latitude,
                                                v.camera.center.longitude),
                                            mapType: context
                                                .read<HomeBloc>()
                                                .mapType,
                                          ),
                                        );
                                  }
                                },
                                onPositionChanged: (p, l) async {
                                  if (l == false) {
                                    context.read<HomeBloc>().currentLatLng =
                                        LatLng(p.center.latitude,
                                            p.center.longitude);
                                    context.read<HomeBloc>().add(UpdateEvent());
                                  }
                                },
                                initialCenter: fmlt.LatLng(
                                    context
                                        .read<HomeBloc>()
                                        .currentLatLng
                                        .latitude,
                                    context
                                        .read<HomeBloc>()
                                        .currentLatLng
                                        .longitude),
                                initialZoom: 16,
                                minZoom: 13,
                                maxZoom: 20,
                              ),
                              children: [
                                fm.TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                fm.MarkerLayer(
                                  markers: context
                                      .read<HomeBloc>()
                                      .markerList
                                      .asMap()
                                      .map(
                                        (k, value) {
                                          final marker = context
                                              .read<HomeBloc>()
                                              .markerList
                                              .elementAt(k);
                                          return MapEntry(
                                            k,
                                            fm.Marker(
                                              alignment: Alignment.topCenter,
                                              point: fmlt.LatLng(
                                                  marker.position.latitude,
                                                  marker.position.longitude),
                                              child: RotationTransition(
                                                turns: AlwaysStoppedAnimation(
                                                    marker.rotation / 360),
                                                child: Image.asset(
                                                  (marker.markerId.value
                                                          .toString()
                                                          .contains('truck'))
                                                      ? AppImages.truck
                                                      : marker.markerId.value
                                                              .toString()
                                                              .contains(
                                                                  'motor_bike')
                                                          ? AppImages.bike
                                                          : marker.markerId
                                                                  .value
                                                                  .toString()
                                                                  .contains(
                                                                      'auto')
                                                              ? AppImages.auto
                                                              : marker.markerId
                                                                      .value
                                                                      .toString()
                                                                      .contains(
                                                                          'lcv')
                                                                  ? AppImages
                                                                      .lcv
                                                                  : marker.markerId
                                                                          .value
                                                                          .toString()
                                                                          .contains(
                                                                              'ehcv')
                                                                      ? AppImages
                                                                          .ehcv
                                                                      : marker.markerId
                                                                              .value
                                                                              .toString()
                                                                              .contains('hatchback')
                                                                          ? AppImages.hatchBack
                                                                          : marker.markerId.value.toString().contains('hcv')
                                                                              ? AppImages.hcv
                                                                              : marker.markerId.value.toString().contains('mcv')
                                                                                  ? AppImages.mcv
                                                                                  : marker.markerId.value.toString().contains('luxury')
                                                                                      ? AppImages.luxury
                                                                                      : marker.markerId.value.toString().contains('premium')
                                                                                          ? AppImages.premium
                                                                                          : marker.markerId.value.toString().contains('suv')
                                                                                              ? AppImages.suv
                                                                                              : AppImages.car,
                                                  width: 16,
                                                  height: 25,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      .values
                                      .toList(),
                                ),
                                const fm.RichAttributionWidget(
                                  attributions: [],
                                ),
                              ],
                            ),
                          ),

                    // Marker in the center of the screen
                    Positioned(
                      child: Container(
                        height: size.height * 0.8,
                        width: size.width * 1,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: screenWidth * 0.6 + size.width * 0.06),
                          child: Image.asset(
                            AppImages.confirmationPin,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                          ),
                        ),
                      ),
                    ),

                    if (context.read<HomeBloc>().confirmPinAddress)
                      Positioned(
                        top: screenWidth * 0.09,
                        right: screenWidth * 0.38,
                        child: Container(
                          height: size.height * 0.8,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: screenWidth * 0.6 + size.width * 0.06),
                            child: Row(
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    return context.read<HomeBloc>().isDragging
                                        ? CustomButton(
                                            buttonColor: Theme.of(context)
                                                .disabledColor
                                                .withAlpha((0.5 * 255).toInt()),
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {},
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .pickMeHere,
                                          )
                                        : CustomButton(
                                            buttonColor:
                                                Theme.of(context).primaryColor,
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {
                                              context
                                                  .read<HomeBloc>()
                                                  .confirmPinAddress = false;
                                              context.read<HomeBloc>().add(
                                                    UpdateLocationEvent(
                                                      isFromHomePage: true,
                                                      latLng: context
                                                          .read<HomeBloc>()
                                                          .currentLatLng,
                                                      mapType: context
                                                          .read<HomeBloc>()
                                                          .mapType,
                                                    ),
                                                  );
                                            },
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .confirm,
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.28,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [topOverlayStart, topOverlayEnd],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: size.height * 0.22,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [bottomOverlayStart, bottomOverlayEnd],
                      ),
                    ),
                  ),
                ),
              ),
              // Locate Me
              Positioned(
                bottom: size.height * 0.51,
                right: size.width * 0.03,
                child: Column(
                  children: [
                    if (context.read<HomeBloc>().mapType == 'google_map')
                      PopupMenuButton<MapType>(
                        color: theme.scaffoldBackgroundColor,
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                primary.withOpacity(isDark ? 0.6 : 0.4),
                                accentBlend.withOpacity(isDark ? 0.45 : 0.25),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.2),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.layers,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                        onSelected: (mapType) {
                          context
                              .read<HomeBloc>()
                              .add(UpdateMapTypeEvent(mapType));
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: MapType.normal,
                              child: MyText(
                                  text:
                                      AppLocalizations.of(context)!.normal)),
                          PopupMenuItem(
                              value: MapType.satellite,
                              child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .satellite)),
                          PopupMenuItem(
                            value: MapType.terrain,
                            child: MyText(
                                text: AppLocalizations.of(context)!.terrain),
                          ),
                          PopupMenuItem(
                            value: MapType.hybrid,
                            child: MyText(
                                text: AppLocalizations.of(context)!.hybrid),
                          ),
                        ],
                      ),
                    if (context.read<HomeBloc>().mapType == 'google_map')
                      SizedBox(height: size.width * 0.02),
                    InkWell(
                      onTap: () {
                        // Remove confirmPinAddress for envato code
                        context.read<HomeBloc>().confirmPinAddress = false;
                        context.read<HomeBloc>().add(LocateMeEvent(
                            mapType: context.read<HomeBloc>().mapType));
                      },
                      child: Container(
                        height: size.width * 0.12,
                        width: size.width * 0.12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(isDark ? 0.95 : 0.9),
                              accentBlend.withOpacity(isDark ? 0.75 : 0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            width: 1.2,
                            color: Colors.white.withOpacity(isDark ? 0.25 : 0.7),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.28),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location,
                          size: size.width * 0.05,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Navigation and location bar
              SafeArea(
                bottom: false,
                top: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: size.width * 0.02,
                  ),
                  child: _buildTopControls(
                    context,
                    size,
                    accentBlend,
                    glassBackground,
                    borderColor,
                    isDark,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    double sheetSize = context.read<HomeBloc>().sheetSize;
                    double minChildSize =
                        context.read<HomeBloc>().minChildSize; // Bottom
                    double midChildSize =
                        context.read<HomeBloc>().midChildSize; // Midpoint
                    double maxChildSize =
                        context.read<HomeBloc>().maxChildSize; // Top
                    double currentSize = sheetSize;
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        final dragAmount = details.primaryDelta ?? 0;

                        currentSize =
                            (currentSize - dragAmount / context.size!.height)
                                .clamp(minChildSize, maxChildSize);
                        context
                            .read<HomeBloc>()
                            .add(UpdateScrollPositionEvent(currentSize));
                      },
                      onVerticalDragEnd: (details) {
                        // If scrolling up, snap to the top or midpoint
                        if (details.velocity.pixelsPerSecond.dy < 0) {
                          currentSize = currentSize >= midChildSize
                              ? maxChildSize
                              : midChildSize;
                        } else {
                          // If scrolling down, skip the midpoint and go directly to the bottom
                          currentSize = minChildSize;
                        }

                        context
                            .read<HomeBloc>()
                            .add(UpdateScrollPositionEvent(currentSize));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height:
                            MediaQuery.of(context).size.height * currentSize,
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.03,
                          vertical: size.width * 0.015,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor
                                    .withOpacity(isDark ? 0.92 : 0.94),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(32)),
                                border: Border.all(
                                  color:
                                      borderColor.withOpacity(isDark ? 0.4 : 0.2),
                                  width: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentBlend.withOpacity(0.16),
                                    blurRadius: 35,
                                    offset: const Offset(0, -6),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: context.read<HomeBloc>().serviceAvailable
                                    ? BottomSheetWidget(cont: context)
                                    : Column(
                                        children: [
                                      SizedBox(height: size.width * 0.03),
                                      Image.asset(AppImages.noDataFound,
                                          height: size.width * 0.5,
                                          width: size.width),
                                      SizedBox(height: size.width * 0.02),
                                      MyText(
                                          text: AppLocalizations.of(context)!
                                              .serviceNotAvailable)
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    // },);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopControls(
    BuildContext context,
    Size size,
    Color accentBlend,
    Color glassBackground,
    Color borderColor,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuButton(context, size, accentBlend, isDark),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: _buildLocationCard(
            context,
            size,
            accentBlend,
            glassBackground,
            borderColor,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    Size size,
    Color accentBlend,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final homeBloc = context.read<HomeBloc>();
    return GestureDetector(
      onTap: () {
        if (homeBloc.userData != null) {
          Navigator.pushNamed(
            context,
            AccountPage.routeName,
            arguments: AccountPageArguments(userData: homeBloc.userData!),
          ).then((value) {
            if (!context.mounted) return;
            homeBloc.add(GetDirectionEvent());
            if (value != null) {
              homeBloc.userData = value as UserDetail;
              homeBloc.add(UpdateEvent());
            }
          });
        }
      },
      child: Container(
        height: size.width * 0.12,
        width: size.width * 0.12,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentBlend.withOpacity(isDark ? 0.85 : 0.8),
              theme.colorScheme.primary.withOpacity(isDark ? 0.95 : 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentBlend.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.menu,
          size: 22,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    Size size,
    Color accentBlend,
    Color glassBackground,
    Color borderColor,
    bool isDark,
  ) {
    final homeBloc = context.read<HomeBloc>();
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (homeBloc.userData != null) {
          if (homeBloc.userData!.enableModulesForApplications == 'both' ||
              homeBloc.userData!.enableModulesForApplications == 'taxi') {
            homeBloc.add(DestinationSelectEvent(isPickupChange: true));
          } else {
            homeBloc.add(ServiceTypeChangeEvent(serviceTypeIndex: 1));
          }
        }
      },
      borderRadius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.width * 0.035,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: glassBackground,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: accentBlend.withOpacity(0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: size.width * 0.12,
                  width: size.width * 0.12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        accentBlend.withOpacity(isDark ? 0.6 : 0.35),
                        theme.colorScheme.primary
                            .withOpacity(isDark ? 0.7 : 0.45),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const PickupIcon(),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.pickupLocation,
                        textStyle: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w600,
                          color: accentBlend.withOpacity(isDark ? 0.7 : 0.8),
                        ),
                      ),
                      SizedBox(height: size.width * 0.01),
                      MyText(
                        text: homeBloc.currentLocation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: size.width * 0.02),
                Container(
                  height: size.width * 0.1,
                  width: size.width * 0.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentBlend.withOpacity(isDark ? 0.35 : 0.2),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: accentBlend.withOpacity(isDark ? 0.9 : 0.75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
