#include <Timer.h>
#include "TransmitTimer.h"

configuration TransmitTimerAppC{
}
implementation{
	
	components MainC;
	components TransmitTimerC as app;
	
	components new TimerMilliC() as Timer0;
	components new TimerMilliC() as Timer1;
	
	components LocalTimeMilliC;
	
	components ActiveMessageC;
	components new AMSenderC(AM_TRANSMITTIMER);
	
	components new VoltageC() as Battery;
	
	
	app.Boot -> MainC;
	
	app.Timer0 -> Timer0;
	app.Timer1 -> Timer1;
	
	app.LocalTime -> LocalTimeMilliC; 
	
	
	app.AMControl -> ActiveMessageC;
	app.AMSend -> AMSenderC;
	app.Packet -> AMSenderC;
	app.AMPacket -> AMSenderC;
	
	app.PacketAck -> ActiveMessageC;
		
	app.BatteryVoltage -> Battery;
	
}
