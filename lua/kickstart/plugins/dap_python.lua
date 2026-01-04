-- lua/kickstart/plugins/dap_python.lua

return {
	-- nvim-dap-python config
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = {
			"mfussenegger/nvim-dap",
			{
				"jay-babu/mason-nvim-dap.nvim",
				opts = {
					ensure_installed = { "debugpy" },
					handlers = {}, -- Default handlers are usually fine
				},
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			local dap_python = require("dap-python")

			-- Setup nvim-dap-python
			-- This tries to find the debugpy executable.
			-- It's often good at auto-detecting from your virtual environment.
			-- If it fails, you might need to specify the exact path to your python executable
			-- e.g., dap_python.setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
			dap_python.setup()

			-- Define DAP configurations for Python
			-- This tells nvim-dap how to launch/attach to Python processes
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}", -- Debug the current file
					pythonPath = function()
						-- This is crucial for virtual environments!
						-- Tries to use the virtual environment detected by Mason/LSP
						-- Or resolve from a poetry/venv ./.venv path
						local venv = os.getenv("VIRTUAL_ENV")
						if venv then
							return venv .. "/bin/python"
						end
						-- Fallback to a common system python path if no venv is active
						return "/usr/bin/python3"
					end,
				},
				-- You can add more configurations here, e.g., for Django, Flask, pytest
				-- {
				--   type = 'python',
				--   request = 'attach',
				--   name = 'Attach to process',
				--   processId = require('dap.utils').pick_process,
				--   pythonPath = function()
				--     return os.getenv('VIRTUAL_ENV') .. '/bin/python' or '/usr/bin/python3'
				--   end,
				-- },
			}

			-- Optional: nvim-dap-virtual-text for inline variable display
			-- If you don't have this plugin installed, comment out or remove this line.
			-- pcall(require, 'nvim-dap-virtual-text') and require('nvim-dap-virtual-text').setup()

			-- Ensure DAP UI is set up and opens/closes correctly
			-- (You might already have this in kickstart.plugins.debug)
			if vim.fn.has("nvim-0.7") then -- Check if dapui is available from debug plugin
				dap.listeners.before.attach.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.launch.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.event_terminated.dapui_config = function()
					dapui.close()
				end
				dap.listeners.before.event_exited.dapui_config = function()
					dapui.close()
				end
			end
		end,
	},
}
