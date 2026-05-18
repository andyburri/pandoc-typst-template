-- newline.lua
if FORMAT ~= "typst" then
    return {}
end

function RawInline(el)
    if el.format == "html" then
        local s = el.text:lower()
        if s:match("^<br%s*/?>$") then
            return pandoc.LineBreak()
        end
    end
end
