import { type NextRequest, NextResponse } from "next/server"

// In-memory storage for bin status
let binStatus = {
  status: "UNKNOWN",
  message: "No data received",
  timestamp: Date.now(),
  device_id: "ecobot_001",
  containerLevel: 0,
}

export async function GET() {
  return NextResponse.json(binStatus)
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    // Update bin status from Arduino
    binStatus = {
      status: body.status || binStatus.status,
      message: body.message || binStatus.message,
      timestamp: body.timestamp || Date.now(),
      device_id: body.device_id || binStatus.device_id,
      containerLevel: body.containerLevel || binStatus.containerLevel,
    }

    console.log("Bin status updated:", binStatus)

    // Log different status types
    if (body.status === "full") {
      console.log("🚨 CONTAINER FULL - Notification received from Arduino")
    } else if (body.status === "empty") {
      console.log("✅ CONTAINER EMPTY - Ready for use")
    }

    return NextResponse.json({
      success: true,
      status: binStatus.status,
      message: "Status updated successfully",
    })
  } catch (error) {
    console.error("Error updating bin status:", error)
    return NextResponse.json({ error: "Failed to update bin status" }, { status: 500 })
  }
}
