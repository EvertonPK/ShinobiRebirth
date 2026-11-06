local Util = {}

function Util.DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[Util.DeepCopy(key)] = Util.DeepCopy(child)
	end
	return result
end

function Util.Reconcile(target, template)
	for key, value in template do
		if target[key] == nil then
			target[key] = Util.DeepCopy(value)
		elseif type(value) == "table" and type(target[key]) == "table" then
			Util.Reconcile(target[key], value)
		end
	end
	return target
end

function Util.WeightedChoice(random, entries, weightKey)
	local total = 0
	for _, entry in entries do
		total += entry[weightKey]
	end
	local cursor = random:NextNumber() * total
	for _, entry in entries do
		cursor -= entry[weightKey]
		if cursor <= 0 then
			return entry
		end
	end
	return entries[#entries]
end

function Util.IsFiniteNumber(value)
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

return table.freeze(Util)
