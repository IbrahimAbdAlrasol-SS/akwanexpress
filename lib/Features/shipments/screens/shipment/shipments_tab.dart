import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

class ShipmentsTab extends StatefulWidget {
  final Future<ApiResponse<Shipment>> Function(int pageKey, dynamic pageSize)
      fetchPage;

  const ShipmentsTab({
    super.key,
    required this.fetchPage,
  });

  @override
  State<ShipmentsTab> createState() => _ShipmentsTabState();
}

class _ShipmentsTabState extends State<ShipmentsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for keeping alive
    return GenericPagedListView<Shipment>(
      noItemsFoundIndicatorBuilder: buildNoItemsFound(context),
      fetchPage: widget.fetchPage,
      itemBuilder: (context, shipment, index) => ShipmentCartItem(
        showState: true,
        shipment: shipment,
      ),
    );
  }
}

Widget buildNoItemsFound(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Image.asset(
      //   'assets/svg/NoItemsFound.gif',
      //   width: 240,
      //   height: 240,
      // ),
      // const Gap(AppSpaces.medium),
      Text(
        'لم يتم تعيين قائمة حاليا',
        style: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.primary,
          fontSize: 24,
        ),
      ),
      Text(
        'سيتم اعلامك عند اضافة قائمة جديدة',
        style: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    ],
  );
}
