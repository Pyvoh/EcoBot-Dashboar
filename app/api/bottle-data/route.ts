import { type NextRequest, NextResponse } from "next/server"

// In-memory storage (in production, use a database)
let bottleData = {
  history: [], // Start empty
  total: 0, // Start with 0 bottles
  sessions: 0, // Start with 0 sessions
}

export async function GET() {
  return NextResponse.json(bottleData)
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    // Add new bottle collection session
    const newSession = {
      id: bottleData.history.length + 1,
      sessionType: body.sessionType || "Arduino Collection",
      bottles: body.bottles || 3,
      timestamp: new Date().toLocaleString(),
      status: body.status || "Completed",
      reward: 1, // Each session costs 1 reward point
    }

    bottleData.history.unshift(newSession)
    bottleData.total += newSession.bottles
    bottleData.sessions += 1

    console.log("New bottle collection recorded:", newSession)

    // Update the reward system (decrease by 1 for each session)
    const rewardResponse = await fetch(
      `${process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"}/api/reward-bottle`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: "decrease",
          amount: 1,
          reason: `Session ${newSession.id} completed`,
        }),
      },
    ).catch(() => null) // Ignore fetch errors in API route

    return NextResponse.json({
      success: true,
      session: newSession,
      total: bottleData.total,
    })
  } catch (error) {
    console.error("Error processing bottle data:", error)
    return NextResponse.json({ error: "Failed to process bottle data" }, { status: 500 })
  }
}

export async function DELETE() {
  // Clear all history
  bottleData = {
    history: [],
    total: 0,
    sessions: 0,
  }

  return NextResponse.json({ success: true, message: "History cleared" })
}
