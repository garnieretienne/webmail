# Providers
#
# GMail:
# Official documentation: https://support.google.com/mail/bin/answer.py?hl=fr&answer=78799
#   Domain name:  gmail.com
#   IMAP address: imap.gmail.com
#   IMAP port:    993
#   IMAP use ssl: true
gmail = Provider.create
gmail.name         = 'gmail.com'
gmail.imap_address = 'imap.gmail.com'
gmail.imap_port    = 993
gmail.imap_ssl     = true
gmail.save
