import 'package:covi/utils/settings.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationPermissions { os, app, service }
enum BluetoothPermissions { app, service }

class PermissionsManager {
  // Permissions we'll need to request
  static final List<PermissionGroup> permissionsGroup = [
    PermissionGroup
        .location, // Access to location for Bluetooth Low Energy scanning
  ];

  /// Request the permissions we need
  static Future<bool> requestPermissions() async {
    await PermissionHandler().requestPermissions(permissionsGroup);

    bool hasAcceptedPermissions = await checkPermissions();

    return hasAcceptedPermissions;
  }

  static Future<bool> checkPermissions() async {
    bool permissionsGranted = true;

    for (PermissionGroup permission in permissionsGroup) {
      if (permission == PermissionGroup.notification) {
        continue;
      }

      PermissionStatus status =
          await PermissionHandler().checkPermissionStatus(permission);

      if (status != PermissionStatus.granted) {
        permissionsGranted = false;
      }
    }

    return permissionsGranted;
  }

  static Future<List<LocationPermissions>> isLocationAllowed() async {
    List<LocationPermissions> activePermissions = [];

    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationAlways);
    ServiceStatus serviceStatus =
        await PermissionHandler().checkServiceStatus(PermissionGroup.location);

    if (permission == PermissionStatus.granted) {
      activePermissions.add(LocationPermissions.os);
    }

    if (serviceStatus == ServiceStatus.enabled) {
      activePermissions.add(LocationPermissions.service);
    }

    SettingsManager settingsManager = SettingsManager();

    await settingsManager.loadSettings();
    if (settingsManager.settings.allowLocationServices) {
      activePermissions.add(LocationPermissions.app);
    }

    return activePermissions;
  }

  static Future<bool> isStoragePermissionAllowed() async {
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    return status == PermissionStatus.granted;
  }

  /// Open the app settings
  static Future<void> openAppSettings() async {
    await PermissionHandler().openAppSettings();
  }
}
