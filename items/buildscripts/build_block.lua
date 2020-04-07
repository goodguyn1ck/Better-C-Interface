function build(directory, config, parameters, level, seed)
	isAddon = root.assetJson("/BCI_version.config:isAddon")

	-- materialID
  config.tooltipFields = config.tooltipFields or {}
	if config.materialId and config.materialId ~= 0 then
		if isAddon then
			parameters.tooltipFields = parameters.tooltipFields or {}
		end
		config.tooltipFields.materialIdLabel = "MaterialID: " .. config.materialId
	else
		config.tooltipFields.materialIdLabel = "MaterialID: -"
	end
	-- rarity
	if config.rarity and config.rarity ~= 0 then
		if isAddon then
			parameters.tooltipFields = parameters.tooltipFields or {}
		end
		config.tooltipFields.rarityLabelLabel = "Rarity: " .. config.rarity
	else
		config.tooltipFields.rarityLabelLabel = "Rarity: -"
	end

  	return config, parameters
end
