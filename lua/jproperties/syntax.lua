local M = {}

function M.setup()
  vim.cmd([[
    " 键名高亮，允许空格和多种分隔符
    syntax match jpropertiesKey /^\s*\zs[^=:#\s][^=:#]*\ze\s*[=:]/ nextgroup=jpropertiesDelimiter
    syntax match jpropertiesDelimiter /[=:]/ contained nextgroup=jpropertiesValue
    syntax match jpropertiesValue /.\+/ contained contains=jpropertiesEscape,jpropertiesChinese
    syntax match jpropertiesEscape /\\u[0-9a-fA-F]\{4}/ contained
    syntax match jpropertiesComment /^\s*[#!].*$/
    " 支持续行的注释
    syntax match jpropertiesComment /\\\_.\{-}\n\s*[#!].*$/ contains=jpropertiesComment

    highlight default link jpropertiesKey Identifier
    highlight default link jpropertiesDelimiter Delimiter
    highlight default link jpropertiesValue String
    highlight default link jpropertiesEscape SpecialChar
    highlight default link jpropertiesComment Comment
  ]])

  -- 高亮中文 Unicode 转义序列（\u4e00-\u9fff）
  vim.api.nvim_set_hl(0, "jpropertiesChinese", { fg = "#d19a66", bold = true })
  vim.cmd([[syntax match jpropertiesChinese /\\u[4-9a-fA-F][0-9a-fA-F]\{3}/ containedin=jpropertiesValue]])
end

return M
