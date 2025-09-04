#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_iconfont/flutter_iconfont.dart';
import 'package:flutter_iconfont/src/iconfont_generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('config', 
      abbr: 'c', 
      defaultsTo: 'iconfont.yaml',
      help: 'Path to the iconfont configuration file')
    ..addFlag('help', 
      abbr: 'h', 
      negatable: false, 
      help: 'Print this usage information');

  try {
    final results = parser.parse(arguments);

    if (results['help']) {
      _printUsage(parser);
      exit(0);
    }

    final configPath = results['config'];
    final generator = IconfontGenerator(configPath: configPath);
    await generator.run();
  } catch (e) {
    print('Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Usage: flutter_iconfont [options]');
  print(parser.usage);
  print('\nExample:');
  print('  flutter_iconfont -c path/to/iconfont.yaml');
}