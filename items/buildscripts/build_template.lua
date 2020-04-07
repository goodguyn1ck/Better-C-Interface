function build(directory, config, parameters, level, seed)
	isAddon = root.assetJson("/BCI_version.config:isAddon")

	-- materialID
  config.tooltipFields = config.tooltipFields or {}
	if config.rarity and config.rarity ~= 0 then
		if isAddon then
			parameters.tooltipFields = parameters.tooltipFields or {}
		end
		config.tooltipFields.materialIdLabel = "MaterialID: " .. config.rarity
	else
		config.tooltipFields.materialIdLabel = "MaterialID: -"
	end
  	return config, parameters
end
