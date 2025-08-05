import 'package:Tosell/Features/support/models/ticket.dart';
import 'package:Tosell/Features/support/screens/support_card_item.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportTab extends ConsumerStatefulWidget {
  final Future<ApiResponse<Ticket>> Function(int pageKey, dynamic pageSize)
      fetchPage;
  const SupportTab({super.key, required this.fetchPage});

  @override
  ConsumerState<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends ConsumerState<SupportTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for keeping alive
    return GenericPagedListView<Ticket>(
      // noItemsFoundIndicatorBuilder: buildNoItemsFound(context),
      fetchPage: widget.fetchPage,
      itemBuilder: (context, ticket, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SupportCardItem(
          ticket: ticket,
        ),
      ),
    );
  }
}
