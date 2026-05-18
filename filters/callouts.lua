-- callouts.lua
if FORMAT ~= "typst" then
    return {}
end

function BlockQuote(el)
    local alert_type = el.content[1].content[1]

    local icon = ""
    local color = ""
    local type = ""
    local title = ""

    if alert_type.text == "[!NOTE]" then
        icon = "info"
        color = "rgb(9, 105, 218)"
        type = "Note"
    elseif alert_type.text == "[!TIP]" then
        icon = "light-bulb"
        color = "rgb(31, 136, 61)"
        type = "Tip"
    elseif alert_type.text == "[!IMPORTANT]" then
        icon = "report"
        color = "rgb(130, 80, 223)"
        type = "Important"
    elseif alert_type.text == "[!WARNING]" then
        icon = "alert"
        color = "rgb(154, 103, 0)"
        type = "Warning"
    elseif alert_type.text == "[!CAUTION]" then
        icon = "stop"
        color = "rgb(209, 36, 47)"
        type = "Caution"
    end

    local content_after_alert = el.content[1].content
    table.remove(content_after_alert, 1)

    local title_end_idx = nil
    for i, item in ipairs(content_after_alert) do
        if item.t == "SoftBreak" then
            title_end_idx = i
            break
        end
    end

    if title_end_idx then
        local title_content = {}
        for i = 1, title_end_idx - 1 do
            table.insert(title_content, content_after_alert[i])
        end
        title = pandoc.utils.stringify(title_content)
        for i = 1, title_end_idx do
            table.remove(content_after_alert, 1)
        end
    end

    if title == "" then
        title = type
    end

    if alert_type.text == "[!NOTE]" or alert_type.text == "[!TIP]" or alert_type.text == "[!IMPORTANT]" or
        alert_type.text == "[!WARNING]" or alert_type.text == "[!CAUTION]" then

        local out = {}
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "#admonition(")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "icon-path: \"icons/" .. icon .. ".svg\",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "color: " .. color .. ",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "title: \"" .. title .. "\",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", ")[")})

        table.insert(out, content_after_alert)

        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "]")})
        return out
    end
end
