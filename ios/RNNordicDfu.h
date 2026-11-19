#import <CoreBluetooth/CoreBluetooth.h>
#import <React/RCTEventEmitter.h>

/**
 * TurboModule `RNNordicDfu`.
 *
 * This header deliberately imports neither the NordicDFU Swift module nor the
 * codegen'd spec, so the app delegate can import it from Objective-C(++)
 * without `use_frameworks!`.
 */
@interface RNNordicDfu : RCTEventEmitter

+ (void)setCentralManagerGetter:(CBCentralManager * (^)(void))getter;
+ (void)setOnDFUComplete:(void (^)(void))onComplete;
+ (void)setOnDFUError:(void (^)(void))onError;

@end
