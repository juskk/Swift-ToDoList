//
//  TodosNativeModule.m
//  ToDoList
//
//  Minimal ObjC native module exposing openNewItem() to React Native.
//  Works with both Legacy and New Architecture (interop layer).
//
//  When RN calls TodosNativeModule.openNewItem(), this posts an
//  NSNotification that TodosRNViewController picks up and uses to
//  present the Swift NewItem sheet.
//

#import <React/RCTBridgeModule.h>

@interface TodosNativeModule : NSObject <RCTBridgeModule>
@end

@implementation TodosNativeModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(openNewItem) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"TodosOpenNewItem"
                          object:nil];
    });
}

// Required for New Architecture interop layer
+ (BOOL)requiresMainQueueSetup {
    return NO;
}

@end
