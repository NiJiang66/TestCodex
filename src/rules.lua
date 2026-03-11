local Tile = require("src.tile")

local Rules = {}

local function tile_key(suit, rank)
    return suit .. tostring(rank)
end

local function hand_to_counts(hand)
    local counts = {}
    for _, tile in ipairs(hand) do
        local key = tile_key(tile.suit, tile.rank)
        counts[key] = (counts[key] or 0) + 1
    end
    return counts
end

local function next_existing_key(counts)
    local min_key = nil
    for key, count in pairs(counts) do
        if count > 0 and (min_key == nil or key < min_key) then
            min_key = key
        end
    end
    return min_key
end

local function parse_key(key)
    local suit = key:sub(1, 1)
    local rank = tonumber(key:sub(2))
    return suit, rank
end

local function can_form_melds(counts)
    local key = next_existing_key(counts)
    if not key then
        return true
    end

    local suit, rank = parse_key(key)

    if counts[key] >= 3 then
        counts[key] = counts[key] - 3
        if can_form_melds(counts) then
            counts[key] = counts[key] + 3
            return true
        end
        counts[key] = counts[key] + 3
    end

    if suit ~= "Z" and rank <= 7 then
        local key2 = tile_key(suit, rank + 1)
        local key3 = tile_key(suit, rank + 2)
        if (counts[key2] or 0) > 0 and (counts[key3] or 0) > 0 then
            counts[key] = counts[key] - 1
            counts[key2] = counts[key2] - 1
            counts[key3] = counts[key3] - 1

            if can_form_melds(counts) then
                counts[key] = counts[key] + 1
                counts[key2] = counts[key2] + 1
                counts[key3] = counts[key3] + 1
                return true
            end

            counts[key] = counts[key] + 1
            counts[key2] = counts[key2] + 1
            counts[key3] = counts[key3] + 1
        end
    end

    return false
end

function Rules.is_standard_win(hand)
    if #hand ~= 14 then
        return false
    end

    table.sort(hand, Tile.compare)
    local counts = hand_to_counts(hand)

    for key, count in pairs(counts) do
        if count >= 2 then
            counts[key] = count - 2
            if can_form_melds(counts) then
                counts[key] = count
                return true
            end
            counts[key] = count
        end
    end

    return false
end

function Rules.suggest_discard(hand)
    table.sort(hand, Tile.compare)

    local best_index = 1
    local best_score = -1

    for i = 1, #hand do
        local simulated = {}
        for j = 1, #hand do
            if j ~= i then
                table.insert(simulated, hand[j]:clone())
            end
        end

        local score = 0
        local counts = hand_to_counts(simulated)
        for _, c in pairs(counts) do
            if c >= 2 then
                score = score + 2
            else
                score = score + c
            end
        end

        if score > best_score then
            best_score = score
            best_index = i
        end
    end

    return best_index
end

return Rules
