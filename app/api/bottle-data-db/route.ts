import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function GET() {
  try {
    // Get bottle sessions
    const { data: sessions, error } = await supabase
      .from("bottle_sessions")
      .select("*")
      .order("created_at", { ascending: false })

    if (error) throw error

    // Calculate totals
    const total = sessions?.reduce((sum, session) => sum + session.bottles_collected, 0) || 0
    const sessionsCount = sessions?.length || 0

    return NextResponse.json({
      history: sessions || [],
      total,
      sessions: sessionsCount,
    })
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Database error" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    // Insert new session into database
    const { data, error } = await supabase
      .from("bottle_sessions")
      .insert({
        device_id: body.device_id || "ecobot_001",
        bottles_collected: body.bottles || 3,
        session_type: body.sessionType || "Arduino Collection",
        status: "completed",
        reward_points: 1,
      })
      .select()
      .single()

    if (error) throw error

    // Update rewards
    await supabase.from("rewards").insert({
      device_id: body.device_id || "ecobot_001",
      session_id: data.id,
      points_awarded: -1,
      reason: "Session completed - reward used",
    })

    return NextResponse.json({
      success: true,
      session: data,
    })
  } catch (error) {
    console.error("Database error:", error)
    return NextResponse.json({ error: "Database error" }, { status: 500 })
  }
}
