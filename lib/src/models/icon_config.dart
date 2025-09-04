import 'package:yaml/yaml.dart';

/// 单个图标配置
class IconConfig {
  /// 图标CSS文件URL
  final String url;
  
  /// 字体资源路径
  final String fontAssetsPath;
  
  /// 类名，默认从icon_name获取
  late String className;

  IconConfig({
    required this.url,
    required this.fontAssetsPath,
  });

  /// 从YAML配置创建IconConfig
  factory IconConfig.fromYaml(YamlMap yaml) {
    final config = IconConfig(
      url: yaml['url'] as String,
      fontAssetsPath: yaml['font_assets_path'] as String,
    );
    
    // 设置类名，优先使用配置中的icon_name
    if (yaml.containsKey('icon_name')) {
      config.className = yaml['icon_name'] as String;
    }
    
    return config;
  }
}