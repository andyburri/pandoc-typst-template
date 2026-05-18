-- preserve-ref.lua
if FORMAT ~= "typst" then
    return {}
end

function Para(el)
    local inlines = el.content
    if #inlines == 0 then
        return el
    end

    local last = inlines[#inlines]
    if last.t == "RawInline" and last.format == "html" then
        local text = last.text
        local ref = text:match("(<[%w:_-]+>)%s*$")
        if ref then
            local clean = text:gsub("(<[%w:_-]+>)%s*$", "")
            local new_inlines = {}
            for i = 1, #inlines - 1 do
                table.insert(new_inlines, inlines[i])
            end
            if clean ~= "" then
                table.insert(new_inlines, pandoc.Str(clean))
            end
            if clean ~= "" then
                table.insert(new_inlines, pandoc.Space())
            end
            table.insert(new_inlines, pandoc.RawInline('typst', ref))
            return pandoc.Para(new_inlines)
        end
    end
    
    return el
end
