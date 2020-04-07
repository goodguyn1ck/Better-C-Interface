function build(directory, config, parameters, level, seed)
	isAddon = root.assetJson("/IFD_version.config:isAddon")

	if not parameters.timeToRot and config.foodValue ~= nil and config.foodValue ~= 0 then
		local rottingMultiplier = parameters.rottingMultiplier or config.rottingMultiplier or 1.0

		if isAddon then
			rottingMultiplier = 1.0
		end
		parameters.timeToRot = root.assetJson("/items/rotting.config:baseTimeToRot") * rottingMultiplier
  end

	-- food amount
  config.tooltipFields = config.tooltipFields or {}
	if config.foodValue and config.foodValue ~= 0 then
		if isAddon then
			parameters.tooltipFields = parameters.tooltipFields or {}
			parameters.tooltipFields.rotTimeLabel = ""
		else
			config.tooltipFields.rotTimeLabel = getRotTimeDescription(parameters.timeToRot)
		end
		config.tooltipFields.foodAmountLabel = "Food: " .. config.foodValue
	else
		config.tooltipFields.foodAmountLabel = "Food: -"	
	end

	-- effect description
	local localEffectConfig = root.assetJson("/IFD_statuseffects.config:effectNames")
	local localEffectConfigTypes = root.assetJson("/IFD_statuseffects.config:effectConfigTypes")
	if config.effects and next(config.effects) then
		local labelText = ""
		for _, effect in ipairs(config.effects[1]) do
			local effectName = effect.effect or effect or ""
			local effectDuration = "??"
			local effectDescription = "- Unknown effect\n"
			local effectDescription1 = ""
			local effectDescription2 = ""
			local effectData = {}

			-- check json for effect name
			if localEffectConfig[effectName] then
				local list = localEffectConfig[effectName]

				-- set effect duration
				local rootEffectConfig = root.assetJson(list.path)
				local effectDefaultDuration = rootEffectConfig.defaultDuration
				effectDuration = effect.duration or effectDefaultDuration or 0

				-- build effectConfigTypes
				if list.effectConfigTypes then
					for _, v in ipairs(list.effectConfigTypes) do
						if localEffectConfigTypes[v] then

							-- calculate amount
							local effectAmount
							local i = localEffectConfigTypes[v]
							local effectTypeAmount = effect[v] or rootEffectConfig.effectConfig[v]

							if i.isRegeneration then
								effectAmount = math.floor( (effectDuration * 100) / effectTypeAmount )
							elseif i.isMultiplier then
								effectAmount = tonumber( string.format( "%.0f", ( effectTypeAmount - 1 ) * 100 ) )
							elseif i.isPercentage then
								effectAmount = tonumber( string.format( "%.0f", effectTypeAmount * 100 ) )
							else
								effectAmount = effectTypeAmount
							end

							-- set sign
							local effectSign = "-"
							if effectAmount >= 0 then
								effectSign = "+"
							else
								effectAmount = math.abs( effectAmount )
							end

							-- set label color
							local colorPrefix = "^red;"
							if (effectSign == "-" and i.invertColor) or (effectSign == "+" and not i.invertColor) then
								colorPrefix = "^green;"
							end

							-- build effect table
							effectData[v] = {
								colorPrefix = colorPrefix,
								sign = effectSign,
								amount = effectAmount,
								dimension = i.dimension or "",
								label = list.effectConfigOverride or i['label'],
								colorPostfix = "^reset;"
							}
						end
					end
					-- build description text
					effectDescription1 = ""
					for _, data in pairs(effectData) do
						effectDescription1 = effectDescription1 .. data['colorPrefix'] .. data['sign'] .. " " .. data['amount'] .. data['dimension'] .. " " .. data['label'] .. data['colorPostfix'] .. ""
					end
				end

				-- build customLabels
				effectDescription2 = ""
				if list.customLabels then
					for _, customLabel in ipairs(list.customLabels) do
						effectDescription2 = effectDescription2 .. customLabel .. ""
					end
				end

				effectDescription = effectDescription1 .. effectDescription2
				-- use effectName in case of missing json part
				if effectDescription == "" then
					effectDescription = "- " .. effectName .. ""
				end
			end
			labelText = labelText .. effectDescription .. "   (" .. effectDuration .. "s)\n"
		end
		config.tooltipFields.effectLabel = labelText
	else
		config.tooltipFields.effectLabel = "\n\n\n\n     - No effects -"
	end
	
  return config, parameters
end

function getRotTimeDescription(rotTime)
	local color = ""
	if rotTime <= 300 then color = "^red;"
		elseif rotTime <= 1800 then color = "^orange;"
		elseif rotTime <= 3600 then color = "^yellow;"
		elseif rotTime <= 10800 then color = "^green;"
		else color = "^green;"
	end

	hours = string.format("%i", math.floor(rotTime/3600))
	minutes = string.format("%i", math.floor(rotTime/60 - (hours*60)))
	seconds = string.format("%i", math.floor(rotTime - hours*3600 - minutes*60))
	return color .. "Spoils in: " .. hours .."h ".. minutes .."m ".. seconds .. "s" .. "^reset;"
end