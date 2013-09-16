class TutorialPagesController < ApplicationController

	def get_verb_in_technology_for_version(technology, verb, version)
		verb_node = TECHNOLOGIES[technology][:verbs][verb]
		versions = verb_node[:meta][:versions]
	end

  def show
    @verb = canonize_name(params[:verb])
    @technology = canonize_name(params[:technology])
    verb_node = TECHNOLOGIES[@technology][:verbs][@verb]
    default_version = verb_node[:meta][:default_version]
    @version = canonize_name(params[:version] || default_version)
    info = TECHNOLOGIES[@technology][:verbs][@verb][:versions][@version]
  end

  def canonize_name(name)
  	if name.nil?
  		nil
  	else
  		name.gsub(/[^0-9a-z _-]/i, '').gsub(' ', '-').gsub('_', '-').downcase
  	end
  end

end
