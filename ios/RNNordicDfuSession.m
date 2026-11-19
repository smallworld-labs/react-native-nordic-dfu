#import "RNNordicDfuSession.h"

@import NordicDFU;

static NSString * const RNNordicDfuErrorDomain = @"RNNordicDfu";

@interface RNNordicDfuSession () <DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>
// The initiator holds its delegates weakly and the library keeps the DFU alive
// only through the controller, so retain it for the lifetime of the session.
@property (nonatomic, strong, nullable) DFUServiceController * controller;
@end

@implementation RNNordicDfuSession

- (NSString *)stateDescription:(enum DFUState)state
{
  switch (state)
  {
    case DFUStateAborted:
      return @"DFU_ABORTED";
    case DFUStateStarting:
      return @"DFU_PROCESS_STARTING";
    case DFUStateCompleted:
      return @"DFU_COMPLETED";
    case DFUStateUploading:
      return @"DFU_STATE_UPLOADING";
    case DFUStateConnecting:
      return @"CONNECTING";
    case DFUStateConnected:
      return @"DEVICE_CONNECTED";
    case DFUStateDisconnected:
      return @"DEVICE_DISCONNECTED";
    case DFUStateValidating:
      return @"FIRMWARE_VALIDATING";
    case DFUStateDisconnecting:
      return @"DEVICE_DISCONNECTING";
    case DFUStateEnablingDfuMode:
      return @"ENABLING_DFU_MODE";
    default:
      return @"UNKNOWN_STATE";
  }
}

- (NSString *)errorDescription:(enum DFUError)error
{
  switch(error)
  {
    case DFUErrorCrcError:
      return @"DFUErrorCrcError";
    case DFUErrorBytesLost:
      return @"DFUErrorBytesLost";
    case DFUErrorFileInvalid:
      return @"DFUErrorFileInvalid";
    case DFUErrorFailedToConnect:
      return @"DFUErrorFailedToConnect";
    case DFUErrorFileNotSpecified:
      return @"DFUErrorFileNotSpecified";
    case DFUErrorBluetoothDisabled:
      return @"DFUErrorBluetoothDisabled";
    case DFUErrorDeviceDisconnected:
      return @"DFUErrorDeviceDisconnected";
    case DFUErrorDeviceNotSupported:
      return @"DFUErrorDeviceNotSupported";
    case DFUErrorInitPacketRequired:
      return @"DFUErrorInitPacketRequired";
    case DFUErrorUnsupportedResponse:
      return @"DFUErrorUnsupportedResponse";
    case DFUErrorReadingVersionFailed:
      return @"DFUErrorReadingVersionFailed";
    case DFUErrorRemoteLegacyDFUSuccess:
      return @"DFUErrorRemoteLegacyDFUSuccess";
    case DFUErrorRemoteSecureDFUSuccess:
      return @"DFUErrorRemoteSecureDFUSuccess";
    case DFUErrorServiceDiscoveryFailed:
      return @"DFUErrorServiceDiscoveryFailed";
    case DFUErrorRemoteLegacyDFUCrcError:
      return @"DFUErrorRemoteLegacyDFUCrcError";
    case DFUErrorEnablingControlPointFailed:
      return @"DFUErrorEnablingControlPointFailed";
    case DFUErrorExtendedInitPacketRequired:
      return @"DFUErrorExtendedInitPacketRequired";
    case DFUErrorReceivingNotificationFailed:
      return @"DFUErrorReceivingNotificationFailed";
    case DFUErrorRemoteButtonlessDFUSuccess:
      return @"DFUErrorRemoteButtonlessDFUSuccess";
    case DFUErrorRemoteLegacyDFUInvalidState:
      return @"DFUErrorRemoteLegacyDFUInvalidState";
    case DFUErrorRemoteLegacyDFUNotSupported:
      return @"DFUErrorRemoteLegacyDFUNotSupported";
    case DFUErrorWritingCharacteristicFailed:
      return @"DFUErrorWritingCharacteristicFailed";
    case DFUErrorRemoteSecureDFUExtendedError:
      return @"DFUErrorRemoteSecureDFUExtendedError";
    case DFUErrorRemoteSecureDFUInvalidObject:
      return @"DFUErrorRemoteSecureDFUInvalidObject";
    case DFUErrorRemoteLegacyDFUOperationFailed:
      return @"DFUErrorRemoteLegacyDFUOperationFailed";
    case DFUErrorRemoteSecureDFUOperationFailed:
      return @"DFUErrorRemoteSecureDFUOperationFailed";
    case DFUErrorRemoteSecureDFUUnsupportedType:
      return @"DFUErrorRemoteSecureDFUUnsupportedType";
    case DFUErrorRemoteLegacyDFUDataExceedsLimit:
      return @"DFUErrorRemoteLegacyDFUDataExceedsLimit";
    case DFUErrorRemoteSecureDFUInvalidParameter:
      return @"DFUErrorRemoteSecureDFUInvalidParameter";
    case DFUErrorRemoteSecureDFUSignatureMismatch:
      return @"DFUErrorRemoteSecureDFUSignatureMismatch";
    case DFUErrorRemoteSecureDFUOpCodeNotSupported:
      return @"DFUErrorRemoteSecureDFUOpCodeNotSupported";
    case DFUErrorRemoteButtonlessDFUOperationFailed:
      return @"DFUErrorRemoteButtonlessDFUOperationFailed";
    case DFUErrorRemoteSecureDFUInsufficientResources:
      return @"DFUErrorRemoteSecureDFUInsufficientResources";
    case DFUErrorRemoteSecureDFUOperationNotPermitted:
      return @"DFUErrorRemoteSecureDFUOperationNotPermitted";
    case DFUErrorRemoteButtonlessDFUOpCodeNotSupported:
      return @"DFUErrorRemoteButtonlessDFUOpCodeNotSupported";
    case DFUErrorRemoteExperimentalButtonlessDFUSuccess:
      return @"DFUErrorRemoteExperimentalButtonlessDFUSuccess";
    case DFUErrorRemoteExperimentalButtonlessDFUOperationFailed:
      return @"DFUErrorRemoteExperimentalButtonlessDFUOperationFailed";
    case DFUErrorRemoteExperimentalButtonlessDFUOpCodeNotSupported:
      return @"DFUErrorRemoteExperimentalButtonlessDFUOpCodeNotSupported";
    case DFUErrorRemoteExtendedErrorWrongCommandFormat:
      return @"DFUErrorRemoteExtendedErrorWrongCommandFormat";
    case DFUErrorRemoteExtendedErrorUnknownCommand:
      return @"DFUErrorRemoteExtendedErrorUnknownCommand";
    case DFUErrorRemoteExtendedErrorInitCommandInvalid:
      return @"DFUErrorRemoteExtendedErrorInitCommandInvalid";
    case DFUErrorRemoteExtendedErrorFwVersionFailure:
      return @"DFUErrorRemoteExtendedErrorFwVersionFailure";
    case DFUErrorRemoteExtendedErrorHwVersionFailure:
      return @"DFUErrorRemoteExtendedErrorHwVersionFailure";
    case DFUErrorRemoteExtendedErrorSdVersionFailure:
      return @"DFUErrorRemoteExtendedErrorSdVersionFailure";
    case DFUErrorRemoteExtendedErrorSignatureMissing:
      return @"DFUErrorRemoteExtendedErrorSignatureMissing";
    case DFUErrorRemoteExtendedErrorWrongHashType:
      return @"DFUErrorRemoteExtendedErrorWrongHashType";
    case DFUErrorRemoteExtendedErrorHashFailed:
      return @"DFUErrorRemoteExtendedErrorHashFailed";
    case DFUErrorRemoteExtendedErrorWrongSignatureType:
      return @"DFUErrorRemoteExtendedErrorWrongSignatureType";
    case DFUErrorRemoteExtendedErrorVerificationFailed:
      return @"DFUErrorRemoteExtendedErrorVerificationFailed";
    case DFUErrorRemoteExtendedErrorInsufficientSpace:
      return @"DFUErrorRemoteExtendedErrorInsufficientSpace";
    case DFUErrorRemoteButtonlessDFUInvalidAdvertisementName:
      return @"DFUErrorRemoteButtonlessDFUInvalidAdvertisementName";
    case DFUErrorRemoteButtonlessDFUBusy:
      return @"DFUErrorRemoteButtonlessDFUBusy";
    case DFUErrorRemoteButtonlessDFUNotBonded:
      return @"DFUErrorRemoteButtonlessDFUNotBonded";
    case DFUErrorInvalidAdvertisementName:
      return @"DFUErrorInvalidAdvertisementName";
    case DFUErrorInvalidInternalState:
      return @"DFUErrorInvalidInternalState";
    default:
      return @"UNKNOWN_ERROR";
  }
}

- (BOOL)startWithCentralManager:(CBCentralManager *)centralManager
                     peripheral:(CBPeripheral *)peripheral
                       filePath:(NSString *)filePath
alternativeAdvertisingNameEnabled:(BOOL)alternativeAdvertisingNameEnabled
                          error:(NSError **)error
{
  NSURL * url = [NSURL URLWithString:filePath];
  NSString * extension = [url pathExtension];
  NSError * firmwareError = nil;
  DFUFirmware * firmware;

  if (([extension caseInsensitiveCompare:@"bin"] == NSOrderedSame) ||
      ([extension caseInsensitiveCompare:@"hex"] == NSOrderedSame)) {
    firmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:url
                                                 urlToDatFile:nil
                                                         type:DFUFirmwareTypeApplication
                                                        error:&firmwareError];
  } else {
    firmware = [[DFUFirmware alloc] initWithUrlToZipFile:url error:&firmwareError];
  }

  if (!firmware) {
    if (error) {
      *error = firmwareError ?: [NSError errorWithDomain:RNNordicDfuErrorDomain
                                                    code:1
                                                userInfo:@{NSLocalizedDescriptionKey: @"Could not load the firmware file"}];
    }
    return NO;
  }

  // The app owns the central manager (see +[RNNordicDfu setCentralManagerGetter:]),
  // so keep using the initializer that takes one. NordicDFU deprecates it in
  // favour of an initiator that creates its own manager.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  DFUServiceInitiator * initiator = [[[DFUServiceInitiator alloc]
                                      initWithCentralManager:centralManager
                                      target:peripheral]
                                     withFirmware:firmware];
#pragma clang diagnostic pop

  initiator.logger = self;
  initiator.delegate = self;
  initiator.progressDelegate = self;
  initiator.alternativeAdvertisingNameEnabled = alternativeAdvertisingNameEnabled;

  // Change for iOS 13
  initiator.packetReceiptNotificationParameter = 1; //Rate limit the DFU using PRN.
  [NSThread sleepForTimeInterval: 2]; //Work around for being stuck in iOS 13
  // End change for iOS 13

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  self.controller = [initiator start];
#pragma clang diagnostic pop

  if (!self.controller) {
    if (error) {
      *error = [NSError errorWithDomain:RNNordicDfuErrorDomain
                                   code:2
                               userInfo:@{NSLocalizedDescriptionKey: @"Could not start the DFU"}];
    }
    return NO;
  }
  return YES;
}

#pragma mark - DFUServiceDelegate

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
  [self.delegate dfuSessionDidChangeState:[self stateDescription:state]
                                completed:state == DFUStateCompleted];
}

- (void)   dfuError:(enum DFUError)error
didOccurWithMessage:(NSString * _Nonnull)message
{
  [self.delegate dfuSessionDidFailWithCode:[self errorDescription:error] message:message];
}

#pragma mark - DFUProgressDelegate

- (void)dfuProgressDidChangeFor:(NSInteger)part
                          outOf:(NSInteger)totalParts
                             to:(NSInteger)progress
     currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
         avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
  [self.delegate dfuSessionDidProgress:@{@"currentPart": @(part),
                                         @"partsTotal": @(totalParts),
                                         @"percent": @(progress),
                                         @"speed": @(currentSpeedBytesPerSecond),
                                         @"avgSpeed": @(avgSpeedBytesPerSecond),}];
}

#pragma mark - LoggerDelegate

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
  NSLog(@"logWith: %ld message: '%@'", (long)level, message);
}

@end
