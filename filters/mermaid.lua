PANDOC_VERSION:must_be_at_least '3.0'

-- Mermaid → SVG via Mermaid CLI (mmdc), same pattern as plantuml.lua
--
-- Puppeteer/Chromium often needs --no-sandbox on Linux (Ubuntu 23.10+ AppArmor).
-- By default we write a small JSON next to Pandoc's cwd and pass `mmdc -p ...`.
-- Override with metadata `mmdc-puppeteer-config` (path to JSON), or disable with
-- `mmdc-no-sandbox: false` (e.g. from extension setting).

local mmdc_path = 'mmdc'
-- Path passed to `mmdc -p` when non-nil
local puppeteer_config_for_mmdc = nil
-- Track if we created a temp file so we can delete it
local created_temp_config = nil

-- True only when key is present and reads as boolean false (opt out of default -p JSON).
local function meta_is_false(m, key)
  local v = m[key]
  if v == nil then
    return false
  end
  local s = pandoc.utils.stringify(v):lower()
  return s == 'false' or s == '0' or s == 'no' or s == ''
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

local function block_is_mermaid(block)
  for _, c in ipairs(block.classes) do
    if class_signals_mermaid(c) then
      return true
    end
  end
  return false
end

local function write_default_puppeteer_config(rel_path)
  local json =
    '{"args":["--no-sandbox","--disable-setuid-sandbox","--disable-dev-shm-usage"]}'
  local f = io.open(rel_path, 'w')
  if not f then
    io.stderr:write('[mermaid.lua] could not write ' .. rel_path .. '\n')
    return nil
  end
  f:write(json)
  f:close()
  return rel_path
end

function Meta(m)
  if m['mmdc-path'] then
    mmdc_path = pandoc.utils.stringify(m['mmdc-path'])
  end

  puppeteer_config_for_mmdc = nil

  if m['mmdc-puppeteer-config'] then
    local p = pandoc.utils.stringify(m['mmdc-puppeteer-config'])
    if p ~= '' then
      puppeteer_config_for_mmdc = p
    end
  elseif not meta_is_false(m, 'mmdc-no-sandbox') then
    -- absent or true → write default Chromium args for restricted Linux sandboxes
    local tmp = os.tmpname()
    puppeteer_config_for_mmdc = write_default_puppeteer_config(tmp)
    created_temp_config = puppeteer_config_for_mmdc
  end

  return m
end

function Pandoc(doc)
  if created_temp_config then
    os.remove(created_temp_config)
  end
  return doc
end

function CodeBlock(block)
  if not block_is_mermaid(block) then
    return nil
  end

  local args = { '--input', '-', '--output', '-', '--outputFormat', 'pdf', '--quiet', '--pdfFit' }
  if puppeteer_config_for_mmdc then
    table.insert(args, '-p')
    table.insert(args, puppeteer_config_for_mmdc)
  end

  local success, pdf = pcall(pandoc.pipe, mmdc_path, args, block.text)

  if not success or not pdf or #pdf == 0 then
    io.stderr:write('[mermaid.lua] mmdc error: ' .. tostring(pdf) .. '\n')
    return nil
  end

  local fname = pandoc.sha1(pdf) .. '.pdf'
  pandoc.mediabag.insert(fname, 'application/pdf', pdf)

  local alt_raw = block.attributes.caption
  local alt = alt_raw and pandoc.utils.stringify(alt_raw) or ''
  local img = pandoc.Image(alt_raw or {}, fname, '', block.attr)

  if alt ~= '' then
    return pandoc.Figure(
      { pandoc.Plain{img} },
      { pandoc.Plain{pandoc.Str(alt)} },
      block.attr
    )
  end

  return pandoc.Para{img}
end

return { { Meta = Meta }, { CodeBlock = CodeBlock }, { Pandoc = Pandoc } }
