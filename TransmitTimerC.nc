#include <Timer.h>
#include "TransmitTimer.h"


module TransmitTimerC{
	
	uses interface Boot;
	
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	
	uses interface LocalTime<TMilli>;
	
	uses interface SplitControl as AMControl;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	
	uses interface PacketAcknowledgements as PacketAck;
	
	uses interface Read<uint16_t> as BatteryVoltage;

}

implementation{
	
	uint16_t counter;
	uint16_t LostPackets;
	uint16_t retransmissions = 0;
	uint16_t acknowledged = 0;
	uint8_t retx = 0;
	
	//float PRR;
	//float mavg;
	
	uint16_t PRR;
	uint16_t mavg;
	float ftmavg;
		
	message_t pkt;
	
	bool RADIO = FALSE;
	bool BUSY = FALSE;
	bool ACKed = TRUE;
	
	uint8_t node1 = 0x03;
	uint8_t node2 = 0x04;
	uint8_t node3 = 0x99;
	
	uint8_t node0 = 0x05;
	
	event void Boot.booted()
	{
		call Timer0.startPeriodic(TIMER_PERIODIC_MILLI_0);
		
		call AMControl.start();
	}
	
	event void AMControl.startDone(error_t err)
	{
		if (err == SUCCESS)
		{
			RADIO = TRUE;
			
			call Timer1.startPeriodic(TIMER_PERIODIC_MILLI_1);
		}
		
		else
		{
			call AMControl.start();
		}
	}
	
	event void AMControl.stopDone(error_t err)
	{}
	
	event void Timer1.fired()
	{
		node3 = node2;
		node2 = node1;
		node1 = node3;
	}
	
	task void SendMsg()
	{
		TransmitTimerMsg* TTpkt = (TransmitTimerMsg*)(call Packet.getPayload(&pkt, sizeof(TransmitTimerMsg)));
		if (TTpkt == NULL)
		{
			return;
		}
		
		//mavg = (float)retransmissions / (float)(acknowledged + LostPackets);
		//PRR = (float)acknowledged / (float)(acknowledged + LostPackets);
		
		ftmavg = (float)(retransmissions + (counter * mavg)) / (float)(counter+1);
		mavg = ftmavg*1000;
		PRR = acknowledged / (acknowledged + LostPackets);
		
		TTpkt->nodeid = TOS_NODE_ID;
		TTpkt->counter = counter;
		TTpkt->lostpackets = LostPackets;
		TTpkt->retransmission = retransmissions;
		TTpkt->acknowledged = acknowledged;
		TTpkt->movingaverage = mavg;
		
		if (TTpkt->counter%0x02 == 0)
		{
			call PacketAck.requestAck(&pkt);
			if (call AMSend.send(node0, &pkt, sizeof(TransmitTimerMsg)) == SUCCESS)
			{
				BUSY = TRUE;
			}			
		}
		
		else
		{
			call PacketAck.requestAck(&pkt);
			if (call AMSend.send(node0, &pkt, sizeof(TransmitTimerMsg)) == SUCCESS)
			{
				BUSY = TRUE;
			}		
		}
	}
	
	event void Timer0.fired()
	{
		if (RADIO == TRUE)
		{
			retx = 0;		
			counter++;
			
			
			if (!BUSY)
			{
				post SendMsg();
			}
		}
		
		else
		{
			call AMControl.start();
		}
	}
	
	event void BatteryVoltage.readDone(error_t error, uint16_t battery)
	{}
	
	event void AMSend.sendDone(message_t* msg, error_t err)
	{
		if (&pkt == msg)
		{
			BUSY = FALSE;
			dbg("TransmitTimerC", "Message was sent @ %s, \n", sim_time_string());
		}
		
		if (call PacketAck.wasAcked(msg))
		{
			retransmissions = 0;
			//retx = 0;
			acknowledged++;
			ACKed = TRUE;
		}
		
		else
		{
			retx++;
			retransmissions = retx;
			LostPackets++;
			ACKed = FALSE;
			if (retx < 8)
			{
				post SendMsg();
			}
			
			
		}
	}
}
