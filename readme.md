```
         .--"--.           
       / -     - \         
      / (O)   (O) \        
   ~~~| -=(,Y,)=- |         
    .---. /`  \   |~~      
 ~/  o  o \~~~~.----. ~~   
  | =(X)= |~  / (O (O) \   
   ~~~~~~~  ~| =(Y_)=-  |   
  ~~~~    ~~~|   U      |~~ 

```


remove port 39762 from firewall


# random commands
sudo firewall-cmd --remove-port=39762/tcp --permanent
sudo firewall-cmd --reload

# healthchecks

- factorio
- uptime
- gluetun
- immich_ml
