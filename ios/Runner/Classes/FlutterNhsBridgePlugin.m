#import "FlutterNhsBridgePlugin.h"
#if __has_include(<flutter_nhs_bridge/flutter_nhs_bridge-Swift.h>)
#import <flutter_nhs_bridge/flutter_nhs_bridge-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_nhs_bridge-Swift.h"
#endif

@implementation FlutterNhsBridgePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNhsBridgePlugin registerWithRegistrar:registrar];
}
@end
