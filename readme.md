# Vos - Virtual Operating System

Small abstraction over Operating System, mainly it should be used in conjunction with [Virtual File System][vos] tool. Kind of 
Capistrano but without extra stuff and more universal, not forcing You to follow 'The Rails Way'.

Currently, there are following implementations available:

- local os
- remote os (over ssh)

## Installation

    $ gem install vos

## Code samples:
    gem 'vos'                                    # Virtual Operating System
    require 'vos'

    # Connections, let's deploy our 'cool_app' project from our local box to remote server
    server = Vfs::Box.new(host: 'cool_app.com', ssh: {user: 'me', password: 'secret'})
    
    server.bash 'ls'
    server['apps/cool_app'].bash 'rails production'

For more details look also to [Virtual File System][vos] project. 
Or checkout configuration I use to control my production servers [My Cluster][my_cluster] in conjunction with small 
configuration tool [Cluster Management][cluster_management].
  
## TODO

### v 0.1 (all done)

- bash
- some handy shortcuts for ubuntu
- integration with Vos

### v 0.2

- process management (find/kill/filters/attributes)
- other os resources management (disk)

[vos]: http://github.com/alexeypetrushin/vos
[cluster_management]: http://github.com/alexeypetrushin/cluster_management
[my_cluster]: http://github.com/alexeypetrushin/my_cluster