import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/screens/shipment/shipments_tab.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShipmentsScreen extends ConsumerStatefulWidget {
  const ShipmentsScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                          child: Text(
                            'التوصيل',
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'الاستحصال',
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'الراجع',
                            style: context.textTheme.bodyMedium,
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
                    ShipmentsTab(
                      fetchPage: (pageKey, _) async {
                        return await ref
                            .read(shipmentsNotifierProvider.notifier)
                            .getAll(
                          page: pageKey,
                          queryParams: {
                            'type': 1,
                            'priority': 0,
                          },
                        );
                      },
                    ),
                    ShipmentsTab(
                      fetchPage: (pageKey, _) async {
                        return await ref
                            .read(shipmentsNotifierProvider.notifier)
                            .getAll(
                          page: pageKey,
                          queryParams: {
                            'type': 0,
                            'priority': 0,
                          },
                        );
                      },
                    ),
                    ShipmentsTab(
                      fetchPage: (pageKey, _) async {
                        return await ref
                            .read(shipmentsNotifierProvider.notifier)
                            .getAll(
                          page: pageKey,
                          queryParams: {
                            'type': 2,
                            'priority': 0,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrap the paged list in a RefreshIndicator
}
