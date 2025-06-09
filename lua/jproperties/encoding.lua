local M = {}

-- 检测文件是否包含中文Unicode转义序列
function M.contains_chinese_escape(content)
  return content:find("\\u[4-9][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]") ~= nil
end

-- 将Unicode转义序列转换为UTF-8字符
function M.unescape_unicode(str)
  return str:gsub("\\u([0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])", function(hex)
    return utf8.char(tonumber(hex, 16))
  end)
end

-- 将UTF-8字符转换为Unicode转义序列
function M.escape_unicode(str)
  return str:gsub("([^\x20-\x7E])", function(char)
    local code = utf8.codepoint(char, 1)
    -- 仅转换非ASCII字符
    return code > 127 and string.format("\\u%04x", code) or char
  end)
end

-- 智能编码检测与转换
function M.process_encoding(content)
  -- 检测是否已包含转义中文
  if M.contains_chinese_escape(content) then
    return M.unescape_unicode(content)
  end

  -- 尝试UTF-8解码
  local success, utf8_content = pcall(vim.iconv, content, "utf-8", "latin1")
  if success and utf8_content then
    return utf8_content
  end

  -- 回退到原始内容
  return content
end

-- 准备保存内容
function M.prepare_for_save(content)
  -- 转换非ASCII字符为Unicode转义序列
  local escaped = M.escape_unicode(content)

  -- 确保使用ISO-8859-1编码
  return vim.iconv(escaped, "latin1", "utf-8")
end

return M
