#Elsewhere

###Simple wrapper for Ruby Net::SSH for running commands remotely

#Why?
  This was abstracted from a larger project. There are many solutions out there that already do or require this paradigm like Capistrano or RemoteRun for Rake. But this code exists and 
  Is used in several active projects so I thought it might be useful to others.

#Usage:
```Ruby
r = Elsewhere::RemoteRun.new("www.example.com","app_user")
r.commands << "source /etc/profile"
r.commands << "cd ~/current"
r.commands << "rake do:something:useful"

r.execute

=> { "www.example.com" => "results from data stream"}
```

#Notes:
   I'm still in the process of adding some tests and porting this over to a gem but the core library is used in a working project