import '../core/api_client.dart';
import '../models/category.dart';

class CategoryService {
  Future<List<Category>> getCategories({String? type}) async {
    final res = await ApiClient.instance.dio.get('/categories', queryParameters: {
      if (type != null) 'type': type,
    });
    return (res.data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> create(String name, String type, String color) async {
    final res = await ApiClient.instance.dio.post('/categories', data: {
      'name': name,
      'type': type,
      'color': color,
    });
    return Category.fromJson(res.data);
  }

  Future<Category> update(int id, String name, String type, String color) async {
    final res = await ApiClient.instance.dio.put('/categories/$id', data: {
      'name': name,
      'type': type,
      'color': color,
    });
    return Category.fromJson(res.data);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.dio.delete('/categories/$id');
  }
}
