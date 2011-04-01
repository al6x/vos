# Vos - Virtual Operating System

Small abstraction over Operating System, mainly it should be used in conjunction with [Virtual File System][vos] tool. Kind of 
Capistrano but without extra stuff and more universal, not forcing You to follow 'The Rails Way'.

Currently, there are following implementations available:

- local os
- remote os (over ssh)

## Installation

    $ gem install vos

## Code samples:
    gem 'vos'                                         # Virtual Operating System
    require 'vos'

    server = Box.new('cool_app.com')                  # it will use id_rsa, or You can add {user: 'me', password: 'secret'}
    
    server.bash 'ls'                                  # ls /
    server['apps/cool_app'].bash 'rails production'   # cd /apps/cool_app && rails production

For more details look also to [Virtual File System][vfs] project. 
Or checkout configuration I use to control my production servers [My Cluster][my_cluster] in conjunction with small 
configuration tool [Cluster Management][cluster_management].
  
## TODO

### v 0.1 (all done)

- bash
- some handy shortcuts for ubuntu
- integration with Vos

### v 0.2

- add :host/:user/:port attributes to box
- process management (find/kill/filters/attributes)
- other os resources management (disk)

[vfs]: http://github.com/alexeypetrushin/vfs
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster