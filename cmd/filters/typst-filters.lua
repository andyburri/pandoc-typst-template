-- typst-filters.lua
-- Only run this filter when the output format is exactly "typst"
if FORMAT ~= "typst" then
    return {}
end

-- Preserve Typst-style @refs and <refs> when converting Markdown → Typst
-- Handle citations like @formula-one literally
function Cite(el)
    local result = {}
    for _, citation in ipairs(el.citations) do
        table.insert(result, pandoc.RawInline('typst', '@' .. citation.id))
    end
    return result
end

-- Detect trailing <ref> in paragraphs and preserve it as Typst inline
function Para(el)
    local inlines = el.content
    if #inlines == 0 then
        return el
    end

    -- Work backward to find a trailing <ref>
    local last = inlines[#inlines]
    if last.t == "RawInline" and last.format == "html" then
        local text = last.text
        -- Match <something> at the END of the paragraph
        local ref = text:match("(<[%w:_-]+>)%s*$")
        if ref then
            -- Remove the ref from the text
            local clean = text:gsub("(<[%w:_-]+>)%s*$", "")
            local new_inlines = {}
            for i = 1, #inlines - 1 do
                table.insert(new_inlines, inlines[i])
            end
            if clean ~= "" then
                table.insert(new_inlines, pandoc.Str(clean))
            end
            -- Add a space if needed, then the raw Typst reference
            if clean ~= "" then
                table.insert(new_inlines, pandoc.Space())
            end
            table.insert(new_inlines, pandoc.RawInline('typst', ref))
            return pandoc.Para(new_inlines)
        end
    end
    
    -- Preserve #[@ref] as Typst inline
    -- Detect a pattern: [Str "#",RawInline (typst) "@something",Str "-text"]
    if #inlines == 3 
        and inlines[1].t == "Str" and inlines[1].text == "#" 
        and inlines[2].t == "RawInline" and inlines[2].format == "typst"
        and inlines[2].text:match("^@[%w:_-]+$")
        and inlines[3].t == "Str" and inlines[3].text == "-text" then
        local ref = inlines[2].text
        -- output Typst: #[@blindtext]
        return pandoc.Para({pandoc.RawInline('typst', '#[' .. ref .. ']')})
    end

    return el
end

function RawInline(el)
    if el.format == "html" then
        local s = el.text:lower()

        -- Convert HTML <br> to LineBreak
        if s:match("^<br%s*/?>$") then
            return pandoc.LineBreak()
        end
    end
end



-- Helper: check for class
local function hasClass(el, class)
    return el.classes and el.classes:includes(class)
end

-- Pandoc Lua filter: wrap table in new context and set figure align
function Table(el)
    local tbl_before = ""

    local align = el.attr and el.attr.attributes["align"]
    if align then
        tbl_before = "#show figure: set align(" .. align .. ")\n"
    end

    if hasClass(el, "plain") then
        el.attr.attributes["typst:stroke"] = "none"
    end

    local tbl = pandoc.write(pandoc.Pandoc({el}), "typst")

    if hasClass(el, "unlisted") then
        local pattern = "([ \t]*), kind: table"
        tbl = tbl:gsub(pattern, ", numbering: none,\n  outlined: false,\n  kind: table")
    end

    local cols = el.attr and el.attr.attributes["columns"]
    if cols then
        cols = cols:gsub("^%s*%(", ""):gsub("%)%s*$", "")
        local new_cols = "columns: (" .. cols .. "),"

        -- replace columns: ( ... ),
        tbl = tbl:gsub("([ \t]*)columns:%s*%b(),", function(indent)
            return indent .. new_cols
        end, 1)

        -- replace columns: 3,
        tbl = tbl:gsub("([ \t]*)columns:%s*%d+,", function(indent)
            return indent .. new_cols
        end, 1)
    end

    if tbl_before ~= "" then
        tbl = "#[\n" .. tbl_before .. tbl .. "]\n\n"
    end

    return pandoc.RawBlock("typst", tbl)
end

function CodeBlock(el)
    local code = pandoc.write(pandoc.Pandoc({el}), "typst")

    local code_before = "#figure("
    local code_after = ")"

    if el.attr.attributes["caption"] then
        code_after = ", caption: [" .. el.attr.attributes["caption"] .. "],\n" .. code_after
    end

    if #el.identifier > 0 then
        code_after = code_after .. "<" .. el.identifier .. ">"
    end

    return pandoc.RawBlock("typst", code_before .. code .. code_after)

end

function Figure(fig)
    local before = ""
    local align = fig.content[1].content[1].attr and fig.content[1].content[1].attr.attributes["align"]
    if align then
        before = "#show figure: set align(" .. align .. ")\n"
    end

    if before ~= "" then
        local out = {}
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "#[")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", before)})
        table.insert(out, pandoc.Figure(fig.content, fig.caption, fig.attr))
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "]")})

        return out
    end

    return fig
end

function BlockQuote(el)
    local alert_type = el.content[1].content[1]

    local icon = ""
    local color = ""
    local type = ""
    local title = ""

    -- Define default values for the different alert types
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

    -- Now let's try to parse the title from the content
    -- Remove the alert type part and start looking for a title
    local content_after_alert = el.content[1].content
    table.remove(content_after_alert, 1) -- Remove the alert_type

    -- Look for the first SoftBreak to mark the end of the title
    local title_end_idx = nil
    for i, item in ipairs(content_after_alert) do
        if item.t == "SoftBreak" then
            title_end_idx = i
            break
        end
    end

    -- If there is a title (i.e., no SoftBreak was found), it means the rest is the title
    if title_end_idx then
        -- The title is all content before the SoftBreak
        local title_content = {}
        for i = 1, title_end_idx - 1 do
            table.insert(title_content, content_after_alert[i])
        end
        -- Concatenate the content into a single string
        title = pandoc.utils.stringify(title_content)
        -- Remove the parsed title from the content
        for i = 1, title_end_idx do
            table.remove(content_after_alert, 1)
        end
    end

    -- If no title was found, use the default title
    if title == "" then
        title = type
    end

    -- Now construct the Typst admonition output
    if alert_type.text == "[!NOTE]" or alert_type.text == "[!TIP]" or alert_type.text == "[!IMPORTANT]" or
        alert_type.text == "[!WARNING]" or alert_type.text == "[!CAUTION]" then

        local out = {}
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "#admonition(")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "icon-path: \"icons/" .. icon .. ".svg\",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "color: " .. color .. ",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "title: \"" .. title .. "\",")})
        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", ")[")})

        -- Add the remaining content after the title
        table.insert(out, content_after_alert)

        table.insert(out, pandoc.Plain {pandoc.RawInline("typst", "]")})
        return out
    end
end
