-- EdenLost Citizenship Mod.
-- license: Apache 2.0

-- This mod implements the mod proposed in
-- https://github.com/EdenLostMinetest/edenlost/issues/34

-- minetest.conf:
--    citizenship.pos1 = x,y,z
--    citizenship.pos2 = x,y,z
--    citizenship.return_point = x,y,z
--    citizenship.return_yaw_degrees = 180
--    citizenship.scan_seconds = 10

-- Lower left corner of area where non-citizen players are allowed to be.
local pos1 = minetest.setting_get_pos("citizenship.pos1")
  or vector.new(-100, 0, -100)

-- Upper right corner of area where non-citizen players are allowed to be.
local pos2 = minetest.setting_get_pos("citizenship.pos2")
  or vector.new(100, 100, 100)

-- Where to teleport non-citizens to if they are out of bounds.
local return_point = minetest.setting_get_pos("citizenship.return_point")
  or minetest.setting_get_pos("static_spawnpoint")
  or vector.new(0,3,0)

-- Angle to orient player to when warping them to the return_point.
local return_yaw_degrees = tonumber(minetest.settings:get("citizenship.return_yaw_degrees") or 0)

-- How often to scan all active players
local scan_seconds = tonumber(minetest.settings:get("citizenship.scan_seconds") or 10)

-- Name of privilege required to allow player to exit non-citizen area.
local priv_name = "citizenship"

-- Text to append to playername when telling them to read th rules.
-- This should probably be moved into minetest.conf, but I'm too lazy.
local warn_text = 
  ": please read and agree to our server rules. There is a button near " ..
  "the rules that you can press to signify that you have read and " ..
  "accepted the rules."

-- Patch up pos1, pos2 if coords are not sorted.
if pos1.x > pos2.x then
  local x = pos1.x
  pos1.x = pos2.x
  pos2.x = x
end

if pos1.y > pos2.y then
  local y = pos1.y
  pos1.y = pos2.y
  pos2.y = y
end

if pos1.z > pos2.z then
  local z = pos1.z
  pos1.z = pos2.z
  pos2.z = z
end

local function send_player_to_return_point(player_obj)
  local name = player_obj:get_player_name()

  minetest.log("info", "Teleporting non-citizen " .. name .. " from " .. minetest.pos_to_string(player_obj:get_pos(), 0))
  minetest.chat_send_player(name, minetest.colorize("#FFFF30", name .. warn_text))

  player_obj:set_pos(return_point)
  player_obj:set_look_vertical(0.0)
  player_obj:set_look_horizontal(return_yaw_degrees * 3.1415965 / 180.0)
end

-- Returns true if `pos` is between `pos1` and `pos2`, inclusive.
local function inside_safe_zone(pos)
  return (pos1.x <= pos.x) and (pos.x <= pos2.x) and
    (pos1.y <= pos.y) and (pos.y <= pos2.y) and
    (pos1.z <= pos.z) and (pos.z <= pos2.z)
end

-- Returns true if the player is in jail, or otherwise exempt from citizneship
-- requirements.  This is because the EdenLost jail is OUTSIDE of the spawn
-- area.
local function player_is_exempt(player_name)
  if jail and jail.api then
    return jail.api.is_jailed(player_name)
  end
  return false
end

-- Returns true if the player is a citizen.
local function player_is_citizen(player_name)
  return minetest.check_player_privs(player_name, {[priv_name] = true})
end

local function enforce_citizenship()
  for _, player in ipairs(minetest.get_connected_players()) do
    local player_name = player:get_player_name()

    if player_is_citizen(player_name)
    or player_is_exempt(player_name)
    or inside_safe_zone(player:get_pos()) then
      -- do nothing
    else
      send_player_to_return_point(player)
    end
  end
end

local function timer_loop()
  enforce_citizenship()
  minetest.after(scan_seconds, timer_loop)
end

minetest.register_privilege(priv_name, {
    description = "Declares player a citizen, allowing them to exit spawn.",
})

minetest.after(scan_seconds, timer_loop)
