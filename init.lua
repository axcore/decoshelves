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
decoshelves.ver_min = 0
decoshelves.ver_rev = 0

---------------------------------------------------------------------------------------------------
-- Customisation
---------------------------------------------------------------------------------------------------

-- You can make a bookshelf out of any node you like!
-- Add or remove as many lines as you like from this list
-- Just make sure that the parent mod has already been loaded, by adding that mod to mod.conf
setup_list = {
    "default:aspen_wood",       -- The node whose texture we'll borrow
    "aspen",                    -- This word is used to name the new bookshelf node
    S("Aspen Wood Bookshelf"),  -- The new bookshelf node's description
    --
    "default:wood", "apple", S("Apple Tree Wood Bookshelf"),
    "default:acacia_wood", "acacia", S("Acacia Wood Bookshelf"),
    "default:junglewood", "jungle", S("Jungle Wood Bookshelf"),
    "default:pine_wood", "pine", S("Pine Wood Bookshelf"),
    "default:stone", "stone", S("Stone Bookshelf"),
}

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

function decoshelves.register_bookshelf(material_node, material_name, descrip)

    local tile_table = minetest.registered_nodes[material_node].tiles
    local wood_img = tile_table[1]
    local shelf_img = wood_img .. "^decoshelves_overlay.png"

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
            {material_node, material_node, material_node},
            {"default:book", "default:book", "default:book"},
            {material_node, material_node, material_node},
        }
    })

end

---------------------------------------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------------------------------------

local stop_flag = false
while not stop_flag do

    material_node = table.remove(setup_list, 1)
    material_name = table.remove(setup_list, 1)
    descrip = table.remove(setup_list, 1)

    if material_node == nil then
        stop_flag = true
    else
        decoshelves.register_bookshelf(material_node, material_name, descrip)
    end

end
