# MatMavDecode
Matlab code for deciphering Mavlink messages.

I am working on a project where we will be using an arduino (Teensy3.5) to read data from both a PixHawk autopilot controller and other sensors. The sensor data is then combined with the autopilot message to form a new Mavlink message to send to the ground station.

We will be working on new algorithms etc using this data so we wish to use Matlab to enable rapid development. While searching for information relating to decoding Mavlink messages I found many question relating to achieving this in Matlab, but no available code examples to actually achieve it.

This code shows an examples of how to decode a Mavlink message, received via a 3DR telemetry radio on a serial port in windows. The data is displayed in a table format so you can compare it with any debug display of te data being sent (e.g. using VisualMicro). The Mavlink message is our own, and so has extra sensor data tagged on to it. We only expect to receive a single message format and so this is a simple example, however, it shows how to decipher the Mavlink message and return the data in suitable variables. There is no fancy error checking, timeouts etc, just the bare minimum necessary. For testing we transmitted Mavlink messages at 1Hz, but it will work much fatser of course.

It is hoped to build this into a simple, intuitive library for all to use.

The first 'next step' is to look at incoming data, without prior knowledge of the message format, and identify the message. From that point, building up the decoding function is relatively simple. However, it is unlikely I will have time to do this any time soon so please feel free to contribute!
