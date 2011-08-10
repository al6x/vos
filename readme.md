# Vos - Virtual Operating System

Small abstraction over Operating System, mainly it should be used in conjunction with [Virtual File System][vfs] tool. Kind of
Capistrano but without extra stuff and more universal, not forcing You to follow 'The Rails Way'.

Currently, there are following implementations available:

- local os
- remote os (over ssh)

## Installation

```bash
$ gem install vos
```

## Code samples:

```ruby
gem 'vos'                                         # Virtual Operating System
require 'vos'

server = Box.new('cool_app.com')                  # it will use id_rsa, or You can add {user: 'me', password: 'secret'}

server.bash 'ls'                                  # ls /
server['apps/cool_app'].bash 'rails production'   # cd /apps/cool_app && rails production
```

For more details look also to [Virtual File System][vfs] project.
Or checkout configuration I use to control my production servers [My Cluster][my_cluster] in conjunction with small
configuration tool [Cluster Management][cluster_management].

## Please let me know about bugs and Your proposals, there's the 'Issues' tab at the top, feel free to submit.

Copyright (c) Alexey Petrushin http://petrush.in, released under the MIT license.

[vfs]: http://github.com/alexeypetrushin/vfs
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster