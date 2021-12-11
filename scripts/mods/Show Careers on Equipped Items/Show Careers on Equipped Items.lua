local mod = get_mod("Show Careers on Equipped Items")

local DEFAULT_START_LAYER = 994

-- readable names plus their profile index, easier to have here than retrieve from source, fingers crossed they don't change for no reason
CareerNameMappings = {
	dr_ranger = {name = "Ranger Veteran", index = 3},
	es_knight = {name = "Foot Knight", index = 5},
	we_waywatcher = {name = "Waystalker", index = 4},
	es_mercenary = {name = "Mercenary", index = 5},
	we_maidenguard = {name = "Handmaiden", index = 4},
	dr_slayer = {name = "Slayer", index = 3},
	wh_captain = {name = "Witch Hunter Captain", index = 1},
	bw_adept = {name = "Battle Wizard", index = 2},
	wh_zealot = {name = "Zealot", index = 1},
	es_huntsman = {name = "Huntsman", index = 5},
	dr_ironbreaker = {name = "Ironbreaker", index = 3},
	we_shade = {name = "Shade", index = 4},
	bw_unchained = {name = "Unchained", index = 2},
	bw_scholar = {name = "Pyromancer", index = 2},
    	wh_bountyhunter = {name = "Bounty Hunter", index = 1},
    	es_questingknight = {name = "Grail Knight", index = 5},
	we_thornsister = {name = "Sister of the Thorn", index = 4},
	dr_engineer = {name = "Outcast Engineer", index = 3},
	wh_priest = {name = "Warrior Priest of Sigmar", index = 1},
}

local function get_career_names(backend_id)
    local backend_items = Managers.backend:get_interface("items")
    local careers = backend_items:equipped_by(backend_id)
    return careers
end

local function map_career_display_names(career_names)
    local display_names = {}
    for key, value in pairs(career_names) do
        table.insert(display_names, CareerNameMappings[value].name)
    end

    return display_names
end

UITooltipPasses.equipped_on_careers = {
    -- frames giving me trouble, skip em for now
    setup_data = function()
        local frame_name = "default"
		local frame_settings = UIPlayerPortraitFrameSettings[frame_name]
        local data = {
            default_icon = "icons_placeholder",
			frame_name = frame_name,
            text_pass_data = {
                text_id = "text"
            },
            text_size = {},
            content = {
                icon = "icons_placeholder",
				frame = frame_settings.texture
            },
            style = {
                text = {
                    vertical_alignment = "center",
                    name = "description",
                    localize = false,
                    word_wrap = true,
                    font_size = 16,
                    horizontal_alignment = "left",
                    font_type = "hell_shark",
                    text_color = Colors.get_color_table_with_alpha("font_default", 255),
                },
                frame = {
                    color = {
                        255,
                        255,
                        255,
                        255
                    },
                    offset = {
                        0,
                        0,
                        1
                    }
                },
                icon = {
                    color = {
                        255,
                        255,
                        255,
                        255
                    },
                    offset = {
                        0,
                        0,
                        2
                    }
                },
            },
            icon_pass_data = {},
            icon_pass_definition = {
                texture_id = "icon",
                style_id = "icon"
            },
            icon_size = {
                40,
                40
            },
            frame_pass_data = {},
			frame_pass_definition = {
				texture_id = "frame",
				style_id = "frame"
			},
			frame_size = {
				40,
				40
			},
        }

        return data
    end,
    draw = function (data, draw, draw_downwards, ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt, ui_style_global, item)
        local alpha_multiplier = pass_data.alpha_multiplier
        local alpha = 240 * alpha_multiplier
        local start_layer = pass_data.start_layer or DEFAULT_START_LAYER
        local frame_margin = data.frame_margin or 0
        local style = data.style
        local content = data.content
        local backend_id = item.backend_id
        local bottom_spacing = 2
        local total_height = 0

        local icon_style = data.style.icon
        local icon_size = data.icon_size
        local icon_pass_data = data.icon_pass_data
        local icon_pass_definition = data.icon_pass_definition

        local frame_size = data.frame_size
		local frame_pass_data = data.frame_pass_data
		local frame_pass_definition = data.frame_pass_definition
		local frame_content = data.content
		local frame_style = data.style.frame

        -- format for retrieving portraits
        local career_names = get_career_names(backend_id)

        if mod:is_enabled() and #career_names > 0 then
            content.text = "Equipped On:\n"
            local position_x = position[1]
            local position_y = position[2]
            local position_z = position[3]
            position[3] = start_layer + 5

            local text_style = style.text
            local text_pass_data = data.text_pass_data
            local text_size = data.text_size
            text_size[1] = size[1] - frame_margin * 2
            text_size[2] = 0
            local text_height = UIUtils.get_text_height(ui_renderer, text_size, text_style, content.text, ui_style_global)
            text_size[2] = text_height

            -- move to a 2nd row after 8 icons, based on tooltip width on my display, could break based on resolution?
            local icons_per_row = 8
            local icons_height = icon_size[1] * math.ceil(#career_names / icons_per_row)

            if draw then
                position[1] = position_x + frame_margin
                position[2] = position_y - 10

                if mod:get("career_display_mode") == "portraits" then
                    -- draw header text then move down 50px to draw icons
                    UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
                    position[2] = position[2] - 50

                    for index, value in pairs(career_names) do
                        -- use backend career name to ultimately get career profile texture
                        local profile_settings = SPProfiles[CareerNameMappings[value].index] 
                        local careers = profile_settings.careers
                        local career_settings = careers[career_index_from_name(CareerNameMappings[value].index, value)]
                        local portrait_image = career_settings.portrait_image
        
                        content.icon = portrait_image
                        UIPasses.texture.draw(ui_renderer, icon_pass_data, ui_scenegraph, icon_pass_definition, icon_style, content, position, icon_size, input_service, dt)
    
                        -- move right after each icon, drop to a new row and reset x coord after icons_per_row value, 5px margin on everything
                        position[1] = position[1] + icon_size[1] + 5
                        
                        if (index % icons_per_row == 0) then
                            position[1] = position_x + frame_margin
                            position[2] = position[2] - icon_size[2] -5
                        end
                    end

                    total_height = text_height + icons_height + bottom_spacing

                elseif mod:get("career_display_mode") == "names" then
                    -- format career names for text display
                    local career_display_names = map_career_display_names(career_names)
                    content.text = "Equipped On:\n" .. table.concat(career_display_names, ", ")

                    text_height = UIUtils.get_text_height(ui_renderer, text_size, text_style, content.text, ui_style_global)
                    text_size[2] = text_height
                    position[2] = position[2] - text_height + 25

                    UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)

                    total_height = text_height + bottom_spacing
                end
            end

            position[1] = position_x
            position[2] = position_y
            position[3] = position_z

            return total_height
        else
            return 0
        end
    end
}

mod:hook(UIPasses.item_tooltip, "init", function(func, pass_definition, ui_content, ui_style, style_global)
    local pass_data = func(pass_definition, ui_content, ui_style, style_global)

    local index_of_insertion = nil
    for i, pass in ipairs(pass_data.passes) do
        if pass.draw == UITooltipPasses.traits.draw then
            index_of_insertion = i
            break
        end
    end
    if index_of_insertion then
        table.insert(pass_data.passes, index_of_insertion + 1, {
            data = UITooltipPasses.equipped_on_careers.setup_data(),
            draw = UITooltipPasses.equipped_on_careers.draw
        })
    end

    return pass_data
end)
