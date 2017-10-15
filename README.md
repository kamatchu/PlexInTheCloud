[![Build Status](https://travis-ci.org/chrisanthropic/PlexInTheCloud.svg?branch=ansible-tdd)](https://travis-ci.org/chrisanthropic/PlexInTheCloud.svg?branch=ansible-tdd)


## Rough Notes

## Getting Started
- git clone the repo
- rename `hosts.sample` to `hosts`
    - modify as needed
- copy `roles/defaults/main.yml` to `roles/vars/main.yml`
    - modify as needed
- open `main.yml` and uncomment any tasks/software you want to install

### TESTING
- bundle install
- bundle exec kitchen list
- bundle exec kitchen create
- bundle exec kitchen test
- bundle exec kitchen login
- bundle exec kitchen destroy



