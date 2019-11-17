#import "E3kitPlugin.h"
#import <e3kit/e3kit-Swift.h>

@implementation E3kitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftE3kitPlugin registerWithRegistrar:registrar];
}
@end
