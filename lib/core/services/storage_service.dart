import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';


class StorageService extends GetxService {
  static StorageService get to => Get.find();
  
  late final Box _settingsBox;

  Future<StorageService> init() async {
    // Hive init logic actually happens in main.dart or better here
    // But we need to await getApplicationDocumentsDirectory
    // For Hive Flutter helper:
    await Hive.initFlutter();
    
    // We will register adapters later in main, but boxes can be opened here
    _settingsBox = await Hive.openBox('settings');
    
    return this;
  }

  T read<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  Future<void> write(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  Future<void> clear() async {
    await _settingsBox.clear();
  }
}
