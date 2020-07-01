local mod = get_mod("Show Careers on Equipped Items")

local DEFAULT_START_LAYER = 994

CareerNameMappings = {
	dr_ranger = "Ranger Veteran",
	es_knight = "Foot Knight",
	we_waywatcher = "Waystalker",
	es_mercenary = "Mercenary",
	we_maidenguard = "Handmaiden",
	dr_slayer = "Slayer",
	wh_captain = "Witch Hunter Captain",
	bw_adept = "Battle Wizard",
	wh_zealot = "Zealot",
	es_huntsman = "Huntsman",
	dr_ironbreaker = "Ironbreaker",
	we_shade = "Shade",
	bw_unchained = "Unchained",
	bw_scholar = "Pyromancer",
    wh_bountyhunter = "Bounty Hunter",
    es_questingknight = "Grail Knight",
}

local function get_career_names(backend_id)
    local backend_items = Managers.backend:get_interface("items")
    local careers = backend_items:equipped_by(backend_id)
    local career_names = {}
    for key, value in pairs(careers) do
        table.insert(career_names, CareerNameMappings[value])
    end

    return career_names
end

UITooltipPasses.equipped_on_careers = {
    setup_data = function()
        local data = {
            text_pass_data = {
                text_id = "text"
            },
            text_size = {},
            content = {},
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
                }
            }
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

        local career_names = get_career_names(backend_id)

        if mod:is_enabled() and #career_names > 0 then
            content.text = "Equipped On:\n" .. table.concat(career_names, ", ")
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

            if draw then
                position[1] = position_x + frame_margin
                position[2] = position_y - text_height + 15
                text_style.text_color[1] = alpha

                UIPasses.text.draw(ui_renderer, text_pass_data, ui_scenegraph, pass_definition, text_style, content, position, text_size, input_service, dt, ui_style_global)
            end

            position[1] = position_x
            position[2] = position_y
            position[3] = position_z
            total_height = text_height + bottom_spacing

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
