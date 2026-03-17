import {AppRegistry} from 'react-native';
import {TodosScreen} from './src/screens/TodosScreen';

// Register with the same module name Swift uses in RCTRootView(moduleName:)
AppRegistry.registerComponent('TodosScreen', () => TodosScreen);
