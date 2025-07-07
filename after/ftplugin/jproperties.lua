-- 仅在 jproperties 文件类型下设置
vim.bo.commentstring = '# %s'

-- Set default value if not set
vim.b.JPropertiesDisable = false

-- 保存后自动恢复可读内容
vim.api.nvim_create_autocmd('BufWritePost', {
  buffer = 0,
  group = vim.api.nvim_create_augroup('JPropertiesBufWritePost', { clear = false }),
  callback = function()
    if vim.b.JPropertiesDisable then return end
    require('jproperties').post_save(0)
  end,
  desc = 'jproperties: 恢复可读内容'
})

-- 本地键映射
vim.keymap.set('n', '<leader>eu', ':JPropertiesToggleEncoding<CR>',
  { buffer = true, desc = 'Toggle encoding display' })
vim.keymap.set('n', '<leader>ec', ':JPropertiesConvertToChinese<CR>',
  { buffer = true, desc = 'Convert escapes to Chinese' })
