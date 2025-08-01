import 'package:Tosell/Features/support/providers/ticket_provider.dart';
import 'package:Tosell/Features/support/screens/support_tab.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 12),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: context.colorScheme.outline,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: context.colorScheme.primary,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: [
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              'التذاكر المفتوحة',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              'أرشيف التذاكر',
                              style: context.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    SupportTab(fetchPage: (pageKey, _) async {
                      final response = await ref
                          .read(ticketNotifierProvider.notifier)
                          .getAll(page: pageKey);
                      return response;
                    }),
                    SupportTab(fetchPage: (pageKey, _) async {
                      final response = await ref
                          .read(ticketNotifierProvider.notifier)
                          .getAll(page: pageKey);
                      return response;
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
