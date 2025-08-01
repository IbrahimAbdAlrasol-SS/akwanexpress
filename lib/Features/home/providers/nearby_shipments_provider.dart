import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:flutter/material.dart';

final assignedShipmentsNotifier = ValueNotifier<List<ShipmentInMap>>([]);

final unAssignedShipmentsNotifier = ValueNotifier<List<ShipmentInMap>>([]);

final currentLocationNotifier = ValueNotifier<LocationWithHeading?>(null);
