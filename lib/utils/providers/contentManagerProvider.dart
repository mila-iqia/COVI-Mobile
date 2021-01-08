import 'dart:io';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:covi/utils/constants.dart' as Constants;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';

enum ContentTypes { news, recommendations }

class NewsContent {
  Map<String, dynamic> _title;
  Map<String, dynamic> _content;
  DateTime _from;
  DateTime _to;

  Map<String, dynamic> get title => _title;
  Map<String, dynamic> get content => _content;
  DateTime get from => _from;
  DateTime get to => _to;

  NewsContent(this._title, this._content, this._from, this._to);

  factory NewsContent.fromJson(Map<String, dynamic> parsedJson) {
    return NewsContent(
        parsedJson['title'],
        parsedJson['content'],
        DateTime.fromMillisecondsSinceEpoch(parsedJson['from']),
        DateTime.fromMillisecondsSinceEpoch(parsedJson['to']));
  }
}

class ContentFile {
  String get assetPath => this._assetPath;
  String _assetPath;

  String get fileUrl => this._fileUrl;
  String _fileUrl;

  ContentFile(String assetPath, String fileUrl) {
    this._assetPath = assetPath;
    this._fileUrl = fileUrl;
  }
}

class ContentManagerProvider with ChangeNotifier {
  bool _isReady = false;
  bool get isReady => _isReady;
  void set isReady(bool isReady) {
    _isReady = isReady;
    notifyListeners();
  }

  List<NewsContent> _news;
  List<NewsContent> get news => _news;

  Map<String, dynamic> _mainRecommendations;
  Map<String, dynamic> get mainRecommendations => _mainRecommendations;

  List<dynamic> _recommendations;
  List<dynamic> get recommendations => _recommendations;

  Map<String, ContentFile> contentFiles = {
    "singularRecommendations": ContentFile(
        'assets/data/singularRecommendations.json',
        '${Constants.cdnUrl}/content/singularRecommendations.json'),
    "mainRecommendations": ContentFile('assets/data/mainRecommendations.json',
        '${Constants.cdnUrl}/content/mainRecommendations.json'),
    "news": ContentFile(
        'assets/data/news.json', '${Constants.cdnUrl}/content/news.json'),
  };

  Map<String, Function> parserMap = new Map();

  ContentManagerProvider() {
    this.parserMap['singularRecommendations'] =
        this.parseSingularRecommendations;
    this.parserMap['mainRecommendations'] = this.parseMainRecommendations;
    this.parserMap['news'] = this.parseNews;

    this.loadInitialContent().then((value) {
      this.isReady = true;
    });

    this.loadExternalContent();
  }

  Future<void> loadInitialContent() {
    return Future.wait(contentFiles.keys.map(loadJsonAssetContent));
  }

  Future<void> loadJsonAssetContent(contentKey) async {
    String jsonString =
        await rootBundle.loadString(this.contentFiles[contentKey].assetPath);
    final parsedJson = json.decode(jsonString);
    this.parserMap[contentKey](parsedJson);
  }

  Future<void> loadExternalContent() {
    return Future.wait(contentFiles.keys.map(loadExternalJsonContent));
  }

  Future<void> loadExternalJsonContent(contentKey) async {
    try {
      await DefaultCacheManager()
          .removeFile(this.contentFiles[contentKey].fileUrl);
      var file = await DefaultCacheManager()
          .getSingleFile(this.contentFiles[contentKey].fileUrl);
      String contents = await file.readAsString();
      final parsedJson = json.decode(contents);
      this.parserMap[contentKey](parsedJson);
    } on HttpException {
      Logger().v(
          '[ContentManagerProvider] Could not load ${contentKey} content file.');
    } catch (e) {
      Logger().e('[ContentManagerProvider] ${e.toString()}');
    }
  }

  void parseSingularRecommendations(List<dynamic> parsedJson) {
    this._recommendations = parsedJson;
  }

  void parseMainRecommendations(Map<String, dynamic> parsedJson) {
    this._mainRecommendations = parsedJson;
  }

  void parseNews(List<dynamic> parsedJson) {
    List<NewsContent> tempContent = [];

    parsedJson.forEach((news) {
      tempContent.add(NewsContent.fromJson(news));
    });
    this._news = tempContent;
  }
}
