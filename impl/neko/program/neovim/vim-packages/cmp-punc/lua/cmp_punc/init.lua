local cmp = require('cmp')

local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_keyword_pattern = function()
  return '\\%([\\.,\\\\]\\)*'
end

source.get_trigger_characters = function()
    return { '.', ',', '\\' }
end

source._mapping = {
    ['.'] = '。',
    [','] = '，',
    ['\\'] = '、'
}

source.complete = function(self, request, callback)
    local input = string.sub(request.context.cursor_before_line, request.offset)
    local text = self._mapping[input]
    if text == nil then
        callback()
    else
        callback({{ label = text, filterText = input, insertText = text }})
    end
end

return source
