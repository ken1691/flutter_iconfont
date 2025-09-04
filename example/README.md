# Flutter Iconfont 示例项目

这个示例项目展示了如何使用 flutter_iconfont 包来生成和使用图标字体。

## 运行步骤

1. 安装依赖

```bash
flutter pub get
```

2. 生成图标文件

```bash
flutter pub run flutter_iconfont
```

3. 运行示例应用

```bash
flutter run
```

## 配置说明

示例项目使用了两个图标字体：

1. `icon1` - 包含基本图标
2. `icon2` - 包含天气图标

配置文件位于 `iconfont.yaml`，内容如下：

```yaml
icons:
  - url: //at.alicdn.com/t/font_3892650_94qckhszrmg.css
    font_assets_path: assets/iconfont
    icon_name: icon1
  - url: //at.alicdn.com/t/font_4878696_10u44l2n1n9f.css
    font_assets_path: assets/iconfont
    icon_name: icon2
```

生成的图标文件位于 `lib/iconfont/` 目录下。