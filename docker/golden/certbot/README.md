# Certbot for Let's Encrypt

## Domain setup.
This image is designed to be used with [Gandi](https://www.gandi.net/) as the DNS provider and uses an [authenticatpr plugin](https://github.com/obynio/certbot-plugin-gandi)
for Gandi. I wanted to keep the certificate renewal process separated from the Nginx configuration which is why I'm using the
authenticator plugin.

A new domain needs to be registered with Let's Encrypt using the Certbot. Run the image interactively:
```
$ docker run -v /home/pi/letsencrypt:/etc/letsencrypt --name certbot -it golden-certbot:latest sh
```
Then generate the certificate files for the domain:
```
/ # certbot certonly --authenticator dns-gandi --dns-gandi-credentials /etc/letsencrypt/gandi/gandi.ini -d domain.tld -d www.domain.tld
```
Example output:
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator dns-gandi, Installer None
Enter email address (used for urgent renewal and security notices)
(Enter 'c' to cancel): <email>

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: Y

Account registered.
Requesting a certificate for domain.tld and www.domain.tld
Performing the following challenges:
dns-01 challenge for domain.tld
dns-01 challenge for www.domain.tld
Waiting 10 seconds for DNS changes to propagate
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:

- Congratulations! Your certificate and chain have been saved at:
  /etc/letsencrypt/live/domain.tld/fullchain.pem
  Your key file has been saved at:
  /etc/letsencrypt/live/domain.tld/privkey.pem
  Your certificate will expire on 2021-06-13. To obtain a new or
  tweaked version of this certificate in the future, simply run
  certbot again. To non-interactively renew *all* of your
  certificates, run "certbot renew"
- If you like Certbot, please consider supporting our work by:

Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
Donating to EFF:                    https://eff.org/donate-le 
```
