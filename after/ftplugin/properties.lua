vim.bo.commentstring = '# %s'
vim.bo.filetype = 'jproperties'

-- 设置保存后钩子
vim.api.nvim_create_autocmd('BufWritePost', {
  buffer = 0,
  callback = function()
    require('jproperties').post_save()
  end
})

-- 本地键映射
vim.keymap.set('n', '<leader>eu', ':JPropertiesToggleEncoding<CR>',
  { buffer = true, desc = 'Toggle encoding display' })
vim.keymap.set('n', '<leader>ec', ':JPropertiesConvertToChinese<CR>',
  { buffer = true, desc = 'Convert escapes to Chinese' })
