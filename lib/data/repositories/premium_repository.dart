import '../models/pago_premium_model.dart';
import '../models/premium_status_response.dart';
import '../services/premium_service.dart';

class PremiumRepository {
  final PremiumService _service = PremiumService();

  Future<PagoPremium> iniciarSuscripcion({required String jwt}) {
    return _service.iniciarSuscripcion(jwt: jwt);
  }

  Future<PremiumStatusResponse> verificarEstadoPremium({required String jwt}) {
    return _service.verificarEstadoPremium(jwt: jwt);
  }
}
