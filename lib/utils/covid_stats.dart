/**
   _
  | |
  | |  K9-TEAM WAS HERE 🌈
  | |___
  |_____| */

import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:covi/utils/permissions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:covi/utils/download.dart';
import 'package:covi/utils/user_regions.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

enum CovidStatsStatuses { noOsLocationPermission, noLocationServices, noGPSService, noStoragePermission }

class CovidStatsManager extends ChangeNotifier {
  static List types = ['cases', 'deaths', 'recoveries'];

  // Stats map, containing all data
  Map<String, UserRegion> _stats = new Map();
  // Stats getter
  Map<String, UserRegion> get stats => _stats;

  // Stats active status. Any status in this list represents a "problem".
  List<CovidStatsStatuses> _statuses = [];
  // Stats active status getter
  List<CovidStatsStatuses> get statuses => _statuses;

  // Last update date time getter
  DateTime get lastUpdateTime => lastUpdate;
  // Last update date time
  DateTime lastUpdate = null;
  // Collection of updates for each file type (region+data type)
  Map<String, dynamic> lastUpdates;

  // File download service
  DownloadService downloadService;

  // User Regions manager
  UserRegionsManager userRegionsManager;

  // Stream listener, coming from User Regions updates.
  StreamSubscription readySubscription;
  StreamSubscription startedSubscription;
  StreamSubscription notFoundSubscription;
  StreamSubscription connectivitySubscription;

  //Previous Connectivity Status
  ConnectivityResult connectivityStatus;

  /// Localstorage access
  static final String _fileName = "covidstats.json";
  static final String _itemKey = "lastUpdates";
  static final LocalStorage _storage = new LocalStorage(_fileName);

  /// COVID stats manager constructor
  CovidStatsManager(BuildContext context) {
    Logger().v("[CovidStatsManager] Constructor...");

    downloadService = new DownloadService();
    userRegionsManager = Provider.of<UserRegionsManager>(context, listen: false);

    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      if (connectivityStatus != null && connectivityStatus == ConnectivityResult.none) {
        this.updateStats();
      }
      connectivityStatus = result;
    });
  }

  // Update the CovidStats permission status list.
  Future<bool> updateLocationPermissionsValidation() async {
    List<LocationPermissions> locationPermissions = await PermissionsManager.isLocationAllowed();
    _statuses = [];
    if (!locationPermissions.contains(LocationPermissions.os)) {
      _statuses.add(CovidStatsStatuses.noOsLocationPermission);
    }
    if (!locationPermissions.contains(LocationPermissions.app)) {
      _statuses.add(CovidStatsStatuses.noLocationServices);
    }
    if (!locationPermissions.contains(LocationPermissions.service)) {
      _statuses.add(CovidStatsStatuses.noGPSService);
    }

    notifyListeners();
    return !_statuses.isEmpty;
  }

  Future<bool> updateStoragePermissionValidation() async {
    bool hasPermission = await PermissionsManager.isStoragePermissionAllowed();
    if (hasPermission) {
      return true;
    }
    return PermissionsManager.requestPermissions();
  }

  // Update the stats, if possible.
  void updateStats() async {
    await _storage.ready;
    lastUpdates = _storage.getItem(_itemKey) ?? {};
    userRegionsManager.regions.forEach((level, region) {
      if (_stats[level] == null) {
        _stats[level] = new UserRegion();
      }

      _stats[level].state = UserRegionState.loading;
      loadStatFiles(level, region);
    });
    updateLastUpdateTime();
    notifyListeners();
  }

  void updateLastUpdateTime() {
    List covidStatsUpdateTimes = lastUpdates.entries.map((update) => update.value != null ? DateTime.parse(update.value) : null).toList();
    if (covidStatsUpdateTimes.length > 1) {
      covidStatsUpdateTimes.sort((a, b) => a.difference(b).inSeconds);
    }
    lastUpdate = covidStatsUpdateTimes != null && covidStatsUpdateTimes.length > 0 ? covidStatsUpdateTimes[0] : null;
  }

  Future<void> loadFiles(dynamic _region) async {
    Logger().v("[CovidStatsManager] Region ${_region['region']} downloading");
    // Loop through stats files to download
    List<String> files = ["${_region['region']}_cases_hist.json", "${_region['region']}_deaths_hist.json", "${_region['region']}_recoveries_hist.json"];
    await Future.wait(files.map(loadFile));
  }

  Future<void> loadFile(String _file) async {
    Logger().v("[CovidStatsManager] Checking $_file status...");

    // Last update time
    DateTime lastUpdate = lastUpdates[_file] != null ? DateTime.parse(lastUpdates[_file]) : null;

    if (lastUpdate == null || lastUpdate.isBefore(DateTime.now().subtract(new Duration(hours: 4)))) {
      Logger().v("[CovidStatsManager] Local copy is expired, loading from server (${_file}) ...");

      await downloadService.downloadFromUrl("https://cdn.coviapp.io/covid-stats/${_file}", _file);

      lastUpdates[_file] = DateTime.now().toString();

      await updateLastUpdateTime();

      // Save last updates for files
      _storage.setItem(_itemKey, lastUpdates);
    }
  }

  Future<void> loadStatFiles(String _level, Map<String, dynamic> _region) async {
    _region['stats'] = {};

    UserRegionState state = UserRegionState.loaded;

    DateTime latestUpdate = null;

    for (String type in types) {
      String fileName = "${_region['region']}_${type}_hist.json";
      try {
        await loadFile(fileName);
      } on NoConnectivityException {
        state = UserRegionState.noDataNoInternet;
      } on UnreachableException {
        state = UserRegionState.noDataNotReachable;
      }
      String statsJson = await downloadService.readFile(fileName);

      DateTime fileUpdate = lastUpdates[fileName] != null ? DateTime.parse(lastUpdates[fileName]) : DateTime.now();
      if (latestUpdate == null || fileUpdate.isAfter(latestUpdate)) {
        latestUpdate = fileUpdate;
      }
      _region['stats'][type] = statsJson != null ? json.decode(statsJson) : null;
    }

    _region['lastUpdate'] = latestUpdate.toString();
    _stats[_level].data = _region;
    _stats[_level].state = state;
    notifyListeners();
  }

  static Future<void> clear() async {
    await _storage.deleteItem(_itemKey);
    return;
  }
}
