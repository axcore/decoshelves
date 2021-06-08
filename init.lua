---------------------------------------------------------------------------------------------------
-- decoshelves mod by A S Lewis, based on code from minetest-game/default
-- License (code): GNU Lesser General Public License, version 2.1
-- License (media): Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
--
-- Literally cobbled together during a lunchbreak. Don't expect the code to be elegant
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
decoshelves.ver_min = 0
decoshelves.ver_rev = 1

---------------------------------------------------------------------------------------------------
-- Customisation
---------------------------------------------------------------------------------------------------

-- You can make a new bookshelf out of any node you like, or using any texture you like!
-- Add or remove as many lines as you like from this list
-- If you specify a texture directly, it must be added to this mod's /textures folder
-- If you specify a node from another mod, add that mod to this mod's mod.conf file
-- Note that decoshelves can't usually retrieve textures from water and other specialised nodes

setup_list = {
    -- The node whose texture we'll borrow. You can also specify the texture directly, if you have
    --      copied the texture into this mod's /textures folder
    "default:aspen_wood",
    -- The node used to craft the bookshelf. If it's the same as the node above, you can use an
    --      empty string
    "",
    -- This word is used to name the new bookshelf node
    "aspen",
    -- This description is added to the new bookshelf node
    S("Aspen Wood Bookshelf"),

    -- Add your own bookshelves here!
    "default:aspen_tree", "", "aspen_trunk", S("Aspen Tree Bookshelf"),
    "default:aspen_leaves", "", "aspen_leaves", S("Aspen Leaf Bookshelf"),

    "default:tree", "", "apple_trunk", S("Apple Tree Bookshelf"),
    "default:wood", "", "apple_wood", S("Apple Wood Bookshelf"),
    "default:leaves", "", "apple_leaves", S("Apple Leaf Bookshelf"),

    "default:acacia_tree", "", "acacia_trunk", S("Acacia Tree Bookshelf"),
    "default:acacia_wood", "", "acacia_wood", S("Acacia Wood Bookshelf"),
    "default:acacia_leaves", "", "acacia_leaves", S("Acacia Leaf Bookshelf"),

    "default:jungletree", "", "jungle_trunk", S("Jungle Tree Bookshelf"),
    "default:junglewood", "", "jungle_wood", S("Jungle Wood Bookshelf"),
    "default:jungleleaves", "", "jungle_leaves", S("Jungle Leaf Bookshelf"),

    "default:pine_tree", "", "pine_trunk", S("Pine Tree Bookshelf"),
    "default:pine_wood", "", "pine_wood", S("Pine Wood Bookshelf"),
    "default:pine_needles", "", "pine_needles", S("Pine Needle Bookshelf"),

    "default:stone", "", "stone", S("Stone Bookshelf"),
    "default:cobble", "", "cobble", S("Coblestone Bookshelf"),

    "default:desert_stone", "", "desert_stone", S("Desert Stone Bookshelf"),
    "default:desert_cobble", "", "desert_cobble", S("Desert Cobbletone Bookshelf"),

    "default:sandstone", "", "sandstone", S("Sandstone Bookshelf"),
    "default:sand", "", "sand", S("Sand Bookshelf"),

    "default:desert_sandstone", "", "desert_sandstone", S("Desert Sandstone Bookshelf"),
    "default:desert_sand", "", "desert_sand", S("Desert Sand Bookshelf"),

    "default:silver_sandstone", "", "silver_sandstone", S("Silver Sandstone Bookshelf"),
    "default:silver_sand", "", "silver_sand", S("Silver Sand Bookshelf"),

    "default:cactus", "", "cactus", S("Cactus Bookshelf"),

    "default:glass", "", "glass", S("Glass Bookshelf"),
    "default:obsidian", "", "obsidian", S("Obsidian Bookshelf"),
    "default:obsidian_glass", "", "obsidian_glass", S("Obsidian Glass Bookshelf"),

    "default:coral_brown", "", "coral_brown", S("Brown Coral Bookshelf"),
    "default:coral_orange", "", "coral_orange", S("Orange Coral Bookshelf"),

    "default:dirt", "", "dirt", S("Dirt Bookshelf"),
    "default:dirt_with_grass", "", "dirt_grass", S("Grass Bookshelf"),
    "default:dirt_with_dry_grass", "", "dirt_dry_grass", S("Dry Grass Bookshelf"),

    "default:gravel", "", "gravel", S("Gravel Bookshelf"),
    "default:ice", "", "ice", S("Ice Bookshelf"),
    "default:mese", "", "mese", S("Mese Bookshelf"),

--    "decoshelves_water.png", "default:water_source", "water", S("Wet Bookshelf"),
--    "decoshelves_river_water.png", "", "river_water", S("Watery Bookshelf"),
--    "decoshelves_lava.png", "", "lava", S("Lava Bookshelf"),
}

-- (default is a hard dependency, but bones and bucket are soft dependencies)
if minetest.get_modpath("bones") then
    table.insert(setup_list, "bones:bones")
    table.insert(setup_list, "")
    table.insert(setup_list, "bones")
    table.insert(setup_list, "Bony bookshelf")
end

if minetest.get_modpath("bucket") then
    table.insert(setup_list, "decoshelves_water.png")
    table.insert(setup_list, "bucket:bucket_water")
    table.insert(setup_list, "water")
    table.insert(setup_list, "Wet bookshelf")

    table.insert(setup_list, "decoshelves_river_water.png")
    table.insert(setup_list, "bucket:bucket_river_water")
    table.insert(setup_list, "river_water")
    table.insert(setup_list, "River bookshelf")

    table.insert(setup_list, "decoshelves_lava.png")
    table.insert(setup_list, "bucket:bucket_lava")
    table.insert(setup_list, "lava")
    table.insert(setup_list, "Lava bookshelf")
end

---------------------------------------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------------------------------------

local bookshelf_formspec =
        "size[8,7;]" ..
        "list[context;books;0,0.3;8,2;]" ..
        "list[current_player;main;0,2.85;8,1;]" ..
        "list[current_player;main;0,4.08;8,3;8]" ..
        "listring[context;books]" ..
        "listring[current_player;main]" ..
        default.get_hotbar_bg(0,2.85)

local function update_bookshelf(pos)

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
            formspec = formspec ..
                "image[" .. bx .. "," .. by .. ";1,1;decoshelves_slot.png]"
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
    if n_written + n_empty == 0 then
        meta:set_string("infotext", S("Empty Bookshelf"))
    else
        meta:set_string("infotext", S("Bookshelf (@1 written, @2 empty books)", n_written, n_empty))
    end

end

function decoshelves.register_bookshelf(material_node, craft_node, material_name, descrip)

    local tile_table, wood_img, shelf_img

    if string.find(material_node, ".png$") then

        -- The texture has been specified directly
        wood_img = material_node
        if craft_node == "" then
            -- No crafting recipe supplied, so ignore this bookshelf
            minetest.log("[DECOSHELVES] Invalid bookshelf definition")
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

    shelf_img = wood_img .. "^decoshelves_overlay.png"

    minetest.register_node("decoshelves:bookshelf_"..material_name, {
        description = descrip,
        tiles = {wood_img, wood_img, wood_img, wood_img, shelf_img, shelf_img},
        groups = {choppy = 3, flammable = 3, oddly_breakable_by_hand = 2},
        sounds = default.node_sound_wood_defaults(),

        is_ground_content = false,
        paramtype2 = "facedir",

        allow_metadata_inventory_put = function(pos, listname, index, stack)
            if minetest.get_item_group(stack:get_name(), "book") ~= 0 then
                return stack:get_count()
            end
            return 0
        end,

        can_dig = function(pos,player)
            local inv = minetest.get_meta(pos):get_inventory()
            return inv:is_empty("books")
        end,

        on_blast = function(pos)
            local drops = {}
            default.get_inventory_drops(pos, "books", drops)
            drops[#drops+1] = "decoshelves:bookshelf_"..material_name
            minetest.remove_node(pos)
            return drops
        end,

        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size("books", 8 * 2)
            update_bookshelf(pos)
        end,

        on_metadata_inventory_move = function(
            pos, from_list, from_index, to_list, to_index, count, player
        )
            minetest.log("action", player:get_player_name() ..
                    " moves stuff in bookshelf at " .. minetest.pos_to_string(pos))
            update_bookshelf(pos)
        end,

        on_metadata_inventory_put = function(pos, listname, index, stack, player)
            minetest.log("action", player:get_player_name() ..
                    " puts stuff to bookshelf at " .. minetest.pos_to_string(pos))
            update_bookshelf(pos)
        end,

        on_metadata_inventory_take = function(pos, listname, index, stack, player)
            minetest.log("action", player:get_player_name() ..
                    " takes stuff from bookshelf at " .. minetest.pos_to_string(pos))
            update_bookshelf(pos)
        end,
    })

    minetest.register_craft({
        output = "decoshelves:bookshelf_"..material_name,
        recipe = {
            {craft_node, craft_node, craft_node},
            {"default:book", "default:book", "default:book"},
            {craft_node, craft_node, craft_node},
        }
    })

end

---------------------------------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------------------------------

local stop_flag = false

while not stop_flag do

    material_node = table.remove(setup_list, 1)
    craft_node = table.remove(setup_list, 1)
    material_name = table.remove(setup_list, 1)
    descrip = table.remove(setup_list, 1)

    if material_node == nil then
        stop_flag = true
    else
        decoshelves.register_bookshelf(material_node, craft_node, material_name, descrip)
    end

end
