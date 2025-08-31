using System.Net.Mail;
using System.Net;
using Newtonsoft.Json;
using ZemljaSlova.Model.Messages;
using ZemljaSlova.Model;

namespace ZemljaSlova.Subscriber
{
    public class EmailService
    {
        private readonly string _smtpServer;
        private readonly int _smtpPort;
        private readonly string _smtpUsername;
        private readonly string _smtpPassword;

        public EmailService()
        {
            _smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
            _smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587");
            _smtpUsername = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "";
            _smtpPassword = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "";
        }

        public void SendEmail(string messageJson)
        {
            try
            {
                var emailModel = JsonConvert.DeserializeObject<EmailModel>(messageJson);
                if (emailModel == null)
                {
                    return;
                }

                // Validate email addresses
                if (string.IsNullOrWhiteSpace(emailModel.To))
                {
                    return;
                }

                if (string.IsNullOrWhiteSpace(emailModel.From))
                {
                    return;
                }

                // Validate SMTP credentials
                if (string.IsNullOrWhiteSpace(_smtpUsername) || string.IsNullOrWhiteSpace(_smtpPassword))
                {
                    return;
                }

                using var client = new SmtpClient(_smtpServer, _smtpPort)
                {
                    EnableSsl = true,
                    Credentials = new NetworkCredential(_smtpUsername, _smtpPassword)
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(emailModel.From),
                    Subject = emailModel.Subject,
                    Body = emailModel.Body,
                    IsBodyHtml = true
                };
                mailMessage.To.Add(emailModel.To);

                client.Send(mailMessage);
            }
            catch (UserException)
            {
                throw new UserException("Greška pri slanju emaila");
            }
            catch (Exception)
            {
                throw new UserException("Greška pri slanju emaila");
            }
        }
    }
}
