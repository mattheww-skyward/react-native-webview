import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';
import { Double } from 'react-native/Libraries/Types/CodegenTypes';

export interface Spec extends TurboModule {
  supportsProfiles(): Promise<string | null>;
  removeDataStore(profile: string): Promise<boolean>;
  shouldStartLoadWithLockIdentifier(shouldStart: boolean, lockIdentifier: Double): void;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNCWebViewModule');
