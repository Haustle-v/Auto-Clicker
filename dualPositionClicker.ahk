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

; 默认值
defaultX1 := 390
defaultY1 := 1420
defaultX2 := 1532
defaultY2 := 994
defaultInterval1 := 180  ; 点完位置1后等待，再点位置2
defaultInterval2 := 220  ; 点完位置2后等待，再点位置1
jitterEnabled := true

; 创建配置 GUI
mainGui := Gui()
mainGui.Title := "鼠标连点器 - 配置参数"
mainGui.MarginX := 15
mainGui.MarginY := 15

mainGui.Add("Text", "cBlue", "按 F8 开始连点，F9 停止连点")
mainGui.Add("Text", , "位置1 X 坐标:")
editX1 := mainGui.Add("Edit", "w120", defaultX1)

mainGui.Add("Text", , "位置1 Y 坐标:")
editY1 := mainGui.Add("Edit", "w120", defaultY1)

mainGui.Add("Text", , "位置2 X 坐标:")
editX2 := mainGui.Add("Edit", "w120", defaultX2)

mainGui.Add("Text", , "位置2 Y 坐标:")
editY2 := mainGui.Add("Edit", "w120", defaultY2)

mainGui.Add("Text", , "间隔1 (毫秒，点1→点2):")
editInterval1 := mainGui.Add("Edit", "w120", defaultInterval1)

mainGui.Add("Text", , "间隔2 (毫秒，点2→点1):")
editInterval2 := mainGui.Add("Edit", "w120", defaultInterval2)
; 复选框控制是否启用随机抖动（可取消勾选）
jitterCheck := mainGui.Add("Checkbox", "Checked", "随机时间间隔抖动")

btnOK := mainGui.Add("Button", "Default xm", "确定")
btnCancel := mainGui.Add("Button", "x+10", "取消")

confirmed := false
; 先用默认值初始化，防止 GUI 销毁后访问控件报错
clickX1 := defaultX1
clickY1 := defaultY1
clickX2 := defaultX2
clickY2 := defaultY2
interval1 := defaultInterval1
interval2 := defaultInterval2
jitterEnabled := true
nextTarget := 1

; --- 使用普通函数替代箭头函数 ---
btnOK.OnEvent("Click", OnOKClick)
btnCancel.OnEvent("Click", OnCancelClick)
mainGui.OnEvent("Close", OnGuiClose)
mainGui.OnEvent("Escape", OnGuiClose)

; 事件处理函数定义
OnOKClick(*) {
    global confirmed, mainGui
    global editX1, editY1, editX2, editY2, editInterval1, editInterval2, jitterCheck
    global clickX1, clickY1, clickX2, clickY2, interval1, interval2, jitterEnabled
    confirmed := true
    ; 先读取值再销毁 GUI，避免控件已销毁导致报错
    clickX1 := SafeInt(editX1.Value, defaultX1)
    clickY1 := SafeInt(editY1.Value, defaultY1)
    clickX2 := SafeInt(editX2.Value, defaultX2)
    clickY2 := SafeInt(editY2.Value, defaultY2)
    interval1 := SafeInt(editInterval1.Value, defaultInterval1)
    interval2 := SafeInt(editInterval2.Value, defaultInterval2)
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
    clickX1 := defaultX1
    clickY1 := defaultY1
    clickX2 := defaultX2
    clickY2 := defaultY2
    interval1 := defaultInterval1
    interval2 := defaultInterval2
    jitterEnabled := true
}

; 最小间隔保护
if (interval1 < 10)
    interval1 := 10
if (interval2 < 10)
    interval2 := 10

running := false
nextTarget := 1

; 启动连点（F8）
F8:: {
    global running, nextTarget
    if (!running) {
        running := true
        nextTarget := 1
        DoClick()  ; 立即开始
        ToolTip("连点开始（双点轮询）")
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
DoClick(*) {
    global running, nextTarget
    global clickX1, clickY1, clickX2, clickY2, interval1, interval2, jitterEnabled
    if (!running) {
        SetTimer(DoClick, 0)
        return
    }

    baseInterval := 0

    if (nextTarget = 1) {
        Click(clickX1, clickY1)
        nextTarget := 2
        baseInterval := interval1
    } else {
        Click(clickX2, clickY2)
        nextTarget := 1
        baseInterval := interval2
    }

    nextInterval := baseInterval
    if (jitterEnabled) {
        jitterFactor := Random(0, 50) / 100.0  ; 0.0 ~ 0.5
        jitterDelta := Round(baseInterval * jitterFactor)
        nextInterval := baseInterval + jitterDelta
    }

    if (nextInterval < 10)
        nextInterval := 10

    ; 负值代表一次性定时器，等待后再执行
    SetTimer(DoClick, -nextInterval)
}
