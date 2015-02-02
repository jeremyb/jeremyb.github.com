---
layout: post
title: Speed-up your Vagrant environment for Symfony2
excerpt:
    On this post I want to share with you some tips about Symfony2 development 
    on a Virtual Machine. I know that Docker is really trendy and cool nowadays
    and we used it a lot during the KNP hackathon but for project virtualization 
    I'm still using Vagrant for now because it's a stable solution, 
    multi-platform and easy to provision.
tags: [Vagrant]
image:
  feature: slides/manchester-street.jpg
comments: true
share: true
---

This is my first post in english and probably not the last one for this new 
year. First of all, I'm really happy to say that I've joined the awesome KNP 
Labs team! I've just met all these cool guys during a hackathon in the north of 
France. It was a really nice experience.

On this post I want to share with you some tips about Symfony2 development on a 
Virtual Machine. I know that [Docker][docker] is really trendy and cool nowadays
and we used it a lot during the KNP hackathon but for project virtualization 
I'm still using [Vagrant][vagrant] for now because it's a stable solution, 
multi-platform and easy to provision.

There was a lot of articles about how to optimize your Vagrant environment, 
especially for Symfony2. Some of them date back to 2013:

* [Speedup Symfony2 on Vagrant boxes][vagrant_whitewashing]
* [Optimizing Symfony applications on Vagrant boxes][vagrant_erikaheidi]

And one more recent:

* [Running the Symfony application on Vagrant without NFS below 100ms][vagrant_by_examples]

All these articles point the slow filesystem performance of shared folders in 
Virtual Machines, but the related techniques/tips to boost performance have a 
big drawback to me. You need to modify the source files of your project... 

They advice to update the `composer.json` file, or even the `autoload.php`, 
`AppKernel.php`. And the idea is to move some directories, like `vendor/` or 
`app/{cache,logs}`, outside of the shared folder to prevent too much I/O. I 
don't really like this technique because it makes your code coupled to Vagrant, 
and in my opinion Vagrant is only a development platform for your project, it 
should not be required to adapt your code to this platform.

A better way should be to add some symbolic links of these folders to a 
destination inside of the Virtual Machine. 

Hopefully there's a Vagrant plugin that handle this kind of problem. His name is
[vagrant-cachier][vagrant_cachier]. This plugin creates some "cache buckets" 
that you can use in the Virtual Machine and they are also symlinked to the host 
machine. Initially this plugin was created to share some folders between Virtual 
Machines, especially for packages in common (like APT packages or Ruby, npm, 
etc.). But you can use it for any kind of packages or files, so it can be used 
for cache, logs and vendors files of Symfony2!

Finally, it speeds-up the Virtual Machine performance through symbolic links, 
and you can also access to these files from your host machine. It can be very 
useful for your text editor or your IDE to be able to access all the vendor 
files :-)

The plugin installation process is very easy (make sure you have Vagrant 1.4+):

{% highlight bash %}
$ vagrant plugin install vagrant-cachier
{% endhighlight %}

You can see below a configuration example for Vagrant and with the 
vagrant-cachier plugin configured for Symfony2 with `vendor/` or 
`app/{cache,logs}` folders into cache buckets.

{% highlight ruby %}
Vagrant.configure("2") do |config|
  # Configure the box
  config.vm.box = "your-box"

  # Example of shared folder
  config.vm.synced_folder ".", "/var/www", id: "application", :nfs => true

  # ...

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :machine

    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }

    config.cache.enable :generic, {
      "cache"  => { cache_dir: "/var/www/app/cache" },
      "logs"   => { cache_dir: "/var/www/app/logs" },
      "vendor" => { cache_dir: "/var/www/vendor" },
    }
  end
end
{% endhighlight %}

I hope this Vagrant tip could help ;-)

[docker]: https://www.docker.com/
[vagrant]: https://www.vagrantup.com/
[vagrant_whitewashing]: http://www.whitewashing.de/2013/08/19/speedup_symfony2_on_vagrant_boxes.html
[vagrant_erikaheidi]: http://www.erikaheidi.com/blog/optimizing-symfony-applications-vagrant-boxes
[vagrant_by_examples]: http://by-examples.net/2014/12/09/symfony2-on-vagrant.html
[vagrant_cachier]: http://fgrehm.viewdocs.io/vagrant-cachier
