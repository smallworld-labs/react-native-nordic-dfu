#import "RNNordicDfu.h"
#import "RNNordicDfuSession.h"

#import <RNNordicDfuSpec/RNNordicDfuSpec.h>

static CBCentralManager * (^getCentralManager)(void);
static void (^onDFUComplete)(void);
static void (^onDFUError)(void);

static NSString * const DFUProgressEvent = @"DFUProgress";
static NSString * const DFUStateChangedEvent = @"DFUStateChanged";

@interface RNNordicDfu () <NativeRNNordicDfuSpec, RNNordicDfuSessionDelegate>

@property (strong, nonatomic) NSString * deviceAddress;
@property (copy, nonatomic) RCTPromiseResolveBlock resolve;
@property (copy, nonatomic) RCTPromiseRejectBlock reject;
@property (strong, nonatomic) RNNordicDfuSession * session;

@end

@implementation RNNordicDfu

// Registered through `codegenConfig.ios.modulesProvider` in package.json rather
// than RCT_EXPORT_MODULE's +load registration, which belongs to the legacy
// module system.
+ (NSString *)moduleName
{
  return @"RNNordicDfu";
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeRNNordicDfuSpecJSI>(params);
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[DFUProgressEvent,
           DFUStateChangedEvent,];
}

#pragma mark - NativeRNNordicDfuSpec

- (void)startDFU:(NSString *)deviceAddress
      deviceName:(NSString *)deviceName
        filePath:(NSString *)filePath
packetReceiptNotificationParameter:(double)packetReceiptNotificationParameter
         options:(JS::NativeRNNordicDfu::DfuOptions &)options
         resolve:(RCTPromiseResolveBlock)resolve
          reject:(RCTPromiseRejectBlock)reject
{
  // Defaults to YES, like index.js and NordicDFU itself.
  BOOL alternativeAdvertisingNameEnabled = options.alternativeAdvertisingNameEnabled().value_or(true);

  self.deviceAddress = deviceAddress;
  self.resolve = resolve;
  self.reject = reject;

  if (!getCentralManager) {
    reject(@"nil_central_manager_getter", @"Attempted to start DFU without central manager getter", nil);
    return;
  }

  CBCentralManager * centralManager = getCentralManager();

  if (!centralManager) {
    reject(@"nil_central_manager", @"Call to getCentralManager returned nil", nil);
    return;
  }
  if (!deviceAddress) {
    reject(@"nil_device_address", @"Attempted to start DFU with nil deviceAddress", nil);
    return;
  }
  if (!filePath) {
    reject(@"nil_file_path", @"Attempted to start DFU with nil filePath", nil);
    return;
  }

  NSUUID * uuid = [[NSUUID alloc] initWithUUIDString:deviceAddress];

  if (!uuid) {
    reject(@"unable_to_find_device", @"deviceAddress is not a peripheral UUID", nil);
    return;
  }

  // Change for iOS 13
  [NSThread sleepForTimeInterval: 1]; //Work around for not finding the peripheral in iOS 13
  // End change for iOS 13

  NSArray<CBPeripheral *> * peripherals = [centralManager retrievePeripheralsWithIdentifiers:@[uuid]];

  if ([peripherals count] != 1) {
    reject(@"unable_to_find_device", @"Could not find device with deviceAddress", nil);
    return;
  }

  RNNordicDfuSession * session = [RNNordicDfuSession new];
  session.delegate = self;
  self.session = session;

  NSError * error = nil;
  BOOL started = NO;

  @try {
    started = [session startWithCentralManager:centralManager
                                    peripheral:[peripherals objectAtIndex:0]
                                      filePath:filePath
             alternativeAdvertisingNameEnabled:alternativeAdvertisingNameEnabled
                                         error:&error];
  } @catch (NSException * exception) {
    NSLog(@"Error starting DFU: %@", exception.reason);
    error = [NSError errorWithDomain:@"RNNordicDfu"
                                code:0
                            userInfo:@{NSLocalizedDescriptionKey: exception.reason ?: @"Unknown error"}];
  }

  if (!started) {
    // The promise used to be left pending forever here.
    self.session = nil;
    reject(@"unable_to_start_dfu", error.localizedDescription ?: @"Could not start the DFU", error);
  }
}

#pragma mark - RNNordicDfuSessionDelegate

- (void)dfuSessionDidChangeState:(NSString *)state completed:(BOOL)completed
{
  [self sendEventWithName:DFUStateChangedEvent
                     body:@{@"deviceAddress": self.deviceAddress,
                            @"state": state,}];

  if (completed) {
    if (onDFUComplete) {
      onDFUComplete();
    }
    if (self.resolve) {
      self.resolve(@{@"deviceAddress": self.deviceAddress,});
    }
  }
}

- (void)dfuSessionDidFailWithCode:(NSString *)code message:(NSString *)message
{
  if (onDFUError) {
    onDFUError();
  }

  [self sendEventWithName:DFUStateChangedEvent
                     body:@{@"deviceAddress": self.deviceAddress,
                            @"state": @"DFU_FAILED",}];

  if (self.reject) {
    self.reject(code, message, nil);
  }
}

- (void)dfuSessionDidProgress:(NSDictionary<NSString *, NSNumber *> *)progress
{
  NSMutableDictionary * evtBody = [progress mutableCopy];
  evtBody[@"deviceAddress"] = self.deviceAddress;

  [self sendEventWithName:DFUProgressEvent body:evtBody];
}

#pragma mark - App hooks

+ (void)setCentralManagerGetter:(CBCentralManager * (^)(void))getter
{
  getCentralManager = getter;
}

+ (void)setOnDFUComplete:(void (^)(void))onComplete
{
  onDFUComplete = onComplete;
}

+ (void)setOnDFUError:(void (^)(void))onError
{
  onDFUError = onError;
}

@end
