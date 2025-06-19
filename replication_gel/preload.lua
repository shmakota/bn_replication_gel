--gdebug.log_info("duplication goo: preload.")

local mod = game.mod_runtime[game.current_mod]

-- Register our item use function
game.iuse_functions["DUPLICATION_GEL"] = function(...)
  return mod.iuse_function(...)
end
