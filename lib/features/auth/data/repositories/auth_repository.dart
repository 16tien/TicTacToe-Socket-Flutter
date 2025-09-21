import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_local_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  final UserLocalStorage localStorage;
  AuthRepository(this.dioClient, this.localStorage);

  Future<UserModel> login(String email, String password) async {
    final response = await dioClient.dio.post("/auth/login", data: {
      "email": email,
      "password": password,
    });

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(response.data['user']);
      await dioClient.storage.write(
          key: "accessToken", value: response.data['accessToken']);
      await dioClient.storage.write(
          key: "refreshToken", value: response.data['refreshToken']);
      await localStorage.saveUser(user);
      return user;
    } else {
      throw Exception("Đăng nhập thất bại: ${response.data['message'] ?? 'Unknown'}");
    }
  }

  Future<void> logout() async {
    await dioClient.storage.delete(key: "accessToken");
    await dioClient.storage.delete(key: "refreshToken");
  }

  Future<bool> hasToken() async {
    final token = await dioClient.storage.read(key: "accessToken");
    return token != null;
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await dioClient.dio.get("/profile");
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
    } catch (_) {}
    return null;
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final response = await dioClient.dio.post(
        "/auth/register",
        data: {
          "email": email,
          "username": username,
          "password": password,
        },
      );
      if (response.statusCode == 200) {
        return;
      } else {
        final message = response.data['message'] ?? 'Đăng ký thất bại';
        throw Exception(message);
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'] ?? 'Đăng ký thất bại';
        throw Exception(message);
      }
      throw Exception('Lỗi kết nối. Vui lòng thử lại.');
    } catch (e) {
      throw Exception("Có lỗi xảy ra: ${e.toString()}");
    }
  }

}
