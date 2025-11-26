import 'package:fynso/data/models/api_response.dart';

import '../models/income_request.dart';
import '../services/income_service.dart';

class IncomeRepository {
  final IncomeService _service = IncomeService();

  Future<ApiResponse> registrarIngreso({
    required String jwt,
    required IncomeRequest request,
  }) {
    return _service.registrarIngreso(jwt: jwt, req: request);
  }
}
