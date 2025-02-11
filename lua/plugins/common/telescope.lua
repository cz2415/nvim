return {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.2",
    tag = "0.1.8",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "BurntSushi/ripgrep",
        -- {
        --     "nvim-telescope/telescope-fzf-native.nvim",
        --     build = "make"
        -- }
    },
    config = function()
        require("telescope").setup {
            -- extensions = {
            --     fzf = {
            --         fuzzy = true, -- false will only do exact matching
            --         override_generic_sorter = true, -- override the generic sorter
            --         override_file_sorter = true, -- override the file sorter
            --         case_mode = "smart_case" -- or "ignore_case" or "respect_case" the default case_mode is "smart_case"
            --
            --         --sbtrkt	fuzzy-match	                Items that match sbtrkt
            --         --'wild	    exact-match (quoted)	    Items that include wild
            --         --^music	prefix-exact-match	        Items that start with music
            --         --.mp3$	    suffix-exact-match	        Items that end with .mp3
            --         --!fire	    inverse-exact-match	        Items that do not include fire
            --         --!^music	inverse-prefix-exact-match	Items that do not start with music
            --         --!.mp3$	inverse-suffix-exact-match	Items that do not end with .mp3
            --     }
            -- }
        }

        require("telescope").load_extension("projects")
        -- require("telescope").load_extension("fzf")
    end
}
