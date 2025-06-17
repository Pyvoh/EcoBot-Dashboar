// Timestamp utility functions for EcoBot system
// Handles UTC+8 (Asia/Manila) timezone consistently

export const TIMEZONE = "Asia/Manila" // UTC+8

/**
 * Get current timestamp in ISO format with UTC+8 timezone
 * Returns: "2025-06-17T15:30:45+08:00"
 */
export function getFormattedISODate(): string {
  const now = new Date()

  // Convert to UTC+8
  const utc8Time = new Date(now.getTime() + 8 * 60 * 60 * 1000)

  // Format as ISO string with timezone offset
  const isoString = utc8Time.toISOString().replace("Z", "+08:00")

  return isoString
}

/**
 * Get current timestamp in display format for dashboard
 * Returns: "6/17/2025, 3:30:45 PM"
 */
export function getFormattedDisplayDate(): string {
  return new Date().toLocaleString("en-US", {
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

/**
 * Convert ISO date string to display format
 */
export function formatISOToDisplay(isoString: string): string {
  const date = new Date(isoString)
  return date.toLocaleString("en-US", {
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

/**
 * Get current Unix timestamp in milliseconds (for Arduino compatibility)
 */
export function getCurrentUnixTimestamp(): number {
  return Date.now()
}

/**
 * Convert Unix timestamp to display format
 */
export function formatUnixToDisplay(timestamp: number): string {
  const date = new Date(timestamp)
  return date.toLocaleString("en-US", {
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
