class TutorialPagesController < ApplicationController

	def get_verb_in_technology_for_version(technology, verb, version)
		version_range_delimiter = "through"
		if (! TECHNOLOGIES.has_key? technology) or (! TECHNOLOGIES[technology][:verbs].has_key? verb)
			return nil
		end
		if version.nil?
			version = TECHNOLOGIES[technology][:meta][:default_version]
		end
		verb_node = TECHNOLOGIES[technology][:verbs][verb]
		literal_versions = verb_node[:versions]
		version_mappings = verb_node[:meta][:version_mappings]
		if literal_versions.has_key? version # First, check if there's a literal file for this version. Don't bother converting to 
			return literal_versions[version]
		else # If not, fall back to the mappings and search
			our_version = Gem::Version.new(version)
			version_mappings.each_pair do |version_range, literal_version|
				if version_range.include? version_range_delimiter
					low, high = (version_range.split(version_range_delimiter).map { |s| Gem::Version.new(s) } )
					if (low <= our_version) and (high >= our_version)
						return literal_versions[literal_version]
					end
				end
			end
			return nil
		end
	end

  def show
  	@param_verb = canonize_name(params[:verb])
    @param_technology = canonize_name(params[:technology])
    @param_version = canonize_name(params[:version])
    Rails.logger.debug @param_version
  	response = get_verb_in_technology_for_version(@param_technology, @param_verb, @param_version)
  	if response
  		@tutorial = response
  	else
  		@tutorial = "error occurred"
  	end
  end

  def canonize_name(name)
  	if name.nil?
  		nil
  	else
  		name.gsub(/[^0-9a-z _-]/i, '').gsub(' ', '-').gsub('_', '-').downcase
  	end
  end
end
