module ApplicationHelper
  def error_prefixed_title(title, has_errors)
    has_errors ? "#{t('page_title.error_prefix')} #{title}" : title
  end
end
