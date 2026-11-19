#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNNordicDfuSessionDelegate <NSObject>
- (void)dfuSessionDidChangeState:(NSString *)state completed:(BOOL)completed;
- (void)dfuSessionDidFailWithCode:(NSString *)code message:(NSString *)message;
- (void)dfuSessionDidProgress:(NSDictionary<NSString *, NSNumber *> *)progress;
@end

/**
 * Everything that touches the NordicDFU Swift module lives here, in plain
 * Objective-C, so the Objective-C++ TurboModule never has to import it.
 */
@interface RNNordicDfuSession : NSObject

@property (nonatomic, weak, nullable) id<RNNordicDfuSessionDelegate> delegate;

/**
 * Starts the DFU. Returns NO and sets `error` if the firmware file could not be
 * loaded or the DFU could not be started; no delegate call is made in that case.
 */
- (BOOL)startWithCentralManager:(CBCentralManager *)centralManager
                     peripheral:(CBPeripheral *)peripheral
                       filePath:(NSString *)filePath
alternativeAdvertisingNameEnabled:(BOOL)alternativeAdvertisingNameEnabled
                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
