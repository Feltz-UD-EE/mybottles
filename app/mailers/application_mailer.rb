class ApplicationMailer < ActionMailer::Base
  default from: "My Bottles <no-reply@mybottles.tech>"
  layout "mailer"
end
