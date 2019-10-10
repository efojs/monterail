# For testing errors responses

Rails.application.configure do
  # to not raise Rails' development exceptions,
  # but return a corresponding HTTP status code
  # https://github.com/rails/rails/issues/29712
  config.action_dispatch.show_exceptions = true
end
