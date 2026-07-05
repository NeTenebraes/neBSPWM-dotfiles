-- =========================================================
-- init.lua
-- Main entry point with local package management.
-- =========================================================

vim.g.mapleader = " " -- Main leader.
vim.g.maplocalleader = "\\" -- Local leader.

-- =========================================================
-- MANAGEMENT COMMANDS
-- =========================================================

-- :PackUpdate -> Explicitly checks GitHub and updates your plugins
vim.api.nvim_create_user_command("PackUpdate", function()
  vim.notify("Checking for updates...", vim.log.levels.INFO)
  local ok, pack = pcall(require, "config.pack")
  if ok and type(pack.update) == "function" then
    pack.update()
  else
    vim.notify("Could not trigger update function from pack.lua.", vim.log.levels.ERROR)
  end
end, { desc = "Update/Sync plugins" })

-- :PackClean -> Deletes folders in 'start' not mentioned in pack.lua
vim.api.nvim_create_user_command("PackClean", function()
  local pack_config_file = vim.fn.stdpath("config") .. "/lua/config/pack.lua"
  local f = io.open(pack_config_file, "r")
  if not f then
    vim.notify("Could not open lua/config/pack.lua to scan plugins.", vim.log.levels.ERROR)
    return
  end
  local content = f:read("*all")
  f:close()

  local start_path = vim.fn.stdpath("config") .. "/pack/plugins/start"
  local handle = vim.uv.fs_scandir(start_path)
  
  if handle then
    local deleted_any = false
    while true do
      local name, type_name = vim.uv.fs_scandir_next(handle)
      if not name then break end
      
      if type_name == "directory" or type_name == "link" then
        local escaped_name = name:gsub("([^%w])", "%%%1")
        if not content:find(escaped_name) then
          local target_dir = start_path .. "/" .. name
          vim.fn.delete(target_dir, "rf")
          vim.notify("🗑️ Obsolete package deleted: " .. name, vim.log.levels.WARN)
          deleted_any = true
        end
      end
    end
    
    if not deleted_any then
      vim.notify("✨ Clean! All folders in 'start' match your pack.lua.", vim.log.levels.INFO)
    end
  else
    vim.notify("Directory pack/plugins/start not found.", vim.log.levels.ERROR)
  end
end, { desc = "Clean/Uninstall unused plugins" })

-- =========================================================
-- LOAD CONFIGURATION
-- =========================================================
require("config.options") -- Load options.
require("config.keymaps") -- Load keymaps.
require("config.pack")    -- Load plugins (Blazing fast startup).