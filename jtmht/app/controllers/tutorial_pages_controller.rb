class TutorialPagesController < ApplicationController

	def get_verb_in_technology_for_version(technology, verb, version)
		version_range_delimiter = "through"
		if (! TECHNOLOGIES.has_key? technology) or (! TECHNOLOGIES[technology][:verbs].has_key? verb)
			raise "No such verb '#{verb}' for '#{technology}'"
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
			raise "No such version '#{version}' for '#{verb}' in '#{technology}', however, tech and verb exist."
		end
	end

  def show
  	canonized_verb = canonize_name(params[:verb])
    canonized_technology = canonize_name(params[:technology])
    canonized_version = canonize_name(params[:version])
    @view_verb = viewify_name(params[:verb])
    @view_technology = capitalize_words(viewify_name(params[:technology]))
    @view_version = params[:version] ? viewify_name(params[:version]) : viewify_name(TECHNOLOGIES[canonized_technology][:meta][:default_version])
  	response = get_verb_in_technology_for_version(canonized_technology, canonized_verb, canonized_version)
  	if response
  		@view_tutorial = response
  	else
  		raise "Tutorial page was empty"
  	end
  end

  def capitalize_words(s)
  	if s.nil?
  		nil
  	else
  		s.split.map(&:capitalize).join(' ')
  	end
  end

  def viewify_name(name)
  	if name.nil?
  		nil
  	else
  		name.gsub('-', ' ').gsub('_', ' ')
  	end
  end

  def canonize_name(name)
  	if name.nil?
  		nil
  	else
  		name.gsub(/[^0-9a-z. _-]/i, '').gsub(' ', '-').gsub('_', '-').downcase
  	end
  end
end
