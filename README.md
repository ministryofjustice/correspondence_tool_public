# Correspondence Tools - Public
[![Build Status](https://travis-ci.org/ministryofjustice/correspondence_tool_public.svg?branch=develop)](https://travis-ci.org/ministryofjustice/correspondence_tool_public) [![Code Climate](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/coverage) [![Issue Count](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/issue_count.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public)


A simple application to allow public users to submit correspondence. A present this only forwards the request to a set email address.

## Local development

### Clone this repository change to the new directory

```bash
$ git clone git@github.com:ministryofjustice/correspondence_tool_public.git
$ cd correspondence_tool_public
```

### Setup MailCatcher

When developing or testing locally we use
[MailCatcher](https://mailcatcher.me/) to capture mail being sent locally and
view it locally. The development environment is already setup to use
MailCatcher so install it and run it:

```bash
$ gem install mailcatcher
$ mailcatcher --smtp-port 2050
```

We run it on port 2050 because MacOS appears to be running the new
`cloud-drive` process on default MailCatcher port (1025). Once run, you can
visit http://localhost:1080/ to view what emails have been sent locally.

## Production Environment Setup

### Web Server Setup

`public/500-nginx.html` provides a static 500 error for when the Rails application cannot be reached.

`public/images` contains images required by the static 500 error.

`public/files` contains the stylesheet required by the static 500 error.

### Smoke Tests

Smoke tests try sending a piece of correspondence and test for it's receipt in
an accessible mailbox. This is typically not a production mailbox
(i.e. general_enquiries or foi mailbox) so a separate email address has to be
setup which can be accessed from wherever the tests will run.

Use the script `smoketest.rb` to run smoke tests, for example to test the app
running locally with foreman:

```bash
$ RAILS_ENV=test ./smoketest.rb -s pop.server -U user_login -P user_password http://localhost:5000
```

Or in an environment where the SETTINGS environment variables are set correctly:

```bash
$ RAILS_ENV=test ./smoketest.rb http://localhost:5000
```

See the script's usage information for more info about settings and
environment variables:

```bash
$ RAILS_ENV=test ./smoketest.rb -h
```

As this script uses a couple of gems that (currently) are only needed for
testing, we need to ensure the RAILS_ENV is set to `test` to pull those gems
in. Keep in mind that as we'll be testing sending correspondence through the
server given on the command-line, that process will have to be configured to
send email, which may mean fiddling around with it's settings if you're
testing smoke tests locally as those settings may point to a locally running
`mailcatcher`.

#### Jenkins Integration

To ensure that the environment is setup correctly there is a script
`run-smoketests.sh` that Jenkins can use to run the smoke tests.

### Environment Variables

Certain settings are defined by environment variables so that they can be
specific to the deployment environment in which the app is running (dev,
staging, prod, etc) and secret or sensitive values aren't kept within the
repository. See the `config/settings.yml` file for a full list, any variable
there can be over-ridden with an environment variable of the same name but
prefixed with `SETTINGS__`.

* **SETTINGS__GA_TRACKING_ID** — the tracking ID used for Google
  Analytics. Can be unset in which case it will be empty-string.
* **SETTINGS__SENDGRID_USERNAME** — The username to use to login to
  SendGrid. Note that SendGrid isn't used in local development (as described
  above we use MailCatcher running on localhost:2050).
* **SETTINGS__SENDGRID_PASSWORD** — The password for SendGrid. See above.
* **SETTINGS__CORRESPONDENCE_EMAIL_FROM** — The email address which will be
  used in the From address of email sent for correspondence and feedback.
* **SETTINGS__GENERAL_ENQUIRIES_EMAIL** — The email address to send general
  correspondence emails to.
* **SETTINGS__FREEDOM_OF_INFORMATION_REQUEST_EMAIL** — The email address to
  send freedom of information request emails to. (Currently unused, this
  should probably be removed.)
* **SETTINGS__AAQ_FEEDBACK_EMAIL** — The email address to send feedback to.
* **SETTINGS__AAQ_EMAIL_URL** — The URL used for static assets presented in
  the correspondence email.
* **SETTINGS__SMOKE_TEST_EMAIL** — Email address to send smoke tests to.
* **SETTINGS__SMOKE_TESTS__PROTOCOL** — Protocol to use when connecting to
  mail server, :pop3 or :imap.
* **SETTINGS__SMOKE_TESTS__SERVER** — Mail server to connect with to check for
  smoke test receipt.
* **SETTINGS__SMOKE_TESTS__PORT** — Port to use when connecting to POP3
  server.
* **SETTINGS__SMOKE_TESTS__SSL** — Whether to use SSL when connecting to the
  mail server or not. true/false
* **SETTINGS__SMOKE_TESTS__USERNAME** — Username to use when connecting to
  mail server.
* **SETTINGS__SMOKE_TESTS__PASSWORD** — Password to use when connecting to
  mail server.
