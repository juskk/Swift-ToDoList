import React, {useEffect, useState} from 'react';
import {ActivityIndicator, FlatList, View} from 'react-native';
import {
  collection,
  doc,
  onSnapshot,
  orderBy,
  query,
  updateDoc,
} from 'firebase/firestore';

import {db} from '../../config/firebase';
import {TodoItem as TodoItemType} from '../../types/todo';
import {Colors} from '../../constants/colors';
import {AddButton, EmptyState, TodoItem} from '../../components';
import {styles} from './styles';

interface Props {
  userId?: string;
}

export const TodosScreen = ({userId}: Props) => {
  const [todos, setTodos] = useState<TodoItemType[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!userId) {
      setLoading(false);
      return;
    }

    const q = query(
      collection(db, `users/${userId}/todos`),
      orderBy('createdDate', 'desc'),
    );

    const unsubscribe = onSnapshot(
      q,
      snapshot => {
        const items = snapshot.docs.map(d => ({
          id: d.id,
          ...d.data(),
        })) as TodoItemType[];
        setTodos(items);
        setLoading(false);
      },
      _error => {
        setLoading(false);
      },
    );

    return unsubscribe;
  }, [userId]);

  const handleToggle = async (id: string) => {
    if (!userId) return;
    const current = todos.find(t => t.id === id);
    if (!current) return;
    setTodos(prev =>
      prev.map(t => (t.id === id ? {...t, isDone: !t.isDone} : t)),
    );
    try {
      await updateDoc(doc(db, `users/${userId}/todos/${id}`), {
        isDone: !current.isDone,
      });
    } catch {
      setTodos(prev =>
        prev.map(t => (t.id === id ? {...t, isDone: current.isDone} : t)),
      );
    }
  };

  if (loading) {
    return (
      <View style={styles.center}>
        <ActivityIndicator size="large" color={Colors.primary} />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={todos}
        keyExtractor={item => item.id}
        renderItem={({item}) => (
          <TodoItem item={item} onToggle={handleToggle} />
        )}
        contentContainerStyle={styles.listContent}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
        ListEmptyComponent={<EmptyState />}
      />

      <AddButton />
    </View>
  );
};
