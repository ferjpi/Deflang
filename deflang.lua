local Module = {}

Module.current_language = nil
Module.default_language = "en"
Module.language_list = { en = "en" }
Module.initialize = false

Module.locale_data = {}

local function is_gui_context()
  if pcall(go.get_id) then
    return false
  else
    return true
  end
end

function Module.init()
  local language = Module.current_language or sys.get_sys_info().language

  if Module.language_list[language] then
    Module.current_language = language
  else
    if Module.language_list[Module.default_language] then
      Module.current_language = Module.default_language
    else
      print("Deflang[Error]: The language is not defined, please define the language and in the locale file")
    end
  end

  Module.initialize = true
end

function Module.get_language()
  return Module.language
end

function Module.get_text(key)
  if next(Module.locale_data) == nil then
    print("Deflang: You have not set any language data. Check the example.")
  end

  local text = Module.locale_data[Module.language][key]
  if text == nil then
    if Module.use_default_if_missing then
      text = Module.locale_data[Module.default_language][key]
      if text ~= nil then
        print("Deflang: Warning using default for " .. key)
        return text
      else
        print("Deflang: " .. key .. " is missing for " .. Module.current_language)
        return Module.locale_data.en.MISSING_KEY .. key
      end
    else
      print("Deflang: " .. key .. " is missing for " .. Module.current_language)
      return Module.locale_data.en.MISSING_KEY .. key
    end
  else
    return text
  end
end

function Module.autofit_text(node, set_scale)
  if set_scale == nil then
    set_scale = 1
  end
  local text_metrics = gui.get_text_metrics_from_node(node)
  local scale = math.min(1, gui.get_size(node).x / text_metrics.width) * set_scale
  gui.set_scale(node, vmath.vector3(scale, scale, scale))
end

function Module.set_text(target, key, scale)
  if Module.initilized == false then
    print("Deflang: You should init Deflang with Deflang.init() in your script's init!")
    print("Deflang: Check the Deflang example for the Deflang_helper.lua usage")
  end

  if is_gui_context() then
    if key == nil then -- set text based on current text of label
      local node_text_key = gui.get_text(target)
      gui.set_text(target, Module.get_text(node_text_key))
    else -- set text based on passed key value
      gui.set_text(target, Module.get_text(key))
    end
    Module.autofit_text(target, scale)
  else
    if key == nil then
      print("Deflang: You must always pass a key when setting GO label text as there is currently no label.get_text")
      label.set_text(target, "YOU MUST SET WITH A KEY!")
    else
      label.set_text(target, Module.get_text(key))
    end
  end
end

return Module
