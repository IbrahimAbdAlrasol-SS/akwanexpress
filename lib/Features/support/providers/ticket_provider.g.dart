// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ticketNotifierHash() => r'abf6754e2220ad4924854f73fa9c58e30620d371';

/// See also [TicketNotifier].
@ProviderFor(TicketNotifier)
final ticketNotifierProvider = AutoDisposeAsyncNotifierProvider<TicketNotifier,
    ApiResponse<Ticket>?>.internal(
  TicketNotifier.new,
  name: r'ticketNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ticketNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TicketNotifier = AutoDisposeAsyncNotifier<ApiResponse<Ticket>?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
