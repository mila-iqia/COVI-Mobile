/**
   _
  | |
  | |  K9-TEAM WAS HERE 🌈
  | |___
  |_____| */
  
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:covi/utils/covid_stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geojson/geojson.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geopoint/geopoint.dart';
import 'package:geodesy/geodesy.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';

enum UserRegionState { loading, notFound, loaded, noDataNoInternet, noDataNotReachable }

class UserRegion {
  UserRegion({this.state = UserRegionState.loading});

  UserRegionState state;
  Map<String, dynamic> _data;

  void set data(Map<String, dynamic> data) => _data = data;
  Map<String, dynamic> get data => _data;

  bool hasLoadedData() {
    if (this.data == null) {
      return false;
    }
    if (_data['stats'] != null) {
      for (var i = 0; i < CovidStatsManager.types.length; i++) {
        if (_data['stats'][CovidStatsManager.types[i]] == null) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
}

class UserRegionsManager extends ChangeNotifier {
  bool _isReady = false;
  void set isReady(bool isReady) => _isReady = isReady;
  bool get isReady => _isReady;

  // Region Levels
  static List<String> levels = ["country", "state", "subregion"];

  // Stream Controllers
  StreamController _regionStartedController;
  StreamController _regionNotFoundController;
  StreamController _regionReadyController;

  Map<String, dynamic> _userRegionObjects = null;
  dynamic get regions => _userRegionObjects;

  // Access the controller outside
  StreamController get regionStartedController => _regionStartedController;
  StreamController get regionNotFoundController => _regionNotFoundController;
  StreamController get regionReadyController => _regionReadyController;

  Geodesy geodesy;
  List nearRegions;

  /// Localstorage access
  static final String _fileName = "userregions.json";
  static final String _locationKey = "location";
  static final String _regionsKey = "regions";
  static final LocalStorage _storage = new LocalStorage(_fileName);

  bool regionFound;
  bool isProcessing = false;

  // User regions manager constructor
  UserRegionsManager(BuildContext context) {
    Logger().v("[UserRegionsManager] Constructor...");

    // Initialize Geodesy utility class
    geodesy = Geodesy();

    _regionStartedController = new StreamController.broadcast();
    _regionReadyController = new StreamController.broadcast();
    _regionNotFoundController = new StreamController.broadcast();

    _userRegionObjects = new Map();

    // Populate user regions objects on constructor if available.
    _storage.ready.then((ready) async {
      _userRegionObjects = _storage.getItem("regionsByLevel");

      //Set default values if emppty
      if (_userRegionObjects == null) {
        List<dynamic> allRegions = await loadRegionsData();

        _userRegionObjects = new Map();

        Map<String, dynamic> subregion = allRegions.firstWhere((region) => region['region'] == '2406');
        Map<String, dynamic> state = allRegions.firstWhere((region) => region['region'] == 'QC');
        Map<String, dynamic> country = allRegions.firstWhere((region) => region['region'] == 'CA');

        _userRegionObjects['subregion'] = subregion;
        _userRegionObjects['state'] = state;
        _userRegionObjects['country'] = country;

        await _storage.setItem("regionsByLevel", _userRegionObjects);
      }
      _changeReadyStatus(true);
      notifyListeners();
    });
  }

  void _changeReadyStatus(bool status){
    this._isReady = status;
    notifyListeners();
  }

  // Loads regions data from asset file
  Future<List<dynamic>> loadRegionsData() async {
    Logger().v("[UserRegionsManager] Loading regions...");

    // Load regions data from file
    String regionsJson = await rootBundle.loadString("assets/data/regions.json");

    // Decode regions data
    return json.decode(regionsJson);
  }

  /// Find regions by user location
  Future<void> computeRegionsByLocation() async {
    if (isProcessing) {
      return;
    }
    //Set Processing flag
    isProcessing = true;

    Logger().v("[UserRegionsManager] Finding user regions _levels...");

    try {
      // Load user regions from storage when ready
      await _storage.ready;

      _userRegionObjects = _storage.getItem("regionsByLevel") ?? new Map();

      UserRegionsManager.levels.forEach((level) {
        _regionStartedController.sink.add(level);
      });

      // If user regions are not loaded
      if (_userRegionObjects.isEmpty) {
        // Save user regions
        await updateRegionsData();
      } else {
        _userRegionObjects.forEach((level, region) {
          _regionReadyController.sink.add(level);
        });
      }
    } catch (e) {
      Logger().v(e);
      isProcessing = false;
    }
    isProcessing = false;
  }

  Future<void> updateRegionsData() async {
    Logger().v('[UserRegionsManager] User regions not found, finding regions for user');

    _userRegionObjects = new Map();

    // Start stopwatch to keep track of how long it takes to find regions
    final Stopwatch stopwatch = Stopwatch()..start();

    // Load regions Data
    List<dynamic> regions = await loadRegionsData();

    // Get Active user position
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    GeoPoint currentLocation = GeoPoint(latitude: position.latitude, longitude: position.longitude);

    await findUserRegionsByParent(regions, currentLocation, null);

    // Output how long it took to find all the info
    Logger().v('[UserRegionsManager] Finding user all regions took ${stopwatch.elapsed}');

    // Clear regions to save some memory
    regions = null;

    Logger().v('[UserRegionsManager] Saving user regions...');
  }

  Future<void> saveRegionToUserRegions(Map<String, dynamic> region) async {
    _userRegionObjects[region['level']] = region;
    await _storage.setItem("regionsByLevel", _userRegionObjects);
    _regionReadyController.sink.add(region['level']);
  }

  Future<void> levelNotFound(String level) async {
    _regionNotFoundController.sink.add(level);
  }

  Future<Map<String, dynamic>> findUserRegionsByParent(List<dynamic> regions, GeoPoint location, String parentRegion) async {
    // Initialize Geodesy utility class
    final Geodesy geodesy = Geodesy();

    // Filter regions by parent
    List filteredRegions = regions.where((region) => region['parent'] == parentRegion).toList();

    /// Exact region found (user location inside)
    bool regionFound = false;

    /// Regions near user location
    List nearRegions = [];

    for (Map<String, dynamic> region in filteredRegions) {
      // Build temporary JSON, has GeoJSON needs a FeatureCollection
      String featuresJson = '{"type": "FeatureCollection","features": [' + json.encode(region['geoJson']) + ']}';

      // Initialize GeoJson util class
      final geojson = GeoJson();

      // Parse GeoJson
      await geojson.parse(featuresJson);

      /// Polygons of Region GeoJSON
      List<GeoJsonPolygon> polygons = geojson.polygons + geojson.multipolygons.map((multiPolygon) => multiPolygon.polygons).expand((i) => i).toList();

      for (GeoJsonPolygon polygon in polygons) {
        // If exact region has not been found
        if (!regionFound) {
          // If user location is inside the current polygon
          if (geodesy.isGeoPointInPolygon(location.toLatLng(), polygon.geoSeries[0].toLatLng())) {
            // Clean up for storage
            region['geoJson'] = null;
            region['nearPoints'] = null;

            // Exact region found
            regionFound = true;

            Logger().v("[UserRegionsManager] Found user region : " + region['name']['en']);

            saveRegionToUserRegions(region);
            return findUserRegionsByParent(regions, location, region['region']);
          } else {
            // Points near user location
            List nearPoints = geodesy.pointsInRange(location.toLatLng(ignoreErrors: true), polygon.geoSeries[0].toLatLng(ignoreErrors: true), 10000);

            // Current polygon has points near user location
            if (nearPoints.length > 0 && !_userRegionObjects.containsKey(region['level'])) {
              // Add near points to current region
              region['nearPoints'] = nearPoints;

              // Add current region to near regions
              nearRegions.add(region);
            }
          }
        }
      }
    }

    // If exact region has not been found and near regions have been found
    if (!regionFound && nearRegions.length > 0) {
      // If more than one near region has been found
      if (nearRegions.length > 1) {
        for (dynamic region in nearRegions) {
          /// Distances for near region points and user location
          List<num> distances =
              region['nearPoints'].map<num>((point) => geodesy.distanceBetweenTwoGeoPoints(location.toLatLng(ignoreErrors: true), point)).toList();

          // Get the minimum distance between user and near region
          region['minDistance'] = distances.reduce(min);

          Logger().v("[UserRegionsManager] Near user region : " + region['name']['en'] + " (${region['minDistance']})");
        }

        // Sort near region by distance closer to user
        nearRegions.sort((a, b) => a['minDistance'].compareTo(b['minDistance']));
      }

      // Clean up for storage
      nearRegions[0]['geoJson'] = null;
      nearRegions[0]['nearPoints'] = null;

      Logger().v("[UserRegionsManager] Selected near user region : " + nearRegions[0]['name']['en']);
      saveRegionToUserRegions(nearRegions[0]);
      return findUserRegionsByParent(regions, location, nearRegions[0]['region']);
    }
    String notFoundLevel;
    if (parentRegion == null) {
      notFoundLevel = "country";
    } else {
      notFoundLevel = regions.firstWhere((region) => region['region'] == parentRegion)['region'];
    }
    levelNotFound(notFoundLevel);
    return null;
  }

  static Future<void> clear() async {
    await _storage.deleteItem(_locationKey);
    await _storage.deleteItem(_regionsKey);
    return;
  }
}
