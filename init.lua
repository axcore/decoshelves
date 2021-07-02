---------------------------------------------------------------------------------------------------
-- decoshelves mod by A S Lewis, based on code from minetest-game/default
-- License (code): GNU Lesser General Public License, version 2.1
-- License (media): Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
---------------------------------------------------------------------------------------------------

local S = minetest.get_translator(minetest.get_current_modname())

---------------------------------------------------------------------------------------------------
-- Create global namespace
---------------------------------------------------------------------------------------------------

decoshelves = {}

---------------------------------------------------------------------------------------------------
-- Set mod name/version
---------------------------------------------------------------------------------------------------

decoshelves.name = "decoshelves"

decoshelves.ver_max = 1
decoshelves.ver_min = 5
decoshelves.ver_rev = 0

---------------------------------------------------------------------------------------------------
-- Customisation
---------------------------------------------------------------------------------------------------

-- You can make a new bookshelf out of any node you like, or using any texture you like!
-- Add or remove as many items as you like from this list
-- If you specify a texture directly, it must be added to this mod's /textures folder
-- If you specify a node from another mod, add that mod to this mod's mod.conf file
-- Note that decoshelves can't usually retrieve textures from water and other specialised nodes

setup_list = {
    {
        -- The node whose texture we'll borrow. You can also specify the texture directly, if you
        --      have copied the texture into this mod's /textures folder
        "default:aspen_wood",
        -- The node used to craft the bookshelf. If it's the same as the node above, you can use an
        --      empty string
        "",
        -- This word is used to name the new bookshelf node
        "aspen",
        -- This description is added to the new bookshelf node
        S("Aspen Wood Bookshelf"),
        -- The bookshelf is flammable (true or false)
        true,
    },

    -- Add your own bookshelves here!
    {"default:aspen_tree", "", "aspen_trunk", S("Aspen Tree Bookshelf"), true},
    {"default:aspen_leaves", "", "aspen_leaves", S("Aspen Leaf Bookshelf"), true},

    {"default:tree", "", "apple_trunk", S("Apple Tree Bookshelf"), true},
    {"default:wood", "", "apple_wood", S("Apple Wood Bookshelf"), true},
    {"default:leaves", "", "apple_leaves", S("Apple Leaf Bookshelf"), true},

    {"default:acacia_tree", "", "acacia_trunk", S("Acacia Tree Bookshelf"), true},
    {"default:acacia_wood", "", "acacia_wood", S("Acacia Wood Bookshelf"), true},
    {"default:acacia_leaves", "", "acacia_leaves", S("Acacia Leaf Bookshelf"), true},

    {"default:jungletree", "", "jungle_trunk", S("Jungle Tree Bookshelf"), true},
    {"default:junglewood", "", "jungle_wood", S("Jungle Wood Bookshelf"), true},
    {"default:jungleleaves", "", "jungle_leaves", S("Jungle Leaf Bookshelf"), true},

    {"default:pine_tree", "", "pine_trunk", S("Pine Tree Bookshelf"), true},
    {"default:pine_wood", "", "pine_wood", S("Pine Wood Bookshelf"), true},
    {"default:pine_needles", "", "pine_needles", S("Pine Needle Bookshelf"), true},

    {"default:stone", "", "stone", S("Stone Bookshelf"), false},
    {"default:cobble", "", "cobble", S("Cobblestone Bookshelf"), false},

    {"default:desert_stone", "", "desert_stone", S("Desert Stone Bookshelf"), false},
    {"default:desert_cobble", "", "desert_cobble", S("Desert Cobbletone Bookshelf"), false},

    {"default:sandstone", "", "sandstone", S("Sandstone Bookshelf"), false},
    {"default:sand", "", "sand", S("Sand Bookshelf"), false},

    {"default:desert_sandstone", "", "desert_sandstone", S("Desert Sandstone Bookshelf"), false},
    {"default:desert_sand", "", "desert_sand", S("Desert Sand Bookshelf"), false},

    {"default:silver_sandstone", "", "silver_sandstone", S("Silver Sandstone Bookshelf"), false},
    {"default:silver_sand", "", "silver_sand", S("Silver Sand Bookshelf"), false},

    {"default:cactus", "", "cactus", S("Cactus Bookshelf"), false},

    {"default:glass", "", "glass", S("Glass Bookshelf"), false},
    {"default:obsidian", "", "obsidian", S("Obsidian Bookshelf"), false},
    {"default:obsidian_glass", "", "obsidian_glass", S("Obsidian Glass Bookshelf"), false},

    {"default:coral_brown", "", "coral_brown", S("Brown Coral Bookshelf"), false},
    {"default:coral_orange", "", "coral_orange", S("Orange Coral Bookshelf"), false},

    {"default:dirt", "", "dirt", S("Dirt Bookshelf"), false},
    {"default:dirt_with_grass", "", "dirt_grass", S("Grass Bookshelf"), false},
    {"default:dirt_with_dry_grass", "", "dirt_dry_grass", S("Dry Grass Bookshelf"), false},

    {"default:gravel", "", "gravel", S("Gravel Bookshelf"), false},
    {"default:ice", "", "ice", S("Ice Bookshelf"), false},
    {"default:mese", "", "mese", S("Mese Bookshelf"), false},
}

-- (default is a hard dependency, but bones and bucket are soft dependencies)
if minetest.get_modpath("bones") then

    table.insert(setup_list,
        {"bones:bones", "", "bones", S("Bony bookshelf"), false}
    )

end

if minetest.get_modpath("bucket") then

    table.insert(setup_list,
        {"decoshelves_water.png", "bucket:bucket_water", "water", S("Wet bookshelf"), false}
    )

    table.insert(setup_list,
        {
            "decoshelves_river_water.png",
            "bucket:bucket_river_water",
            "river_water",
            S("River bookshelf"),
            false,
        }
    )

    table.insert(setup_list,
        {"decoshelves_lava.png", "bucket:bucket_lava", "lava", S("Lava bookshelf"), false}
    )

end

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

local bookshelf_formspec =
        "size[8,7;]"..
        "list[context;books;0,0.3;8,2;]"..
        "list[current_player;main;0,2.85;8,1;]"..
        "list[current_player;main;0,4.08;8,3;8]"..
        "listring[context;books]"..
        "listring[current_player;main]"..
        default.get_hotbar_bg(0,2.85)

local function update_bookshelf(pos, protected_flag)

    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local invlist = inv:get_list("books")

    local formspec = bookshelf_formspec
    -- Inventory slots overlay
    local bx, by = 0, 0.3
    local n_written, n_empty = 0, 0

    -- (Bookshelf has room for 16 books)
    for i = 1, 16 do

        if i == 9 then

            bx = 0
            by = by + 1

        end

        local stack = invlist[i]
        if stack:is_empty() then

            formspec = formspec.."image[".. bx..","..by..";1,1;decoshelves_slot.png]"

        else

            local metatable = stack:get_meta():to_table() or {}
            if metatable.fields and metatable.fields.text then
                n_written = n_written + stack:get_count()
            else
                n_empty = n_empty + stack:get_count()
            end

        end

        bx = bx + 1

    end

    meta:set_string("formspec", formspec)

    local info_string = ""
    if n_written + n_empty == 0 then

        if not protected_flag then
            info_string = S("Empty Bookshelf")
        else
            info_string = S("Locked Empty Bookshelf")
        end

    else

        if not protected_flag then
            info_string = S("Bookshelf (@1 written, @2 empty books)", n_written, n_empty)
        else
            info_string = S("Locked Bookshelf (@1 written, @2 empty books)", n_written, n_empty)
        end

    end

    if protected_flag then
        info_string = info_string.."\n("..S("Owned by @1", meta:get_string("owner"))..")"
    end

    meta:set_string("infotext", info_string)

end

local function register_bookshelf(full_name, def_table)

    def_table.is_ground_content = false
    def_table.paramtype2 = "facedir"

    if def_table.protected then

        def_table.after_place_node = function(pos, placer)

            local meta = minetest.get_meta(pos)
            meta:set_string("owner", placer:get_player_name() or "")

            update_bookshelf(pos, def_table.protected)

        end

        def_table.allow_metadata_inventory_move = function(
            pos, from_list, from_index, to_list, to_index, count, player
        )
            if not default.can_interact_with_node(player, pos) then
                return 0
            end

            return count

        end

    end

    if not def_table.protected then

        def_table.allow_metadata_inventory_put = function(pos, listname, index, stack)

            if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
                return stack:get_count()
            end

            return 0

        end

    else

        def_table.allow_metadata_inventory_put = function(pos, listname, index, stack, player)

            if not default.can_interact_with_node(player, pos) then
                return 0
            elseif minetest.get_item_group(stack:get_name(), "book") ~= 0 then
                return stack:get_count()
            end

            return 0

        end

    end

    if def_table.protected then

        def_table.allow_metadata_inventory_take = function(pos, listname, index, stack, player)

            if not default.can_interact_with_node(player, pos) then
                return 0
            end

            return stack:get_count()

        end

    end

    if not def_table.protected then

        def_table.can_dig = function(pos, player)

            local inv = minetest.get_meta(pos):get_inventory()
            return inv:is_empty("books")

        end

    else

        def_table.can_dig = function(pos, player)

            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            return inv:is_empty("books") and default.can_interact_with_node(player, pos)

        end

    end

    if not def_table.protected then

        def_table.on_blast = function(pos)

            local drops = {}
            default.get_inventory_drops(pos, "books", drops)
            drops[#drops+1] = "decoshelves:bookshelf_"..material_name
            minetest.remove_node(pos)
            return drops

        end

    else

        def_table.on_blast = function() end

    end

    if not def_table.protected then

        def_table.on_construct = function(pos)

            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size("books", 8 * 2)

            update_bookshelf(pos, def_table.protected)

        end

    else

        def_table.on_construct = function(pos)

            local meta = minetest.get_meta(pos)
            meta:set_string("owner", "")
            local inv = meta:get_inventory()
            inv:set_size("books", 8 * 2)

            update_bookshelf(pos, def_table.protected)

        end

    end

    if def_table.protected then

        def_table.on_key_use = function(pos, player)

            local secret = minetest.get_meta(pos):get_string("key_lock_secret")
            local itemstack = player:get_wielded_item()
            local key_meta = itemstack:get_meta()

            if itemstack:get_metadata() == "" then
                return
            end

            if key_meta:get_string("secret") == "" then
                key_meta:set_string("secret", minetest.parse_json(itemstack:get_metadata()).secret)
                itemstack:set_metadata("")
            end

            if secret ~= key_meta:get_string("secret") then
                return
            end

            minetest.show_formspec(
                player:get_player_name(),
                full_name.."_locked",
                default.chest.get_chest_formspec(pos)
            )

        end

        def_table.on_skeleton_key_use = function(pos, player, newsecret)

            local meta = minetest.get_meta(pos)
            local owner = meta:get_string("owner")
            local pn = player:get_player_name()

            -- Verify placer is owner of lockable bookshelf
            if owner ~= pn then

                minetest.record_protection_violation(pos, pn)
                minetest.chat_send_player(pn, S("You do not own this bookshelf."))
                return nil

            end

            local secret = meta:get_string("key_lock_secret")
            if secret == "" then
                secret = newsecret
                meta:set_string("key_lock_secret", secret)
            end

            return secret, S("a locked bookshelf"), owner

        end

        def_table.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

            if owner ~= pn then
                return nil
            elseif not default.can_interact_with_node(clicker, pos) then
                return itemstack
            end

        end

    end

    def_table.on_metadata_inventory_move = function(
        pos, from_list, from_index, to_list, to_index, count, player
    )
        minetest.log(
            "action",
            player:get_player_name().." moves stuff in bookshelf at "..
                    minetest.pos_to_string(pos)
        )

        update_bookshelf(pos, def_table.protected)

    end

    def_table.on_metadata_inventory_put = function(pos, listname, index, stack, player)

        minetest.log(
            "action",
            player:get_player_name().." puts stuff to bookshelf at "..
                    minetest.pos_to_string(pos)
        )

        update_bookshelf(pos, def_table.protected)

    end

    def_table.on_metadata_inventory_take = function(pos, listname, index, stack, player)

        minetest.log(
            "action",
            player:get_player_name().." takes stuff from bookshelf at "..
                    minetest.pos_to_string(pos)
        )

        update_bookshelf(pos, def_table.protected)

    end

    minetest.register_node(full_name, def_table)

end

local function prepare_bookshelf(
    material_node, craft_node, material_name, description, flammable_flag
)
    local full_name, tile_table, wood_img, shelf_img, locked_shelf_img, groups

    full_name = "decoshelves:bookshelf_"..material_name

    if string.find(material_node, ".png$") then

        -- The texture has been specified directly
        wood_img = material_node
        if craft_node == "" then

            -- No crafting recipe supplied, so ignore this bookshelf
            minetest.log("[DECOSHELVES] Invalid bookshelf definition: "..full_name)
            return

        end

    elseif minetest.registered_nodes[material_node] == nil then

        minetest.log("[DECOSHELVES] Cannot retrieve texture for node: "..material_node)
        return

    else

        -- Get the texture from the specified node
        tile_table = minetest.registered_nodes[material_node].tiles
        wood_img = tile_table[1]

        if craft_node == "" then

            -- If the first two arguments are (some_png, nil), then an error will be produced
            craft_node = material_node

        end

    end

    shelf_img = wood_img.."^decoshelves_overlay.png"
    locked_shelf_img = wood_img.."^decoshelves_locked_overlay.png"

    -- Hack to use flowing water/lava animations as textures
    if material_name == "water" then

        wood_img = {
            name = "decoshelves_water_animated.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        }

    elseif material_name == "river_water" then

        wood_img = {
            name = "decoshelves_river_water_animated.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        }

    elseif material_name == "lava" then

        wood_img = {
            name = "decoshelves_lava_animated.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 3.0,
            },
        }

    end

    if not flammable_flag then
        groups = {choppy = 3, oddly_breakable_by_hand = 2}
    else
        groups = {choppy = 3, flammable = 3, oddly_breakable_by_hand = 2}
    end

    register_bookshelf(full_name, {
        description = description,
        tiles = {wood_img, wood_img, wood_img, wood_img, shelf_img, shelf_img},
        groups = groups,
        sounds = default.node_sound_wood_defaults(),
        protected = false,
    })
    minetest.register_craft({
        output = full_name,
        recipe = {
            {craft_node, craft_node, craft_node},
            {"default:book", "default:book", "default:book"},
            {craft_node, craft_node, craft_node},
        }
    })

    register_bookshelf(full_name.."_locked", {
        description = description.." ("..S("Locked")..")",
        tiles = {wood_img, wood_img, wood_img, wood_img, locked_shelf_img, locked_shelf_img},
        groups = groups,
        sounds = default.node_sound_wood_defaults(),
        protected = true,
    })
    minetest.register_craft({
        output = full_name.."locked",
        recipe = {
            {craft_node, craft_node, craft_node},
            {"default:book", "default:steel_ingot", "default:book"},
            {craft_node, craft_node, craft_node},
        }
    })

    if flammable_flag then

        minetest.register_craft({
            type = "fuel",
            recipe = full_name,
            burntime = 30,
        })

        minetest.register_craft({
            type = "fuel",
            recipe = full_name.."_locked",
            burntime = 30,
        })

    end

end

---------------------------------------------------------------------------------------------------
-- Setup code
---------------------------------------------------------------------------------------------------

for _, mini_list in ipairs(setup_list) do

    prepare_bookshelf(
        mini_list[1], mini_list[2], mini_list[3], mini_list[4], mini_list[5]
    )

end
