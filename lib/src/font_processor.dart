import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import 'models/icon_config.dart';
import 'models/iconfont_config.dart';

/// 字体处理器，负责下载和处理字体文件
class FontProcessor {
  /// 图标配置
  final IconConfig config;
  
  /// 字体名称
  late String fontFamily;
  
  /// 图标列表
  List<IconInfo> icons = [];

  FontProcessor(this.config);

  /// 处理字体
  Future<void> process() async {
    // 使用icon_name作为字体family名称
    if (config.className.isNotEmpty) {
      // 如果className已设置（来自icon_name），则使用它作为fontFamily
      fontFamily = config.className;
    } else {
      // 从URL中提取字体family名称作为后备选项
      final url = config.url;
      final regex = RegExp(r'font_([^.]+)');
      final match = regex.firstMatch(url);
      if (match != null) {
        fontFamily = 'iconfont_${match.group(1)}';
        config.className = 'iconfont_${match.group(1)}';
      } else {
        // 如果无法提取，使用完整的文件名
        final urlParts = url.split('/');
        final cssFileName = urlParts.last.split('.').first;
        fontFamily = 'iconfont_$cssFileName';
        config.className = 'iconfont_$cssFileName';
      }
    }
    
    print('   字体名称: $fontFamily');
    
    // 1. 下载并解析CSS文件
    await _downloadAndParseCss();
    
    // 2. 下载字体文件
    await _downloadFontFile();
    
    // 3. 更新pubspec.yaml
    await _updatePubspecYaml();
    
    // 4. 生成iconfont.dart文件
    await _generateIconfontDart();
  }

  /// 下载并解析CSS文件
  Future<void> _downloadAndParseCss() async {
    print('🌐 下载CSS文件...');
    
    // 检查URL是否为占位符
    if (config.url.contains('your-project-url')) {
      throw Exception('请替换配置文件中的占位符URL为您在iconfont.cn上的真实项目URL。\n当前URL: ${config.url}');
    }
    
    // 正常下载CSS文件
    final cssUrl = config.url.startsWith('//') ? 'https:${config.url}' : config.url;
    
    try {
      final response = await http.get(Uri.parse(cssUrl));
      if (response.statusCode != 200) {
        throw Exception('下载CSS文件失败: ${response.statusCode}');
      }
      
      final cssContent = response.body;
      print('   CSS文件下载完成');
      
      // 解析CSS内容
      _parseCssContent(cssContent);
    } catch (e) {
      throw Exception('下载CSS文件失败: $e');
    }
  }

  /// 解析CSS内容
  void _parseCssContent(String cssContent) {
    print('🔍 解析CSS内容...');
    
    // 提取图标信息
    final iconRegex = RegExp(r'\.icon-([^:]+):before\s*\{\s*content:\s*"\\([^"]+)"');
    final matches = iconRegex.allMatches(cssContent);
    
    // 解析CSS
    icons.clear();
    for (final match in matches) {
      final iconName = match.group(1)!;
      final unicode = match.group(2)!;
      icons.add(IconInfo(name: iconName, unicode: unicode));
    }
    
    print('   解析完成，找到 ${icons.length} 个图标');
    print('   字体family: $fontFamily');
  }

  /// 下载字体文件
  Future<void> _downloadFontFile() async {
    print('📥 下载字体文件...');
    
    // 检查URL是否为占位符
    if (config.url.contains('your-project-url')) {
      throw Exception('请替换配置文件中的占位符URL为您在iconfont.cn上的真实项目URL。\n当前URL: ${config.url}');
    }
    
    // 从CSS URL构造TTF文件URL
    final baseUrl = config.url.replaceAll('.css', '.ttf');
    final ttfUrl = baseUrl.startsWith('//') ? 'https:$baseUrl' : baseUrl;
    
    final response = await http.get(Uri.parse(ttfUrl));
    if (response.statusCode != 200) {
      throw Exception('下载TTF文件失败: ${response.statusCode}');
    }
    
    // 智能选择字体文件保存路径
    final currentDir = Directory.current;
    String actualFontAssetsPath;
    
    if (currentDir.path.endsWith('example')) {
      // 如果在example目录下运行，使用配置的路径
      actualFontAssetsPath = config.fontAssetsPath;
    } else {
      // 如果在用户项目中运行，优先使用当前目录的assets路径
      actualFontAssetsPath = config.fontAssetsPath;
      
      // 检查当前目录是否有assets目录的权限
      final currentAssetsDir = Directory(actualFontAssetsPath);
      try {
        if (!await currentAssetsDir.exists()) {
          await currentAssetsDir.create(recursive: true);
        }
      } catch (e) {
        // 如果无法在当前目录创建，尝试example目录
        actualFontAssetsPath = 'example/${config.fontAssetsPath}';
      }
    }
    
    // 确保目录存在
    final fontDir = Directory(actualFontAssetsPath);
    if (!await fontDir.exists()) {
      await fontDir.create(recursive: true);
    }
    
    // 保存字体文件
    final fileName = '${config.className}.ttf';
    final fontPath = actualFontAssetsPath.endsWith('/') 
        ? '${actualFontAssetsPath}$fileName'
        : '${actualFontAssetsPath}/$fileName';
    final fontFile = File(fontPath);
    await fontFile.writeAsBytes(response.bodyBytes);
    
    print('   字体文件保存到: ${fontFile.path}');
  }

  /// 更新pubspec.yaml
  Future<void> _updatePubspecYaml() async {
    print('📝 更新pubspec.yaml...');
    
    // 检测当前工作目录
    final currentDir = Directory.current;
    print('   当前工作目录: ${currentDir.path}');
    
    // 智能检测pubspec.yaml文件位置
    File? pubspecFile;
    String pubspecPath;
    
    // 始终优先查找当前目录的pubspec.yaml
    pubspecPath = 'pubspec.yaml';
    pubspecFile = File(pubspecPath);
    
    // 只有在开发环境（当前目录是flutter_iconfont包目录）时，才尝试example目录
    if (!await pubspecFile.exists()) {
      // 检查是否在flutter_iconfont包的开发环境中
      // 通过检查当前目录是否包含特定的包文件来判断
      final binDir = Directory('bin');
      final libDir = Directory('lib');
      final exampleDir = Directory('example');
      
      if (await binDir.exists() && await libDir.exists() && await exampleDir.exists()) {
        // 很可能在包开发环境中，尝试example目录
        pubspecPath = 'example/pubspec.yaml';
        pubspecFile = File(pubspecPath);
      }
    }
    
    if (!await pubspecFile.exists()) {
      throw Exception('未找到pubspec.yaml文件: ${pubspecFile.path}');
    }
    
    print('   使用pubspec.yaml文件: ${pubspecFile.path}');
    
    final content = await pubspecFile.readAsString();
    final yamlDoc = loadYaml(content);
    final Map yamlMap = yamlDoc as Map;
    
    // 查找flutter配置部分
    if (!yamlMap.containsKey('flutter')) {
      throw Exception('pubspec.yaml中未找到flutter配置');
    }
    
    // 构建字体资源路径
    final assetPath = config.fontAssetsPath.endsWith('/') 
        ? '${config.fontAssetsPath}${config.className}.ttf'
        : '${config.fontAssetsPath}/${config.className}.ttf';
    
    // 读取现有的fonts配置
    final Map newYaml = Map.from(yamlMap);
    final Map flutterConfig = Map.from(yamlMap['flutter'] ?? {});
    
    // 获取现有的fonts配置或创建新的
    List fontsList = [];
    if (flutterConfig.containsKey('fonts')) {
      fontsList = List.from(flutterConfig['fonts'] as List);
    }
    
    // 使用fontFamily作为字体family名称，确保与生成的字体文件名一致
    final String familyName = fontFamily;
    
    // 检查是否已存在相同family的字体
    bool fontExists = false;
    for (int i = 0; i < fontsList.length; i++) {
      final font = fontsList[i];
      if (font['family'] == familyName) {
        // 更新现有字体
        fontsList[i] = {
          'family': familyName,
          'fonts': [{'asset': assetPath}]
        };
        fontExists = true;
        break;
      }
    }
    
    // 如果不存在，添加新字体
    if (!fontExists) {
      fontsList.add({
        'family': familyName,
        'fonts': [{'asset': assetPath}]
      });
    }
    
    // 更新flutter配置
    flutterConfig['fonts'] = fontsList;
    newYaml['flutter'] = flutterConfig;
    
    // 将更新后的配置写回pubspec.yaml
    final lines = content.split('\n');
    int flutterIndex = -1;
    int fontsIndex = -1;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim() == 'flutter:') {
        flutterIndex = i;
      }
      if (lines[i].trim().startsWith('fonts:')) {
        fontsIndex = i;
        break;
      }
    }
    
    final fontConfig = '''
  fonts:${_generateFontsYaml(fontsList)}''';
    
    if (fontsIndex != -1) {
      // 替换现有的fonts配置
      int endIndex = fontsIndex + 1;
      while (endIndex < lines.length && 
             (lines[endIndex].startsWith('    ') || lines[endIndex].trim().isEmpty)) {
        endIndex++;
      }
      lines.removeRange(fontsIndex, endIndex);
      lines.insert(fontsIndex, fontConfig);
    } else {
      // 添加新的fonts配置
      lines.insert(flutterIndex + 1, fontConfig);
    }
    
    await pubspecFile.writeAsString(lines.join('\n'));
    print('   pubspec.yaml更新完成');
  }
  
  /// 生成fonts YAML配置
  String _generateFontsYaml(List fontsList) {
    final buffer = StringBuffer();
    
    for (final font in fontsList) {
      buffer.write('\n    - family: ${font['family']}');
      buffer.write('\n      fonts:');
      
      final fonts = font['fonts'] as List;
      for (final fontAsset in fonts) {
        buffer.write('\n        - asset: ${fontAsset['asset']}');
      }
    }
    
    return buffer.toString();
  }

  /// 生成iconfont.dart文件
  Future<void> _generateIconfontDart() async {
    print('🎨 生成iconfont.dart文件...');
    
    final libIconfontDir = Directory('lib/iconfont');
    if (!await libIconfontDir.exists()) {
      await libIconfontDir.create(recursive: true);
    }
    
    // 使用类名作为文件名
    final fileName = '${config.className}.dart';
    
    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln();
    buffer.writeln('// ignore_for_file: constant_identifier_names');
    buffer.writeln('/// ${config.className} icon font');
    buffer.writeln('///');
    buffer.writeln('/// to use these icons, import the font file:');
    buffer.writeln('/// ```dart');
    buffer.writeln("/// import 'package:your_project/iconfont/${config.className}.dart';");
    buffer.writeln('/// ```');
    buffer.writeln('///');
    buffer.writeln('/// then use in your widgets:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// Icon(${config.className}.iconName)');
    buffer.writeln('/// ```');
    buffer.writeln('class ${config.className} {');
    
    // 用于跟踪已使用的图标名称
    final usedNames = <String>{};
    
    for (final icon in icons) {
      var iconName = _toCamelCase(icon.name);
      
      // 处理重复的图标名称
      var counter = 1;
      var originalName = iconName;
      while (usedNames.contains(iconName)) {
        iconName = '${originalName}${counter++}';
      }
      
      // 记录已使用的名称
      usedNames.add(iconName);
      
      buffer.writeln('  static const $iconName = IconData(');
      buffer.writeln('    0x${icon.unicode},');
      buffer.writeln("    fontFamily: '${config.className}',");
      buffer.writeln('    matchTextDirection: true,');
      buffer.writeln('  );');
      if (icon != icons.last) buffer.writeln();
    }
    
    buffer.writeln('}');
    
    // 使用前面定义的fileName变量
    final dartFile = File('lib/iconfont/$fileName');
    await dartFile.writeAsString(buffer.toString());
    
    print('   ${fileName}文件生成完成');
    print('   包含 ${icons.length} 个图标');
  }

  /// 将字符串转换为驼峰命名
  String _toCamelCase(String input) {
    // 处理以数字开头的标识符，添加前缀
    final result = input.split('-').map((word) {
      if (word.isEmpty) return word;
      return word[0].toLowerCase() + word.substring(1);
    }).join('');
    
    // 如果以数字开头，添加'icon'前缀
    if (result.isNotEmpty && RegExp(r'^[0-9]').hasMatch(result)) {
      return 'icon' + result;
    }
    
    return result;
  }
}