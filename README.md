# Correspondence Tools - Public
[![Build Status](https://travis-ci.org/ministryofjustice/correspondence_tool_public.svg?branch=develop)](https://travis-ci.org/ministryofjustice/correspondence_tool_public) [![Code Climate](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/coverage) [![Issue Count](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public/badges/issue_count.svg)](https://codeclimate.com/github/ministryofjustice/correspondence_tool_public)


A simple application to allow public users to submit correspondence. A present this only forwards the request to a set email address.

## Local development

### Clone this repository change to the new directory

```bash
$ git clone git@github.com:ministryofjustice/correspondence_tool_public.git
$ cd correspondence_tool_public
```

### Emails

Emails are sent using the
[GOVUK Notify service](https://www.notifications.service.gov.uk).
Configuration relies on an API key which is not stored with the project, as even
the test API key can be used to access account information. To do local testing
you need to have an account that is attached to the "Track a query" service, and
a "Team and whitelist" API key generated from the GOVUK Notify service website.
See the instructions in the `.env.example` file for how to setup the correct
environment variable to override the `govuk_notify_api_key` setting.

The urls generated in the mail use the `cts_email_host` and `cts_mail_port`
configuration variables from the `settings.yml`. These can be overridden by
setting the appropriate environment variables, e.g.

```
$ export SETTINGS__CTS_EMAIL_HOST=localhost
$ export SETTINGS__CTS_EMAIL_PORT=5000
```

## Production Environment Setup

### Web Server Setup

`public/500-nginx.html` provides a static 500 error for when the Rails application cannot be reached.

`public/images` contains images required by the static 500 error.

`public/files` contains the stylesheet required by the static 500 error.

### Emails

Emails are sent using the
[GOVUK Notify service](https://www.notifications.service.gov.uk). To configure
this in the production environment ensure that the
`SETTINGS__GOVUK_NOTIFY_API_KEY` environment variable is set with a production
API key.

### Smoke Tests

The smoke test runs through the process of filling out a correspondence item and 
submitting it, checking that the authentication email is received, clicking the 
authentication link, and checking that the confirmation mail to DACU is recieved.


To run the smoke test, set the following environement variables:

```
    SETTINGS__SMOKE_TESTS__SITE_URL    # usually http://localhost:3000 for testing
    SETTINGS__SMOKE_TESTS__SERVER      # the namne of the POP server
    SETTINGS__SMOKE_TESTS__USERNAME    # the email address to use for smoke tests
    SETTINGS__SMOKE_TESTS__PASSWORD    # The password for the smoketest email account
```

and then run

```
    rake smoke
```


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
* **SETTINGS__GOVUK_NOTIFY_API_KEY** — Production API key for the GOVUK Notify
  service.
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
