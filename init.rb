require 'wicked_messenger'
require 'wicked_messenger/action_view_extensions'
ActionView::Base.class_eval { include WickedMessenger::ActionViewExtensions }
