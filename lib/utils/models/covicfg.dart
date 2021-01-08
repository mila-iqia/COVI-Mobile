import 'dart:convert';

import 'package:logger/logger.dart';

import '../download.dart';

class Covicfg {
  int version;
  int dns_prefix_length;
  int prefix_max_sets;
  Map<String, dynamic> authmixnet;
  Map<String, dynamic> unverifiedmixnet;
  List<dynamic> seqauthmixnet;
  List<dynamic> seqmixnet;
  String milapubkey;
  bool transmitdatatomixnet;
  int transmitminriskfactorofficiel;
  int transmitminriskfactorself;
  int defaultriskfactor;
  int maxmixnetmsgsperrequests;
  int maxanswerperdnsV1;
  int maxretendiondays;
  int transmissionprobabilityconstant;
  int maxDnsResolveAttempts;

  int riskFactorThreshold;

  int mailboxRequestFrequencyInMilliseconds;

  List<String> dnsServers;

  String cdnCoviAppDomain;
  String mailboxCoviAppDomain;
  String oldEncryptionKey;

  String mixnetUrl;

  DownloadService downloadService;

  static final Covicfg _instance = Covicfg._internal();

  factory Covicfg() {
    _instance.mixnetUrl = "https://mixnet4.coviapp.io/mixnet/v0/receive";
    if (_instance.riskFactorThreshold == null) {
      _instance.riskFactorThreshold = 14;
    }
    ;
    if (_instance.oldEncryptionKey == null) {
      _instance.oldEncryptionKey =
          "wFeHK0flRHRnRDn15NY4/jHdx5C3kjxchU15ZeoxQHg=";
    }
    ;
    if (_instance.dnsServers == null) {
      _instance.dnsServers = [
        "149.112.122.30",
        "216.21.129.22",
        "65.39.139.53",
        "66.163.0.173",
        "142.44.163.35"
      ];
    }
    ;
    if (_instance.maxDnsResolveAttempts == null) {
      _instance.maxDnsResolveAttempts = 3;
    }
    ;
    if (_instance.mailboxRequestFrequencyInMilliseconds == null) {
      _instance.mailboxRequestFrequencyInMilliseconds = 500;
    }
    ;
    if (_instance.mailboxCoviAppDomain == null) {
      _instance.mailboxCoviAppDomain = "mailbox.coviapp.io";
    }
    ;

    return _instance;
  }

  Covicfg._internal();

  /**
   * Load the covi config from the cdn then cache it locally.
   */
  static Future<Covicfg> load() async {
    if (_instance.downloadService == null) {
      _instance.downloadService = new DownloadService();
    }

    // Check if we have the config file saved locally
    String jsonConfig =
        await _instance.downloadService.readFile("covicfg.json");

    if (jsonConfig == null) {
      // else retrieve latest config from cdn
      jsonConfig = await _instance._retrieveConfigFromCdn();
    }

    // Update all values
    fromJson(json.decode(jsonConfig));

    return _instance;
  }

  /**
   * Update the local covi config from the cdn
   */
  static Future<void> update() async {
    // Retrieve latest config from cdn
    String jsonConfig = await _instance._retrieveConfigFromCdn();

    Logger().d("new config : " + jsonConfig);

    // Update all values
    fromJson(json.decode(jsonConfig));
  }

  /**
   * Retrieve the latest covi config from the cdn using the download service
   */
  Future<String> _retrieveConfigFromCdn() async {
    if (downloadService == null) {
      downloadService = new DownloadService();
    }

    if (cdnCoviAppDomain == null) {
      cdnCoviAppDomain = "cdn.coviapp.io";
    }

    // Download the covi config from the cdn url and save it locally
    String cdnAddress = "https://$cdnCoviAppDomain/covicfg.json";

    await downloadService.downloadFromUrl(cdnAddress, "covicfg.json");

    // Load the file
    String jsonConfig = await downloadService.readFile("covicfg.json");

    return jsonConfig;
  }

  static fromJson(Map<String, dynamic> json) {
    _instance.version = json['version'];
    _instance.dns_prefix_length = json['dns_prefix_length'];
    _instance.prefix_max_sets = json['prefix_max_sets'];
    _instance.authmixnet = json['authmixnet'];
    _instance.unverifiedmixnet = json['unverifiedmixnet'];
    _instance.seqauthmixnet = json['seqauthmixnet'];
    _instance.seqmixnet = json['seqmixnet'];
    _instance.milapubkey = json['milapubkey'];
    _instance.transmitdatatomixnet = json['transmitdatatomixnet'];
    _instance.transmitminriskfactorofficiel =
        json['transmitminriskfactorofficiel'];
    _instance.transmitminriskfactorself = json['transmitminriskfactorself'];
    _instance.defaultriskfactor = json['defaultriskfactor'];
    _instance.maxmixnetmsgsperrequests = json['maxmixnetmsgsperrequests'];
    _instance.maxanswerperdnsV1 = json['maxanswerperdnsV1'];
    _instance.maxretendiondays = json['maxretendiondays'];
    _instance.mailboxRequestFrequencyInMilliseconds =
        json['mailboxRequestFrequencyInMilliseconds'];
    _instance.cdnCoviAppDomain = json['cdnCoviAppDomain'];
    _instance.mailboxCoviAppDomain = json['mailboxCoviAppDomain'];
    _instance.transmissionprobabilityconstant =
        json['transmissionprobabilityconstant'];
    _instance.dnsServers = json['dnsservers'];
    _instance.maxDnsResolveAttempts = json['maxdnsresolveattempts'];
    _instance.oldEncryptionKey = json['oldencryptionkey'];
    _instance.riskFactorThreshold = json['riskfactorthreshold'];
  }

  static Map<String, dynamic> toJson() => {
        'version': _instance.version,
        'dns_prefix_length': _instance.dns_prefix_length,
        'prefix_max_sets': _instance.prefix_max_sets,
        'authmixnet': _instance.authmixnet,
        'unverifiedmixnet': _instance.unverifiedmixnet,
        'seqauthmixnet': _instance.seqauthmixnet,
        'seqmixnet': _instance.seqmixnet,
        'milapubkey': _instance.milapubkey,
        'transmitdatatomixnet': _instance.transmitdatatomixnet,
        'transmitminriskfactorofficiel':
            _instance.transmitminriskfactorofficiel,
        'transmitminriskfactorself': _instance.transmitminriskfactorself,
        'defaultriskfactor': _instance.defaultriskfactor,
        'maxmixnetmsgsperrequests': _instance.maxmixnetmsgsperrequests,
        'maxanswerperdnsV1': _instance.maxanswerperdnsV1,
        'maxretendiondays': _instance.maxretendiondays,
        'mailboxRequestFrequencyInMilliseconds':
            _instance.mailboxRequestFrequencyInMilliseconds,
        'cdnCoviAppDomain': _instance.cdnCoviAppDomain,
        'mailboxCoviAppDomain': _instance.mailboxCoviAppDomain,
        'transmissionprobabilityconstant':
            _instance.transmissionprobabilityconstant,
        'dnsservers': _instance.dnsServers,
        'maxdnsresolveattempts': _instance.maxDnsResolveAttempts,
        'oldencryptionkey': _instance.oldEncryptionKey,
        'riskfactorthreshold': _instance.riskFactorThreshold
      };
}
