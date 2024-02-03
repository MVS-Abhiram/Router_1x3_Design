Router-1x3's features include packet routing, parity checking, and a reset function. Packet routing facilitates the transfer of packets from an input port to a designated output port, determined by the destination network's address. Parity checking is a method to verify the integrity of the data transferred between a server and a client, ensuring the data sent by the server network is accurately received by the client network without corruption. Lastly, the reset function is a proactive low synchronous input that initializes the router's reset process. During a reset, the router's FIFOs (First In, First Out queues) are cleared, and the valid output signals are lowered, indicating the absence of any valid packets on the output data bus. These features are crucial for maintaining efficient and reliable data transmission across networks.

There are 4 different sub blocks 
1. FSM (Used to generate control signal for parallel read and write)
2. Register (Used to provide control signals to the memory)
3. Synchronizer ( To provide synchronization between FSM and Memory)
4. FIFO (Destination memory)
