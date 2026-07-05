local set = function (keybinds, command, mode, brackets)
    mode = mode or "n"
    brackets = brackets or {silent = true, noremap = true}
    vim.keymap.set(mode, keybinds, command, brackets)
end

set("<Leader>;", vim.cmd.Ex)
set("<C-p>", ":Telescope git_files<CR>")
set("<Leader>pf", ":Telescope find_files<CR>")
set("<Leader>ps", ":Telescope grep_string<CR>")


set("<Leader>su", ":StrudelUpdate<CR>")
set("<Leader>st", ":StrudelToggle<CR>")


for _, key in ipairs({ "d", "D", "c", "C", "x" }) do
  set(key, '"_' .. key)
  set('y' .. key, key)
end


-- Prompt templates: :Tpl <name> inserts library/_templates/prompt-<name>.md,
-- <Leader><Tab> jumps to the next <++> placeholder and replaces it.
vim.api.nvim_create_user_command("Tpl", function(opts)
  vim.cmd("r ~/veloking/library/_templates/prompt-" .. opts.args .. ".md")
end, {
  nargs = 1,
  complete = function()
    local names = {}
    for _, f in ipairs(vim.fn.glob("~/veloking/library/_templates/prompt-*.md", false, true)) do
      table.insert(names, (vim.fn.fnamemodify(f, ":t:r"):gsub("^prompt%-", "")))
    end
    return names
  end,
})
set("<Leader><Tab>", '/<++><CR>"_cf>')

-- <Leader><Leader><Tab>: insert the next numbered list item "<n>. [<++>] <++>"
-- below the cursor, continuing the current category's numbering (a blank line
-- ends the category, so the count restarts at 1 in a fresh one).
set("<Leader><Leader><Tab>", function()
  local lnum = vim.fn.line(".")
  local n = 0
  for i = lnum, 1, -1 do
    local line = vim.fn.getline(i)
    local num = line:match("^%s*(%d+)%.")
    if num then n = tonumber(num); break end
    if line:match("^%s*$") then break end
  end
  vim.fn.append(lnum, (n + 1) .. ". [<++>] <++>")
  vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
  local keys = vim.api.nvim_replace_termcodes('/<++><CR>"_cf>', true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end)

-- <Leader><Leader><Leader><Tab>: start a new category below the cursor — a
-- blank separator, a "<++>" label line, then a first "1. [<++>] <++>" item,
-- landing on the label placeholder.
set("<Leader><Leader><Leader><Tab>", function()
  local lnum = vim.fn.line(".")
  vim.fn.append(lnum, { "", "<++>", "1. [<++>] <++>" })
  vim.api.nvim_win_set_cursor(0, { lnum + 1, 0 })
  local keys = vim.api.nvim_replace_termcodes('/<++><CR>"_cf>', true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end)
