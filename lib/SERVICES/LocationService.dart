import 'dart:async';
import 'package:humanly/MODELS/UserLocationModel.dart';
import 'package:location/location.dart';

class LocationService {
  // UserLocationModel _currentLocation;

  Location location = Location();

  StreamController<UserLocationModel> _locationController =
      StreamController<UserLocationModel>.broadcast();

  LocationService() {
    location.changeSettings(accuracy: LocationAccuracy.high);
    location.requestPermission().then((value) async {
      if (value == PermissionStatus.granted) {
        bool _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          await location.requestService();
          location.onLocationChanged.listen((event) {
            if (event != null) {
              _locationController.add(UserLocationModel(
                latitude: event.latitude,
                longitude: event.longitude,
              ));
            }
          });
        } else {
          location.onLocationChanged.listen((event) {
            if (event != null) {
              _locationController.add(UserLocationModel(
                latitude: event.latitude,
                longitude: event.longitude,
              ));
            }
          });
        }
      }
    });
  }

  Stream<UserLocationModel> get locationStream => _locationController.stream;

  Future<UserLocationModel> getLocation() async {
    UserLocationModel _returnable;
    try {
      var userLocation = await location.getLocation();
      _returnable = UserLocationModel(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } catch (e) {
      print(e.toString());
      _returnable = null;
    }
    return _returnable;
  }
}
