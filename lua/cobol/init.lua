local M = {}

-- 🧱 Insert COBOL boilerplate using filename as PROGRAM-ID
function M.insert_cobol_boilerplate()
  local filename = vim.fn.expand '%:t:r'
  local program_name = filename:upper()

  local lines = {
    '       IDENTIFICATION DIVISION.',
    '       PROGRAM-ID.    ' .. program_name .. '.',
    '',
    '       ENVIRONMENT DIVISION.',
    '       INPUT-OUTPUT SECTION.',
    '',
    '       DATA DIVISION.',
    '       WORKING-STORAGE SECTION.',
    '',
    '       PROCEDURE DIVISION.',
    '      * Your code goes here',
    '           STOP RUN.',
    '',
    '       END PROGRAM ' .. program_name .. '.',
  }

  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
end

-- 🧑‍💻 Manual command that prompts for PROGRAM-ID
vim.api.nvim_create_user_command('CobbBoiler', function()
  local program_name = vim.fn.input 'Program-ID: '
  if program_name == '' then
    vim.notify('No Program-ID provided. Aborting.', vim.log.levels.WARN)
    return
  end

  local lines = {
    '       IDENTIFICATION DIVISION.',
    '       PROGRAM-ID.    ' .. program_name .. '.',
    '',
    '       ENVIRONMENT DIVISION.',
    '       INPUT-OUTPUT SECTION.',
    '',
    '       DATA DIVISION.',
    '       WORKING-STORAGE SECTION.',
    '',
    '       PROCEDURE DIVISION.',
    '      * Your code goes here',
    '           STOP RUN.',
    '',
    '       END PROGRAM ' .. program_name .. '.',
  }

  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
end, {})

-- 🧩 Auto-run boilerplate on new COBOL files
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = { '*.cob', '*.cbl', '*.COB', '*.CBL' },
  callback = M.insert_cobol_boilerplate,
})

-- 🛠 COBOL formatting and visual settings
local cobol_group = vim.api.nvim_create_augroup('CobolSettings', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = cobol_group,
  pattern = 'cobol',
  callback = function()
    vim.bo.tabstop = 3
    vim.bo.shiftwidth = 3
    vim.bo.softtabstop = 3
    vim.bo.expandtab = true
    vim.bo.autoindent = true
    vim.bo.smartindent = true
    vim.bo.cindent = false

    vim.opt.colorcolumn = '7,11,72'

    vim.schedule(function()
      vim.cmd [[highlight ColorColumn ctermbg=233 guibg=#12121d]]
    end)
  end,
  desc = 'Set COBOL-specific formatting and column guides',
})

-- 🧹 Clear colorcolumn for non-COBOL files
vim.api.nvim_create_autocmd('FileType', {
  group = cobol_group,
  pattern = '*',
  callback = function(args)
    if vim.bo[args.buf].filetype ~= 'cobol' then
      vim.opt.colorcolumn = ''
    end
  end,
  desc = 'Clear colorcolumn in non-COBOL files',
})

-- Fix indentation issues  NOTE: Doesn't work.
--[[
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = cobol_group,
  pattern = { '*.cob', '*.cbl', '*.COB', '*.CBL' },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local line_nr = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(bufnr, line_nr - 1, line_nr, false)[1]

    -- Skip empty lines or comments
    if not line or line:match '^%s*$' or line:match '^%s*[*]' then
      return
    end

    -- Statements that should start at column 8
    local keywords = { 'ACCEPT', 'DISPLAY', 'MOVE', 'PERFORM', 'IF', 'EVALUATE', 'CALL', 'STOP', 'GO', 'ADD', 'SUBTRACT' }

    for _, kw in ipairs(keywords) do
      if line:match('^%s*' .. kw) then
        -- Align to column 12
        local trimmed = vim.trim(line)
        local padded = string.rep(' ', 11) .. trimmed
        vim.api.nvim_buf_set_lines(bufnr, line_nr - 1, line_nr, false, { padded })
        break
      end
    end
  end,
  desc = 'Align COBOL statements to column 8',
})
]]
return M
