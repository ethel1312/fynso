// lib/data/repositories/usuario_premium_repository.dart
import '../models/usuario_premium_model.dart';
import '../services/usuario_premium_service.dart';

class UsuarioPremiumRepository {
  final UsuarioPremiumService _service = UsuarioPremiumService();

  Future<UsuarioPremium?> fetchEstadoPremium({required String jwt}) {
    return _service.obtenerEstadoPremium(jwt: jwt);
  }
}
