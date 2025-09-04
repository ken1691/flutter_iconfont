import 'package:flutter/material.dart';
import 'package:flutter_iconfont_example/iconfont/icon2.dart';

// 直接使用IconData创建图标，不依赖于生成的图标文件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Iconfont Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Iconfont Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Iconfont图标示例:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // icon1 图标
                Column(
                  children: [
                    Text('icon1:'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(IconData(0xe900, fontFamily: 'icon1'), size: 30, color: Colors.green),
                        SizedBox(width: 20),
                        Icon(IconData(0xe7d5, fontFamily: 'icon1'), size: 30, color: Colors.red),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 50),
                // icon2 图标
                Column(
                  children: [
                    Text('icon2:'),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(IconData(0xe900, fontFamily: 'icon2'), size: 30, color: Colors.orange),
                        SizedBox(width: 20),
                        Icon(icon2.anniu, size: 30, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}