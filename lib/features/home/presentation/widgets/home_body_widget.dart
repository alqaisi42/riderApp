import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Map Layer
              _buildMapLayer(context, size),

              // Top Overlay with Location Card
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: _buildTopBar(context, size, theme, isDark),
              ),

              // Floating Action Buttons
              _buildFloatingActions(context, size, theme, isDark),

              // Bottom Sheet
              DraggableScrollableSheet(
                minChildSize: context.read<HomeBloc>().minChildSize,
                maxChildSize: context.read<HomeBloc>().maxChildSize,
                snap: true,
                snapSizes: [
                  context.read<HomeBloc>().minChildSize,
                  context.read<HomeBloc>().maxChildSize,
                ],
                builder: (context, scrollController) {
                  return NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      context.read<HomeBloc>().sheetSize = notification.extent;
                      context.read<HomeBloc>().isSheetAtTop =
                          notification.extent >=
                              context.read<HomeBloc>().maxChildSize - 0.01;
                      return true;
                    },
                    child: BottomSheetWidget(cont: context),
                  );
                },
              ),

              // Confirm Location Button (when map is being dragged)
              if (context.read<HomeBloc>().confirmPinAddress)
                _buildConfirmLocationButton(context, size, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapLayer(BuildContext context, Size size) {
    final homeBloc = context.read<HomeBloc>();

    return SizedBox(
      height: size.height,
      width: size.width,
      child: homeBloc.mapType == 'google_map'
          ? _buildGoogleMap(context, size)
          : _buildFlutterMap(context, size),
    );
  }

  Widget _buildGoogleMap(BuildContext context, Size size) {
    final homeBloc = context.read<HomeBloc>();

    return GoogleMap(
      mapType: homeBloc.selectedMapType,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        if (homeBloc.googleMapController == null) {
          homeBloc.add(GoogleControllAssignEvent(
            controller: controller,
            isFromHomePage: true,
            isEditAddress: false,
            latlng: homeBloc.currentLatLng,
          ));
        } else {
          homeBloc.add(LocateMeEvent(mapType: homeBloc.mapType));
        }
      },
      padding: EdgeInsets.only(bottom: size.width + size.width * 0.01),
      initialCameraPosition: CameraPosition(
        target: homeBloc.currentLatLng,
        zoom: 15.0,
      ),
      onTap: (argument) {
        homeBloc.currentLatLng = argument;
        if (homeBloc.googleMapController != null) {
          homeBloc.googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: argument, zoom: 15),
            ),
          );
        }
      },
      onCameraMoveStarted: () {
        homeBloc.setDragging(true);
        homeBloc.isCameraMoveComplete = true;
      },
      onCameraMove: (CameraPosition? position) {
        if (position != null) {
          homeBloc.currentLatLng = position.target;
        }
      },
      onCameraIdle: () {
        homeBloc.setDragging(false);
        if (homeBloc.isCameraMoveComplete) {
          if (homeBloc.pickupAddressList.isEmpty) {
            homeBloc.add(UpdateLocationEvent(
              isFromHomePage: true,
              latLng: homeBloc.currentLatLng,
              mapType: homeBloc.mapType,
            ));
          } else {
            homeBloc.confirmPinAddress = true;
            homeBloc.add(UpdateEvent());
          }
        }
      },
      markers: homeBloc.markerList.isNotEmpty
          ? Set.from(homeBloc.markerList)
          : {},
      minMaxZoomPreference: const MinMaxZoomPreference(13, 20),
      buildingsEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }

  Widget _buildFlutterMap(BuildContext context, Size size) {
    final homeBloc = context.read<HomeBloc>();

    return fm.FlutterMap(
      mapController: homeBloc.fmController,
      options: fm.MapOptions(
        onTap: (tapPosition, latLng) {
          homeBloc.currentLatLng = LatLng(latLng.latitude, latLng.longitude);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (homeBloc.fmController != null) {
              homeBloc.fmController!.move(latLng, 15);
            }
          });
          homeBloc.add(UpdateLocationEvent(
            isFromHomePage: true,
            latLng: homeBloc.currentLatLng,
            mapType: homeBloc.mapType,
          ));
        },
        initialCenter: fmlt.LatLng(
          homeBloc.currentLatLng.latitude,
          homeBloc.currentLatLng.longitude,
        ),
        initialZoom: 15,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
      ],
    );
  }

  Widget _buildTopBar(
      BuildContext context,
      Size size,
      ThemeData theme,
      bool isDark,
      ) {
    return Row(
      children: [
        // Menu Button
        _buildMenuButton(context, size, theme, isDark),
        SizedBox(width: size.width * 0.03),
        // Location Card
        Expanded(
          child: _buildLocationCard(context, size, theme, isDark),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
      BuildContext context,
      Size size,
      ThemeData theme,
      bool isDark,
      ) {
    final homeBloc = context.read<HomeBloc>();

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
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
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.menu,
          color: isDark ? Colors.white : Colors.black87,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildLocationCard(
      BuildContext context,
      Size size,
      ThemeData theme,
      bool isDark,
      ) {
    final homeBloc = context.read<HomeBloc>();
    final primaryColor = AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (homeBloc.userData != null) {
          if (homeBloc.userData!.enableModulesForApplications == 'both' ||
              homeBloc.userData!.enableModulesForApplications == 'taxi') {
            homeBloc.add(DestinationSelectEvent(isPickupChange: true));
          } else {
            homeBloc.add(ServiceTypeChangeEvent(serviceTypeIndex: 1));
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.width * 0.03,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pickupLocation,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    homeBloc.currentLocation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(
      BuildContext context,
      Size size,
      ThemeData theme,
      bool isDark,
      ) {
    final homeBloc = context.read<HomeBloc>();

    return Positioned(
      right: 16,
      bottom: size.height * 0.5,
      child: Column(
        children: [
          // My Location Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              homeBloc.add(LocateMeEvent(mapType: homeBloc.mapType));
            },
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.my_location,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          SizedBox(height: size.width * 0.03),
          // Map Type Toggle (if needed)
          if (homeBloc.mapType == 'google_map')
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.layers,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmLocationButton(
      BuildContext context,
      Size size,
      ThemeData theme,
      ) {
    final homeBloc = context.read<HomeBloc>();

    return Positioned(
      left: 16,
      right: 16,
      bottom: size.height * 0.52,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            homeBloc.confirmPinAddress = false;

          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.width * 0.04,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: size.width * 0.03),
                Text(
                  AppLocalizations.of(context)!.confirmLocation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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