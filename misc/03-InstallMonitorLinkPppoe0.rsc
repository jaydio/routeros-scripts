/system script add name="SetGlobalVarsMonitorPppoe0" source={
:global Pppoe0Interface "pppoe-out1"
:global Pppoe0AlertStatus "down"
:global Pppoe0Status
}

/system scheduler
add name=SetGlobalVarsMonitorPppoe0 on-event="/system script run SetGlobalVarsMonitorPppoe0" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup
add interval=5s name=MonitorLinkPppoe0 on-event=":system script run MonitorLinkPppoe0" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-date=may/07/2017 start-time=16:36:15

/system script add name="MonitorLinkPppoe0" source={
:global Pppoe0Interface
:global Pppoe0AlertStatus
:global Pppoe0Status

/interface pppoe-client monitor $Pppoe0Interface once do={
  :set Pppoe0Status $status
  }

:if ($Pppoe0Status = "connected") do={
  if ($Pppoe0AlertStatus = "down") do={

    :beep frequency=4000 length=100ms;
    :delay 100ms;
    :beep frequency=3000 length=100ms;
    :delay 400ms;
    :beep frequency=4000 length=100ms;
    :delay 100ms;
    :beep frequency=3000 length=100ms;
    :delay 400ms;
    :beep frequency=4000 length=1s;

    :global Pppoe0AlertStatus "up";
    }

  } else={

  if ($Pppoe0AlertStatus = "up") do={

    :beep frequency=3000 length=100ms;
    :delay 100ms;
    :beep frequency=4000 length=100ms;
    :delay 400ms;
    :beep frequency=3000 length=100ms;
    :delay 100ms;
    :beep frequency=4000 length=100ms;
    :delay 400ms;
    :beep frequency=3000 length=1s;

    :global Pppoe0AlertStatus "down";
    }
  }
}
