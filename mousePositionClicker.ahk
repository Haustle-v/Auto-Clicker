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

defaultInterval := 100
jitterEnabled := true

; 创建配置 GUI
mainGui := Gui()
mainGui.Title := "AHK"
mainGui.MarginX := 15
mainGui.MarginY := 15

mainGui.Add("Text", "cBlue", "按 F8 开始连点，F9 停止连点")
mainGui.Add("Text", , "每次点击取当前鼠标位置")
mainGui.Add("Text", , "点击间隔 (毫秒):")
editInterval := mainGui.Add("Edit", "w120", defaultInterval)
; 复选框控制是否启用随机抖动（可取消勾选）
jitterCheck := mainGui.Add("Checkbox", "Checked", "随机时间间隔抖动")

btnOK := mainGui.Add("Button", "Default xm", "确定")
btnCancel := mainGui.Add("Button", "x+10", "取消")

confirmed := false
; 先用默认值初始化，防止 GUI 销毁后访问控件报错
interval := defaultInterval
jitterEnabled := true

; --- 使用普通函数替代箭头函数 ---
btnOK.OnEvent("Click", OnOKClick)
btnCancel.OnEvent("Click", OnCancelClick)
mainGui.OnEvent("Close", OnGuiClose)
mainGui.OnEvent("Escape", OnGuiClose)

; 事件处理函数定义
OnOKClick(*) {
    global confirmed, mainGui, editInterval, jitterCheck
    global interval, jitterEnabled
    confirmed := true
    ; 先读取值再销毁 GUI，避免控件已销毁导致报错
    interval := SafeInt(editInterval.Value, defaultInterval)
    jitterEnabled := (jitterCheck.Value = 1)
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
    interval := defaultInterval
    jitterEnabled := true
}

; 最小间隔保护
if (interval < 10)
    interval := 10

running := false

; 启动连点（F8）
F8:: {
    global running, interval, jitterEnabled
    if (!running) {
        running := true
        if (jitterEnabled) {
            SetTimer(DoClickWithJitter, interval)
            ToolTip("连点开始 - 当前鼠标位置（随机抖动）")
        } else {
            SetTimer(DoClick, interval)
            ToolTip("连点开始 - 当前鼠标位置，间隔:" interval "ms")
        }
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
        SetTimer(DoClickWithJitter, 0)
        ToolTip("连点停止")
        Sleep(500)
        ToolTip()
    }
}

; 退出程序（Esc）
Esc::ExitApp()

; 连点执行函数：使用当前鼠标位置
DoClick() {
    Click()
}

; 带随机抖动的连点函数
DoClickWithJitter(*) {
    global running, interval

    jitterFactor := Random(0, 50) / 100.0
    actualDelay := Round(interval * jitterFactor)

    ; 在本次调用里等待抖动后的时间，再点击一次
    Sleep(actualDelay)
    DoClick()
}

