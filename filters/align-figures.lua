-- align-figures.lua
if FORMAT ~= "typst" then
    return {}
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
