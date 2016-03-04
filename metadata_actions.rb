module MetadataActions
  def archive
    render partial: 'shared/archive',
      locals: { countable: countable_model, filters: countable_filters }
  end

  ###
  ## Include ArchiveCountable module to appropriate model
  ###

  class << self
    private
    def included(base)
      modelize(base).class_eval { |model| model.extend(ArchiveCountable) }
    end

    def modelize(controller)
      controller.to_s.split("Controller").first.classify.constantize
    end
  end

  private

  ####
  ## Utility
  ####

  def countable_filters
    get_params.slice(*countable_filter_params)
  end

  # Also used in ApplicationController to (conditionally) expand get_params
  def countable_filter_params
    archive_action? ? countable_model.column_names + ['group_by'] : []
  end

  def countable_model
    params[:controller].camelize.singularize.constantize
  end

  def archive_action?
    params[:action] == 'archive'
  end
end
