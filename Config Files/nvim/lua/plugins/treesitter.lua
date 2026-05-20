-- =========================================================
-- Treesitter & Rainbow Delimiters: Configuración para Neovim 0.12+
-- Refactorizado para la nueva arquitectura (Reescritura total).
-- =========================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false, 
    config = function()
      local ts = require("nvim-treesitter")

      -- 1. Instalación de parsers
      ts.install({ 
          -- === BASE & CORE ===
          "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python",
          
          -- === LINUX, SHELL & ADMIN (Arch/BSPWM) ===
          "bash",          -- Scripts (.sh, bspwmrc, sxhkdrc)
          "fish",          -- Shell interactiva
          "awk",           -- Procesamiento de texto (polybar/scripts)
          "ssh_config",    -- Gestión de hosts y llaves
          "passwd",        -- Archivos de sistema /etc/passwd
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
          "json",          -- JSON normal y con comentarios
          "yaml",          -- Configuración de contenedores y servicios
          "toml",          -- Configs modernas (Alacritty/Starship)
          "scss",          -- Estilos avanzados
          "dockerfile",    -- Creación de entornos aislados
          "graphql",       -- Consultas de APIs modernas
          "xml",           -- Formatos de datos y configuraciones
          "svelte", 
          "typst", 
          "vue",
          "astro",

          -- === VERSION CONTROL (GITHUB WORKFLOW) ===
          "git_config",
          "git_rebase",
          "gitcommit",
          "gitignore",
          "gitattributes",
          "diff",
          
          "latex",
        })
      
      -- 2. Configuración de características NATIVAS (Highlight & Indent)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local buftype = vim.bo[args.buf].buftype
          local filetype = vim.bo[args.buf].filetype

          -- Ignorar buffers que no son archivos (terminales, prompts, etc.)
          if buftype ~= "" then return end

          -- FILTRO DE SEGURIDAD:
          -- Si el archivo es texto plano o hereda tipos sin código ejecutable, 
          -- dejamos que Neovim use su resaltado nativo tradicional y salimos sin invocar a Tree-sitter.
          local ignore_ft = { 
            "image", "scat", "snacks_picker_list", "snacks_picker_input", 
            "checkhealth", "help", "qf", "nofile",
            "text", "plain", "conf" -- Añadidos para proteger .txt y configs planas
          }
          if vim.tbl_contains(ignore_ft, filetype) then return end

          -- Intentamos obtener el parser de forma completamente segura.
          -- Usamos pcall sobre vim.treesitter.get_parser. Si el parser del lenguaje no existe
          -- o no está instalado, fallará silenciosamente (success = false) en vez de congelar la UI.
          local success, parser = pcall(vim.treesitter.get_parser, args.buf)
          if success and parser then
            vim.treesitter.start(args.buf)
            -- Activamos también la indentación aquí mismo
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- 3. Plegado (Folding) - Configuración global
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldenable = false
      vim.opt.foldlevel = 99

    end,
  }
}