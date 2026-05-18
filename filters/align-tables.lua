-- align-tables.lua
if FORMAT ~= "typst" then
    return {}
end

local function hasClass(el, class)
    return el.classes and el.classes:includes(class)
end

function Table(el)
    local tbl_before = ""

    local align = el.attr and el.attr.attributes["align"]
    if align then
        tbl_before = "#show figure: set align(" .. align .. ")\n"
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

        tbl = tbl:gsub("([ \t]*)columns:%s*%b(),", function(indent)
            return indent .. new_cols
        end, 1)

        tbl = tbl:gsub("([ \t]*)columns:%s*%d+,", function(indent)
            return indent .. new_cols
        end, 1)
    end

    if tbl_before ~= "" then
        tbl = "#[\n" .. tbl_before .. tbl .. "]\n\n"
    end

    return pandoc.RawBlock("typst", tbl)
end
