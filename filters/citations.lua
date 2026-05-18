-- citations.lua
if FORMAT ~= "typst" then
    return {}
end

function Cite(el)
    local result = {}
    for _, citation in ipairs(el.citations) do
        table.insert(result, pandoc.RawInline('typst', '@' .. citation.id))
    end
    return result
end

function Inlines(inlines)
    local i = 1
    local new_inlines = {}
    local modified = false

    while i <= #inlines do
        if inlines[i] and inlines[i].t == "Str" and inlines[i].text == "#" 
            and inlines[i+1] and inlines[i+1].t == "RawInline" and inlines[i+1].format == "typst"
            and inlines[i+1].text:match("^@[%w:_-]+$")
        then
            local ref = inlines[i+1].text
            table.insert(new_inlines, pandoc.RawInline('typst', '#[' .. ref .. ']'))
            i = i + 2
            modified = true
        elseif inlines[i] and inlines[i].t == "RawInline" and inlines[i].format == "typst"
            and inlines[i].text:match("^@[%w:_-]+$")
        then
            local citation_text = inlines[i].text
            local next_el = inlines[i + 1]
            local should_wrap = false

            if next_el then
                if next_el.t == "Str" then
                    if next_el.text:match("^[%a%d:_-]") then
                        should_wrap = true
                    end
                elseif next_el.t ~= "Space" and next_el.t ~= "SoftBreak" and next_el.t ~= "LineBreak" then
                    should_wrap = true
                end
            end

            if should_wrap then
                table.insert(new_inlines, pandoc.RawInline('typst', '#[' .. citation_text .. ']'))
                modified = true
            else
                table.insert(new_inlines, inlines[i])
            end
            i = i + 1
        else
            table.insert(new_inlines, inlines[i])
            i = i + 1
        end
    end

    if modified then
        return new_inlines
    end
    return nil
end
