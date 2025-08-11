#Requires AutoHotkey v2.0
#SingleInstance Force

; Create the test window
TestGui := Gui("+Resize", "Click Test Window")
TestGui.SetFont("s12", "Segoe UI")

; Add a button that we can click
clickArea := TestGui.Add("Button", "w300 h200", "Click Counter Area")
TestGui.Add("Text", "w300 h30 vClickCount", "Clicks: 0")
TestGui.Add("Text", "w300 h30 vLastPos", "Last Click: None")

; Track click count
clickCount := 0

; Handle clicks
clickArea.OnEvent("Click", UpdateClickInfo)

; Update click information
UpdateClickInfo(ctrl, *) {
    global clickCount, TestGui
    clickCount++
    MouseGetPos(&mouseX, &mouseY)
    TestGui["ClickCount"].Value := "Clicks: " . clickCount
    TestGui["LastPos"].Value := "Last Click: X:" . mouseX . " Y:" . mouseY
}

; Show the window
TestGui.Show("w400 h300")

return 