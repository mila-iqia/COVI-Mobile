/**
   _
  | |
  | |  K9-TEAM WAS HERE 🌈
  | |___
  |_____| */

import 'dart:async';
import 'dart:io';
import "dart:math";

import 'package:logger/logger.dart';

import 'models/covicfg.dart';

class DnsResolver {
  // Dns client
  // UdpDnsClient _client;
  // Covi config
  Covicfg _covicfg;

  Future<bool> init() async {
    // start for 3 attempts:  try internet dns server
    _covicfg = new Covicfg();

    int attempt = 0;
    int maxAttempts = _covicfg.maxDnsResolveAttempts;
    bool dnsResolved = false;

    List<String> dns_servers = _covicfg.dnsServers;
    final _random = new Random();

    while (attempt < maxAttempts && !dnsResolved) {
      attempt += 1;
      var _random_dns = dns_servers[_random.nextInt(dns_servers.length)];
      // Init DNS Client
      //_client = UdpDnsClient(
      //  remoteAddress: InternetAddress(_random_dns)
      //);

      bool result = await validateDnsServer();
      dnsResolved = result;
    }

    return dnsResolved;
  }

  Future<bool> validateDnsServer() async {
    try {
      // validate resolve google.com
      await resolve('google.com');

      return true;
    } on TimeoutException catch (err) {
      Logger().d('Dns server not available : $err');
      return false;
    }
  }

  /**
   * Resolve the domain using the dns client
   */
  Future<List<String>> resolve(String domain,
      {type: String /*DnsQuestion.typeTxt*/}) async {
    /*
    if (_client == null) {
      return Future.error(new ArgumentError.notNull("_client"));
    }

    try {
      final DnsPacket result =
          await _client.lookupPacket(domain, queryType: type);

      // DNS Answers
      List<String> answers = new List<String>();

      // Loop DNS Record
      for (DnsResourceRecord answer in result.answers) {
        answers.add(new String.fromCharCodes(answer.data).substring(1));
      }

      return answers;
    } on TimeoutException catch (err) {
      return Future.error(TimeoutException(err.message));
    }
    */
    return new List<String>();
  }
}
