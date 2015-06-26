# Replaces the standard startup beep with the mario theme

/system scheduler
add name=startup-beep on-event=":delay 6\r\
    \n/system script run supermario" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive start-time=startup

/system script
add name=supermario policy=reboot,read,write,policy,test,password,sniff,sensitive source=":beep frequency=660 length=100ms;\r\
    \n:delay 150ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=510 length=100ms;\r\
    \n:delay 100ms;\r\
    \n:beep frequency=660 length=100ms;\r\
    \n:delay 300ms;\r\
    \n:beep frequency=770 length=100ms;\r\
    \n:delay 550ms;\r\
    \n:beep frequency=380 length=100ms;\r\
    \n:delay 575ms;"
