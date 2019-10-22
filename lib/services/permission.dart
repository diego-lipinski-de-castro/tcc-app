import 'package:permission_handler/permission_handler.dart';

class Permission {
  static final PermissionHandler _permissionHandler = PermissionHandler();

  static Future<bool> _request(PermissionGroup permission) async {
    var status = await _permissionHandler.requestPermissions([permission]);

    if (status[permission] == PermissionStatus.granted) {
      return true;
    }

    return false;
  }

  static Future<bool> _check(PermissionGroup permissions) async {
    PermissionStatus status =
        await _permissionHandler.checkPermissionStatus(permissions);
    return status == PermissionStatus.granted;
  }

  static Future<bool> checkAndRequestLocation() async {
    bool hasPermission = await _check(PermissionGroup.location);
    if (!hasPermission) {
      return _request(PermissionGroup.location);
    }

    return true;
  }
}
