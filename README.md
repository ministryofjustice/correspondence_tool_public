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
