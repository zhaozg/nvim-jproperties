local M = {}
local bit = require("bit")

-- 检测文件是否包含中文Unicode转义序列（如 \u4e00-\u9fff）
function M.contains_chinese_escape(content)
  -- 匹配 \u4e00-\u9fff 范围的转义
  return content:find("\\u[4-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]") ~= nil
end

-- 将Unicode转义序列（\uXXXX 或代理对）转换为UTF-8字符
function M.unescape_unicode(str)
  -- 先处理代理对（高低代理项，超出BMP）
  str = str:gsub("\\u(d[89ab][0-9a-fA-F][0-9a-fA-F])\\u(d[cdef][0-9a-fA-F][0-9a-fA-F])", function(high, low)
    local hi = tonumber(high, 16)
    local lo = tonumber(low, 16)
    local codepoint = 0x10000 + bit.lshift(hi - 0xD800, 10) + (lo - 0xDC00)
    -- 转为UTF-8
    local b1 = 0xF0 + bit.rshift(codepoint, 18)
    local b2 = 0x80 + bit.band(bit.rshift(codepoint, 12), 0x3F)
    local b3 = 0x80 + bit.band(bit.rshift(codepoint, 6), 0x3F)
    local b4 = 0x80 + bit.band(codepoint, 0x3F)
    return string.char(b1, b2, b3, b4)
  end)
  -- 普通BMP内的字符
  return (str:gsub("\\u(%x%x%x%x)", function(hex)
    local n = tonumber(hex, 16)
    if n < 0x80 then
      return string.char(n)
    elseif n < 0x800 then
      return string.char(
        0xC0 + bit.rshift(n, 6),
        0x80 + bit.band(n, 0x3F)
      )
    elseif n < 0x10000 then
      return string.char(
        0xE0 + bit.rshift(n, 12),
        0x80 + bit.band(bit.rshift(n, 6), 0x3F),
        0x80 + bit.band(n, 0x3F)
      )
    else
      -- 超出BMP平面（如emoji），LuaJIT支持4字节UTF-8
      return "?"
    end
  end))
end

-- 将UTF-8字符转换为Unicode转义序列（仅非ASCII部分）
function M.escape_unicode(str)
  local out = {}
  local i = 1
  local len = #str
  while i <= len do
    local c = str:byte(i)
    local code
    if c < 0x80 then
      table.insert(out, string.char(c))
      i = i + 1
    elseif c < 0xE0 then
      local c2 = str:byte(i + 1)
      code = bit.lshift(c % 0x20, 6) + (c2 % 0x40)
      if code > 127 then
        table.insert(out, string.format("\\u%04x", code))
      else
        table.insert(out, utf8.char(code))
      end
      i = i + 2
    elseif c < 0xF0 then
      local c2, c3 = str:byte(i + 1, i + 2)
      code = bit.lshift(c % 0x10, 12) + bit.lshift(c2 % 0x40, 6) + (c3 % 0x40)
      if code > 127 then
        table.insert(out, string.format("\\u%04x", code))
      else
        table.insert(out, utf8.char(code))
      end
      i = i + 3
    elseif c < 0xF8 then
      -- 4字节UTF-8，超出BMP，转为?
      table.insert(out, "?")
      i = i + 4
    else
      table.insert(out, "?")
      i = i + 1
    end
  end
  return table.concat(out)
end

-- 智能编码检测与转换
function M.process_encoding(content)
  if M.contains_chinese_escape(content) then
    return M.unescape_unicode(content)
  end
  -- 尝试UTF-8解码
  return M.escape_unicode(content)
end

-- 准备保存内容（编码转义并转为latin1存盘）
function M.prepare_for_save(content)
  local escaped = M.escape_unicode(content)
  local ok, converted = pcall(vim.iconv, escaped, "latin1", "utf-8")
  if ok and converted then
    return converted
  else
    return escaped
  end
end

return M
