local M = {}
local encoding = require('jproperties.encoding')

function M.setup()
  -- 切换编码显示模式
  vim.api.nvim_create_user_command('JPropertiesToggleEncoding', function()
    local buf = vim.api.nvim_get_current_buf()
    local display_mode = vim.b.jproperties_display_mode or 'escaped'

    if display_mode == 'escaped' then
      -- 显示原始转义序列
      vim.b.jproperties_display_mode = 'raw'
      vim.notify('显示原始转义序列', vim.log.levels.INFO)
    else
      -- 显示中文
      vim.b.jproperties_display_mode = 'escaped'
      vim.notify('显示中文', vim.log.levels.INFO)
    end

    -- 重新处理文件
    require('jproperties').process_file(buf)
  end, {})

  -- 手动转换为中文
  vim.api.nvim_create_user_command('JPropertiesConvertToChinese', function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local content = table.concat(lines, '\n')

    -- 转换转义序列为中文
    local converted = encoding.unescape_unicode(content)

    -- 更新缓冲区
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(converted, '\n'))
    vim.notify('已转换为中文显示', vim.log.levels.INFO)
  end, {})
end

return M
