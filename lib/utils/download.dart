import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class UnreachableException implements Exception {
  final String msg;
  const UnreachableException(this.msg);
  String toString() => '$msg';
}

class NoConnectivityException implements Exception {
  final String msg;
  const NoConnectivityException(this.msg);
  String toString() => '$msg';
}

class DownloadService {
  DownloadService() {}

  /// Get the Appliation dir
  Future<String> getDir() async {
    Directory path = await getApplicationDocumentsDirectory();

    return path.path;
  }

  /// Get a file that was downloaded
  Future<String> readFile(String filename) async {
    // Application dir and path for the file
    String dir = await getDir();
    String path = "${dir}/$filename";

    Logger().v("[DownloadService] Reading file at $path");

    // Load up the file and make sure it exists
    File file = File.fromUri(Uri.parse(path));

    if (file.existsSync()) {
      return file.readAsStringSync();
    }

    return null;
  }

  /// Download the file at provided url with optional filename
  Future<void> downloadFromUrl(String url, [String filename]) async {
    String dir = await getDir();

    Logger().v("[DownloadService] Downloading from ${url.toString()}");

    // Parse our URL
    Uri _url = Uri.parse(url);

    // Set the filename
    String _filename =
        filename == null ? url.substring(url.lastIndexOf("/") + 1) : filename;

    // Check if we're online
    ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      throw new NoConnectivityException(
          'Device is not connected to the internet.');
    }
    // Get an HTTP client and do a request
    try {
      http.Client _client = new http.Client();
      http.Response response = await _client.get(_url);
      if (response.statusCode >= 400) {
        throw new UnreachableException('Could not get URL.');
      }

      // Download and write the file
      Uint8List bytes = response.bodyBytes;
      File file = new File('${dir}/$_filename');

      await file.writeAsBytes(bytes);
    } catch (e) {
      throw new UnreachableException(e.message);
    }

    Logger()
        .v("[DownloadService] Downloaded file $_filename to ${dir}/$_filename");
  }
}
