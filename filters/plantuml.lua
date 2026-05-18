PANDOC_VERSION:must_be_at_least '3.0'

-- Minimalistic PlantUML to SVG filter for Pandoc
--
-- Fenced code (also ```puml):
--   ```plantuml
--   @startuml ... @enduml
--   ```
--
-- Bracket attributes (Pandoc markdown):
--   ```{.plantuml caption="Title" align=left #my-id}
--   @startuml ... @enduml
--   ```
--
-- Same-line attributes (Pandoc markdown):
--   ```plantuml {caption="Title" align=left #my-id}
--   @startuml ... @enduml
--   ```
--
-- Note: With reader `gfm`, bracket fences become class "{.plantuml" (GFM has no
-- fenced_code_attributes). We still treat that as PlantUML so the diagram runs.

-- Pandoc 3.x: document metadata is not on PANDOC_STATE (unknown key if indexed).
local plantuml_path = 'plantuml'

-- GFM puts the first word of the info string in classes, e.g. "{.plantuml".
local function class_signals_plantuml(c)
  if c == 'plantuml' or c == 'puml' then
    return true
  end
  if string.find(c, '{.plantuml', 1, true) == 1 then
    return true
  end
  if string.find(c, '{.puml', 1, true) == 1 then
    return true
  end
  return false
end

local function block_is_plantuml(block)
  for _, c in ipairs(block.classes) do
    if class_signals_plantuml(c) then
      return true
    end
  end
  return false
end

function Meta(m)
  if m['plantuml-path'] then
    plantuml_path = pandoc.utils.stringify(m['plantuml-path'])
  end
  return m
end

function CodeBlock(block)
  if not block_is_plantuml(block) then
    return nil
  end

  local success, svg = pcall(pandoc.pipe, plantuml_path, {'-tsvg', '-pipe', '-charset', 'UTF8'}, block.text)

  if not success then
    io.stderr:write("[plantuml.lua] PlantUML Error: " .. tostring(svg) .. "\n")
    return nil
  end

  -- Use hash of SVG content as filename
  local fname = pandoc.sha1(svg) .. '.svg'
  pandoc.mediabag.insert(fname, 'image/svg+xml', svg)

  -- Create the image element (inherit CodeBlock attr: align, etc.)
  local alt_raw = block.attributes.caption
  local alt = alt_raw and pandoc.utils.stringify(alt_raw) or ''
  local img = pandoc.Image(alt_raw or {}, fname, '', block.attr)

  -- Wrap in Figure if a caption is provided in attributes
  if alt ~= '' then
    return pandoc.Figure(
      { pandoc.Plain{img} },
      { pandoc.Plain{pandoc.Str(alt)} },
      block.attr
    )
  end

  return pandoc.Para{img}
end

return {{ Meta = Meta }, { CodeBlock = CodeBlock }}
