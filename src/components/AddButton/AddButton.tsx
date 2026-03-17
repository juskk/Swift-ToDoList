import React from 'react';
import {NativeModules, Text, TouchableOpacity} from 'react-native';
import {styles} from './styles';

const {TodosNativeModule} = NativeModules;

interface Props {
  onPress?: () => void;
}

export const AddButton = ({onPress}: Props) => {
  const handlePress = () => {
    if (onPress) {
      onPress();
    } else {
      TodosNativeModule?.openNewItem();
    }
  };

  return (
    <TouchableOpacity
      style={styles.fab}
      onPress={handlePress}
      activeOpacity={0.85}
      accessibilityRole="button"
      accessibilityLabel="Add new todo">
      <Text style={styles.fabIcon}>+</Text>
    </TouchableOpacity>
  );
};
