export interface TodoItem {
  id: string;
  title: string;
  dueDate: number;     // Unix timestamp (seconds) — matches Swift TimeInterval
  createdDate: number; // Unix timestamp (seconds)
  isDone: boolean;
}
