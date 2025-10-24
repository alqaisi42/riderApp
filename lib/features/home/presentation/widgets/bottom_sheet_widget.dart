import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/common.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/user_details_model.dart';
import 'banner_widget.dart';
import 'home_on_going_rides.dart';
import 'recent_search_places_widget.dart';
import 'services_module_widget.dart';

class BottomSheetWidget extends StatefulWidget {
  final BuildContext cont;

  const BottomSheetWidget({super.key, required this.cont});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _showPromoHeader = true;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = widget.cont.read<HomeBloc>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    // Define new orange palette
    const Color primaryOrange = Color(0xFFF0AF49);
    const Color secondaryOrange = Color(0xFFE8B25F);

    return BlocProvider.value(
      value: homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return DraggableScrollableSheet(
            minChildSize: 0.25,
            maxChildSize: 0.95,
            initialChildSize: 0.45,
            expand: false,
            snap: true,
            builder: (context, scrollController) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                      blurRadius: 25,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildDragHandle(),
                            if (homeBloc.userData == null)
                              _buildShimmerLoading(context, isDark)
                            else
                              _buildSheetContent(
                                  context, theme, isDark, homeBloc, primaryOrange, secondaryOrange),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDragHandle() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: Container(
        height: 5,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    ),
  );

  Widget _buildSheetContent(
      BuildContext context,
      ThemeData theme,
      bool isDark,
      HomeBloc bloc,
      Color primary,
      Color secondary) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showPromoHeader) _buildPromoHeader(context, size, isDark, primary, secondary),
          const SizedBox(height: 10),
          _buildEnhancedDestinationSection(context, size, isDark, primary),
          const SizedBox(height: 16),
          _buildQuickAccessLocations(context, size, isDark, primary),
          const SizedBox(height: 20),
          if (bloc.userData?.bannerImage?.data.isNotEmpty ?? false)
            _buildBanner(context, size),
          const SizedBox(height: 24),
          if (_shouldShowServiceModules(bloc))
            _buildServiceModulesSection(context, size, isDark, primary),
          const SizedBox(height: 24),
          if (bloc.isMultipleRide)
            _buildOngoingRides(context, size, isDark, primary),
          const SizedBox(height: 24),
          if (bloc.recentSearchPlaces.isNotEmpty)
            _buildRecentPlacesSection(context, size, isDark, primary),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPromoHeader(BuildContext context, Size size, bool isDark,
      Color primary, Color secondary) {
    return AnimatedOpacity(
      opacity: _showPromoHeader ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Enhance your pick-up experience\nGet a faster, hassle-free ride',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.3),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _showPromoHeader = false);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedDestinationSection(
      BuildContext context, Size size, bool isDark, Color primary) {
    final bloc = context.read<HomeBloc>();

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (bloc.userData != null) {
          bloc.add(DestinationSelectEvent(isPickupChange: false));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222222) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.whereAreYouGoing ??
                    "Where are you going?",
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.calendar_today_outlined, size: 18, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessLocations(
      BuildContext context, Size size, bool isDark, Color primary) {
    final bloc = context.read<HomeBloc>();
    final saved = _getSavedLocations(bloc);
    if (saved.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Saved Places",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 10),
        ...saved.map((loc) => _buildQuickAccessItem(
          loc['icon'],
          loc['title'],
          loc['address'],
          loc['onTap'],
          isDark,
          primary,
        )),
      ],
    );
  }

  Widget _buildQuickAccessItem(IconData icon, String title, String address,
      VoidCallback onTap, bool isDark, Color primary) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(address,
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, Size size) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BannerWidget(cont: context),
  );

  Widget _buildServiceModulesSection(
      BuildContext context, Size size, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Services",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ServicesModuleWidget(cont: widget.cont),
        ),
      ],
    );
  }

  Widget _buildOngoingRides(
      BuildContext context, Size size, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.onGoingRides,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 10),
        HomeOnGoingRidesWidget(cont: context),
      ],
    );
  }

  Widget _buildRecentPlacesSection(
      BuildContext context, Size size, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Places",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 10),
        RecentSearchPlacesWidget(cont: context),
      ],
    );
  }

  Widget _buildShimmerLoading(BuildContext context, bool isDark) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        _ShimmerBox(width: size.width * 0.9, height: 140, isDark: isDark),
        const SizedBox(height: 10),
        _ShimmerBox(width: size.width * 0.9, height: 100, isDark: isDark),
      ],
    );
  }

  bool _shouldShowServiceModules(HomeBloc bloc) {
    final u = bloc.userData;
    if (u == null) return false;
    return (u.enableModulesForApplications == 'both') ||
        (u.enableModulesForApplications == 'taxi' && u.showRentalRide);
  }

  List<Map<String, dynamic>> _getSavedLocations(HomeBloc bloc) {
    final locations = <Map<String, dynamic>>[];
    if (bloc.userData?.workAddress?.isNotEmpty ?? false) {
      locations.add({
        'icon': Icons.work_rounded,
        'title': 'Work',
        'address': bloc.userData!.workAddress!,
        'onTap': () {
          bloc.add(DestinationSelectEvent(
              isPickupChange: false,
              prefilledAddress: bloc.userData!.workAddress));
        },
      });
    }
    if (bloc.userData?.homeAddress?.isNotEmpty ?? false) {
      locations.add({
        'icon': Icons.home_rounded,
        'title': 'Home',
        'address': bloc.userData!.homeAddress!,
        'onTap': () {
          bloc.add(DestinationSelectEvent(
              isPickupChange: false,
              prefilledAddress: bloc.userData!.homeAddress));
        },
      });
    }
    return locations;
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width, height;
  final bool isDark;

  const _ShimmerBox(
      {required this.width, required this.height, required this.isDark});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * _controller.value, 0),
                end: Alignment(1 + 2 * _controller.value, 0),
                colors: widget.isDark
                    ? [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF3A3A3A),
                  const Color(0xFF2A2A2A)
                ]
                    : [
                  const Color(0xFFFFF1E0),
                  const Color(0xFFFFE0B2),
                  const Color(0xFFFFF1E0)
                ],
              ),
            ),
          );
        });
  }
}
