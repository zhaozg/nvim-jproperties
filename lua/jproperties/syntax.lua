local M = {}

function M.setup()
  vim.cmd([[
  syntax match jpropertiesKey /^\s*[^=:[:space:]]\+\s*[=:]\?/ nextgroup=jpropertiesDelimiter
  syntax match jpropertiesDelimiter /[=:]/ contained nextgroup=jpropertiesValue
  syntax match jpropertiesValue /.*$/ contained contains=jpropertiesEscape
  syntax match jpropertiesEscape /\\u[0-9a-fA-F]\{4}/ contained
  syntax match jpropertiesComment /^\s*[#!].*$/

  highlight default link jpropertiesKey Identifier
  highlight default link jpropertiesDelimiter Delimiter
  highlight default link jpropertiesValue String
  highlight default link jpropertiesEscape SpecialChar
  highlight default link jpropertiesComment Comment
  ]])

  -- 特殊高亮中文转义序列
  vim.api.nvim_set_hl(0, 'jpropertiesChinese', {fg = '#d19a66', bold = true})
  vim.cmd('syntax match jpropertiesChinese /\\u[4-9][0-9a-fA-F]\{3}/ containedin=jpropertiesValue')
end

return M
