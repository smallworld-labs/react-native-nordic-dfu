# react-native-nordic-dfu [![npm version](https://badge.fury.io/js/react-native-nordic-dfu.svg)](https://badge.fury.io/js/react-native-nordic-dfu) [![CircleCI](https://circleci.com/gh/Pilloxa/react-native-nordic-dfu.svg?style=svg)](https://circleci.com/gh/Pilloxa/react-native-nordic-dfu) [![Known Vulnerabilities](https://snyk.io/test/github/pilloxa/react-native-nordic-dfu/badge.svg)](https://snyk.io/test/github/pilloxa/react-native-nordic-dfu)

This library allows you to do a Device Firmware Update (DFU) of your nrf51 or
nrf52 chip from Nordic Semiconductor. It works for both iOS and Android.

For more info about the DFU process, see: [Resources](#resources)

### This is a fork from the main library!

- Please keep in mind the our availability to maintain this fork is limited and is based on our project needs.
- If need the main documentation you can find it [here](https://github.com/Pilloxa/react-native-nordic-dfu).
- This fork uses [`NordicDFU`](https://github.com/nordicsemi/IOS-DFU-Library) on iOS (the renamed `iOSDFULibrary` pod) and [`no.nordicsemi.android:dfu`](https://github.com/nordicsemi/Android-DFU-Library) on Android.

### Requirements (4.x)

- React Native 0.77 or newer with the New Architecture enabled. The module is a TurboModule with a codegen spec ([`src/NativeRNNordicDfu.ts`](src/NativeRNNordicDfu.ts)); it no longer goes through the legacy native-module interop layer. Use 3.x on the old architecture.
- iOS: `use_frameworks!` is **not** required any more. The NordicDFU Swift pod is imported as a module, so the package builds as a static library as well as with (static) frameworks.
- Android: the Android Gradle Plugin, compile/target/min SDK and React Native version are taken from the app. The DFU library version can be overridden with `ext.nordicDfuVersion` in the root `build.gradle`.

### Installation

```bash
yarn add https://github.com/smallworldus/react-native-nordic-dfu
```

The package is autolinked on both platforms.

### Project Setup

`AppDelegate.mm`:

```
...
#import "RNNordicDfu.h"
...

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...

  [RNNordicDfu setCentralManagerGetter:^() {
           return [[CBCentralManager alloc] initWithDelegate:nil queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
       }];

         // Reset manager delegate since the Nordic DFU lib "steals" control over it
             [RNNordicDfu setOnDFUComplete:^() {
                 NSLog(@"onDFUComplete");
             }];
             [RNNordicDfu setOnDFUError:^() {
                 NSLog(@"onDFUError");
             }];
  ...

}
```

### New Example

1. `cd newExample`
2. `yarn setup`
3. Go to `newExample/App.tsx`
4. Update the `filePath` variable with the link to the firmware file
5. Update the `BleManagerService.init('', '');` function with the DFU Service & the device name
6. Press `Connect to Device in Area` button
7. When you see some small info about the device on the screen Press the `Start Update`
8. If you have any problems connecting to the Device pleas consult the [react-native-ble-manager](https://github.com/innoveit/react-native-ble-manager)

### Issues

- For configuration issues please also check this (https://github.com/Pilloxa/react-native-nordic-dfu/issues/171)

### Resources

- [DFU Introduction](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/examples_ble_dfu.html?cp=6_0_0_4_3_1 "BLE Bootloader/DFU")
- [Secure DFU Introduction](http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v12.0.0/ble_sdk_app_dfu_bootloader.html?cp=4_0_0_4_3_1 "BLE Secure DFU Bootloader")
- [How to create init packet](https://github.com/NordicSemiconductor/Android-nRF-Connect/tree/master/init%20packet%20handling "Init packet handling")
- [nRF51 Development Kit (DK)](http://www.nordicsemi.com/eng/Products/nRF51-DK "nRF51 DK") (compatible with Arduino Uno Revision 3)
- [nRF52 Development Kit (DK)](http://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF52-DK "nRF52 DK") (compatible with Arduino Uno Revision 3)
