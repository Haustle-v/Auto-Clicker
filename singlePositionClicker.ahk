#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode("Mouse", "Screen")

SafeInt(str, default) {
    try {
        return Integer(str)
    } catch {
        return default
    }
}

xStr := InputBox("请输入点击 X 坐标（默认: 1274）", "X 坐标")
clickX := SafeInt(xStr, 1274)

yStr := InputBox("请输入点击 Y 坐标（默认: 904）", "Y 坐标")
clickY := SafeInt(yStr, 904)

intervalStr := InputBox("请输入点击间隔（毫秒，默认: 100）", "点击间隔")
interval := SafeInt(intervalStr, 100)

if (interval < 10)
    interval := 10

running := false

F8:: {
    global running, clickX, clickY, interval
    if (!running) {
        running := true
        SetTimer(DoClick, interval)
        ToolTip("连点开始 - X:" clickX ", Y:" clickY ", 间隔:" interval "ms")
        Sleep(800)
        ToolTip()
    }
}

F9:: {
    global running
    if (running) {
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
