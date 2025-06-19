local mod = game.mod_runtime[game.current_mod]

-- Main iuse function. Returns amount of charges consumed from item.
mod.iuse_function = function(who, item, pos)
	local items = gapi.get_avatar().all_items(gapi.get_avatar(), true)
	local ui = UiList.new()
	ui:title(item:display_name(1))
	ui:border_color(Color.c_dark_gray)
	ui:title_color(Color.i_black)
	ui:text("Replicate which item?")

	-- Iterate through items and add them to the list
	for i, item in ipairs(items) do
		ui:add(-1, item:display_name(1))
	end

	-- Get user's selection index
	local selected_index = ui:query()

	-- Get the selected item
	local selected_item = items[selected_index+1]

	if (selected_item == nil) then
		return 0
	end

	if (selected_item) then
		gapi.add_msg("The " .. item:display_name(1) .. " engulfs the " .. selected_item:display_name(1) .. ", memorizing it's molecular structure.  A few moments later, the gel pops off and quickly forms a replica.")
		item:convert(selected_item:get_type())
		return 1
	else
		gapi.add_msg("Nothing selected.")

		return 0
	end
end
