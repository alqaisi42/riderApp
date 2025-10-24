import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/booking_bloc.dart';
import 'schedule_ride.dart';

class EtaListViewWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;
  final dynamic thisValue;

  const EtaListViewWidget(
      {super.key, required this.cont, required this.arg, this.thisValue});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color primaryOrange = Color(0xFFFF6A00);
    const Color secondaryOrange = Color(0xFFFFA000);

    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          final bookingBloc = context.read<BookingBloc>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingBloc.isMultiTypeVechiles &&
                  !arg.isOutstationRide &&
                  (arg.isWithoutDestinationRide == null ||
                      (arg.isWithoutDestinationRide != null &&
                          !arg.isWithoutDestinationRide!))) ...[
                SizedBox(height: size.width * 0.04),
                _buildRideTypeToggle(
                  context: context,
                  size: size,
                  bookingBloc: bookingBloc,
                  showBidding: arg.isWithoutDestinationRide == null ||
                      !arg.isWithoutDestinationRide!,
                  gradientColors: const [primaryOrange, secondaryOrange],
                  isDark: isDark,
                  nearbyValue: thisValue,
                ),
                SizedBox(height: size.width * 0.05),
              ],
              if (arg.isWithoutDestinationRide != null &&
                  arg.isWithoutDestinationRide!)
                SizedBox(height: size.width * 0.04),
              if (arg.isOutstationRide) ...[
                _buildOutstationSection(
                  context: context,
                  size: size,
                  bookingBloc: bookingBloc,
                  arg: arg,
                  gradientColors: const [primaryOrange, secondaryOrange],
                  isDark: isDark,
                ),
              ],
              _buildRideDetailsHeader(
                context: context,
                size: size,
                bookingBloc: bookingBloc,
                arg: arg,
                gradientColors: const [primaryOrange, secondaryOrange],
                isDark: isDark,
              ),
              SizedBox(height: size.width * 0.02),
              ((bookingBloc.isEtaFilter &&
                          !bookingBloc.filterSuccess) ||
                      ((bookingBloc.isMultiTypeVechiles &&
                              bookingBloc.sortedEtaDetailsList
                                  .isEmpty) ||
                          bookingBloc.etaDetailsList.isEmpty))
                  ? SizedBox(
                      height: size.height * 0.49,
                      child: Center(child: Image.asset(AppImages.noDataFound)))
                  : RawScrollbar(
                      thumbColor:
                          isDark ? Colors.white24 : Colors.black.withOpacity(0.1),
                      radius: const Radius.circular(12),
                      thickness: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: bookingBloc.etaScrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // physics: bookingBloc.enableEtaScrolling
                        //     ? const BouncingScrollPhysics()
                        //     : const NeverScrollableScrollPhysics(),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookingBloc.isMultiTypeVechiles
                            ? bookingBloc.sortedEtaDetailsList
                                .length
                            : bookingBloc.etaDetailsList.length,
                        itemBuilder: (context, index) {
                          final eta =
                              bookingBloc.isMultiTypeVechiles
                                  ? bookingBloc.sortedEtaDetailsList
                                      .elementAt(index)
                                  : bookingBloc.etaDetailsList
                                      .elementAt(index);
                          final isSelected =
                              bookingBloc.selectedVehicleIndex == index;
                          return InkWell(
                            onTap: () {
                              bookingBloc.add(
                                  BookingEtaSelectEvent(
                                      selectedVehicleIndex: index,
                                      isOutstationRide: arg.isOutstationRide));
                              final selectedSize = bookingBloc.dropAddressList
                                          .length ==
                                      1
                                  ? bookingBloc.currentSize
                                  : bookingBloc.dropAddressList
                                              .length ==
                                          2
                                      ? bookingBloc.currentSizeTwo
                                      : bookingBloc.currentSizeThree;
                              bookingBloc.updateScrollHeight(selectedSize);
                              bookingBloc.scrollToBottomFunction(context
                                      .read<BookingBloc>()
                                      .dropAddressList
                                      .length);

                              bookingBloc.etaScrollController
                                  .jumpTo(selectedSize);

                              bookingBloc.checkNearByEta(
                                  bookingBloc.nearByDriversData, thisValue);
                            },
                            child: _EtaOptionTile(
                              eta: eta,
                              size: size,
                              isSelected: isSelected,
                              bookingBloc: bookingBloc,
                              index: index,
                              gradientColors:
                                  const [primaryOrange, secondaryOrange],
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildRideTypeToggle({
  required BuildContext context,
  required Size size,
  required BookingBloc bookingBloc,
  required bool showBidding,
  required List<Color> gradientColors,
  required bool isDark,
  required dynamic nearbyValue,
}) {
  final textTheme = Theme.of(context).textTheme;
  final backgroundColor = isDark
      ? Colors.white.withOpacity(0.04)
      : Colors.black.withOpacity(0.04);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RideTypeSegment(
              height: size.width * 0.1,
              label: AppLocalizations.of(context)!.onDemand,
              isSelected: !bookingBloc.showBiddingVehicles,
              gradientColors: gradientColors,
              textStyle: textTheme.bodyMedium!,
              onTap: () {
                if (bookingBloc.showBiddingVehicles) {
                  bookingBloc.add(SelectBiddingOrDemandEvent(
                      selectedTypeEta: 'On Demand', isBidding: false));
                  bookingBloc.checkNearByEta(
                      bookingBloc.nearByDriversData, nearbyValue);
                }
              },
            ),
          ),
          if (showBidding) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _RideTypeSegment(
                height: size.width * 0.1,
                label: AppLocalizations.of(context)!.bidding,
                isSelected: bookingBloc.showBiddingVehicles,
                gradientColors: gradientColors,
                textStyle: textTheme.bodyMedium!,
                onTap: () {
                  if (!bookingBloc.showBiddingVehicles) {
                    bookingBloc.add(SelectBiddingOrDemandEvent(
                        selectedTypeEta: 'Bidding', isBidding: true));
                    bookingBloc.checkNearByEta(
                        bookingBloc.nearByDriversData, nearbyValue);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _RideTypeSegment extends StatelessWidget {
  final double height;
  final String label;
  final bool isSelected;
  final List<Color> gradientColors;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const _RideTypeSegment({
    required this.height,
    required this.label,
    required this.isSelected,
    required this.gradientColors,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isSelected ? Colors.white : Theme.of(context).hintColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient:
              isSelected ? LinearGradient(colors: gradientColors) : null,
          color: isSelected
              ? null
              : Theme.of(context).cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors.last.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: foregroundColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildOutstationSection({
  required BuildContext context,
  required Size size,
  required BookingBloc bookingBloc,
  required BookingPageArguments arg,
  required List<Color> gradientColors,
  required bool isDark,
}) {
  final roundTripEnabled = arg.userData.enableOutstationRoundTripFeature == '1';
  final textTheme = Theme.of(context).textTheme;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.07),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.route, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: 'Outstation planning',
                      textStyle: textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    MyText(
                      text: 'Tailor your outstation ride preferences',
                      textStyle: textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: size.width * 0.04),
          Row(
            children: [
              Expanded(
                child: _OutstationTripCard(
                  title: AppLocalizations.of(context)!.oneWayTrip,
                  subtitle: AppLocalizations.of(context)!.getDropOff,
                  icon: Icons.arrow_circle_right_rounded,
                  gradientColors: gradientColors,
                  isSelected: !bookingBloc.isRoundTrip,
                  onTap: () {
                    bookingBloc.isRoundTrip = false;
                    bookingBloc.showReturnDateTime = '';
                    bookingBloc.scheduleDateTimeForReturn = '';
                    bookingBloc.add(UpdateEvent());
                  },
                  enabled: true,
                  isDark: isDark,
                ),
              ),
              if (roundTripEnabled) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _OutstationTripCard(
                    title: AppLocalizations.of(context)!.roundTrip,
                    subtitle:
                        AppLocalizations.of(context)!.keepTheCarTillReturn,
                    icon: Icons.cached_rounded,
                    gradientColors: gradientColors,
                    isSelected: bookingBloc.isRoundTrip,
                    enabled: roundTripEnabled,
                    isDark: isDark,
                    onTap: () {
                      bookingBloc.isRoundTrip = true;
                      bookingBloc.add(UpdateEvent());
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: false,
                          enableDrag: false,
                          isDismissible: true,
                          barrierColor: Theme.of(context).shadowColor,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          builder: (_) {
                            return scheduleRide(context, size, arg, true);
                          });
                    },
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: size.width * 0.04),
          _buildScheduleCard(
            context: context,
            label: AppLocalizations.of(context)!.leaveOn,
            value: bookingBloc.showDateTime,
            placeholder: AppLocalizations.of(context)!.now,
            icon: Icons.calendar_month_rounded,
            gradientColors: gradientColors,
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  enableDrag: false,
                  isDismissible: true,
                  barrierColor: Theme.of(context).shadowColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  builder: (_) {
                    return scheduleRide(context, size, arg, false);
                  });
            },
          ),
          if (bookingBloc.isRoundTrip)
            Padding(
              padding: EdgeInsets.only(top: size.width * 0.02),
              child: _buildScheduleCard(
                context: context,
                label: AppLocalizations.of(context)!.returnBy,
                value: bookingBloc.showReturnDateTime,
                placeholder: AppLocalizations.of(context)!.selectDate,
                icon: Icons.timelapse,
                gradientColors: gradientColors,
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      enableDrag: false,
                      isDismissible: true,
                      barrierColor: Theme.of(context).shadowColor,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      builder: (_) {
                        return scheduleRide(context, size, arg, true);
                      });
                },
              ),
            ),
        ],
      ),
    ),
  );
}

class _OutstationTripCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool enabled;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isDark;

  const _OutstationTripCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.enabled,
    required this.gradientColors,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : theme.cardColor;
    final onSurfaceColor = textTheme.titleMedium?.color ??
        (isDark ? Colors.white : Colors.black87);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: gradientColors)
                : null,
            color: isSelected ? null : cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Theme.of(context).dividerColor.withOpacity(0.15),
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : gradientColors.first.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : gradientColors.first,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall!.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.85)
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildScheduleCard({
  required BuildContext context,
  required String label,
  required String value,
  required String placeholder,
  required IconData icon,
  required List<Color> gradientColors,
  required VoidCallback onTap,
}) {
  final hasValue = value.isNotEmpty;
  final theme = Theme.of(context);

  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue
              ? gradientColors.first.withOpacity(0.4)
              : theme.dividerColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? value : placeholder,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                    color: hasValue
                        ? gradientColors.first
                        : theme.textTheme.bodyMedium!.color,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            hasValue ? Icons.edit_calendar : Icons.add_circle_outline,
            color: hasValue
                ? gradientColors.first
                : theme.hintColor.withOpacity(0.8),
            size: 20,
          ),
        ],
      ),
    ),
  );
}

Widget _buildRideDetailsHeader({
  required BuildContext context,
  required Size size,
  required BookingBloc bookingBloc,
  required BookingPageArguments arg,
  required List<Color> gradientColors,
  required bool isDark,
}) {
  final canSchedule = (!bookingBloc.showBiddingVehicles ||
          !bookingBloc.isMultiTypeVechiles) &&
      arg.userData.showRideLaterFeature;
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.28 : 0.07),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_taxi, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.rideDetails,
                  textStyle: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.whereAreYouGoing ??
                      'Review and schedule your next ride',
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: theme.hintColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (canSchedule)
            _RideLaterChip(
              bookingBloc: bookingBloc,
              size: size,
              gradientColors: gradientColors,
              arg: arg,
            ),
        ],
      ),
    ),
  );
}

class _RideLaterChip extends StatelessWidget {
  final BookingBloc bookingBloc;
  final Size size;
  final List<Color> gradientColors;
  final BookingPageArguments arg;

  const _RideLaterChip({
    required this.bookingBloc,
    required this.size,
    required this.gradientColors,
    required this.arg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSchedule = bookingBloc.showDateTime.isNotEmpty;
    final label = hasSchedule
        ? bookingBloc.showDateTime
        : AppLocalizations.of(context)!.now;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            isScrollControlled: false,
            enableDrag: false,
            isDismissible: true,
            barrierColor: Theme.of(context).shadowColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            builder: (_) {
              return scheduleRide(context, size, arg, false);
            });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: hasSchedule
              ? LinearGradient(colors: gradientColors)
              : null,
          color: hasSchedule
              ? null
              : theme.colorScheme.primary.withOpacity(0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSchedule ? Icons.edit_calendar : Icons.calendar_today,
              size: 18,
              color: hasSchedule ? Colors.white : gradientColors.first,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: hasSchedule ? Colors.white : gradientColors.first,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtaOptionTile extends StatelessWidget {
  final dynamic eta;
  final Size size;
  final bool isSelected;
  final BookingBloc bookingBloc;
  final int index;
  final List<Color> gradientColors;
  final bool isDark;

  const _EtaOptionTile({
    required this.eta,
    required this.size,
    required this.isSelected,
    required this.bookingBloc,
    required this.index,
    required this.gradientColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = eta.hasDiscount && !bookingBloc.showBiddingVehicles;
    final nearbyDuration = _resolveDuration();
    final priceText = bookingBloc.isRoundTrip
        ? '${eta.currency} ${eta.pricePerDistance.toStringAsFixed(1)}/${eta.unitInWords}'
        : '${eta.currency} ${eta.total.toStringAsFixed(1)}';
    final discountText = '${eta.currency} ${eta.discountTotal.toStringAsFixed(1)}';
    final tileColor = isDark ? const Color(0xFF1C1C1E) : theme.cardColor;
    final textColor = isSelected ? Colors.white : theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final subtitleColor = isSelected
        ? Colors.white.withOpacity(0.85)
        : theme.hintColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: size.width,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(colors: gradientColors) : null,
        color: isSelected ? null : tileColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected
              ? Colors.transparent
              : theme.dividerColor.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.25 : 0.08),
            blurRadius: isSelected ? 26 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isSelected ? 0.2 : 0.9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: eta.vehicleIcon,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: Loader()),
                errorWidget: (context, url, error) => const Center(child: Icon(Icons.directions_car)),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        eta.name,
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasDiscount)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.25)
                              : gradientColors.first.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer,
                                size: 12,
                                color: isSelected
                                    ? Colors.white
                                    : gradientColors.first),
                            const SizedBox(width: 4),
                            Text(
                              'Deal',
                              style: theme.textTheme.labelSmall!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : gradientColors.first,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.timer,
                        color: subtitleColor,
                        size: 16),
                    const SizedBox(width: 6),
                    Text(
                      nearbyDuration,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => bookingBloc
                          .add(ShowEtaInfoEvent(infoIndex: index)),
                      child: Icon(
                        Icons.info_outline,
                        color: subtitleColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                priceText,
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: hasDiscount ? FontWeight.w600 : FontWeight.w700,
                  color: hasDiscount
                      ? (isSelected ? Colors.white70 : theme.hintColor)
                      : (isSelected
                          ? Colors.white
                          : theme.colorScheme.primary),
                  decoration:
                      hasDiscount ? TextDecoration.lineThrough : null,
                  decorationColor:
                      isSelected ? Colors.white70 : theme.colorScheme.primary,
                  decorationThickness: hasDiscount ? 1.5 : 0,
                ),
              ),
              if (hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    discountText,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveDuration() {
    final list = bookingBloc.nearByEtaVechileList;
    if (list.isEmpty) return '--';
    final nearbyIndex =
        list.indexWhere((element) => element.typeId == eta.typeId);
    if (nearbyIndex == -1) return '--';
    final duration = list.elementAt(nearbyIndex).duration;
    if (duration == null || duration.isEmpty) return '--';
    return duration;
  }
}
