import type { TurboModule } from "react-native";
import { TurboModuleRegistry } from "react-native";

export type DfuOptions = {
  /** iOS only. */
  alternativeAdvertisingNameEnabled?: boolean;
  /** Android only. */
  retries?: number;
  /** Android only. */
  maxMtu?: number;
};

export type DfuResult = {
  deviceAddress: string;
};

export interface Spec extends TurboModule {
  startDFU(
    deviceAddress: string,
    deviceName: string | null,
    filePath: string,
    packetReceiptNotificationParameter: number,
    options: DfuOptions
  ): Promise<DfuResult>;

  // Required by NativeEventEmitter ("DFUProgress" and "DFUStateChanged").
  addListener(eventName: string): void;
  removeListeners(count: number): void;
}

export default TurboModuleRegistry.get<Spec>("RNNordicDfu");
