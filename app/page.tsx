"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Wifi, WifiOff, Trash2, Download, BarChart3, CheckCircle, AlertCircle, Clock } from "lucide-react"

interface BottleData {
  id: number
  sessionType: string
  bottles: number
  timestamp: string
  status: string
  reward: number
}

interface BinStatus {
  status: string
  message: string
  timestamp: number
  device_id: string
  containerLevel?: number
}

export default function EcoBotDashboard() {
  const [connected, setConnected] = useState(false)
  const [binStatus, setBinStatus] = useState<BinStatus>({
    status: "UNKNOWN",
    message: "No data received",
    timestamp: Date.now(),
    device_id: "ecobot_001",
  })
  const [bottleHistory, setBottleHistory] = useState<BottleData[]>([])
  const [totalBottles, setTotalBottles] = useState(0)
  const [totalReward, setTotalReward] = useState(15) // Start with 15 rewards
  const [sessionsCompleted, setSessionsCompleted] = useState(0)

  // Simulate connection status
  useEffect(() => {
    const interval = setInterval(() => {
      // Simulate random connection status changes
      setConnected((prev) => (Math.random() > 0.1 ? true : prev))
    }, 5000)

    return () => clearInterval(interval)
  }, [])

  // Poll for updates
  useEffect(() => {
    const pollData = async () => {
      try {
        // Check bin status
        const binResponse = await fetch("/api/bin-status")
        if (binResponse.ok) {
          const binData = await binResponse.json()
          setBinStatus(binData)
        }

        // Get bottle data
        const bottleResponse = await fetch("/api/bottle-data")
        if (bottleResponse.ok) {
          const bottleData = await bottleResponse.json()
          setBottleHistory(bottleData.history || [])
          setTotalBottles(bottleData.total || 0)
          setSessionsCompleted(bottleData.sessions || 0)
        }

        // Get reward data
        const rewardResponse = await fetch("/api/reward-bottle")
        if (rewardResponse.ok) {
          const rewardData = await rewardResponse.json()
          // Ensure totalReward doesn't go below 0
          setTotalReward(Math.max(0, rewardData.totalReward || 0))
        }
      } catch (error) {
        console.error("Error polling data:", error)
      }
    }

    // Poll every 5 seconds
    const interval = setInterval(pollData, 5000)
    pollData() // Initial poll

    return () => clearInterval(interval)
  }, [])

  const handleConnectToEcoBot = async () => {
    try {
      const response = await fetch("/api/bin-status", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: "connect",
          device_id: "ecobot_001",
        }),
      })

      if (response.ok) {
        setConnected(true)
        console.log("Connected to EcoBot")
      }
    } catch (error) {
      console.error("Connection failed:", error)
    }
  }

  const handleClearHistory = async () => {
    try {
      const response = await fetch("/api/bottle-data", {
        method: "DELETE",
      })

      if (response.ok) {
        setBottleHistory([])
        setTotalBottles(0)
        setSessionsCompleted(0)
        console.log("History cleared")
      }
    } catch (error) {
      console.error("Failed to clear history:", error)
    }
  }

  const handleExportData = () => {
    const data = {
      binStatus,
      bottleHistory,
      totalBottles,
      totalReward,
      sessionsCompleted,
      exportDate: new Date().toISOString(),
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `ecobot-data-${new Date().toISOString().split("T")[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  const getBinStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case "full":
        return "bg-red-500"
      case "empty":
        return "bg-green-500"
      case "connected":
        return "bg-blue-500"
      default:
        return "bg-yellow-500"
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status.toLowerCase()) {
      case "completed":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "failed":
        return <AlertCircle className="h-4 w-4 text-red-500" />
      default:
        return <Clock className="h-4 w-4 text-yellow-500" />
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 via-blue-800 to-blue-700 text-white p-6">
      {/* Header */}
      <div className="max-w-7xl mx-auto mb-8">
        <div className="bg-blue-800/50 backdrop-blur-sm rounded-2xl p-8 border border-blue-600/30">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="bg-orange-500 p-3 rounded-full">
                <div className="text-2xl">🤖</div>
              </div>
              <div>
                <h1 className="text-4xl font-bold">EcoBot Dashboard</h1>
                <p className="text-blue-200 text-lg">Real-time monitoring of your smart bottle collection system</p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              {connected ? (
                <>
                  <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                  <span className="text-green-400 font-medium">Connected</span>
                </>
              ) : (
                <>
                  <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                  <span className="text-red-400 font-medium">Disconnected</span>
                </>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="max-w-7xl mx-auto mb-8">
        <div className="flex gap-4 justify-center">
          <Button onClick={handleConnectToEcoBot} className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3">
            {connected ? <Wifi className="h-4 w-4 mr-2" /> : <WifiOff className="h-4 w-4 mr-2" />}
            Connect to EcoBot
          </Button>
          <Button
            onClick={handleClearHistory}
            variant="outline"
            className="border-blue-400 text-blue-100 hover:bg-blue-700 px-6 py-3"
          >
            <Trash2 className="h-4 w-4 mr-2" />
            Clear History
          </Button>
          <Button
            onClick={handleExportData}
            variant="outline"
            className="border-blue-400 text-blue-100 hover:bg-blue-700 px-6 py-3"
          >
            <Download className="h-4 w-4 mr-2" />
            Export Data
          </Button>
        </div>
      </div>

      {/* Status Cards */}
      <div className="max-w-7xl mx-auto mb-8">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Bin Status */}
          <Card className="bg-blue-800/50 backdrop-blur-sm border-blue-600/30">
            <CardHeader>
              <CardTitle className="text-white flex items-center gap-2">
                <div className="text-yellow-400">⚠️</div>
                Bin Status
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center gap-3">
                  <div className={`w-3 h-3 rounded-full ${getBinStatusColor(binStatus.status)}`}></div>
                  <span className="text-2xl font-bold text-yellow-400">{binStatus.status.toUpperCase()}</span>
                </div>
                <div className="text-blue-200">
                  <p className="font-medium">Container Level</p>
                  <p className="text-sm text-blue-300">
                    Last updated:{" "}
                    {new Date(binStatus.timestamp).toLocaleString("en-US", {
                      timeZone: "Asia/Manila", // UTC+8
                      year: "numeric",
                      month: "numeric",
                      day: "numeric",
                      hour: "numeric",
                      minute: "2-digit",
                      second: "2-digit",
                      hour12: true,
                    })}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Total Bottles */}
          <Card className="bg-blue-800/50 backdrop-blur-sm border-blue-600/30">
            <CardHeader>
              <CardTitle className="text-white flex items-center gap-2">
                <BarChart3 className="h-5 w-5 text-green-400" />
                Total Bottles Collected
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="text-6xl font-bold text-white">{totalBottles}</div>
                <div className="text-blue-200">
                  <p>All time collection</p>
                  <p className="text-sm">Sessions completed: {sessionsCompleted}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Collection History */}
      <div className="max-w-7xl mx-auto">
        <Card className="bg-blue-800/50 backdrop-blur-sm border-blue-600/30">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-white flex items-center gap-2">
                <div className="text-orange-400">📋</div>
                Collection History
              </CardTitle>
              <div className="text-right">
                <div className="text-sm text-blue-300">REWARD STATUS:</div>
                <div className="text-2xl font-bold text-white">{totalReward}</div>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-blue-600/30">
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">#</th>
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">Session Type</th>
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">Bottles</th>
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">Timestamp</th>
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">Status</th>
                    <th className="text-left py-3 px-4 text-blue-200 font-medium">REWARD</th>
                  </tr>
                </thead>
                <tbody>
                  {bottleHistory.map((session) => (
                    <tr key={session.id} className="border-b border-blue-700/30 hover:bg-blue-700/30">
                      <td className="py-3 px-4 text-white">{session.id}</td>
                      <td className="py-3 px-4 text-white">{session.sessionType}</td>
                      <td className="py-3 px-4 text-white">{session.bottles}</td>
                      <td className="py-3 px-4 text-white">{session.timestamp}</td>
                      <td className="py-3 px-4">
                        <div className="flex items-center gap-2">
                          {getStatusIcon(session.status)}
                          <span className="text-green-400">✓ {session.status}</span>
                        </div>
                      </td>
                      <td className="py-3 px-4 text-white font-bold">{session.reward}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {bottleHistory.length === 0 && (
                <div className="text-center py-8 text-blue-300">No collection history available</div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
