#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode("Mouse", "Screen")

; 安全转换字符串为非负整数，失败则返回默认值
SafeInt(str, default) {
    try {
        val := Integer(str)
        return (val >= 0) ? val : default
    } catch {
        return default
    }
}

; 创建配置 GUI
mainGui := Gui()
mainGui.Title := "鼠标连点器 - 配置参数"
mainGui.MarginX := 15
mainGui.MarginY := 15

mainGui.Add("Text", , "X 坐标:")
editX := mainGui.Add("Edit", "w120", "1274")

mainGui.Add("Text", , "Y 坐标:")
editY := mainGui.Add("Edit", "w120", "904")

mainGui.Add("Text", , "点击间隔 (毫秒):")
editInterval := mainGui.Add("Edit", "w120", "100")

btnOK := mainGui.Add("Button", "Default xm", "确定")
btnCancel := mainGui.Add("Button", "x+10", "取消")

confirmed := false
; 先用默认值初始化，防止 GUI 销毁后访问控件报错
clickX := 1274
clickY := 904
interval := 100

; --- 使用普通函数替代箭头函数 ---
btnOK.OnEvent("Click", OnOKClick)
btnCancel.OnEvent("Click", OnCancelClick)
mainGui.OnEvent("Close", OnGuiClose)
mainGui.OnEvent("Escape", OnGuiClose)

; 事件处理函数定义
OnOKClick(*) {
    global confirmed, mainGui, editX, editY, editInterval, clickX, clickY, interval
    confirmed := true
    ; 先读取值再销毁 GUI，避免控件已销毁导致报错
    clickX := SafeInt(editX.Value, 1274)
    clickY := SafeInt(editY.Value, 904)
    interval := SafeInt(editInterval.Value, 100)
    mainGui.Destroy()
}

OnCancelClick(*) {
    global confirmed, mainGui
    confirmed := false
    mainGui.Destroy()
}

OnGuiClose(*) {
    global confirmed, mainGui
    confirmed := false
    mainGui.Destroy()
}

; 显示窗口并等待关闭
mainGui.Show()
WinWaitClose(mainGui.Hwnd)

; 如果不是点击“确定”，恢复默认值
if (!confirmed) {
    clickX := 1274
    clickY := 904
    interval := 100
}

; 最小间隔保护
if (interval < 10)
    interval := 10

running := false

; 启动连点（F8）
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

; 停止连点（F9）
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

; 退出程序（Esc）
Esc::ExitApp()

; 连点执行函数
DoClick() {
    global clickX, clickY
    Click(clickX, clickY)
}
