module GovukElementsErrorsLocalHelper

  class << self
    include ActionView::Context
    include ActionView::Helpers::TagHelper
  end

  def self.error_summary object, heading, description
    return unless errors_exist? object
    error_summary_div do
      error_summary_heading(heading) +
      error_summary_description(description) +
      error_summary_list(object)
    end
  end

  def self.errors_exist? object
    errors_present?(object)
  end

  def self.instance_variable object, var
    field = var.to_s.sub('@','').to_sym
    if object.respond_to?(field)
      child = object.send(field)
      if respond_to_errors?(child) || child.is_a?(Array)
        child
      else
        nil
      end
    end
  end

  def self.respond_to_errors? object
    object && object.respond_to?(:errors)
  end

  def self.errors_present? object
    respond_to_errors?(object) && object.errors.present?
  end

  def self.error_summary_div &block
    content_tag(:div,
        class: 'error-summary',
        role: 'alert',
        aria: {
          labelledby: 'error-summary-heading'
        },
        tabindex: '-1') do
      yield block
    end
  end

  def self.error_summary_heading text
    content_tag :h2,
      text,
      id: 'error-summary-heading',
      class: 'heading-medium error-summary-heading'
  end

  def self.error_summary_description text
    content_tag :p, text
  end

  def self.error_summary_list object
    content_tag(:ul, class: 'error-summary-list') do
      messages = error_summary_messages(object)
      messages.flatten.join('').html_safe
    end
  end

  def self.error_summary_messages object
    object.errors.attribute_names.map do |attribute|
      error_summary_message object, attribute
    end
  end

  def self.error_summary_message object, attribute
    messages = object.errors.full_messages_for attribute
    messages.map do |message|
      object_prefixes = object_prefixes object
      link = link_to_error(object_prefixes, attribute)
      message.sub! default_label(attribute), localized_label(object_prefixes, attribute)
      content_tag(:li, content_tag(:a, message, href: link))
    end
  end

  def self.link_to_error object_prefixes, attribute
    ['#error', *object_prefixes, attribute].join('_')
  end

  def self.default_label attribute
    attribute.to_s.humanize.capitalize
  end

  def self.localized_label object_prefixes, attribute
    object_key = object_prefixes.shift
    object_prefixes.each { |prefix| object_key += "[#{prefix}]" }
    key = "#{object_key}.#{attribute}"
    I18n.t(key,
      default: default_label(attribute),
      scope: 'helpers.label').presence
  end

  def self.object_prefixes object
    [underscore_name(object)]
  end

  # `underscore` changes '::' to '/' to convert namespaces to paths
  def self.underscore_name object
    object.class.name.underscore.tr('/'.freeze, '_'.freeze)
  end

  private_class_method :error_summary_div
  private_class_method :error_summary_heading
  private_class_method :error_summary_description
  private_class_method :error_summary_messages

end
