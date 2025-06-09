local encoding = require('jproperties.encoding')
local syntax = require('jproperties.syntax')
local commands = require('jproperties.commands')

local M = {}

function M.setup()
  -- 设置语法高亮
  syntax.setup()

  -- 文件类型自动命令
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = '*.jproperties',
    callback = function(args)
      M.process_file(args.buf)
    end
  })

  -- 保存前编码转义
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.jproperties',
    callback = function(args)
      M.prepare_save(args.buf)
    end
  })

  -- 保存后恢复可读内容
  vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = '*.jproperties',
    callback = function(args)
      M.post_save(args.buf)
    end
  })

  -- 注册自定义命令
  commands.setup()
end

function M.process_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
  if not ok or not lines then return end

  local content = table.concat(lines, '\n')
  local processed = encoding.process_encoding(content)

  if processed ~= content then
    local new_lines = vim.split(processed, '\n')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    -- 合并到同一undo块
    pcall(vim.cmd, "undojoin")
  end

  vim.bo[bufnr].fileencoding = 'utf-8'
  vim.bo[bufnr].buftype = ''
end

function M.prepare_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, -1, false)
  if not ok or not lines then return end

  local content = table.concat(lines, '\n')
  local prepared = encoding.prepare_for_save(content)

  if prepared ~= content then
    local new_lines = vim.split(prepared, '\n')
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    pcall(vim.cmd, "undojoin")
  end
end

function M.post_save(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- 保存后恢复可读内容
  M.process_file(bufnr)
end

return M
