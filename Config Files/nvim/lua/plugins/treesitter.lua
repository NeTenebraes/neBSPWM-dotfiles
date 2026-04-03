-- =========================================================
-- Treesitter & Rainbow Delimiters: Resaltado Sintáctico Pro.
-- Proporciona un análisis profundo del código para un coloreado
-- inteligente y estructural. Incluye soporte para el ecosistema 
-- de C, desarrollo Web y coloreado de paréntesis anidados (Rainbow).
-- Configurado con prioridad alta para Neovim 0.11 en Arch Linux.
-- =========================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", 
    build = ":TSUpdate",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim",
    },
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { 
          -- === BASE & CORE ===
          "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python",
          
          -- === LINUX, SHELL & ADMIN (Arch/BSPWM) ===
          "bash",          -- Scripts (.sh, bspwmrc, sxhkdrc)
          "fish",          -- Shell interactiva
          "awk",           -- Procesamiento de texto (polybar/scripts)
          "ssh_config",    -- Gestión de hosts y llaves
          "passwd",        -- Archivos de sistema /etc/passwd
          "git_config",    -- Configuración de git
          "git_rebase",    -- Interactividad en git
          "diff",          -- Comparación de archivos y parches .pacnew
          "tmux",          -- Configuración de multiplexores
          "udev",          -- Reglas de dispositivos en Linux
          "make",          -- Automatización de compilación
          "cmake",         -- Generación de proyectos C/C++

          -- === CIBERSEGURIDAD, REVERSING & BAJO NIVEL ===
          "c", "cpp", "c_sharp", "objc", "cuda", -- Ecosistema C completo
          "go",            -- Herramientas modernas (Gobuster, Nuclei)
          "rust",          -- Herramientas de alto rendimiento y exploit dev
          "ruby",          -- Scripts de Metasploit
          "asm",           -- Ensamblador (análisis de shellcodes)
          "disassembly",   -- Resaltado para salidas de debuggers/objdump
          "php",           -- Auditoría Web (Vulnerabilidades RCE/SQLi)
          "http",          -- Análisis de peticiones Raw
          "regex",         -- Creación de filtros y reglas de búsqueda
          "dot",           -- Grafos de flujo de red o ejecución
          "sql",           -- Inyecciones y auditoría de bases de datos

          -- === DESARROLLO WEB & DATOS ===
          "html", "css", "javascript", "typescript", "tsx", 
          "json", "jsonc", -- JSON normal y con comentarios
          "yaml",          -- Configuración de contenedores y servicios
          "toml",          -- Configs modernas (Alacritty/Starship)
          "scss",          -- Estilos avanzados
          "dockerfile",    -- Creación de entornos aislados
          "graphql",       -- Consultas de APIs modernas
          "xml",           -- Formatos de datos y configuraciones
        },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true, 
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true 
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      })

      -- === CONFIGURACIÓN DE RAINBOW DELIMITERS ===
      local rb = require('rainbow-delimiters')
      
      -- 1. Configuración lógica del plugin
      vim.g.rainbow_delimiters = {
        strategy = {
          [''] = rb.strategy['global'],
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        priority = {
          [''] = 110, -- Prioridad mayor a Treesitter para evitar solapamientos
        },
      }

      -- 3. Autocomando de seguridad para Neovim 0.11
      -- Fuerza la activación si el buffer ya está abierto o al entrar
      vim.api.nvim_create_autocmd({ "BufReadPost", "Syntax" }, {
        callback = function(args)
          if vim.treesitter.highlighter.active[args.buf] then
            rb.enable(args.buf)
          end
        end,
      })
      
      -- =========================================================
      -- ===          CONFIGURACIÓN DE PLEGADO (FOLDING)       ===
      -- Esto permite colapsar bloques de código (if, for, funciones)
      -- de forma inteligente usando el parser de Treesitter.
      -- =========================================================
      vim.opt.foldmethod = "expr"
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldenable = false -- Evita que el código se abra plegado por defecto
      vim.opt.foldlevel  = 99    -- Abre todos los niveles de plegado inicialmente

    end,
  }
}