local M = {}
local encoding = require('jproperties.encoding')

local function get_display_mode(buf)
  return vim.b[buf].jproperties_display_mode or 'escaped'
end

local function set_display_mode(buf, mode)
  vim.b[buf].jproperties_display_mode = mode
end

function M.setup()
  -- 切换编码显示模式
  vim.api.nvim_create_user_command('JPropertiesToggleEncoding', function(opts)
    local buf = vim.api.nvim_get_current_buf()
    local display_mode = get_display_mode(buf)

    if display_mode == 'escaped' then
      set_display_mode(buf, 'raw')
      vim.notify('显示原始转义序列', vim.log.levels.INFO)
    else
      set_display_mode(buf, 'escaped')
      vim.notify('显示中文', vim.log.levels.INFO)
    end

    -- 重新处理文件
    local ok, err = pcall(require('jproperties').process_file, buf)
    if not ok then
      vim.notify('处理文件失败: ' .. tostring(err), vim.log.levels.ERROR)
    end
  end, {})

  -- 手动转换为中文
  vim.api.nvim_create_user_command('JPropertiesConvertToChinese', function(opts)
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if not lines or #lines == 0 then
      vim.notify('缓冲区为空', vim.log.levels.WARN)
      return
    end

    local content = table.concat(lines, '\n')
    local ok, converted = pcall(encoding.unescape_unicode, content)
    if not ok then
      vim.notify('转换失败: ' .. tostring(converted), vim.log.levels.ERROR)
      return
    end

    local new_lines = vim.split(converted, '\n', { plain = true })
    if #new_lines > 0 then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
      vim.notify('已转换为中文显示', vim.log.levels.INFO)
    end
  end, {})
end

return M
