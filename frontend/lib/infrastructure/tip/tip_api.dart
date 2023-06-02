import 'dart:convert';
import 'package:frontend/infrastructure/tip/tip_dto.dart';
import 'package:frontend/infrastructure/tip/tip_form_dto.dart';
import 'package:frontend/util/jj_http_client.dart';
import 'package:frontend/util/jj_http_exception.dart';
import 'package:frontend/util/jj_timeout_exception.dart';


class TipAPI {
  JJHttpClient _customHttpClient = JJHttpClient();

  Future<TipDto> createTip(TipFormDto tipFormDto) async {
    var tip = await _customHttpClient.post("tips",
        body: json.encode(tipFormDto.toJson()));

    if (tip.statusCode == 201) {
      return TipDto.fromJson(jsonDecode(tip.body));
    } else {
      throw JJHttpException(
          json.decode(tip.body)['message'] ?? "Unknown error", tip.statusCode);
    }
  }

  Future<TipDto> updateTip(TipFormDto tipFormDto, String id) async {
    var updatedTip = await _customHttpClient.put("tips/$id",
        body: json.encode(tipFormDto.toJson()));

    if (updatedTip.statusCode == 200) {
      return TipDto.fromJson(jsonDecode(updatedTip.body));
    } else {
      throw JJHttpException(
          json.decode(updatedTip.body)['message'] ?? "Unknown error",
          updatedTip.statusCode);
    }
  }

  Future<void> deleteTip(String tipid) async {
    var response = await _customHttpClient.delete("tips/$tipid");
    print("statusCode" + response.statusCode.toString());
    if (response.statusCode != 200) {
      throw JJHttpException(
          json.decode(response.body)['message'] ?? "Unknown error",
          response.statusCode);
    }
  }

  Future<List<TipDto>> getTips() async {
    var tips = await _customHttpClient.get("tips");

    if (tips.statusCode == 200) {
      return (jsonDecode(tips.body) as List)
          .map((e) => TipDto.fromJson(e))
          .toList();
    } else {
      throw JJHttpException(json.decode(tips.body)['message'] ?? "Unknown error",
          tips.statusCode);
    }
  }

  Future<TipDto> getOneTip(String id) async {
    var tip = await _customHttpClient.get("tips/$id");

    if (tip.statusCode == 201 && tip.body != null) {
      return TipDto.fromJson(jsonDecode(tip.body));
    } else if (tip.body == null) {
      throw JJHttpException("Tip not found", tip.statusCode);
    } else {
      throw JJHttpException(
          json.decode(tip.body)['message'] ?? "Unknown error", tip.statusCode);
    }
  }

  Future<List<TipDto>> getTipsByType(String type) async {
    try{
      const int timeoutDurationInSec = 5;
      final timeoutFuture = Future.delayed(Duration(seconds: timeoutDurationInSec), () {
        throw JJTimeoutException();
      });

      var timeout = Duration(seconds: timeoutDurationInSec);
      var tips = await _customHttpClient.get("tips/bytype/$type").timeout(timeout);


    if (tips.statusCode == 200) {
      print("Yeah I did it, got 200");
      List<TipDto> res = (jsonDecode(tips.body) as List)
          .map((e) => TipDto.fromJson(e))
          .toList();
      print("the tips");
      print(res);
      return res;
    } else {
      throw JJTimeoutException();
      print("There has been an error" + tips.statusCode.toString());
      throw JJHttpException(json.decode(tips.body)['message'] ?? "Unknown error",
          tips.statusCode);
    }
    } catch (_) {
      throw JJTimeoutException();
    }
  }
}
