require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		-- Disable "format_on_save lsp_fallback" for languages that don't
		-- have a well standardized coding style. You can add additional
		-- languages here or re-enable it for the disabled ones.
		local disable_filetypes = { c = true, cpp = true }
		return {
			timeout_ms = 2500,
			lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
		}
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		-- Conform can also run multiple formatters sequentially
		-- javascript = { "prettierd", "prettier" },
		--
		-- You can use a sub-list to tell conform to run *until* a formatter
		-- is found.
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		yml = { "prettierd" },
		prisma = { "prettierd" },
		astro = { "prettierd" },
	},
})
