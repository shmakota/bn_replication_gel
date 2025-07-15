--gdebug.log_info("duplication goo: preload.")

local mod = game.mod_runtime[game.current_mod]

-- Register our item use function
game.iuse_functions["OPEN_BUY_SHOP"] = function(...)
  return mod.iuse_function_buy_shop(...)
end

game.iuse_functions["OPEN_WAVE_CONTROLLER"] = function(...)
  return mod.iuse_function_wave_controller(...)
end