# edenlost_citizenship
Implements the mod described in https://github.com/EdenLostMinetest/edenlost/issues/34

https://github.com/EdenLostMinetest/edenlost_citizenship

This mod is used to keep a player at the "spawn area" until they've gained the
`citizenship` privilege.  In EdenLost, this is used to ensure that the players
have agreed to the server rules, which are posted at spawn.

This mod does not contain any mechanism to grant this privilege.  The world
admins should create this mechanism themselves.  One way to do this is to
build a small mesecons machine near the posted rules consisting of:

1. `mesecons_commandblock:commandblock_off` with the script:
   `grant @nearest citizenship`.
1. `mesecons_button:mesecons_off` connected to the command block.
1. A sign above it that reads something like:
   "I've read and agreed to the rules."

## Configuration

You should add the following to your `minetest.conf`.  The default settings
inside the mod itself (`init.lua`) are for EdenLost.

```
    # Lower bounds of area where non-citizens may explore.
    citizenship.pos1 = x,y,z

    # Upper bounds of area where non-citizens may explore.
    citizenship.pos2 = x,y,z

    # Where to teleport non-citizens to when they escape these bounds.
    citizenship.return_point = x,y,z

    # Angle to orient player to when warping them to the return_point.
    citizenship.return_yaw_degrees = 180

    # How often to scan all active players to enforce citizenship check.
    citizenship.scan_seconds = 10
```

## Jail mod integration.

If the server also runs EdenLost's `jail` mod, then the citizenship test is
skipped, since the jail is outside of the spawn area.

https://github.com/EdenLostMinetest/edenlost_jail
