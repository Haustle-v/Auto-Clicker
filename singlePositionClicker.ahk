#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode("Mouse", "Screen")

clickX   := 1274
clickY   := 904
interval := 100

running := false

F8:: {
    global running, interval
    if !running {
        running := true
        SetTimer(DoClick, interval)
        ToolTip("连点开始")
        Sleep(500)
        ToolTip()
    }
}

F9:: {
    global running
    if running {
        running := false
        SetTimer(DoClick, 0)
        ToolTip("连点停止")
        Sleep(500)
        ToolTip()
    }
}

Esc::ExitApp()

DoClick() {
    global clickX, clickY
    Click(clickX, clickY)
}
