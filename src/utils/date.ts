/**
 * Format a Unix timestamp (seconds) to a readable date string.
 * e.g. "Mar 18, 2026"
 */
export function formatDueDate(timestamp: number): string {
  return new Date(timestamp * 1000).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}
