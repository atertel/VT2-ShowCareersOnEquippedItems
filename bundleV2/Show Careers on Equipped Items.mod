return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Show Careers on Equipped Items` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Show Careers on Equipped Items", {
			mod_script       = "scripts/mods/Show Careers on Equipped Items/Show Careers on Equipped Items",
			mod_data         = "scripts/mods/Show Careers on Equipped Items/Show Careers on Equipped Items_data",
			mod_localization = "scripts/mods/Show Careers on Equipped Items/Show Careers on Equipped Items_localization",
		})
	end,
	packages = {
		"resource_packages/Show Careers on Equipped Items/Show Careers on Equipped Items",
	},
}
