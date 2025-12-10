import 'package:flutter/foundation.dart';
import '../data/response/api_response.dart';
import '../data/response/status.dart';
import '../model/model.dart';
import '../model/international_cost.dart';
import '../model/international_destination.dart';
import '../repository/home_repository.dart';
import '../repository/international_repository.dart';

class InternationalViewModel extends ChangeNotifier {
  final _homeRepo = HomeRepository();
  final _interRepo = InternationalRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();

  // country search results
  ApiResponse<List<InternationalDestination>> countryList = ApiResponse.notStarted();

  // cost results
  ApiResponse<List<InternationalCost>> costList = ApiResponse.notStarted();

  bool isLoading = false;

  // Provinces (reused from HomeRepository)
  Future getProvinceList() async {
    if (provinceList.status == Status.completed) return;
    provinceList = ApiResponse.loading();
    notifyListeners();
    try {
      final data = await _homeRepo.fetchProvinceList();
      provinceList = ApiResponse.completed(data);
    } catch (e) {
      provinceList = ApiResponse.error(e.toString());
    }
    notifyListeners();
  }

  Future getCityOriginList(int provId) async {
    cityOriginList = ApiResponse.loading();
    notifyListeners();
    try {
      final data = await _homeRepo.fetchCityList(provId);
      cityOriginList = ApiResponse.completed(data);
    } catch (e) {
      cityOriginList = ApiResponse.error(e.toString());
    }
    notifyListeners();
  }

  // Search international destinations
  Future searchCountry(String keyword) async {
    if (keyword.trim().isEmpty) {
      countryList = ApiResponse.notStarted();
      notifyListeners();
      return;
    }
    countryList = ApiResponse.loading();
    notifyListeners();
    try {
      final data = await _interRepo.searchDestination(keyword);
      countryList = ApiResponse.completed(data);
    } catch (e) {
      countryList = ApiResponse.error(e.toString());
    }
    notifyListeners();
  }

  Future calculateInternationalCost({
    required String originCityId,
    required String destinationCountryId,
    required int weight,
    required String courier,
  }) async {
    isLoading = true;
    costList = ApiResponse.loading();
    notifyListeners();
    try {
      final result = await _interRepo.calculateCost(
        countryId: destinationCountryId,
        weight: weight,
        courier: courier,
      );
      costList = ApiResponse.completed(result);
    } catch (e) {
      costList = ApiResponse.error(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
