local encoding = require('jproperties.encoding')
local syntax = require('jproperties.syntax')
local commands = require('jproperties.commands')

local M = {}

function M.setup()
  -- 设置文件类型自动命令
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = '*.properties',
    callback = function(args)
      M.process_file(args.buf)
    end
  })

  -- 设置保存前处理
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.properties',
    callback = function(args)
      M.prepare_save(args.buf)
    end
  })

  -- 设置语法高亮
  syntax.setup()

  -- 注册自定义命令
  commands.setup()
end

function M.process_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- 获取文件内容
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')

  -- 处理编码
  local processed = encoding.process_encoding(content)

  -- 更新缓冲区
  if processed ~= content then
    local new_lines = vim.split(processed, '\n')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  end

  -- 设置文件选项
  vim.bo[bufnr].fileencoding = 'utf-8'
  vim.bo[bufnr].buftype = ''
end

function M.prepare_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- 获取当前内容
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, '\n')

  -- 准备保存
  local prepared = encoding.prepare_for_save(content)

  -- 更新缓冲区（临时）
  if prepared ~= content then
    local new_lines = vim.split(prepared, '\n')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  end
end

-- 保存后恢复可读内容
function M.post_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.process_file(bufnr)
end

return M
