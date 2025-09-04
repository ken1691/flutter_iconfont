import 'package:yaml/yaml.dart';
import 'icon_config.dart';

/// Iconfont配置类，包含多个图标配置
class IconfontConfig {
  /// 图标配置列表
  final List<IconConfig> icons;

  IconfontConfig({
    required this.icons,
  });

  /// 从YAML配置创建IconfontConfig
  factory IconfontConfig.fromYaml(dynamic yaml) {
    final yamlMap = yaml as YamlMap;
    final iconsYaml = yamlMap['icons'] as YamlList;
    
    final icons = iconsYaml.map((iconYaml) {
      return IconConfig.fromYaml(iconYaml as YamlMap);
    }).toList();
    
    return IconfontConfig(icons: icons);
  }
}

/// 图标信息类
class IconInfo {
  /// 图标名称
  final String name;
  
  /// 图标Unicode
  final String unicode;

  IconInfo({required this.name, required this.unicode});
}