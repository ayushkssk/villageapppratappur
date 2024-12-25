# iOS Setup Documentation (आईओएस सेटअप डॉक्यूमेंटेशन)

## समस्या
Flutter app को iOS पर build करते समय निम्नलिखित errors आ रहे थे:
1. Unsupported option '-G' for target 'arm64-apple-ios10.0'
2. Could not build the precompiled application for the device
3. File_picker plugin implementation issues

## समाधान
इस समस्या को हल करने के लिए निम्नलिखित steps follow किए गए:

### 1. Podfile Configuration
`ios/Podfile` में निम्नलिखित changes किए गए:

```ruby
# iOS version को update किया
platform :ios, '13.0'

# Post install configuration में compiler flags और deployment target को handle किया
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### 2. Build Steps
निम्नलिखित commands को sequence में execute किया:

1. **Pods को Clean करें**
```bash
cd ios
rm -rf Pods Podfile.lock
```

2. **Pods को Reinstall करें**
```bash
pod install
```

3. **Flutter को Clean करें**
```bash
flutter clean
```

4. **Dependencies को Update करें**
```bash
flutter pub get
```

### 3. महत्वपूर्ण Notes
1. iOS minimum version को 13.0 पर set किया गया है
2. BoringSSL-GRPC target के लिए special handling की गई है
3. Compiler warnings को properly handle किया गया है
4. Runner target की configuration को maintain किया गया है

## Testing
इन changes के बाद app को iOS simulator और physical device पर test किया गया।

### Physical Device Requirements
1. iOS version 13.0 या उससे ऊपर
2. Development profile configured in Xcode
3. Apple Developer account

## Troubleshooting
अगर फिर भी कोई error आए तो:
1. Xcode को clean करें (Xcode > Product > Clean Build Folder)
2. Device को disconnect और reconnect करें
3. Xcode को restart करें
4. सभी steps को फिर से follow करें

## References
1. [Flutter iOS Integration](https://flutter.dev/docs/development/platform-integration/ios)
2. [CocoaPods Documentation](https://guides.cocoapods.org)
3. [BoringSSL Documentation](https://github.com/google/boringssl)
