local mod = get_mod("Show Careers on Equipped Items")

return {
	name = "Show Careers on Equipped Items",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id = "career_display_mode",
				type = "dropdown",
				default_value = "portraits",
				options = {
					{text="portraits", value="portraits"},
					{text="names", value="names"}
				}
			}
		}
	}
}
