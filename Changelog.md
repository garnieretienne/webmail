Changelog
=========

alpha
-----

Goal: User must be able to read his messages accessed throught IMAP on his email service provider

* user must be able to connect to his email service provider's account
  - user connect with his email service provider's email address and password
  - the email provider technicals (IMAP server, port and other settings) must be retrieved from the domain name used in the given email address

* user must be able to list his mailboxes
  - traditionnal mailboxe: 'INBOX'
  - special mailboxes: 'All Mail', 'Spam'
  - custom mailboxes: mailboxes created by the user himself, like 'Personnal' and 'Work' mailboxes

* user must be able to synchronize the email list with the server (IMAP server -> webmail)
  - this action must be perfommed on demand
  - during synchronization, all changes since the last synchronization on the server must be replicated in the webmail
  - during the synchronization, these messages attributes are cached:
    * Unique Identifier (UID)
    * Envelope Structure (message's header)
    * Internal Date (reflect when the message was received)
    * Flags (reflect the message state)
    * From header field
    * subject header field

* user must be able to list his messages from any of his mailboxes
  - the message list must be displayed from the cache and the following informations must appear:
    * From (the identity or the email address of the user sending the message)
    * Subject (the subject of the message)
    * Date (the date the message was received)
  - the list must be ordered by the date (newest message must be displayed first)
  - Non read messages must be highlighted
  
* user must be able to read a message when opened it
  - the message content must be loaded from the server and displayed to the user
  - the message must be displayed in TXT format
  - in HTML display mode, no stylesheets nor javascripts must be loaded from the message body