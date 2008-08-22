require 'error_message_sifter'
require 'error_message_sifter/action_view_extensions'
ActionView::Base.class_eval { include ErrorMessageSifter::ActionViewExtensions }
