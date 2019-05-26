#import "ReactNativeShareExtension.h"
#import "React/RCTRootView.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define URL_IDENTIFIER @"public.url"
#define IMAGE_IDENTIFIER @"public.image"
#define TEXT_IDENTIFIER (NSString *)kUTTypePlainText

NSExtensionContext* extensionContext;

@implementation ReactNativeShareExtension {
    NSTimer *autoTimer;
    NSString* type;
    NSString* value;
}

- (UIView*) shareView {
    return nil;
}

RCT_EXPORT_MODULE();

- (void)viewDidLoad {
    [super viewDidLoad];

    //object variable for extension doesn't work for react-native. It must be assign to gloabl
    //variable extensionContext. in this way, both exported method can touch extensionContext
    extensionContext = self.extensionContext;

    UIView *rootView = [self shareView];
    if (rootView.backgroundColor == nil) {
        rootView.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.1];
    }

    self.view = rootView;
}


RCT_EXPORT_METHOD(close) {
    [extensionContext completeRequestReturningItems:nil
                                  completionHandler:nil];
}



RCT_EXPORT_METHOD(openURL:(NSString *)url) {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *urlToOpen = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [application openURL:urlToOpen options:@{} completionHandler: nil];
}



RCT_EXPORT_METHOD(data:(NSDictionary*)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self extractDataFromContext: extensionContext withCallback:^(id _Nonnull val, NSString* _Nonnull contentType, NSException * _Nonnull err) {
        if(err) {
            reject(@"error", err.description, nil);
        } else {
            resolve(@{
                      @"type": contentType,
                      @"value": val
                      });
        }
    }];
}

- (void)extractDataFromContext:(NSExtensionContext *_Nullable)context withCallback:(void(^ _Nonnull)(id _Nonnull value, NSString* _Nonnull contentType, NSException * _Nonnull exception))callback {
    @try {
        NSExtensionItem *item = [context.inputItems firstObject];
        NSArray *attachments = item.attachments;
        NSMutableArray *mutableUrls = [[NSMutableArray alloc] init];
        dispatch_group_t group = dispatch_group_create();
        
        // Load images from selection
        [attachments enumerateObjectsUsingBlock:^(NSItemProvider *itemProvider, NSUInteger idx, BOOL *stop) {
            if ([itemProvider hasItemConformingToTypeIdentifier:URL_IDENTIFIER]) {
                dispatch_group_enter(group);
                [itemProvider loadItemForTypeIdentifier:URL_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    NSURL *url = (NSURL *)item;
                    
                    if(error == nil) {
                        [mutableUrls addObject:[url absoluteString]];
                    }
                    dispatch_group_leave(group);
                }];
            } else if ([itemProvider hasItemConformingToTypeIdentifier:IMAGE_IDENTIFIER]) {
                
                dispatch_group_enter(group);
                
                [itemProvider loadItemForTypeIdentifier:IMAGE_IDENTIFIER
                                                options:nil
                                      completionHandler: ^(NSURL *url, NSError *error) {
                                          if(error == nil) {
                                              [mutableUrls addObject:[url absoluteString]];
                                          }
                                          dispatch_group_leave(group);
                                      }];
            } else if ([itemProvider hasItemConformingToTypeIdentifier:TEXT_IDENTIFIER]) {
                dispatch_group_enter(group);
                [itemProvider loadItemForTypeIdentifier:TEXT_IDENTIFIER options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    NSString *text = (NSString *)item;
                    
                    if(error == nil) {
                        [mutableUrls addObject:text];
                    }
                    dispatch_group_leave(group);
                }];
            } else {
                dispatch_group_leave(group);
                if(callback) {
                    callback(nil, nil, [NSException exceptionWithName:@"Error" reason:@"couldn't find provider" userInfo:nil]);
                }
            }
        }];
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if(callback) {
                callback(mutableUrls, IMAGE_IDENTIFIER, nil);
            }
        });
    }
    @catch (NSException *exception) {
        if(callback) {
            callback(nil, nil, exception);
        }
    }
}

@end
