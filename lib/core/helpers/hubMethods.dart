import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:Tosell/core/helpers/hubConnection.dart'; // assumes hubConnection is imported

/// Custom model to hold location and heading
class LocationWithHeading {
  final double latitude;
  final double longitude;
  final double heading;

  LocationWithHeading({
    required this.latitude,
    required this.longitude,
    required this.heading,
  });
}

Future<void> startSendingLiveLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
  }

  try {
    final initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await sendLocationToSignalR(initialPosition);
    print('📍 Initial location sent');

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((position) {
      sendLocationToSignalR(position);
    });
  } catch (e) {
    print('❌ Error in location stream: $e');
  }
}

Future<void> sendLocationToSignalR(Position position) async {
  if (hubConnection.state == HubConnectionState.connected) {
    currentLocationNotifier.value = LocationWithHeading(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
    );
    debugPrint(
        '📍 Current location: ${position.latitude}, ${position.longitude}, heading: ${position.heading}');

    await hubConnection.invoke(
      'UpdateLocation',
      args: [position.latitude, position.longitude],
    );

    print(
        '📤 Location sent: ${position.latitude}, ${position.longitude}, heading: ${position.heading}');
  } else {
    print('🚫 SignalR not connected');
  }
}

Future<void> invokeNearbyShipment() async {
  if (hubConnection.state == HubConnectionState.connected) {
    await hubConnection.invoke(
      'NearbyShipments',
      args: [],
    );
  }
}

// Future<bool> assignDelegate(String shipmentId) async {
//   if (hubConnection.state == HubConnectionState.connected) {
//     bool? result = await hubConnection.invoke(
//       'AssignDelegate',
//       args: [shipmentId],
//     );
//     if (result == null) return false;
//     if (result) {
//       startSendingLiveLocation();
//       invokeNearbyShipment();

//       print('📤 Delegate assigned: $shipmentId');
//     } else {
//       print('🚫 Cannot assign delegate.');
//     }
//     return result;
//   } else {
//     print('🚫 Cannot assign delegate. SignalR is not connected.');
//     return false;
//   }
// }
