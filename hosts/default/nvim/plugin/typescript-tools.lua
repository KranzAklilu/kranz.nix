vim.keymap.set("n", "<leader>ti", "<cmd>TSToolsAddMissingImports<CR>", { desc = "Typescript add missing imports" })
vim.keymap.set("n", "<leader>tr", "<cmd>TSToolsRemoveUnused<CR>", { desc = "Typescript remove unused" })

return require("typescript-tools").setup({
	settings = {
		on_attach = function(client)
			-- Disable hover for typescript-tools
			client.server_capabilities.hoverProvider = false
		end,
		tsserver_file_preferences = {
			includeInlayParameterNameHints = "all",
			includeCompletionsForModuleExports = true,
			quotePreference = "auto",
		},
		tsserver_format_options = {
			allowIncompleteCompletions = false,
			allowRenameOfImportPath = false,
		},
	},
})
