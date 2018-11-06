#import "FlutterNearbyMessagesPlugin.h"
#import <flutter_nearby_messages/flutter_nearby_messages-Swift.h>

@implementation FlutterNearbyMessagesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [SwiftFlutterNearbyMessagesPlugin registerWithRegistrar:registrar];
}
@end
