// ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:timona_ec/env.g.dart';
import 'package:timona_ec/libraries/progresshud/progresshud.dart';
import 'package:timona_ec/parts/general.dart';

String generateToken(String apikey, int expSeconds) {
  final parts = apikey.split('.');
  if (parts.length != 2) {
    throw Exception('Invalid apikey');
  }

  final id = parts[0];
  final secret = parts[1];
  final nowMilliseconds = DateTime.now().millisecondsSinceEpoch;

  final payload = {
    'api_key': id,
    'exp': nowMilliseconds + expSeconds * 1000,
    'timestamp': nowMilliseconds,
  };
  final jwt = JWT(payload, header: {'alg': 'HS256', 'sign_type': 'SIGN'});
  return jwt.sign(SecretKey(secret));
}

class GLMResponse {
  String content, model;
  int tokens;

  GLMResponse({
    required this.content,
    required this.model,
    required this.tokens,
  });

  @override
  String toString() {
    return '$content ($model, $tokens)';
  }
}

/// 用例：glm(message: "你如何学习Flutter？", model: "glm-4");
Future<void> glm({
  required String message,
  required void Function(GLMResponse resp) onDone,
  void Function(GLMResponse resp)? onStream,
  String model = "glm-3-turbo",
  String? systemMessage,
  List tools = const [],
  List? historyMessages,
  bool stream = false,
  bool search = false,
  String searchString = "",
}) async {
  var respGLM = GLMResponse(
    content: '',
    model: model,
    tokens: -1,
  );
  if (stream) {
    var sse = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
      header: {
        'Authorization': 'Bearer ${generateToken(Env.zhipuApiKey, 60)}',
        'Content-Type': 'application/json'
      },
      body: {
        'model': model,
        'stream': stream.toString(),
        'tools': [
          ...tools,
          {
            'type': 'web_search',
            "web_search": search
                ? {'enable': true}
                : {'enable': false, 'search_query': searchString}
          }
        ],
        'messages': [
          if (systemMessage != null)
            {
              'role': 'system',
              'content': systemMessage,
            },
          if (historyMessages != null) ...historyMessages,
          {
            'role': 'user',
            'content': message,
          }
        ]
      },
    );
    sse.listen((event) {
      if (event.data!.trim() != '[DONE]') {
        var jsonc = json.decode(event.data!);
        respGLM.content += jsonc['choices'][0]['delta']['content'];
        if (jsonc['usage'] != null) {
          respGLM.tokens = jsonc['usage']['total_tokens'];
        }
        if (onStream != null) onStream(respGLM);
      } else {
        print('--END SUBSCRIBE TO SSE---');
        onDone(respGLM);
      }
    });
  } else {
    var response = await http.post(
      Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${generateToken(Env.zhipuApiKey, 60)}',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'model': model,
        'stream': stream.toString(),
        'tools': tools,
        'messages': [
          if (systemMessage != null)
            {
              'role': 'system',
              'content': systemMessage,
            },
          if (historyMessages != null) ...historyMessages,
          {
            'role': 'user',
            'content': message,
          }
        ]
      }),
    );
    if (response.statusCode == 200) {
      var resp = json.decode(response.body);
      respGLM.content = resp['choices'][0]['message']['content'];
      respGLM.model = resp['model'];
      respGLM.tokens = resp['usage']['total_tokens'];
      onDone(respGLM);
    } else {
      throw 'GLM request failed: ${response.statusCode}';
    }
  }
}

Future<String> gpt(String input) async {
  OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo",
    messages: [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(input)
        ],
        role: OpenAIChatMessageRole.user,
      ),
    ],
  );
  print(chatCompletion);
  String content = chatCompletion.choices[0].message.content?[0].text ?? '';
  return content;
}

class WeatherResponse {
  int temp, feelsLike;
  String text;
  String? rain, tomorrow;

  WeatherResponse({
    required this.temp,
    required this.feelsLike,
    required this.text,
    this.rain,
    this.tomorrow,
  });

  @override
  String toString() {
    return 'Weather: $text, temperature $temp, feels like $feelsLike'
        '${rain != null ? ', $rain' : ''}'
        '${tomorrow != null ? ', tomorrow: $tomorrow' : ''}';
  }
}

// 用于获取和风天气数据
Future<WeatherResponse> qweather({
  required double x,
  required double y,
  bool tomorrow = false,
}) async {
  var response = await http.get(
    Uri.parse(
      'https://devapi.qweather.com/v7/weather/now?key=${Env.qWeatherApiKey}&location=$x,$y',
    ),
    headers: {'Content-Type': 'application/json'},
  );
  var response2 = await http.get(
    Uri.parse(
      tomorrow
          ? 'https://devapi.qweather.com/v7/weather/3d?key=${Env.qWeatherApiKey}&location=$x,$y'
          : 'https://devapi.qweather.com/v7/minutely/5m?key=${Env.qWeatherApiKey}&location=$x,$y',
    ),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200 && response2.statusCode == 200) {
    var resp = json.decode(response.body);
    var resp2 = json.decode(response2.body);
    var tomorrowString = "";
    if (tomorrow) {
      tomorrowString =
          "temperature ${resp2['daily'][0]['tempMin']}~${resp2['daily'][0]['tempMax']}, "
          "day ${resp2['daily'][0]['textDay']}, night ${resp2['daily'][0]['textNight']}";
    }
    var respObj = WeatherResponse(
      temp: int.parse(resp['now']['temp']),
      feelsLike: int.parse(resp['now']['feelsLike']),
      text: resp['now']['text'],
      rain: tomorrow ? null : resp2['summary'],
      tomorrow: tomorrow ? tomorrowString : null,
    );
    // e.g. Weather: 晴, temperature 22, feels like 18, 未来两小时无降水
    print(respObj);
    return respObj;
  } else {
    throw 'Weather request failed: ${response.statusCode}';
  }
}

Future<LocationData?> locationInfo() async {
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  LocationData locationData = await location.getLocation();
  print(locationData);
  return locationData;
}

class BaiduAiResponse {
  String activity, time;
  DateTime? dateTime;

  BaiduAiResponse({
    required this.activity,
    required this.time,
    this.dateTime,
  });

  @override
  String toString() {
    if (dateTime == null) {
      return '$activity ($time)';
    } else {
      return '$activity: $dateTime';
    }
  }
}

Future<List<BaiduAiResponse>> baiduAi(String given) async {
  print(given);
  var response = await http.post(
    Uri.parse(Env.baiduApiUrl),
    headers: {
      'Authorization': 'token ${Env.baiduApiToken}',
      'Content-Type': 'application/json'
    },
    body: json.encode({"content": given}),
  );
  if (response.statusCode == 200) {
    var resp = json.decode(response.body);
    var results = <BaiduAiResponse>[];
    for (var item in resp['results']) {
      try {
        results.add(
            BaiduAiResponse(activity: item['activity'], time: item['time']));
      } catch (e) {
        showHud(ProgressHudType.error, "UIE遇到问题：$e");
      }
    }
    print(results);
    return results;
  } else {
    throw 'AI request failed: ${response.statusCode} ${response.reasonPhrase}';
  }
}
