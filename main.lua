local mod = game.mod_runtime[game.current_mod]
mod.uc_balance = mod.uc_balance or 10000

------------------------
-- CONVENIENCE FUNCTIONS
------------------------
local function random_point_near(centre, r, min_r)
    min_r = min_r or 0  -- default minimum distance is 0 if not provided

    local function distance(a, b)
        local dx = a.x - b.x
        local dy = a.y - b.y
        return math.sqrt(dx * dx + dy * dy)
    end

    local point
    repeat
        point = Tripoint.new(
            centre.x + gapi.rng(-r, r),
            centre.y + gapi.rng(-r, r),
            centre.z
        )
    until distance(point, centre) >= min_r

    return point
end

-- Accept either a string or an existing MtypeId
local function to_mtype(id)
    return (type(id) == "string") and MtypeId.new(id) or id
end

-- Convenience function
local function random_from(array)
    local n = #array
    if n == 0 then
        gapi.add_msg(MsgType.warning, "random_from(): empty array!")
        return nil
    end

    -- gapi.rng yields an integer in [1, n]
    local index = gapi.rng(1, n)
    local value = array[index]

    return value  -- return the element itself, not the index
end

-- Convenience function to convert turns to a TimeDuration
mod.from_turns = function(n) return TimeDuration.new().from_turns(n) end

------------------------
-- SHOP VARIABLES
------------------------

-- start with your built‑in categories...
local shop_categories = {
	Melee = {
    { name = "hammer",  itype = ItypeId.new("hammer"),  cost = 30 },
    { name = "baseball bat",   itype = ItypeId.new("baseball_bat"),   cost = 10 },
    { name = "mace",  itype = ItypeId.new("mace"),  cost = 50 },
    { name = "morningstar",  itype = ItypeId.new("morningstar"),  cost = 50 },
    { name = "sledge hammer",  itype = ItypeId.new("hammer_sledge"),  cost = 50 },
    { name = "hatchet",  itype = ItypeId.new("hatchet"),  cost = 50 },
    { name = "combat knife",  itype = ItypeId.new("knife_combat"),  cost = 50 },
    { name = "carbon fiber knife",  itype = ItypeId.new("knife_carbon"),  cost = 50 },
    { name = "rapier",  itype = ItypeId.new("rapier"),  cost = 50 },
    { name = "machete",  itype = ItypeId.new("machete"),  cost = 50 },
    { name = "katana",  itype = ItypeId.new("katana"),  cost = 50 },
    { name = "pike",  itype = ItypeId.new("pike"),  cost = 50 },
    { name = "carbon fiber sword",  itype = ItypeId.new("sword_carbon"),  cost = 50 },
    { name = "carbon fiber spear",  itype = ItypeId.new("spear_carbon"),  cost = 50 },
    { name = "knife spear",  itype = ItypeId.new("spear_knife"),  cost = 50 },
    { name = "chainsaw",  itype = ItypeId.new("chainsaw_off"),  cost = 50 },
  },
	Ranged = {
    { name = "crossbow",  itype = ItypeId.new("crossbow"),  cost = 30 },
    { name = "Marlin 39A",   itype = ItypeId.new("marlin_9a"),   cost = 10 },
    { name = "H&K MP5A4",  itype = ItypeId.new("hk_mp5"),  cost = 50 },
    { name = "Taurus Spectrum",  itype = ItypeId.new("taurus_spectrum"),  cost = 50 },
    { name = "Desert Eagle .44",  itype = ItypeId.new("hatchet"),  cost = 50 },
    { name = "M1911",  itype = ItypeId.new("m1911"),  cost = 50 },
    { name = "H&K UMP45",  itype = ItypeId.new("hk_ump45"),  cost = 50 },
    { name = "FN P90",  itype = ItypeId.new("fn_p90"),  cost = 50 },
    { name = "Remington 870 Wingmaster",  itype = ItypeId.new("remington_870"),  cost = 50 },
    { name = "Browning BLR",  itype = ItypeId.new("browning_blr"),  cost = 50 },
    { name = "AKM",  itype = ItypeId.new("ak47"),  cost = 50 },
    { name = "M4A1",  itype = ItypeId.new("m4a1"),  cost = 50 },
    { name = "Savage 111F",  itype = ItypeId.new("savage_111f"),  cost = 50 },
    { name = "HK G3",  itype = ItypeId.new("hk_g3"),  cost = 50 },
    { name = "HK G80",  itype = ItypeId.new("hk_g80"),  cost = 50 },
    { name = "Plasma Rifle",  itype = ItypeId.new("plasma_rifle"),  cost = 50 },
  },
  Ammo = {
    { name = "Crossbow Bolt", itype = ItypeId.new("bolt_steel"), cost = 100 },
    { name = ".22 LR", itype = ItypeId.new("22_lr"), cost = 100 },
    { name = "9mm", itype = ItypeId.new("9mm"), cost = 100 },
    { name = "38 Special", itype = ItypeId.new("38_special"), cost = 100 },
    { name = "44 Magnum", itype = ItypeId.new("44magnum"), cost = 100 },
    { name = "45 ACP", itype = ItypeId.new("45_acp"), cost = 100 },
    { name = "Shotgun Shells", itype = ItypeId.new("shot_00"), cost = 100 },
    { name = "Shotgun Slugs", itype = ItypeId.new("shot_slug"), cost = 100 },
    { name = ".30-06", itype = ItypeId.new("3006"), cost = 100 },
    { name = "7.62 M87", itype = ItypeId.new("762_m87"), cost = 100 },
    { name = "5.56", itype = ItypeId.new("556"), cost = 100 },
    { name = "7.62 NATO", itype = ItypeId.new("762_51"), cost = 100 },
    { name = "12mm", itype = ItypeId.new("12mm"), cost = 100 },
    { name = "Plasma", itype = ItypeId.new("plasma"), cost = 100 },
  },
	Crafting = {
    { name = "Rags",  itype = ItypeId.new("rag"),  cost = 30 },
    { name = "Fur Pelts",   itype = ItypeId.new("fur"),   cost = 10 },
    { name = "Leather Patches",  itype = ItypeId.new("leather"),  cost = 50 },
    { name = "Superglue",  itype = ItypeId.new("superglue"),  cost = 50 },
    { name = "String",  itype = ItypeId.new("string_36"),  cost = 50 },
    { name = "Chain",  itype = ItypeId.new("chain"),  cost = 50 },
    { name = "Procesor",  itype = ItypeId.new("processor"),  cost = 50 },
    { name = "RAM",  itype = ItypeId.new("RAM"),  cost = 50 },
    { name = "Power Supply",  itype = ItypeId.new("power_supply"),  cost = 50 },
    { name = "Motor",  itype = ItypeId.new("motor"),  cost = 50 },
    { name = "Hose",  itype = ItypeId.new("hose"),  cost = 50 },
    { name = "Pot",  itype = ItypeId.new("pot"),  cost = 50 },
    { name = "2x4",  itype = ItypeId.new("2x4"),  cost = 50 },
    { name = "Nail",  itype = ItypeId.new("nail"),  cost = 50 },
    { name = "Gasoline",  itype = ItypeId.new("gasoline"),  cost = 50 },
  },
	Tools = {
    { name = "rags x50",  itype = ItypeId.new("hammer"),  cost = 30 },
    { name = "fur pelts x50",   itype = ItypeId.new("baseball_bat"),   cost = 10 },
    { name = "leather patches x50",  itype = ItypeId.new("mace"),  cost = 50 },
    { name = "superglue x50",  itype = ItypeId.new("sledge_hammer"),  cost = 50 },
    { name = "Desert Eagle .44",  itype = ItypeId.new("hatchet"),  cost = 50 },
    { name = "M1911",  itype = ItypeId.new("combat_knife"),  cost = 50 },
    { name = "H&K UMP45",  itype = ItypeId.new("rapier"),  cost = 50 },
    { name = "FN P90",  itype = ItypeId.new("machete"),  cost = 50 },
    { name = "Remington 870 Wingmaster",  itype = ItypeId.new("katana"),  cost = 50 },
    { name = "Browning BLR",  itype = ItypeId.new("chainsaw"),  cost = 50 },
    { name = "AKM",  itype = ItypeId.new("pike"),  cost = 50 },
    { name = "M4A1",  itype = ItypeId.new("pike"),  cost = 50 },
  },
  Chemicals = {
    { name = "mutagenic serum", itype = ItypeId.new("iv_mutagen"), cost = 200 },
  }
}

-- finally expose `shop_categories` to your UI / purchase logic
mod.shop_categories = shop_categories

local flag_values = {
	UC_VALUE_1 = 1,
	UC_VALUE_2 = 2,
	UC_VALUE_4 = 4,
	UC_VALUE_8 = 8,
	UC_VALUE_16 = 16,
	UC_VALUE_32 = 32,
	UC_VALUE_64 = 64,
	UC_VALUE_128 = 128,
	UC_VALUE_256 = 256,
}


----------------------
-- SHOP FUNCTIONALITY
----------------------

-- Trade-in currency screen
mod.collect_currency_popup = function()
	local avatar = gapi.get_avatar()
	local items = avatar:all_items(true)
	local currency_items = {}

	-- Build list of valid currency items, checking for flags
	-- and their associated values
	for _, item in ipairs(items) do
		local value = 0
		for flag_name, multiplier in pairs(flag_values) do
			if item:has_flag(JsonFlagId.new(flag_name)) then
				local charges = item.charges or 0
				value = charges * multiplier

				if value > 0 then
					table.insert(currency_items, {
						item = item,
						value = value,
						display = string.format("%s [%d UC]", item:display_name(1), value),
					})
				end
				break
			end
		end
	end

	if #currency_items == 0 then
		gapi.add_msg("No recognizable currency or trade-marked items detected.")
		return
	end

	-- Scan and liquidate items
	while true do
		local ui = UiList.new()
		ui:title("dematerialization unit")
		ui:border_color(Color.c_dark_gray)
		ui:title_color(Color.i_black)
		ui:text("[" .. mod.uc_balance .. " UC]")
		for i, entry in ipairs(currency_items) do
			ui:add(i, entry.display)
		end

		local selected_index = ui:query()
		if selected_index == -1 then
			gapi.add_msg("Exited liquidation mode.")
			break
		end

		local selected = currency_items[selected_index]
		if selected then
			gapi.add_msg("Scanning " .. selected.item:display_name(1) .. " for valuation markers...")
			gapi.add_msg("Extracted " .. selected.value .. " UC from assets.")

			mod.uc_balance = mod.uc_balance + selected.value
			avatar:inv_remove_item(selected.item)

			table.remove(currency_items, selected_index)

			if #currency_items == 0 then
				gapi.add_msg("All viable assets have been liquidated. New balance: [" .. mod.uc_balance .. " UC].")
				break
			end
		end
	end
end

-- Purchase screen
mod.show_shop = function(use_item)
	-- Build category list and prompt user to select a category
	local category_ui = UiList.new()
	category_ui:title(use_item:display_name(1))
	category_ui:border_color(Color.c_dark_gray)
	category_ui:title_color(Color.i_black)
	category_ui:text("[" .. mod.uc_balance .. " UC]\nSelect category:")
	local category_keys = {}
	local idx = 1
	
	for category_name, _ in pairs(shop_categories) do
		category_ui:add(idx, category_name)
		category_keys[idx] = category_name
		idx = idx + 1
	end

	local selected_category_index = category_ui:query()
	if selected_category_index == -1 then
		gapi.add_msg("No category selected.")
		return
	end

	local selected_category = category_keys[selected_category_index]
	local items = shop_categories[selected_category]
	if not items or #items == 0 then
		gapi.add_msg("No items in this category.")
		return
	end

	-- Build item list for the selected category
	-- and prompt user to select an item to purchase
	local item_ui = UiList.new()
	item_ui:title(selected_category .. " - " .. use_item:display_name(1))
	item_ui:border_color(Color.c_dark_gray)
	item_ui:title_color(Color.i_black)
	item_ui:text("[" .. mod.uc_balance .. " UC]\nSelect item to purchase:")

	for i, entry in ipairs(items) do
		item_ui:add(i, string.format("%s [%d UC]", entry.itype:str(), entry.cost))
	end

	local selected_item_index = item_ui:query()
	if selected_item_index == -1 then
		gapi.add_msg("No item selected.")
		return
	end

	local selected = items[selected_item_index]
	if not selected or not selected.itype:is_valid() then
		gapi.add_msg("Invalid item selection.")
		return
	end

	if mod.uc_balance < selected.cost then
		gapi.add_msg("Insufficient UC. Cannot complete transaction.")
		return
	end

	-- Confirm purchase and create item
	mod.uc_balance = mod.uc_balance - selected.cost

	mod.place_bought_items_at_position(gapi.get_avatar():get_pos_ms(), selected.itype, 1)

	gapi.add_msg("Transaction confirmed. Drone dispatched to deliver " .. selected.itype:str() .. " [" .. selected.cost .. " UC].")
	gapi.add_msg("Remaining balance: [" .. mod.uc_balance .. " UC].")
end

mod.place_bought_items_at_position = function(position, item_type, quantity)
	local avatar = gapi.get_avatar()
	local place_position = avatar:get_pos_ms() + Tripoint.new(gapi.rng(-10, 10), gapi.rng(-10, 10), 0)
	gapi.play_variant_sound("misc", "timber", 50)
	gapi.get_map().set_furn_at(gapi:get_map(), place_position, FurnIntId.new(FurnId.new("f_crate_c")))
	gapi.get_map():create_item_at(place_position, item_type, quantity)
end

-- Main tablet iuse function
mod.iuse_function_buy_shop = function(who, use_item, pos)
	local ui = UiList.new()
	ui:title(use_item:display_name(1))
	ui:border_color(Color.c_dark_gray)
	ui:title_color(Color.i_black)
	ui:text("[" .. mod.uc_balance .. " UC]")
	ui:add(1, "Buy Items")
	ui:add(2, "Dematerialize Items")
	ui:add(3, "Exit")

	local choice = ui:query()

	if choice == 1 then
		mod.show_shop(use_item)
	elseif choice == 2 then
		mod.collect_currency_popup()
	end

	return 1
end

---------------------
-- WAVE VARIABLES
---------------------

-- Wave controller variables
local wave = 1
local wave_started = false

-- List of enemy sets
-- Each set contains a list of monster IDs that can be spawned in the wave
local enemy_sets = {
    zombies = { "mon_zombie", "mon_zombie_fat", "mon_zombie_dog", "mon_zombie_child", "mon_zombie_tough", "mon_boomer", "mon_zombie_predator", "mon_skeleton", "mon_skeleton_brute" },
    triffids = { "mon_triffid_young", "mon_triffid", "mon_vinebeast" },
    robots = { "mon_skitterbot", "mon_secubot", "mon_talon_m202a1", "mon_dispatch", "mon_molebot", "mon_riotbot" }
}

-- List to keep track of monsters in the current wave
-- This will be used to check if all monsters are dead before ending the wave
local mon_list = {}

---------------------
-- WAVE FUNCTIONALITY
---------------------

--- Convenience wrapper: get a random monster ID from the chosen category.
--- @param category string  -- key in `enemy_sets` (e.g. "zombies")
--- @return string|nil      -- monster id or nil if category unknown
local function random_enemy(category)
    local pool = enemy_sets[category]
    if not pool then
        gapi.add_msg(MsgType.error, "random_enemy(): unknown category '" .. tostring(category) .. "'")
        return nil
    end
    return random_from(pool)
end

-- Main iuse function. Returns amount of charges consumed from item.
mod.iuse_function_wave_controller = function(who, item, pos)
	mod.start_wave()
	return 0
end

-- End the current wave and give rewards
mod.end_wave = function()
	gapi.add_msg(MsgType.good, "WAVE COMPLETED!")
	mon_list = {}
	wave_started = false
	mod.uc_balance = mod.uc_balance + 1000 + ( 300 * (wave - 1) )
	wave = wave + 1
end

-- Start a new wave
mod.start_wave = function(g)
	gapi.add_msg(MsgType.warning, "WAVE " .. wave .. " STARTED!")
	mod.spawn_wave{
		group = "zombies"
	}
end

-- Spawn monsters for the wave
mod.spawn_wave = function(spawndata)
    local group    = spawndata.group or "zombies"         -- enemy group key
    local center   = gapi.get_avatar():global_square_location()
	
    local enemies = enemy_sets[group]
	
    if not enemies then
        gapi.add_msg(MsgType.bad, "Invalid enemy group: " .. group)
        return
    end
	
	wave_started = true
	
	for i = 1, 5*wave do
		local mtype = MtypeId.new(random_enemy(group))
		local mon = gapi.place_monster_at(mtype, random_point_near(gapi.get_avatar():get_pos_ms(), 40, 30))
		-- add the mon to our list of monsters
		if not mon then
			gapi.add_msg(MsgType.bad, "Failed to spawn monster of type: " .. mtype:str())
			return
		end

		-- EmmyLUA: add the monster to the list for tracking
		table.insert(mon_list, mon)
	end
end

-- Check for dead monsters and end wave if all are dead
mod.check_dead_monsters = function()
	if wave_started then
		local still_alive = true
		-- EmmyLUA: check if any monsters in the list are still alive by checking if they are NULL or not
		for _, mon in ipairs(mon_list) do	
			if mon ~= nil then
				if mon:is_dead() then
					gapi.add_msg(MsgType.bad, "Mon dead.")
					mon_list[mon] = nil
				else
					still_alive = true
				end
			end
		end

		if not still_alive then
			mod.end_wave()
			return true
		end
	end
end

-- Register the hook to check for dead monsters every turn
gapi.add_on_every_x_hook(mod.from_turns(1), mod.check_dead_monsters)
