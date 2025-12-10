import '../data/network/network_api_service.dart';
import '../model/international_destination.dart';
import '../model/international_cost.dart';

class InternationalRepository {
  final _api = NetworkApiServices();

  Future<List<InternationalDestination>> searchDestination(String keyword) async {
    final response =
        await _api.getApiResponse('international-destination?search=$keyword');

    if (response['meta']['code'] != 200 || response['data'] == null) {
      throw Exception(response['meta']['message']);
    }

    final List list = response['data'];
    return list.map((e) => InternationalDestination.fromJson(e)).toList();
  }

  Future<List<InternationalCost>> calculateCost({
    required String countryId,
    required int weight,
    required String courier,
  }) async {
    final response = await _api.postApiResponse('international-cost', {
      'destination': countryId,
      'weight': weight,
      'courier': courier,
    });

    if (response['meta']['code'] != 200 || response['data'] == null) {
      throw Exception(response['meta']['message']);
    }

    final List list = response['data'];
    return list.map((e) => InternationalCost.fromJson(e)).toList();
  }
}
