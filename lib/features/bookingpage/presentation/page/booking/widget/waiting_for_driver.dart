import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_divider.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_container.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';

class WaitingForDriverConfirmation extends StatelessWidget {
  final double maximumTime;

  static const Color _primaryOrange = Color(0xFFF0AF49);
  static const Color _secondaryOrange = Color(0xFFE8B25F);
  static const LinearGradient _brandGradient = LinearGradient(
    colors: [_primaryOrange, _secondaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  const WaitingForDriverConfirmation({
    super.key,
    required this.maximumTime,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final timerDuration = context.read<BookingBloc>().timerDuration;
        final double progress = maximumTime == 0
            ? 0
            : (timerDuration / maximumTime).clamp(0, 1).toDouble();
        final bool isTimerComplete = timerDuration == 0;
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            width: size.width,
            decoration: const BoxDecoration(
              gradient: _brandGradient,
            ),
            child: Container(
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.width * 0.02),
                    const Center(child: CustomDivider()),
                    SizedBox(height: size.width * 0.02),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _brandGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1.2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _brandGradient,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: ClipOval(
                                  child: Image.asset(AppImages.defaultProfile),
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .discoverYourDriver,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.width * 0.04),
                    Container(
                      height: size.width * 0.02,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(size.width * 0.024),
                        color: isTimerComplete
                            ? Theme.of(context)
                                .primaryColor
                                .withOpacity(0.25)
                            : Theme.of(context)
                                .disabledColor
                                .withOpacity(0.15),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: isTimerComplete ? 1 : progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                size.width * 0.024),
                            gradient: _brandGradient,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyText(
                          text:
                          '${Duration(seconds: timerDuration).toString().substring(3, 7)} ${AppLocalizations.of(context)!.mins}',
                      textStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: size.width * 0.04),
                MyText(
                  text: AppLocalizations.of(context)!.bookingDetails,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Theme.of(context).disabledColor),
                ),
                    SizedBox(height: size.width * 0.03),
                    Container(
                      decoration: BoxDecoration(
                        gradient: _brandGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CustomContainer(
                        isShadow: false,
                        borderRadius: 14,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          child: Column(
                            children: [
                              ListView.builder(
                            itemCount: context
                                .read<BookingBloc>()
                                .pickUpAddressList
                                .length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final address = context
                                  .read<BookingBloc>()
                                  .pickUpAddressList
                                  .elementAt(index);
                              return Container(
                                margin:
                                    EdgeInsets.only(bottom: size.width * 0.02),
                                decoration: BoxDecoration(
                                  gradient: _brandGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(1.2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.01),
                                          child: const PickupIcon(),
                                        ),
                                        Expanded(
                                          child: MyText(
                                            text: address.address,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        SizedBox(height: size.width * 0.01),
                        ListView.builder(
                            itemCount: context
                                .read<BookingBloc>()
                                .dropAddressList
                                .length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final address = context
                                  .read<BookingBloc>()
                                  .dropAddressList
                                  .elementAt(index);
                              return Container(
                                margin:
                                    EdgeInsets.only(bottom: size.width * 0.02),
                                decoration: BoxDecoration(
                                  gradient: _brandGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(1.2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.005),
                                          child: Icon(Icons.place_rounded,
                                              size: 20,
                                              color: _primaryOrange),
                                        ),
                                        Expanded(
                                          child: MyText(
                                            text: address.address,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                            ],
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: size.width * 0.05),
                if (context.read<BookingBloc>().requestData != null) ...[
                  MyText(
                    text: AppLocalizations.of(context)!.rideDetails,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(height: size.width * 0.03),
                  Container(
                    decoration: BoxDecoration(
                      gradient: _brandGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CustomContainer(
                      isShadow: false,
                      borderRadius: 14,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Center(
                              child: CachedNetworkImage(
                                imageUrl: context
                                    .read<BookingBloc>()
                                    .requestData!
                                    .vehicleTypeImage,
                                height: size.width * 0.1,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: Loader(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Text(""),
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Expanded(
                              child: MyText(
                                text: context
                                    .read<BookingBloc>()
                                    .requestData!
                                    .vehicleTypeName,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: size.width * 0.03),
                MyText(
                  text: AppLocalizations.of(context)!.payment,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: size.width * 0.03),
                Container(
                  decoration: BoxDecoration(
                    gradient: _brandGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomContainer(
                    isShadow: false,
                    borderRadius: 14,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                              context.read<BookingBloc>().isSavedCardChoose
                                  ? Icons.credit_card_rounded
                                  : context
                                              .read<BookingBloc>()
                                              .selectedPaymentType ==
                                          'cash'
                                      ? Icons.payments_outlined
                                      : context
                                                  .read<BookingBloc>()
                                                  .selectedPaymentType ==
                                              'card'
                                          ? Icons.credit_card_rounded
                                          : Icons.account_balance_wallet_outlined,
                              color: _primaryOrange),
                          SizedBox(width: size.width * 0.05),
                          Expanded(
                            child: MyText(
                              text: context.read<BookingBloc>().isSavedCardChoose
                                  ? 'Card'
                                  : context
                                      .read<BookingBloc>()
                                      .selectedPaymentType,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                MyText(
                  text: AppLocalizations.of(context)!.manageRide,
                  textStyle: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: size.width * 0.03),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      isScrollControlled: true,
                      enableDrag: false,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        ),
                      ),
                      builder: (_) {
                        return BlocProvider.value(
                            value: context.read<BookingBloc>(),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // SizedBox(height: size.width * 0.1),
                                  Center(
                                      child: Image.asset(AppImages.cancelGif,
                                          height: size.width * 0.2)),
                                  Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .cancelRide,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColorDark),
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .cancelRideText,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.05),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      CustomButton(
                                        buttonName:
                                            AppLocalizations.of(context)!
                                                .cancelRide,
                                        borderRadius: 5,
                                        isBorder: true,
                                        width: size.width * 0.4,
                                        height: size.width * 0.1,
                                        buttonColor: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        textSize: context
                                                    .read<BookingBloc>()
                                                    .languageCode ==
                                                'fr'
                                            ? 14
                                            : null,
                                        textColor:
                                            Theme.of(context).primaryColor,
                                        onTap: () {
                                          context
                                              .read<BookingBloc>()
                                              .timerCount(context,
                                                  duration: 0,
                                                  isNormalRide: true,
                                                  isCloseTimer: true);
                                          context
                                              .read<BookingBloc>()
                                              .onRideBottomPosition = -250;
                                          context.read<BookingBloc>().add(
                                              BookingCancelRequestEvent(
                                                  requestId: context
                                                      .read<BookingBloc>()
                                                      .requestData!
                                                      .id));
                                        },
                                      ),
                                      CustomButton(
                                        buttonName:
                                            AppLocalizations.of(context)!.back,
                                        borderRadius: 5,
                                        width: size.width * 0.4,
                                        height: size.width * 0.1,
                                        buttonColor:
                                            Theme.of(context).primaryColor,
                                        textColor: AppColors.white,
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.width * 0.15),
                                ],
                              ),
                            ));
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.red, Color(0xFFFF7B7B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.red.withOpacity(0.2),
                          offset: const Offset(0, 6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: CustomContainer(
                      isShadow: false,
                      borderRadius: 16,
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.cancel_outlined,
                                color: AppColors.white),
                            SizedBox(width: size.width * 0.05),
                            Expanded(
                              child: MyText(
                                text: AppLocalizations.of(context)!.cancelRide,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.width * 0.1),
              ],
            ),
          ),
            ),
          ),
        );
      },
    );
  }
}
