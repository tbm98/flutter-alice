import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_alice/core/alice_chopper_response_interceptor.dart';
import 'package:flutter_alice/core/alice_core.dart';
import 'package:flutter_alice/core/alice_dio_interceptor.dart';
import 'package:flutter_alice/core/alice_http_adapter.dart';
import 'package:flutter_alice/core/alice_http_client_adapter.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:http/http.dart' as http;

class Alice {
  /// Should inspector use dark theme
  final bool darkTheme;
  late AliceCore _aliceCore;
  late AliceHttpClientAdapter _httpClientAdapter;
  late AliceHttpAdapter _httpAdapter;

  /// Creates alice instance.
  Alice({this.darkTheme = false}) {
    _aliceCore = AliceCore(darkTheme);
    _httpClientAdapter = AliceHttpClientAdapter(_aliceCore);
    _httpAdapter = AliceHttpAdapter(_aliceCore);
  }

  void show(BuildContext context) {
    _aliceCore.show(context);
  }

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() {
    return AliceDioInterceptor(_aliceCore);
  }

  /// Handle request from HttpClient
  void onHttpClientRequest(HttpClientRequest request, {dynamic body}) {
    _httpClientAdapter.onRequest(request, body: body);
  }

  /// Handle response from HttpClient
  void onHttpClientResponse(HttpClientResponse response, HttpClientRequest request,
      {dynamic body}) {
    _httpClientAdapter.onResponse(response, request, body: body);
  }

  /// Handle both request and response from http package
  void onHttpResponse(http.Response response, {dynamic body}) {
    _httpAdapter.onResponse(response, body: body);
  }

  /// Get chopper interceptor. This should be added to Chopper instance.
  List<ResponseInterceptor> getChopperInterceptor() {
    return [AliceChopperInterceptor(_aliceCore)];
  }

  /// Handle generic http call. Can be used to any http client.R
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    _aliceCore.addCall(aliceHttpCall);
  }
}
