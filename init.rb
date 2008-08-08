require 'error_message_sifter'
ActionView::Base.class_eval { include ErrorMessageSifter }
