// Utility functions for consistent timezone handling

export const TIMEZONE = "Asia/Manila" // UTC+8

export function formatTimestamp(date: Date | number | string): string {
  const dateObj = new Date(date)
  return dateObj.toLocaleString("en-US", {
    timeZone: TIMEZONE,
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
    second: "2-digit",
    hour12: true,
  })
}

export function getCurrentTimestamp(): string {
  return formatTimestamp(new Date())
}

export function getCurrentTimestampMs(): number {
  return Date.now()
}

// For Arduino compatibility - returns timestamp in milliseconds
export function getArduinoTimestamp(): number {
  return Date.now()
}

// Convert Arduino timestamp to local display format
export function formatArduinoTimestamp(timestamp: number): string {
  return formatTimestamp(timestamp)
}
