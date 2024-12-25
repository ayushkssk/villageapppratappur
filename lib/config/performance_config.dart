import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerformanceConfig {
  static void init() {
    // Enable memory optimization
    ImageCache().maximumSize = 1000;
    ImageCache().maximumSizeBytes = 50 * 1024 * 1024; // 50 MB
    
    // Optimize system channels
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop') {
        // Handle back button press more efficiently
        return true;
      }
      return null;
    });
    
    // Optimize rendering
    WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
    
    // Set preferred orientations for better performance
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  static void disposeResources() {
    ImageCache().clear();
    ImageCache().clearLiveImages();
  }
}
