# Flutter Iconfont

一个Flutter包，用于从iconfont.cn生成图标字体类。

## 功能

- 从iconfont.cn下载图标字体文件
- 生成Flutter图标类
- 支持多个图标字体
- 自定义图标类名

## 安装

```yaml
flutter pub add flutter_iconfont --dev 
```

## 使用方法

### 1. 创建配置文件

在项目根目录创建`iconfont.yaml`文件：

```yaml
icons:
  # 图标字体1
  - url: //at.alicdn.com/t/font_xxx.css # url
    font_assets_path: assets/iconfont   # 字体文件保存路径
    icon_name: icon1 # 图标类名
  # 图标字体2
  - url: //at.alicdn.com/t/font_xxx.css # url
    font_assets_path: assets/iconfont   # 字体文件保存路径
    icon_name: icon2 # 图标类名
```

### 2. 运行命令

```bash
flutter pub run flutter_iconfont
```

或者全局安装后运行：

```bash
dart pub global activate flutter_iconfont
flutter_iconfont
```

### 3. 使用生成的图标

```dart
import 'package:your_project/iconfont/icon1.dart';
import 'package:your_project/iconfont/icon2.dart';

// 在Widget中使用
Icon(icon1.checkcircle)
Icon(icon2.sun)
```

## 配置选项

- `url`: iconfont.cn生成的CSS文件URL
- `font_assets_path`: 字体文件保存路径
- `icon_name`: 生成的图标类名和字体family名称

## 命令行选项

```
Usage: flutter_iconfont [options]
-c, --config    Path to the iconfont configuration file
                 (defaults to "iconfont.yaml")
-h, --help      Print this usage information
```

### 获取url的方式

![image.png](./images/image1.png)

## 许可证

MIT