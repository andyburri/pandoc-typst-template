-- caption-code-blocks.lua
if FORMAT ~= "typst" then
    return {}
end

local function class_signals_plantuml(c)
    if c == 'plantuml' or c == 'puml' then
        return true
    end
    if string.find(c, '{.plantuml', 1, true) == 1 or string.find(c, '{.puml', 1, true) == 1 then
        return true
    end
    return false
end

local function class_signals_mermaid(c)
    if c == 'mermaid' then
        return true
    end
    if string.find(c, '{.mermaid', 1, true) == 1 then
        return true
    end
    return false
end

function CodeBlock(el)
    -- When diagram conversion fails, the block stays a CodeBlock; do not wrap it
    -- in #figure(...) or the preview shows raw ``` fences as "the diagram".
    for _, c in ipairs(el.classes) do
        if class_signals_plantuml(c) or class_signals_mermaid(c) then
            return nil
        end
    end

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
