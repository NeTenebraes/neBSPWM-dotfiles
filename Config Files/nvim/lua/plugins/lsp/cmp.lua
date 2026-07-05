local ok_cmp, cmp = pcall(require, "cmp")
if not ok_cmp then
  return
end

local ok_lspkind, lspkind = pcall(require, "lspkind")
if ok_lspkind then
  lspkind.init({
    mode = "symbol_text",
    preset = "default",
  })
end

cmp.setup({
  completion = {
    completeopt = "menu,menuone,noinsert",
  },

  window = {
    completion = cmp.config.window.bordered({
      max_height = 12,
      col_offset = 0,
      side_padding = 1,
    }),
    documentation = cmp.config.window.bordered(),
  },

  snippet = {
    expand = function(args)
      local ok_luasnip, luasnip = pcall(require, "luasnip")
      if ok_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },

  mapping = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),

  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = ok_lspkind and lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
      menu = {
        nvim_lsp = "[LSP]",
        path = "[Path]",
        buffer = "[Buf]",
        luasnip = "[Snip]",
      },
    }) or function(entry, vim_item)
      local menus = {
        nvim_lsp = "[LSP]",
        path = "[Path]",
        buffer = "[Buf]",
        luasnip = "[Snip]",
      }
      vim_item.menu = menus[entry.source.name] or ("[" .. entry.source.name .. "]")
      return vim_item
    end,
  },

  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "buffer" },
  }),
})