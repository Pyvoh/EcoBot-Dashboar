import { type NextRequest, NextResponse } from "next/server"

// In-memory storage for rewards
let rewardData = {
  totalReward: 15, // Start with 15 rewards
  rewardHistory: [], // Start empty
}

export async function GET() {
  return NextResponse.json(rewardData)
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    if (body.action === "decrease") {
      // Decrease rewards (for completed sessions)
      const amount = body.amount || 1
      const newReward = {
        id: rewardData.rewardHistory.length + 1,
        amount: -amount, // Negative amount for decrease
        timestamp: new Date().toLocaleString("en-US", {
          timeZone: "Asia/Manila", // UTC+8
          year: "numeric",
          month: "numeric",
          day: "numeric",
          hour: "numeric",
          minute: "2-digit",
          second: "2-digit",
          hour12: true,
        }),
        reason: body.reason || "Session completed - reward used",
      }

      rewardData.rewardHistory.unshift(newReward)
      rewardData.totalReward = Math.max(0, rewardData.totalReward - amount) // Don't go below 0

      console.log("Reward decreased:", newReward, "New total:", rewardData.totalReward)

      return NextResponse.json({
        success: true,
        reward: newReward,
        totalReward: rewardData.totalReward,
        action: "decreased",
      })
    } else {
      // Add rewards (for manual additions or bonuses)
      const newReward = {
        id: rewardData.rewardHistory.length + 1,
        amount: body.amount || 1,
        timestamp: new Date().toLocaleString("en-US", {
          timeZone: "Asia/Manila", // UTC+8
          year: "numeric",
          month: "numeric",
          day: "numeric",
          hour: "numeric",
          minute: "2-digit",
          second: "2-digit",
          hour12: true,
        }),
        reason: body.reason || "Reward added",
      }

      rewardData.rewardHistory.unshift(newReward)
      rewardData.totalReward += newReward.amount

      console.log("Reward added:", newReward)

      return NextResponse.json({
        success: true,
        reward: newReward,
        totalReward: rewardData.totalReward,
        action: "increased",
      })
    }
  } catch (error) {
    console.error("Error processing reward:", error)
    return NextResponse.json({ error: "Failed to process reward" }, { status: 500 })
  }
}

export async function DELETE() {
  // Reset rewards
  rewardData = {
    totalReward: 0,
    rewardHistory: [],
  }

  return NextResponse.json({ success: true, message: "Rewards reset" })
}
