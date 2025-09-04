import 'dart:io';
import 'package:yaml/yaml.dart';

import 'models/iconfont_config.dart';
import 'font_processor.dart';

/// Iconfont生成器，负责读取配置并处理字体
class IconfontGenerator {
  /// Iconfont配置
  late IconfontConfig config;
  
  /// 字体处理器列表
  List<FontProcessor> fontProcessors = [];

  /// 配置文件路径
  final String configPath;

  /// 构造函数
  IconfontGenerator({this.configPath = 'iconfont.yaml'});

  /// 运行生成器
  Future<void> run() async {
    try {
      print('🚀 开始执行 iconfont 插件...');
      
      // 1. 读取配置文件
      await _loadConfig();
      
      // 2. 处理每个字体配置
      for (final iconConfig in config.icons) {
        print('\n📦 处理字体: ${iconConfig.url}');
        final processor = FontProcessor(iconConfig);
        fontProcessors.add(processor);
        await processor.process();
      }
      
      print('\n✅ iconfont 插件执行完成！');
      print('\n🎉 后续步骤:');
      print('1. 在代码中导入: import \'package:your_project/iconfont/your_icon_name.dart\';');
      print('2. 使用图标: Icon(YourIconName.iconName)');
    } catch (e) {
      print('❌ 执行失败: $e');
      exit(1);
    }
  }

  /// 加载配置文件
  Future<void> _loadConfig() async {
    print('📖 读取配置文件...');
    final configFile = File(configPath);
    if (!await configFile.exists()) {
      throw Exception('配置文件 $configPath 不存在');
    }
    
    final configContent = await configFile.readAsString();
    final yamlDoc = loadYaml(configContent);
    config = IconfontConfig.fromYaml(yamlDoc);
    
    print('   配置加载完成，发现 ${config.icons.length} 个字体配置');
  }
}