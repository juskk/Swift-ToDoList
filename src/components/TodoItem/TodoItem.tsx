import React from 'react';
import {Text, TouchableOpacity, View} from 'react-native';
import {TodoItem as TodoItemType} from '../../types/todo';
import {formatDueDate} from '../../utils/date';
import {styles} from './styles';

interface Props {
  item: TodoItemType;
  onToggle: (id: string) => void;
}

export const TodoItem = ({item, onToggle}: Props) => (
  <TouchableOpacity
    style={styles.row}
    onPress={() => onToggle(item.id)}
    activeOpacity={0.7}>
    <View
      style={[styles.checkbox, item.isDone && styles.checkboxDone]}
      accessibilityRole="checkbox"
      accessibilityState={{checked: item.isDone}}>
      {item.isDone && <Text style={styles.checkmark}>✓</Text>}
    </View>

    <View style={styles.rowText}>
      <Text
        style={[styles.title, item.isDone && styles.titleDone]}
        numberOfLines={2}>
        {item.title}
      </Text>
      <Text style={styles.dueDate}>Due {formatDueDate(item.dueDate)}</Text>
    </View>
  </TouchableOpacity>
);
