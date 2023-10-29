import 'package:location/location.dart';

class LocationService{
  Location location = Location();
  late LocationData _locData;
  Future<void> initialize() async{
    bool _servicEnabled;
    PermissionStatus _permission;
    _servicEnabled = await location.serviceEnabled();
    if(!_servicEnabled){
      _servicEnabled = await location.requestService();
      if(!_servicEnabled){
        return;
      }
    }
    _permission = await location.hasPermission();
    if(_permission == PermissionStatus.denied){
      _permission = await location.requestPermission();
      if(_permission != PermissionStatus.granted){
        return;
      }
    }
  }
  Future<double?> getLatitude() async{
     _locData = await location.getLocation();
     return _locData.latitude;
  }

  Future<double?> getLongitude() async{
    _locData = await location.getLocation();
    return _locData.longitude;
  }
}