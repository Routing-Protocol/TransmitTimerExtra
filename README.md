TransmitTimerExtra
==================
This applciation sends a binary count aong with network data like the number of packets lost, number of retransmissions for each count, the number of packets acknowledged and the moving average of the retransmission attempts.

Three nodes are enough to verify the working of this application. This is a transmitting application which may be installed on one mote while 'MessageSnifferExtra' may be installed on the other two mote which can be considered to be the receiver and the sniffer application. The sniffer mote should be number node 5.  The sniffer mote should be connected to the computer so that it can sense the packets being transmitted and send the acquired netwrok data to the computer serially.

The expected result when running the 'SerialSniffer' java aplication along with this application is the display of a sequence number of the packet along with information like the number of packets lost, number of retransmissions for each count, the number of packets acknowledged, the moving average of the retransmission attempts, and the packet reception rate.

The packet serial number should increment every two seconds. When transmission is unsuccessful, the application tries to retransmit the packet a maximum of 8 time before discarding the packet to be transmitted.




08/14/2014 - First upload of the application which includes the header, module, configuration and makefile
