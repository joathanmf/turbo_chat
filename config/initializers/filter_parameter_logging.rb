# Filter sensitive params from logs. Message bodies and names are filtered too:
# the chat promises nothing is kept, and that includes log files.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  :body, :name, :code
]
