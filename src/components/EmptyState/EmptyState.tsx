import React from 'react';
import {Text, View} from 'react-native';
import {styles} from './styles';

export const EmptyState = () => (
  <View style={styles.container}>
    <Text style={styles.title}>No todos yet</Text>
    <Text style={styles.subtitle}>
      Tap the + button to add your first task.
    </Text>
  </View>
);
